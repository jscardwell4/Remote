//
//  GlobalCacheConnectionManager_Private.h
//  Remote
//
//  Created by Jason Cardwell on 3/28/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "GlobalCacheConnectionManager.h"
#import "ConnectionManager_Private.h"
#import "CoreDataManager.h"
#import <CFNetwork/CFNetwork.h>
#import <sys/socket.h>
#import <arpa/inet.h>
#import <netinet/in.h>
#import <unistd.h>
#import <netdb.h>

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Multicast Connections
////////////////////////////////////////////////////////////////////////////////

/**
 * The `GlobalCacheMulticastConnection` class handles managing the resources necessary for
 * joining the iTach multicast group over UDP and listens for beacons broadcast to the group and notifies
 * the connection manager when a message is received.
 */
@interface GlobalCacheMulticastConnection : NSObject {
    dispatch_source_t _multicastSource; // I/O source for multicast group
}

/**
 * Returns the `GlobalCacheMulticastConnection` singleton instance.
 */
+ (GlobalCacheMulticastConnection *)multicastConnection;

/**
 * Asks the connection object to establish its resources and join the multicast group.
 */
- (BOOL)joinMulticastGroup;

/**
 * Asks the connection object to leave the multicast group and relinquish its resources.
 */
- (void)leaveMulticastGroup;

/// Indicates whether a connection to the multicast group has been established and is currently active.
@property (nonatomic, readonly) BOOL isMemberOfMulticastGroup;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Device Connections
////////////////////////////////////////////////////////////////////////////////

/**
 * The `GlobalCacheDeviceConnection` class handles managing the resources necessary for
 * connecting to an iTach device over TCP and the sending/receiving of messages to/from the device.
 * Messages to be sent to the device are received from the connection manager and messages received
 * from the iTach device are passed up to the connection manager.
 */
@interface GlobalCacheDeviceConnection:NSObject {
    NDiTachDevice     * _device;       	 /// Connected iTach device
    dispatch_source_t   _tcpSourceRead;  /// I/O source for receiving from the device
    dispatch_source_t   _tcpSourceWrite; /// I/O source for sending to the device
    MSQueue           * _commandQueue;   /// Basic queue for holding messages not yet sent to the device
    BOOL                _isConnecting;   /// Whether establishing the connection is in process
}

/**
 * Method for creating a new `GlobalCacheDeviceConnection` for connecting to the specified `device`.
 * @param uri The URI for the device to which a connection shall be established
 * @return The Newly instantiated `GlobalCachedDeviceConnection` object
 */
+ (GlobalCacheDeviceConnection *)connectionForDevice:(NSString *)uuid;

/**
 * Asks the `GlobalCacheDeviceConnection` to commence communication with the `device`.
 */
- (BOOL)connect;


/**
 * Asks the `GlobalCacheDeviceConnection` to end communication with the `device`.
 */
- (void)disconnect;

/**
 * Adds the specified `command` to its queue of commands to be sent to the `device`.
 * @param command The string to be transmitted to the device for execution
 */
- (void)enqueueCommand:(NSString *)command;

/// Whether establishing the connection is in process.
@property (nonatomic, readonly) BOOL isConnecting;

/// Whether the connection has been successfully established and is available for send operations.
@property (nonatomic, readonly) BOOL isConnected;

/// The uuid identifying the device to which the connection transmits and receives
@property (nonatomic, readonly) NSString * deviceUUID;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Connection Manager
////////////////////////////////////////////////////////////////////////////////

@interface GlobalCacheConnectionManager () {
    NSMutableDictionary            * _requestLog;          /// Holds completion handlers for ongoing commands
    NSMutableDictionary            * _networkDevices;      /// previously discovered iTach devices.
    NSMutableDictionary            * _connectedDevices;    /// currently connected iTach devices.
    NSMutableSet                   * _beaconsReceived;     /// uuids of devices from processed beacons.
    NSString                       * _capturedCommand;     /// needs to be moved to `IRLearner`
    GlobalCacheMulticastConnection * _multicastConnection; /// reference to the multicast singleton.
    @package
    NSOperationQueue               * _operationQueue;      /// private queue for networking operations.
    NSString                       * _defaultDeviceUUID;
}

@end

@interface GlobalCacheConnectionManager (DynamicPrivate)

/**
 * Processes the beacon broadcast by an iTach device and received by the multicast connection singleton.
 * Messages received from new devices have their attributes extracted from the message and passed on to
 * `deviceDiscoveredOfType:uuid:attributes:`.
 * @param The contents of the received beacon to be parsed by the manager
 */
- (void)receivedMulticastGroupMessage:(NSString *)message;

/**
 * Creates a new `NDiTachDevice` model object with the specified attributes.
 * @param uuid Unique identifier for the device
 * @param attributes Dictionary of key/value pairs to set for created device model object.
 */
- (void)deviceDiscoveredWithAttributes:(NSDictionary *)attributes;

/**
 * Processes messages received through `GlobalCachedDeviceConnection` objects.
 * @param message Contents of the message received by the device connection
 */
- (void)parseiTachReturnMessage:(NSString *)message;

- (void)deviceDisconnected:(NSString *)uri;

- (void)connectionEstablished:(GlobalCacheDeviceConnection *)deviceConnection;

@end


