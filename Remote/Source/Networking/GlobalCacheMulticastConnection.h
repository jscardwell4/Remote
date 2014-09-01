//
// GlobalCacheMulticastConnection.h
// Remote
//
// Created by Jason Cardwell on 9/10/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

@class GlobalCacheMulticastConnection;

/**
 The `GlobalCacheMulticastConnection` class handles managing the resources necessary for
 joining the iTach multicast group over UDP and listens for beacons broadcast to the group and notifies
 the connection manager when a message is received.
 */
@interface GlobalCacheMulticastConnection : NSObject

+ (instancetype)connectionWithHandler:(void (^)(NSString *, GlobalCacheMulticastConnection *))handler;

/**

 Asks the connection object to establish its resources and join the multicast group.

 @param completion Block to be executed upon completion of the task.

 */
- (void)joinMulticastGroup:(void(^)(BOOL success, NSError *error))completion;

/**

 Asks the connection object to leave the multicast group and relinquish its resources.

 @param completion Block to be executed upon completion of the task.

 */
- (void)leaveMulticastGroup:(void(^)(BOOL success, NSError *error))completion;

/** Indicates whether a connection to the multicast group has been established and is currently active. */
@property (readonly) BOOL isMemberOfMulticastGroup;

/** Block to call when message has been received over multicast group connection */
@property (copy) void (^messageHandler)(NSString * message, GlobalCacheMulticastConnection * connection);

@end
