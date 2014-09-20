//
// ConnectionManager.h
// Remote
//
// Created by Jason Cardwell on 7/15/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
@import MoonKit;
#import "MSRemoteMacros.h"

MSEXTERN_NOTIFICATION(CMConnectionStatus);
MSEXTERN_NOTIFICATION(CMNetworkDeviceDiscovery);

MSEXTERN_KEY(CMConnectionStatusWifiAvailable);
MSEXTERN_KEY(CMNetworkDevice);
MSEXTERN_KEY(CMAutoConnectDevice);
MSEXTERN_KEY(CMDevicesUserDefaults);

MSEXTERN_STRING ConnectionManagerErrorDomain;

NS_ENUM(uint8_t, ConnectionManagerErrorCode) {
  ConnectionManagerErrorNoWifi,
  ConnectionManagerErrorInvalidID,
  ConnectionManagerErrorCommandEmpty,
  ConnectionManagerErrorCommandHalted,
  ConnectionManagerErrorConnectionExists,
  ConnectionManagerErrorInvalidNetworkDevice,
  ConnectionManagerErrorConnectionInProgress,
  ConnectionManagerErrorNetworkDeviceError,
  ConnectionManagerErrorAggregate
};

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
