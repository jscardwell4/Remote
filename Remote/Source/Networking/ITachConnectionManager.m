//
// GlobalCacheConnectionManager.m
// Remote
//
// Created by Jason Cardwell on 9/10/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "ITachConnectionManager.h"
#import "NetworkDeviceMulticastConnection.h"
#import "ITachDeviceConnection.h"
#import "ConnectionManager.h"
#import "Remote-Swift.h"

static int ddLogLevel   = LOG_LEVEL_WARN;
static int msLogContext = (LOG_CONTEXT_NETWORKING | LOG_CONTEXT_FILE | LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel, msLogContext)

MSSTATIC_STRING_CONST kGlobalCacheMulticastGroupAddress = @"239.255.250.250";
MSSTATIC_STRING_CONST kGlobalCacheMulticastGroupPort    = @"9131";


MSNOTIFICATION_DEFINITION(LearnerStatusDidChange);
MSNOTIFICATION_DEFINITION(CommandCaptured);

@interface ITachConnectionManager () <NetworkDeviceConnectionDelegate>

@property (strong) MSDictionary                     * connections;          // currently connected devices.
@property (strong) NSMutableSet                     * beaconsReceived;      // uuids  from processed beacons.
@property (strong) NetworkDeviceMulticastConnection * multicastConnection;  // multicast group connection
@property (assign) BOOL                               multicastGroupActive; // tracks whether should be in group

@end


@implementation ITachConnectionManager


/**

 Accessor for the singleton instance of `GlobalCacheConnectionManager`

 @return const GlobalCacheConnectionManager *

 */
+ (const ITachConnectionManager *)sharedManager {

  static dispatch_once_t pred = 0;
  static const ITachConnectionManager * manager = nil;

  dispatch_once(&pred,  ^{

    /// Intialize shared manager and the manager's collection ivars
    ////////////////////////////////////////////////////////////////////////////////

    manager = [self new];
    
    manager.connections          = [MSDictionary dictionary];
    manager.beaconsReceived      = [NSMutableSet setWithCapacity:5];

    /// Initialize the manager's multicast connection with a message handler
    ////////////////////////////////////////////////////////////////////////////////

    manager.multicastConnection =
    [NetworkDeviceMulticastConnection connectionWithAddress:kGlobalCacheMulticastGroupAddress
                                                       port:kGlobalCacheMulticastGroupPort
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
+ (void)sendCommand:(SendIRCommand *)command completion:(void (^)(BOOL success, NSError *))completion {

  // Exit early if command string has no content to send
  if (StringIsEmpty(command.commandString)) {

    MSLogErrorTag(@"cannot send empty or nil command");

    if (completion) completion(NO, [NSError errorWithDomain:ConnectionManagerErrorDomain
                                                       code:ConnectionManagerErrorCommandEmpty
                                                   userInfo:nil]);
  }

  else {

    // Get the unique identifer for the network device
    NSString * identifier = command.networkDevice.uniqueIdentifier;

    // Check for existing connection
    ITachDeviceConnection * connection = [self sharedManager].connections[identifier];

    if (!connection) {
      connection = [ITachDeviceConnection connectionForDevice:command.networkDevice];
      [self sharedManager].connections[identifier] = connection;
    }

    [connection enqueueCommand:command completion:^(BOOL success, NSString * response, NSError * error) {
      if (completion) completion(success, error);
    }];

  }

}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - GlobalCacheDeviceConnectionDelegate
////////////////////////////////////////////////////////////////////////////////

/// Callback executed by a `NetworkDeviceConnection` after disconnecting from its device
/// @param connection The connection which has been disconnected
- (void)deviceDisconnected:(ITachDeviceConnection *)connection {
  MSLogInfoTag(@"");
}

/// Callback executed by a `NetworkDeviceConnection` after connecting to its device
/// @param connection The connection which has been established
- (void)deviceConnected:(ITachDeviceConnection *)connection {
  MSLogInfoTag(@"");
}

/// Callback executed by a `NetworkDeviceConnection` after sending a message
/// @param message The message that has been sent
/// @param connection The connection over which the message has been sent
- (void)messageSent:(NSString *)message overConnection:(NetworkDeviceConnection *)connection {
  MSLogInfoTag(@"message: %@", message);
}

/**
 Processes messages received through `NetworkDeviceConnection` objects.
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

      ITachDeviceConnection * deviceConnection = [ITachDeviceConnection connectionFromDiscoveryBeacon:message];

      if (deviceConnection) {
        self.connections[uniqueIdentifier] = deviceConnection;
        [[self class] stopDetectingDevices:nil];
      }

    }

  }

}

/// Suspend active connections
+ (void)suspend {

  if ([self sharedManager].multicastGroupActive)
    [[self sharedManager].multicastConnection disconnect:nil];

  for (ITachDeviceConnection * connection in [self sharedManager].connections)
    if ([connection isConnected])
      [connection disconnect:nil];

}

/// Resume previously active connections
+ (void)resume {

  if ([self sharedManager].multicastGroupActive) [[self sharedManager].multicastConnection connect:nil];

  // Device connections should re-connect as needed when commands are enqueued

}

@end
