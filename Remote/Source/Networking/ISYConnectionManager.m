//
//  ISYConnectionManager.m
//  Remote
//
//  Created by Jason Cardwell on 9/3/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

#import "ISYConnectionManager.h"
#import "NetworkDeviceMulticastConnection.h"
#import "ISYDevice.h"
#import "Command.h"
#import "ISYDeviceConnection.h"
#import "ConnectionManager.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_NETWORKING | LOG_CONTEXT_FILE | LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel, msLogContext)

MSSTATIC_STRING_CONST kISYMulticastGroupAddress = @"239.255.255.250";
MSSTATIC_STRING_CONST kISYMulticastGroupPort    = @"1900";

@interface ISYConnectionManager () <NetworkDeviceConnectionDelegate>

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

@implementation ISYConnectionManager

/**

 Accessor for the singleton instance of `GlobalCacheConnectionManager`

 @return const GlobalCacheConnectionManager *

 */
+ (const ISYConnectionManager *)sharedManager {

  static dispatch_once_t pred = 0;
  static const ISYConnectionManager * manager = nil;

  dispatch_once(&pred,  ^{

    /// Intialize shared manager and the manager's collection ivars
    ////////////////////////////////////////////////////////////////////////////////

    manager = [self new];

    manager.requestLog           = [@{} mutableCopy];
    manager.deviceConnections    = [@[] mutableCopy];
    manager.connectionCallbacks  = [@{} mutableCopy];
    manager.networkDevices       = [[ISYDevice findAll] mutableCopy] ?: [@[] mutableCopy];
    manager.beaconsReceived      = [NSMutableSet setWithCapacity:5];
    manager.suspendedConnections = [NSHashTable weakObjectsHashTable];

    /// Initialize the manager's multicast connection with a message handler
    ////////////////////////////////////////////////////////////////////////////////

    manager.multicastConnection =
    [NetworkDeviceMulticastConnection connectionWithAddress:kISYMulticastGroupAddress
                                                       port:kISYMulticastGroupPort
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

  MSLogInfoTag(@"");
  
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
  else [[self sharedManager].multicastConnection connect:completion];

}

/**

 Cease listening for beacon broadcasts and release resources.

 @param completion Block to be executed upon completion of the task.

 */
+ (void)stopDetectingDevices:(void(^)(BOOL success, NSError *error))completion {

  MSLogInfoTag(@"");

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
+ (void)sendCommand:(HTTPCommand *)command completion:(void (^)(BOOL success, NSError *))completion {


}


/// Suspend active connections
+ (void)suspend {

  if ([self sharedManager].multicastGroupActive)
    [[self sharedManager].multicastConnection disconnect:nil];

}

/// Resume previously active connections
+ (void)resume {

  if ([self sharedManager].multicastGroupActive)
    [[self sharedManager].multicastConnection disconnect:nil];

}



////////////////////////////////////////////////////////////////////////////////
#pragma mark - NetworkDeviceConnectionDelegate
////////////////////////////////////////////////////////////////////////////////

- (void)deviceDisconnected:(NetworkDeviceConnection *)connection {
  MSLogInfoTag(@"");
}
- (void)deviceConnected:(NetworkDeviceConnection *)connection {
  MSLogInfoTag(@"");
}

- (void)messageReceived:(NSString *)message overConnection:(NetworkDeviceConnection *)connection {

  MSLogInfoTag(@"message received:\n%@\n", message);

  MSDictionary * entries =
  [MSDictionary dictionaryByParsingArray:[message matchingSubstringsForRegEx:@"^[A-Z]+:.*(?=\\r)"]];
  MSLogInfo(@"entries: %@", entries);

  NSString * location = entries[@"LOCATION"];

  // Check if device has already been discovered
  if ([location hasSuffix:@"/desc"] && ![self.beaconsReceived containsObject:location]) {

    // Add to list of received beacons
    [self.beaconsReceived addObject:location];

    NSString * baseURL = [location stringByReplacingOccurrencesOfString:@"/desc" withString:@""];
    __weak ISYConnectionManager * weakself = self;

    [ISYDeviceConnection connectionWithBaseURL:[NSURL URLWithString:baseURL]
                                    completion:^(ISYDeviceConnection *connection)
     {
       assert(IsMainQueue);

       if (connection) {

         assert([weakself.deviceConnections firstObjectCommonWithArray:@[connection]] == nil);
         [weakself.deviceConnections addObject:connection];
         [[weakself class] stopDetectingDevices:nil];

       }

     }];

  }

}

- (void)messageSent:(NSString *)message overConnection:(NetworkDeviceConnection *)connection {
  MSLogInfoTag(@"message: %@", message);
}


@end
