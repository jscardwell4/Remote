//
// ITachDeviceConnection.h
// Remote
//
// Created by Jason Cardwell on 9/10/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
@import MoonKit;
#import "MSRemoteMacros.h"


@class ITachDevice, SendIRCommand, ITachDeviceConnection;

@protocol ITachDeviceConnectionLearnerDelegate <NSObject>

- (void)learnerEnabledOverConnection:(ITachDeviceConnection *)connection;
- (void)learnerDisabledOverConnection:(ITachDeviceConnection *)connection;
- (void)learnerUnavailableOverConnection:(ITachDeviceConnection *)connection;
- (void)commandCaptured:(NSString *)command overConnection:(ITachDeviceConnection *)connection;

@end

/**

 The `GlobalCacheDeviceConnection` class handles managing the resources necessary for
 connecting to an iTach device over TCP and the sending/receiving of messages to/from the device.

 */
@interface ITachDeviceConnection: NSObject

/**

 Method for creating a new `GlobalCacheDeviceConnection` for connecting to the specified `device`.

 @param device The device to which a connection shall be established

 @param delegate The delegate to receive connection callbacks

 @return The Newly instantiated `GlobalCachedDeviceConnection` object

 */
+ (instancetype)connectionForDevice:(ITachDevice *)device;
/**

 connectionFromDiscoveryBeacon:delegate:

 @param beacon description

 @param delegate description

 @return instancetype
 
 */
+ (instancetype)connectionFromDiscoveryBeacon:(NSString *)beacon;


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
@property (nonatomic, readonly) ITachDevice * device;

/**

 Adds the specified `command` to its queue of commands to be sent to the `device`.

 @param command The `SendIRCommand` or `NSString` object encapsulating the message to transmit to the device.
 
 @param completion The block to be executed upon task completion, may be nil.

 */
- (void)enqueueCommand:(id)command
            completion:(void (^)(BOOL success, NSString * response, NSError * error))completion;

/// Delegate to receive IR learner related callbacks
@property (nonatomic, weak) id<ITachDeviceConnectionLearnerDelegate> learnerDelegate;

@end
