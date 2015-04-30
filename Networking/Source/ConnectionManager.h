//
// ConnectionManager.h
// Remote
//
// Created by Jason Cardwell on 7/15/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//
@import Foundation;
@import MoonKit;

@class NSManagedObjectID;

#define LOG_CONTEXT_NETWORKING    0b00000000010000000

MSEXTERN_NOTIFICATION(CMConnectionStatus);
MSEXTERN_NOTIFICATION(CMNetworkDeviceDiscovery);

MSEXTERN_KEY(CMConnectionStatusWifiAvailable);
MSEXTERN_KEY(CMNetworkDevice);
MSEXTERN_KEY(CMAutoConnectDevice);
MSEXTERN_KEY(CMDevicesUserDefaults);

MSEXTERN_STRING ConnectionManagerErrorDomain;

static const int ConnectionManagerErrorNoWifi = 0;
static const int ConnectionManagerErrorInvalidID = 1;
static const int ConnectionManagerErrorCommandEmpty = 2;
static const int ConnectionManagerErrorCommandHalted = 3;
static const int ConnectionManagerErrorConnectionExists = 4;
static const int ConnectionManagerErrorInvalidNetworkDevice = 5;
static const int ConnectionManagerErrorConnectionInProgress = 6;
static const int ConnectionManagerErrorNetworkDeviceError = 7;
static const int ConnectionManagerErrorAggregate = 8;

/**

 The `ConnectionManager` class utilizes a singleton instance to oversee all device-related network
 activity.

 */
@interface ConnectionManager : NSObject

/**

 Executes the send operation, and, optionally, calls the completion handler with the result.

 @param command The command containing the details from which the send message will be constructed.

 @param completion Block to be executed upon completion of the send operation

 */
+ (void)sendCommandWithID:(NSManagedObjectID *)commandID
               completion:(void (^)(BOOL success, NSError *))completion;

/**

 Method for retrieving current status of wifi availability

 @return `YES` if available and `NO` otherwise.

 */
+ (BOOL)isWifiAvailable;

/**

 Join multicast group and listen for beacons broadcast by iTach devices.

 @param completion Block to be executed upon completion of the task.

 */
+ (void)startDetectingDevices:(void(^)(BOOL success, NSError * error))completion;

/**

 Leave multicast group.

 @param completion Block to be executed upon completion of the task.

 */
+ (void)stopDetectingDevices:(void(^)(BOOL success, NSError * error))completion;


/**

 Returns whether network devices are currently being detected

 @return BOOL

 */
+ (BOOL)isDetectingNetworkDevices;


@end
