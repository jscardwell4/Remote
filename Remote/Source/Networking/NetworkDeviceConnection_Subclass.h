//
//  NetworkDeviceConnection_Subclass.h
//  Remote
//
//  Created by Jason Cardwell on 9/4/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
@import Moonkit;
#import "MSRemoteMacros.h"
#import "NetworkDeviceConnection.h"
@import Moonkit;

@interface NetworkDeviceConnection ()

@property (nonatomic, strong, readwrite) dispatch_source_t   readSource;            /// Receiving I/O source
@property (nonatomic, strong, readwrite) dispatch_source_t   writeSource;           /// Sending I/O source
@property (nonatomic, assign, readwrite) BOOL                isConnecting;          /// Connection in progress
@property (nonatomic, strong, readwrite) NetworkDevice     * device;                /// Model for device
@property (nonatomic, strong, readwrite) MSQueue           * messageQueue;          /// Message send buffer
@property (nonatomic, assign, readonly) dispatch_fd_t        sourceFileDescriptor;  /// Dispatch source handle

@property (nonatomic, strong, readwrite) dispatch_queue_t    readSourceQueue;       /// Queue for read source
@property (nonatomic, strong, readwrite) dispatch_queue_t    writeSourceQueue;      /// Queue for write source

@property (nonatomic, copy) void (^connectCallback)   (BOOL, NSError *);            /// Executed on connect
@property (nonatomic, copy) void (^disconnectCallback)(BOOL, NSError *);            /// Executed on disconnect


/// readSourceQueue
/// @return dispatch_queue_t
- (dispatch_queue_t)readSourceQueue;

/// writeSourceQueue
/// @return dispatch_queue_t
- (dispatch_queue_t)writeSourceQueue;

/// readEventHandler
/// @return dispatch_block_t
- (dispatch_block_t)readEventHandler;

/// writeEventHandler
/// @return dispatch_block_t
- (dispatch_block_t)writeEventHandler;

/// readCancelHandler
/// @return dispatch_block_t
- (dispatch_block_t)readCancelHandler;

/// writeCancelHandler
/// @return dispatch_block_t
- (dispatch_block_t)writeCancelHandler;

/// readRegistrationHandler
/// @return dispatch_block_t
- (dispatch_block_t)readRegistrationHandler;

/// writeRegistrationHandler
/// @return dispatch_block_t
- (dispatch_block_t)writeRegistrationHandler;

@end
