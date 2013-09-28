//
// ConnectionManager.h
// Remote
//
// Created by Jason Cardwell on 7/15/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//
#import "RETypedefs.h"

MSEXTERN_STRING   CMConnectionStatusNotification;
MSEXTERN_STRING   CMConnectionStatusWifiAvailable;
MSEXTERN_STRING   CMNetworkDeviceKey;
MSEXTERN_STRING   CMDevicesUserDefaultsKey;
MSEXTERN_STRING   CMCommandDidCompleteNotification;

/**
 * The `ConnectionManager` class utilizes a singleton instance to oversee all device-related network
 * activity.
 */
@interface ConnectionManager : NSObject @end

@interface ConnectionManager (Public)

/**
 * Dumps various details about the current state.
 */
+ (void)logStatus;

/**
 * Obtains the necessary data from the specified `SendCommand` model object, executes the
 * send operation, and, optionally, calls the completion handler with the result.
  @param command The command containing the details from which the send message will be constructed.
  @param completion Block which to be executed upon completion of the send operation
 */
+ (void)sendCommand:(NSManagedObjectID *)commandID completion:(RECommandCompletionHandler)completion;

/// Indicates status of wifi connectivity.
+ (BOOL)isWifiAvailable;

@end
