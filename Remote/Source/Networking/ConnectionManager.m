//
// ConnectionManager.m
// Remote
//
// Created by Jason Cardwell on 7/15/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//
#import "ConnectionManager.h"
#import "NetworkDevice.h"
#import "SettingsManager.h"
#import "GlobalCacheConnectionManager.h"
#import "Command.h"
#import "IRCode.h"
#import "ComponentDevice.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_NETWORKING | LOG_CONTEXT_FILE | LOG_CONTEXT_CONSOLE);

static const int64_t simulatedCommandDelay = 0.5 * NSEC_PER_SEC;

MSNOTIFICATION_DEFINITION(CMConnectionStatus);
MSNOTIFICATION_DEFINITION(CMCommandDidComplete);
MSNOTIFICATION_DEFINITION(CMNetworkDeviceDiscovery);

MSKEY_DEFINITION(CMDevicesUserDefaults);
MSKEY_DEFINITION(CMNetworkDevice);
MSKEY_DEFINITION(CMConnectionStatusWifiAvailable);
MSKEY_DEFINITION(CMAutoConnectDevice);

MSSTRING_CONST ConnectionManagerErrorDomain = @"ConnectionManagerErrorDomain";

@interface ConnectionManager ()

@property (strong) MSNetworkReachability * reachability;           // Monitors changes in connectivity
@property (assign) BOOL                    autoConnect;            // Automatically connect to known devices
@property (assign) BOOL                    autoListen;             // Automatically listen for new devices
@property (assign) BOOL                    wifiAvailable;          // Indicates wifi availability
@property (assign) BOOL                    simulateCommandSuccess; // Whether to simulate send operations

@end

@implementation ConnectionManager

/**

 Accessor for the singleton instance of `ConnectionManager`

 @return const ConnectionManager *

 */
+ (const ConnectionManager *)sharedManager {

  static dispatch_once_t pred = 0;
  static ConnectionManager * connectionManager = nil;

  dispatch_once(&pred, ^{

    connectionManager = [self new];

    // initialize settings
    connectionManager.autoConnect = [SettingsManager boolForSetting:MSSettingsAutoConnectKey];
    connectionManager.simulateCommandSuccess = [UserDefaults boolForKey:@"simulate"];
    connectionManager.autoListen = [SettingsManager boolForSetting:MSSettingsAutoListenKey];

    // initialize reachability
    connectionManager.reachability =
    [MSNetworkReachability reachabilityWithCallback:^(SCNetworkReachabilityFlags flags) {
      BOOL wifi = (  (flags & kSCNetworkReachabilityFlagsIsDirect)
                  && (flags & kSCNetworkReachabilityFlagsReachable));

      connectionManager.wifiAvailable = wifi;

      [NotificationCenter postNotificationName:CMConnectionStatusNotification
                                        object:self
                                      userInfo:@{ CMConnectionStatusWifiAvailableKey : @(wifi) }];
    }];

    // get initial reachability status and try connecting to the default device
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
      [connectionManager.reachability refreshFlags];
    });

  });

  return connectionManager;
}

/**

 Join multicast group and listen for beacons broadcast by iTach devices.

 @param completion Block to be executed upon completion of the task.

 */
+ (void)detectNetworkDevices:(void(^)(BOOL success, NSError *error))completion {
  [GlobalCacheConnectionManager detectNetworkDevices:completion];
}


/**

 Leave multicast group.

 @param completion Block to be executed upon completion of the task.

 */
+ (void)stopDetectingNetworkDevices:(void (^)(BOOL, NSError *))completion {
  [GlobalCacheConnectionManager stopDetectingDevices:completion];
}

/**

 Obtains the necessary data from the specified `SendCommand` model object, executes the
 send operation, and, optionally, calls the completion handler with the result.

 @param command The command containing the details from which the send message will be constructed.

 @param completion Block which to be executed upon completion of the send operation

 */
+ (void)sendCommandWithID:(NSManagedObjectID *)commandID
               completion:(void (^)(BOOL success, NSError *))completion
{
  const ConnectionManager * manager = [self sharedManager];

  // Check for wifi or a simulated environment flag
  if (!(manager.wifiAvailable || manager.simulateCommandSuccess)) {

    MSLogWarnTag(@"wifi not available");

    if (completion) completion(NO, [NSError errorWithDomain:ConnectionManagerErrorDomain
                                                       code:ConnectionManagerErrorNoWifi
                                                   userInfo:nil]);
  }

  // Continue sending command
  else {

    // Get the actual command model object
    NSError * error   = nil;
    SendCommand * command = [SendCommand existingObjectWithID:commandID error:&error];

    if (MSHandleErrors(error)) {

      if (completion) completion(NO, [NSError errorWithDomain:ConnectionManagerErrorDomain
                                                         code:ConnectionManagerErrorInvalidID
                                                     userInfo:@{NSUnderlyingErrorKey: error}]);
    }

    // Handle IR command
    else if (   [command isKindOfClass:[SendIRCommand class]]
             && [((SendIRCommand *)command).networkDevice isKindOfClass:[NDiTachDevice class]])
    {

      // Just execute completion block after a brief delay if we are simulating commands
      if (manager.simulateCommandSuccess && completion) {

        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, simulatedCommandDelay);
        dispatch_queue_t queue = dispatch_get_main_queue();
        dispatch_after(time, queue, ^{ completion(YES, nil); });

      }

      // Otherwise, if we are not simulating and we have a valid network device, send the command
      else if (!manager.simulateCommandSuccess)
        [GlobalCacheConnectionManager sendCommand:(SendIRCommand *)command completion:completion];

    }

    // Handle HTTP command
    else if ([command isKindOfClass:[HTTPCommand class]]) {

      NSURL * url    = ((HTTPCommand *)command).url;

      // Check that url is not empty
      if (StringIsEmpty([url absoluteString])) {

        MSLogErrorTag(@"cannot send empty or nil command");

        if (completion) completion(NO, [NSError errorWithDomain:ConnectionManagerErrorDomain
                                                           code:ConnectionManagerErrorCommandEmpty
                                                       userInfo:nil]);
      }

      else {

        // Just execute completion block after a brief delay if we are simulating commands
        if (manager.simulateCommandSuccess && completion) {

          dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, simulatedCommandDelay);
          dispatch_queue_t queue = dispatch_get_main_queue();
          dispatch_after(time, queue, ^{ completion(YES, nil); });

        }

        // Otherwise create a url request and send it
        else if (!manager.simulateCommandSuccess) {
          
          void(^handler)(NSURLResponse *, NSData *, NSError *) =
          ^(NSURLResponse *response, NSData *data, NSError *connectionError) {

            MSLogDebug(@"response: %@\ndata:%@", response, data);

            //TODO: Determine what constitutes success here.

            if (completion) completion(YES, error);

          };

          NSURLRequest * request = [NSURLRequest requestWithURL:url];
          [NSURLConnection sendAsynchronousRequest:request queue:MainQueue completionHandler:handler];

        }

      }

    }

  }

}

/**

 Method for retrieving current status of wifi availability

 @return `YES` if available and `NO` otherwise.

 */
+ (BOOL)isWifiAvailable { return [self sharedManager].wifiAvailable; }


@end
