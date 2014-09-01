//
// GlobalCacheConnectionManager.m
// Remote
//
// Created by Jason Cardwell on 9/10/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "GlobalCacheConnectionManager.h"
#import "GlobalCacheMulticastConnection.h"
#import "GlobalCacheDeviceConnection.h"
#import "NetworkDevice.h"
#import "Command.h"
#import "ConnectionManager.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_NETWORKING | LOG_CONTEXT_FILE | LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel, msLogContext)


MSNOTIFICATION_DEFINITION(LearnerStatusDidChange);
MSNOTIFICATION_DEFINITION(CommandCaptured);

@interface GlobalCacheConnectionManager () <GlobalCacheDeviceConnectionDelegate>

@property (strong) NSMutableDictionary            * requestLog;           // Holds completion handlers
@property (strong) NSMutableArray                 * networkDevices;       // previously discovered devices.
@property (strong) NSMutableArray                 * deviceConnections;    // currently connected devices.
@property (strong) NSMutableSet                   * beaconsReceived;      // uuids  from processed beacons.
@property (copy)   NSString                       * capturedCommand;      // needs to be moved to `IRLearner`
@property (strong) GlobalCacheMulticastConnection * multicastConnection;  // multicast group connection

@property (assign) BOOL multicastGroupActive; // tracks whether should be in group

@property (strong) MSNotificationReceptionist * backgroundReceptionist;   // handles backgrounded notification
@property (strong) MSNotificationReceptionist * foregroundReceptionist;   // handles foregrounded notification
@property (strong) NSMutableDictionary        * connectionCallbacks;      // device connection callbacks

@end


@implementation GlobalCacheConnectionManager


/**

 Accessor for the singleton instance of `GlobalCacheConnectionManager`

 @return const GlobalCacheConnectionManager *

 */
+ (const GlobalCacheConnectionManager *)sharedManager {

  static dispatch_once_t pred = 0;
  static const GlobalCacheConnectionManager * manager = nil;

  dispatch_once(&pred,  ^{

    /// Intialize shared manager and the manager's collection ivars
    ////////////////////////////////////////////////////////////////////////////////

    manager = [self new];
    
    manager.requestLog          = [@{} mutableCopy];
    manager.deviceConnections   = [@{} mutableCopy];
    manager.connectionCallbacks = [@{} mutableCopy];
    manager.networkDevices      = [[NDiTachDevice findAll] mutableCopy] ?: [@[] mutableCopy];
    manager.beaconsReceived     = [NSMutableSet setWithCapacity:5];


    /// Initialize the manager's multicast connection with a message handler
    ////////////////////////////////////////////////////////////////////////////////

    manager.multicastConnection =
    [GlobalCacheMulticastConnection connectionWithHandler:
     ^(NSString * message, GlobalCacheMulticastConnection * connection) {

       if (StringIsEmpty(message)) return;

       NSArray * stringSegments = [[message stringByReplacingOccurrencesOfString:@"http://" withString:@""]
                                   matchingSubstringsForRegEx:@"(?<=<-)(.*?)(?=>)"];

       NSMutableDictionary * attributes = [NSMutableDictionary dictionaryWithCapacity:stringSegments.count];

       for (NSString * stringSegment in stringSegments) {
         // Split string using '=' and enter key=value pair in dictionary
         NSArray * keyValuePair = [stringSegment componentsSeparatedByString:@"="];
         if ([keyValuePair count] == 2) attributes[keyValuePair[0]] = [keyValuePair lastObject];
       }

       NSString * deviceUUID = attributes[@"UUID"];

       // Check if device has already been discovered
       if (![manager.beaconsReceived containsObject:deviceUUID]) {

         // Add to list of received beacons
         [manager.beaconsReceived addObject:deviceUUID];

         // Map parsed device attributes to model properties
         static NSDictionary const * keyMap;
         static dispatch_once_t onceToken;
         dispatch_once(&onceToken, ^{
           keyMap = @{ @"Make"       : @"make",
                       @"Model"      : @"model",
                       @"PCB_PN"     : @"pcb_pn",
                       @"Pkg_Level"  : @"pkg_level",
                       @"Revision"   : @"revision",
                       @"SDKClass"   : @"sdkClass",
                       @"Status"     : @"status",
                       @"UUID"       : @"deviceUUID",
                       @"Config-URL" : @"configURL" };
         });

         [attributes mapKeysToBlock:^id (id k, id o) { return ([keyMap hasKey:k] ? keyMap[k] : k); }];

         __block NDiTachDevice * networkDevice = nil;


         // Save block to create a new `NDiTachDevice` model object with the specified attributes.
         void(^save)(NSManagedObjectContext *) = ^(NSManagedObjectContext * moc) {
           networkDevice = [NDiTachDevice deviceWithAttributes:attributes context:moc];
         };

         // Completion block to handle errors and/or post discovery notification and stop device detection
         void(^completion)(BOOL, NSError *) = ^(BOOL success, NSError * error) {

           MSHandleErrors(error);

           if (success)
             [MainQueue addOperationWithBlock:^{

               [manager.networkDevices addObject:networkDevice];
               [NotificationCenter postNotificationName:CMNetworkDeviceDiscoveryNotification
                                                 object:manager
                                               userInfo:@{ CMNetworkDeviceKey : networkDevice.uuid }];
               [[manager class] stopDetectingDevices:nil];

             }];
         };
         
         // Execute save and completion blocks
         [CoreDataManager saveWithBlock:save completion:completion];
         
       }

    }];


    /// Initialize the manager's did enter background notification receptionist
    ////////////////////////////////////////////////////////////////////////////////

    void (^backgroundHandler)(MSNotificationReceptionist *) = ^(MSNotificationReceptionist * receptionist) {
      if (manager.multicastGroupActive) [manager.multicastConnection leaveMulticastGroup:nil];
      for (GlobalCacheDeviceConnection * connection in manager.deviceConnections) [connection disconnect:nil];
    };

    manager.backgroundReceptionist =
      [MSNotificationReceptionist receptionistWithObserver:manager
                                                 forObject:UIApp
                                          notificationName:UIApplicationDidEnterBackgroundNotification
                                                     queue:MainQueue
                                                   handler:backgroundHandler];

    /// Initialize the manager's will enter foreground notification receptionist
    ////////////////////////////////////////////////////////////////////////////////

    void (^foregroundHandler)(MSNotificationReceptionist *) = ^(MSNotificationReceptionist * receptionist) {
      if (manager.multicastGroupActive) [manager.multicastConnection joinMulticastGroup:nil];
      for (GlobalCacheDeviceConnection * connection in manager.deviceConnections) [connection connect:nil];
    };

    manager.foregroundReceptionist =
      [MSNotificationReceptionist receptionistWithObserver:manager
                                                 forObject:UIApp
                                          notificationName:UIApplicationWillEnterForegroundNotification
                                                     queue:MainQueue
                                                   handler:foregroundHandler];

  });

  return manager;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Device Discovery
////////////////////////////////////////////////////////////////////////////////


/**

 Join multicast group and listen for beacons broadcast by iTach devices.

 @param completion Block to be executed upon completion of the task.

 */
+ (void)detectNetworkDevices:(void(^)(BOOL success, NSError *error))completion {

  // Set group active flag
  [self sharedManager].multicastGroupActive = YES;

  // Check for wifi
  if (![ConnectionManager isWifiAvailable]) {

    MSLogErrorTag(@"cannot detect network devices without valid wifi connection");

    if (completion) completion(NO, [NSError errorWithDomain:ConnectionManagerErrorDomain
                                                       code:ConnectionManagerErrorNoWifi
                                                   userInfo:nil]);

  }

  // Just execute the completion block if we have already joined
  else if ([self sharedManager].multicastConnection.isMemberOfMulticastGroup) {

    MSLogWarnTag(@"multicast socket already exists");

    if (completion) completion(YES, nil);

  }

  // Otherwise store a copy of the completion block and join the multicast group
  else
    [[self sharedManager].multicastConnection joinMulticastGroup:completion];

}

/**

 Cease listening for beacon broadcasts and release resources.

 @param completion Block to be executed upon completion of the task.

 */
+ (void)stopDetectingDevices:(void(^)(BOOL success, NSError *error))completion {

  // Set group active flag
  [self sharedManager].multicastGroupActive = NO;

  // Leave group if joined to one
  if ([self sharedManager].multicastConnection.isMemberOfMulticastGroup)
    [[self sharedManager].multicastConnection leaveMulticastGroup:completion];

  // Otherwise just execute completion block
  else {

    MSLogWarnTag(@"not currently joined to a multicast group");
    if (completion) completion(YES, nil);

  }

}

/**
 Whether socket is open to receive multicast group broadcast messages.

 @return `YES` if detecting and `NO` otherwise.

 */
+ (BOOL)isDetectingNetworkDevices {
  //???: Should this return whether flag is set for multicast group or whether connection exists?
  return [self sharedManager].multicastGroupActive;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Connecting/sending to a device
////////////////////////////////////////////////////////////////////////////////


/**

 Attempts to connect with the device identified by the specified `uuid`.

 @param device The device with which to connect, or nil for the registered default device.

 @param completion Block to execute after attempt is made to connect with the device.

 */
+ (void)connectWithDevice:(NDiTachDevice *)device
               completion:(void (^)(BOOL success, NSError * error))completion {

  // Check device id
  if (!device) ThrowInvalidNilArgument(device);

  // Check wifi connection
  else if (![ConnectionManager isWifiAvailable]) {
    MSLogErrorTag(@"wifi connection required");
    if (completion) completion(NO, nil);
  }

  // Retrieve or create device connection
  else {

    // Check for existing connection
    GlobalCacheDeviceConnection * connection =
    [[self sharedManager].deviceConnections objectPassingTest:
     ^BOOL(GlobalCacheDeviceConnection * obj, NSUInteger idx) {
       return obj.device == device;
     }];

    // Check for existing connection
    if (connection && connection.isConnected) {
      MSLogWarnTag(@"device with uuid %@ is already connected", device.uuid);
      if (completion) completion(YES, nil);
    }

    // Create connection if one does not exist for device
    else if (!connection)
      connection = [GlobalCacheDeviceConnection connectionForDevice:device delegate:[self sharedManager]];

    [connection connect:completion];
  }

}

/**

 Sends an IR command to the device identified by the specified `uuid`.

 @param command The command to execute

 @param completion The block to execute upon task completion

 */
+ (void)sendCommand:(SendIRCommand *)command completion:(void (^)(BOOL success, NSError *))completion
{

  NSString * cmd = command.commandString;


  // Exit early if command string has no content to send
  if (StringIsEmpty(cmd)) {

    MSLogErrorTag(@"cannot send empty or nil command");

    if (completion) completion(NO, [NSError errorWithDomain:ConnectionManagerErrorDomain
                                                       code:ConnectionManagerErrorCommandEmpty
                                                   userInfo:nil]);
  }

  else {

    // Get the network device
    NetworkDevice * device = command.networkDevice;
    
    if (![device isKindOfClass:[NDiTachDevice class]]) {
      MSLogErrorTag(@"network device is not a Global Caché device");
      if (completion) completion(NO, [NSError errorWithDomain:ConnectionManagerErrorDomain
                                                         code:ConnectionManagerErrorInvalidNetworkDevice
                                                     userInfo:nil]);
    }

    else {

      // check for existing connection
      GlobalCacheDeviceConnection * deviceConnection =
        [[self sharedManager].deviceConnections objectPassingTest:
         ^BOOL(GlobalCacheDeviceConnection * connection, NSUInteger idx) {
           return connection.device == command.networkDevice;
         }];

      if (!deviceConnection)
        deviceConnection = [GlobalCacheDeviceConnection connectionForDevice:(NDiTachDevice *)device
                                                                   delegate:[self sharedManager]];

      static NSUInteger nextTag = 0;
      NSUInteger tag = (++nextTag % 100) + 1;

      NSString * taggedCommand = [[cmd stringByReplacingOccurrencesOfString:@"<tag>"
                                                                 withString:$(@"%lu", (unsigned long)tag)]
                                  stringByAppendingFormat:@"<tag>%lu", (unsigned long)tag];

      // send command
      [deviceConnection enqueueCommand:taggedCommand completion:completion];

    }
  }
  
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - GlobalCacheDeviceConnectionDelegate
////////////////////////////////////////////////////////////////////////////////

/// Callback executed by a `GlobalCacheDeviceConnection` after disconnecting from its device
/// @param connection The connection which has been disconnected
- (void)deviceDisconnected:(GlobalCacheDeviceConnection *)connection {
  [self.deviceConnections removeObject:connection];
}

/// Callback executed by a `GlobalCacheDeviceConnection` after connecting to its device
/// @param connection The connection which has been established
- (void)connectionEstablished:(GlobalCacheDeviceConnection *)connection {
  [self.deviceConnections addObject:connection];
}

/**
 Processes messages received through `GlobalCachedDeviceConnection` objects.
 @param message Contents of the message received by the device connection
 @param connection Device connection which received the message
 */
- (void)messageReceived:(NSString *)message overConnection:(GlobalCacheDeviceConnection *)connection {
  // iTach completeir command: completeir,<module address>:<connector address>,<ID>
  // TODO: handle error messages
  MSSTATIC_STRING_CONST kIREnabled  = @"IR Learner Enabled\r";
  MSSTATIC_STRING_CONST kIRDisabled = @"IR Learner Disabled\r";
  MSSTATIC_STRING_CONST kCompleteIR = @"completeir";
  MSSTATIC_STRING_CONST kSendIR     = @"sendir";
  MSSTATIC_STRING_CONST kError      = @"ERR";

  MSLogDebugTag(@"Return message from device: \"%@\"",
                [message stringByReplacingReturnsWithSymbol]);


  __weak GlobalCacheConnectionManager * weakself = self;

  void(^requestLogHandler)(NSNumber *, BOOL) = ^(NSNumber * tag, BOOL success) {
    void (^completion)(BOOL success, NSError *) = weakself.requestLog[tag];
    if (completion) {
      completion(success, nil);
      [weakself.requestLog removeObjectForKey:tag];
    }
  };

  // command success
  if ([message hasPrefix:kCompleteIR])
    requestLogHandler(@(IntegerValue([message substringFromIndex:15])), YES);

  // error
  else if ([message hasPrefix:kError])
    MSLogErrorTag(@"error message received over connection for device with uuid %@", connection.device.uuid);

  // learner enabled
  else if ([kIREnabled isEqualToString:message]) {
    MSLogInfoTag(@"IR Learner has been enabled on the iTach device");
    [NotificationCenter postNotificationName:LearnerStatusDidChangeNotification
                                      object:self
                                    userInfo:@{ LearnerStatusDidChangeNotification : @YES }];
  }
  // learner disabled
  else if ([kIRDisabled isEqualToString:message]) {
    MSLogInfoTag(@"IR Learner has been disabled on the iTach device");
    [NotificationCenter postNotificationName:LearnerStatusDidChangeNotification
                                      object:self
                                    userInfo:@{ LearnerStatusDidChangeNotification : @NO }];
  }
  // begin captured command
  else if ([message hasPrefix:kSendIR]) self.capturedCommand = message;

  // extend captured command
  else if (ValueIsNotNil(self.capturedCommand)) {
    self.capturedCommand = [self.capturedCommand stringByAppendingString:message];
    [NotificationCenter postNotificationName:CommandCapturedNotification
                                      object:self
                                    userInfo:@{ CommandCapturedNotification : _capturedCommand }];
  }
}


@end
