//
// GlobalCacheDeviceConnection.h
// Remote
//
// Created by Jason Cardwell on 9/10/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
#import "MSKit/MSKit.h"
#import "MSRemoteMacros.h"

#import "NetworkDeviceConnection.h"

@class NDiTachDevice;

/**

 The `GlobalCacheDeviceConnection` class handles managing the resources necessary for
 connecting to an iTach device over TCP and the sending/receiving of messages to/from the device.

 */
@interface GlobalCacheDeviceConnection: NetworkDeviceConnection

/**

 Method for creating a new `GlobalCacheDeviceConnection` for connecting to the specified `device`.

 @param device The device to which a connection shall be established

 @param delegate The delegate to receive connection callbacks

 @return The Newly instantiated `GlobalCachedDeviceConnection` object

 */
+ (instancetype)connectionForDevice:(NDiTachDevice *)device
                           delegate:(id<NetworkDeviceConnectionDelegate>)delegate;

/**

 Adds the specified `command` to its queue of commands to be sent to the `device`.

 @param command The string to be transmitted to the device for execution.

 @param completion The block to be executed upon task completion, may be nil.

 */
- (void)enqueueCommand:(NSString *)command completion:(void (^)(BOOL success, NSError * error))completion;

@end
