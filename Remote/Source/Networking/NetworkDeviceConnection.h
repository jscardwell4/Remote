//
//  NetworkDeviceConnection.h
//  Remote
//
//  Created by Jason Cardwell on 9/4/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
@import MoonKit;
#import "MSRemoteMacros.h"

@class NetworkDeviceConnection, NetworkDevice;

/**

 Protocol to implement to receive callbacks from a `NetworkDeviceConnection` when connected, disconnected,
 and when a message has been sent or received.

 */
@protocol NetworkDeviceConnectionDelegate

- (void)deviceDisconnected:(NetworkDeviceConnection *)connection;
- (void)deviceConnected:(NetworkDeviceConnection *)connection;
- (void)messageReceived:(NSString *)message overConnection:(NetworkDeviceConnection *)connection;
- (void)messageSent:(NSString *)message overConnection:(NetworkDeviceConnection *)connection;

@end

/**

 The `NetworkDeviceConnection` class is an abstract class for managing the resources necessary for
 connecting to a `NetworkDevice` and the sending/receiving of messages to/from the device.

 */
@interface NetworkDeviceConnection : NSObject

/**

 Method for creating a new `NetworkDeviceConnection` for connecting to the specified `device`.

 @param device The device to which a connection shall be established

 @param delegate The delegate to receive connection callbacks

 @return The Newly instantiated `NetworkDeviceConnection` object

 */
+ (instancetype)connectionForDevice:(NetworkDevice *)device
                           delegate:(id<NetworkDeviceConnectionDelegate>)delegate;

/**

 Commence communication with the `device`.

 @param completion The block to execute upon task completion

 */
- (void)connect:(void (^)(BOOL success, NSError * error))completion;


/**

 Ends communication with the `device`.

 @param completion The block to execute upon task completion

 */
- (void)disconnect:(void (^)(BOOL success, NSError * error))completion;

/// Whether establishing the connection is in process.
@property (nonatomic, readonly) BOOL isConnecting;

/// Whether the connection has been successfully established and is available for send/receive operations.
@property (nonatomic, readonly) BOOL isConnected;

/// The device to which the connection transmits and receives
@property (nonatomic, readonly) NetworkDevice * device;

/// Connection manager for the connection
@property (nonatomic, weak) id<NetworkDeviceConnectionDelegate> delegate;


@end
