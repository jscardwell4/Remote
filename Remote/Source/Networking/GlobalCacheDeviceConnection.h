//
// GlobalCacheDeviceConnection.h
// Remote
//
// Created by Jason Cardwell on 9/10/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

@class NDiTachDevice, GlobalCacheDeviceConnection;

/**
 
 Protocol to implement to receive callbacks from a `GlobalCacheDeviceConnection` when connected, disconnected,
 and when a message has been received.

 */
@protocol GlobalCacheDeviceConnectionDelegate

- (void)deviceDisconnected:(GlobalCacheDeviceConnection *)connection;
- (void)connectionEstablished:(GlobalCacheDeviceConnection *)connection;
- (void)messageReceived:(NSString *)message overConnection:(GlobalCacheDeviceConnection *)connection;

@end

/**

 The `GlobalCacheDeviceConnection` class handles managing the resources necessary for
 connecting to an iTach device over TCP and the sending/receiving of messages to/from the device.
 Messages to be sent to the device are received from the connection manager and messages received
 from the iTach device are passed up to the connection manager.
 
 */
@interface GlobalCacheDeviceConnection: NSObject

/**

 Method for creating a new `GlobalCacheDeviceConnection` for connecting to the specified `device`.
 
 @param uri The URI for the device to which a connection shall be established
 
 @param delegate The delegate to receive connection callbacks
 
 @return The Newly instantiated `GlobalCachedDeviceConnection` object
 
 */
+ (instancetype)connectionForDevice:(NDiTachDevice *)device
                           delegate:(id<GlobalCacheDeviceConnectionDelegate>)delegate;

/**

 Asks the `GlobalCacheDeviceConnection` to commence communication with the `device`.
 
 @param completion The block to execute upon task completion
 
 */
- (void)connect:(void (^)(BOOL success, NSError * error))completion;


/**

 Asks the `GlobalCacheDeviceConnection` to end communication with the `device`.
 
 @param completion The block to execute upon task completion

 */
- (void)disconnect:(void (^)(BOOL success, NSError * error))completion;

/**

 Adds the specified `command` to its queue of commands to be sent to the `device`.
 
 @param command The string to be transmitted to the device for execution.
 
 @param completion The block to be executed upon task completion, may be nil.
 
 */
- (void)enqueueCommand:(NSString *)command completion:(void (^)(BOOL success, NSError * error))completion;

/// Whether establishing the connection is in process.
@property (nonatomic, readonly) BOOL isConnecting;

/// Whether the connection has been successfully established and is available for send operations.
@property (nonatomic, readonly) BOOL isConnected;

/// The device to which the connection transmits and receives
@property (nonatomic, readonly) NDiTachDevice * device;

/// Connection manager for the connection
@property (nonatomic, weak) id<GlobalCacheDeviceConnectionDelegate> delegate;

@end
