//
// ConnectionManager.h
// Remote
//
// Created by Jason Cardwell on 7/15/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

MSEXTERN_NOTIFICATION(CMConnectionStatus);
MSEXTERN_NOTIFICATION(CMCommandDidComplete);
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
  ConnectionManagerErrorConnectionExists,
  ConnectionManagerErrorInvalidNetworkDevice,
  ConnectionManagerErrorConnectionInProgress
};

/**

 The `ConnectionManager` class utilizes a singleton instance to oversee all device-related network
 activity.

 */
@interface ConnectionManager : NSObject

/**

 Obtains the necessary data from the specified `SendCommand` model object, executes the
 send operation, and, optionally, calls the completion handler with the result.
 
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
+ (void)detectNetworkDevices:(void(^)(BOOL success, NSError * error))completion;

/**

 Leave multicast group.

 @param completion Block to be executed upon completion of the task.

 */
+ (void)stopDetectingNetworkDevices:(void(^)(BOOL success, NSError * error))completion;

@end
