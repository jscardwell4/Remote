//
// ConnectionManager.h
// Remote
//
// Created by Jason Cardwell on 7/15/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//
#import "RETypedefs.h"

MSKIT_EXTERN_STRING   CMConnectionStatusNotification;
MSKIT_EXTERN_STRING   CMConnectionStatusWifiAvailable;
MSKIT_EXTERN_STRING   CMNetworkDeviceKey;
MSKIT_EXTERN_STRING   CMDevicesUserDefaultsKey;
MSKIT_EXTERN_STRING   CMCommandDidCompleteNotification;

@class RESendCommand;

/**
 * The `ConnectionManager` class utilizes a singleton instance to oversee all device-related network
 * activity.
 */
@interface ConnectionManager : NSObject

/**
 * Dumps various details about the current state.
 */
- (void)logStatus;

/**
 * Obtains the necessary data from the specified `RESendCommand` model object, executes the
 * send operation, and, optionally, calls the completion handler with the result.
  @param command The command containing the details from which the send message will be constructed.
  @param completion Block which to be executed upon completion of the send operation
 */
- (void)sendCommand:(NSManagedObjectID *)commandID completion:(RECommandCompletionHandler)completion;

/// Indicates status of wifi connectivity.
@property (nonatomic, readonly, getter = isWifiAvailable) BOOL wifiAvailable;

/**
  Accessor for the `ConnectionManager` shared singleton instance.
  @return The singleton instance of `ConnectionManager`
 */
+ (ConnectionManager *)sharedConnectionManager;

@end

#define ConnManager [ConnectionManager sharedConnectionManager]


