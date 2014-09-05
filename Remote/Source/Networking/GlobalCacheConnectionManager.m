//
// GlobalCacheConnectionManager.m
// Remote
//
// Created by Jason Cardwell on 9/10/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "GlobalCacheConnectionManager.h"
#import "NetworkDeviceMulticastConnection.h"
#import "GlobalCacheDeviceConnection.h"
#import "NDiTachDevice.h"
#import "Command.h"
#import "ConnectionManager.h"

static int ddLogLevel   = LOG_LEVEL_INFO;
static int msLogContext = (LOG_CONTEXT_NETWORKING | LOG_CONTEXT_FILE | LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel, msLogContext)


MSNOTIFICATION_DEFINITION(LearnerStatusDidChange);
MSNOTIFICATION_DEFINITION(CommandCaptured);

@interface GlobalCacheConnectionManager () <NetworkDeviceConnectionDelegate>

@property (strong) NSMutableDictionary              * requestLog;           // Holds completion handlers
@property (strong) NSMutableArray                   * networkDevices;       // previously discovered devices.
@property (strong) NSMutableArray                   * deviceConnections;    // currently connected devices.
@property (strong) NSMutableSet                     * beaconsReceived;      // uuids  from processed beacons.
@property (copy)   NSString                         * capturedCommand;      // needs to be moved to `IRLearner`
@property (strong) NetworkDeviceMulticastConnection * multicastConnection;  // multicast group connection
@property (strong) NSHashTable                      * suspendedConnections; // active connections suspended

@property (assign) BOOL multicastGroupActive;                               // tracks whether should be in group

@property (strong) NSMutableDictionary * connectionCallbacks;               // device connection callbacks

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
    
    manager.requestLog           = [@{} mutableCopy];
    manager.deviceConnections    = [@[] mutableCopy];
    manager.connectionCallbacks  = [@{} mutableCopy];
    manager.networkDevices       = [[NDiTachDevice findAll] mutableCopy] ?: [@[] mutableCopy];
    manager.beaconsReceived      = [NSMutableSet setWithCapacity:5];
    manager.suspendedConnections = [NSHashTable weakObjectsHashTable];

    /// Initialize the manager's multicast connection with a message handler
    ////////////////////////////////////////////////////////////////////////////////

    manager.multicastConnection =
    [NetworkDeviceMulticastConnection connectionWithAddress:NDiTachDeviceMulticastGroupAddress
                                                       port:NDiTachDeviceMulticastGroupPort
                                                   delegate:manager];

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
+ (void)startDetectingDevices:(void(^)(BOOL success, NSError *error))completion {

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
  else if ([self sharedManager].multicastConnection.isConnected) {

    MSLogWarnTag(@"multicast socket already exists");

    if (completion) completion(YES, nil);

  }

  // Otherwise join the multicast group
  else
    [[self sharedManager].multicastConnection connect:completion];

}

/**

 Cease listening for beacon broadcasts and release resources.

 @param completion Block to be executed upon completion of the task.

 */
+ (void)stopDetectingDevices:(void(^)(BOOL success, NSError *error))completion {

  // Set group active flag
  [self sharedManager].multicastGroupActive = NO;

  // Leave group if joined to one
  if ([self sharedManager].multicastConnection.isConnected)
    [[self sharedManager].multicastConnection disconnect:completion];

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

      // Check for existing connection
      GlobalCacheDeviceConnection * deviceConnection =
        [[self sharedManager].deviceConnections objectPassingTest:
         ^BOOL(GlobalCacheDeviceConnection * connection, NSUInteger idx) {
           return connection.device == command.networkDevice;
         }];

      if (!deviceConnection)
        deviceConnection = [GlobalCacheDeviceConnection connectionForDevice:(NDiTachDevice *)device
                                                                   delegate:[self sharedManager]];

      // Generate tag for command
      static NSUInteger nextTag = 0;
      NSUInteger tag = (++nextTag % 100) + 1;
      
      NSString * taggedCommand = [[cmd stringByReplacingOccurrencesOfString:@"<tag>"
                                                                 withString:$(@"%lu", (unsigned long)tag)]
                                  stringByAppendingFormat:@"<tag>%lu", (unsigned long)tag];

      // Make sure device is connected and queue command
      if (deviceConnection.isConnected)
        [deviceConnection enqueueCommand:taggedCommand completion:completion];

      else {

        [deviceConnection connect:^(BOOL success, NSError *error) {

          if (success)
            [deviceConnection enqueueCommand:taggedCommand completion:completion];

          else if (completion)
            completion(NO, error);

        }];

      }

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
- (void)deviceConnected:(GlobalCacheDeviceConnection *)connection {
  [self.deviceConnections addObject:connection];
}

/// Callback executed by a `GlobalCacheDeviceConnection` after sending a message
/// @param message The message that has been sent
/// @param connection The connection over which the message has been sent
- (void)messageSent:(NSString *)message overConnection:(NetworkDeviceConnection *)connection {
  MSLogInfoTag(@"message: %@", message);
}

/**
 Processes messages received through `GlobalCachedDeviceConnection` objects.
 @param message Contents of the message received by the device connection
 @param connection Device connection which received the message
 */
- (void)messageReceived:(NSString *)message overConnection:(NetworkDeviceConnection *)connection {


  if (connection == self.multicastConnection) {

    MSLogInfoTag(@"message over multicast connection:\n%@\n", message);

    NSString * uniqueIdentifier = [message stringByMatchingFirstOccurrenceOfRegEx:@"(?<=UUID=)[^<]+(?=>)"];

    // Check if device has already been discovered
    if (uniqueIdentifier && ![self.beaconsReceived containsObject:uniqueIdentifier]) {

      // Add to list of received beacons
      [self.beaconsReceived addObject:uniqueIdentifier];

      __block NDiTachDevice * networkDevice = nil;
      __weak GlobalCacheConnectionManager * weakself = self;
      // Get/create the network device with the parsed unique identifier
      [CoreDataManager saveWithBlock:^(NSManagedObjectContext * moc) {

        networkDevice = [NDiTachDevice networkDeviceFromDiscoveryBeacon:message context:moc];

      } completion:^(BOOL success, NSError * error) {

        MSHandleErrors(error);

        // Post notification of discovery if fetch/creation of network device was successful
        if (success)
          [MainQueue addOperationWithBlock:^{

            MSLogInfoWeakTag(@"network device fetched/created:\n%@\n", networkDevice);
            
            [weakself.networkDevices addObject:networkDevice];
            [NotificationCenter postNotificationName:CMNetworkDeviceDiscoveryNotification
                                              object:[weakself class]
                                            userInfo:@{ CMNetworkDeviceKey : networkDevice.uuid }];
            [[weakself class] stopDetectingDevices:nil];


          }];

      }];
      
    }

  } else {

    // iTach completeir command: completeir,<module address>:<connector address>,<ID>
    // TODO: handle error messages
    MSSTATIC_STRING_CONST kIREnabled  = @"IR Learner Enabled\r";
    MSSTATIC_STRING_CONST kIRDisabled = @"IR Learner Disabled\r";
    MSSTATIC_STRING_CONST kCompleteIR = @"completeir";
    MSSTATIC_STRING_CONST kSendIR     = @"sendir";
    MSSTATIC_STRING_CONST kError      = @"ERR";

    MSLogInfoTag(@"Return message from device: \"%@\"", [message stringByReplacingReturnsWithSymbol]);


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

}

/// Suspend active connections
+ (void)suspend {

  if ([self sharedManager].multicastGroupActive)
    [[self sharedManager].multicastConnection disconnect:nil];

  for (GlobalCacheDeviceConnection * connection in [self sharedManager].deviceConnections)
    if ([connection isConnected]) {
      [connection disconnect:^(BOOL success, NSError *error) {
        if (success) [[GlobalCacheConnectionManager sharedManager].suspendedConnections addObject:connection];
      }];
    }
}

/// Resume previously active connections
+ (void)resume {

  if ([self sharedManager].multicastGroupActive)
    [[self sharedManager].multicastConnection disconnect:nil];

  for (GlobalCacheDeviceConnection * connection in [self sharedManager].suspendedConnections) {
    [connection connect:nil];
  }
}

@end
