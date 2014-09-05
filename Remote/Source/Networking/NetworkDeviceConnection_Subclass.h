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
#import "MSKit/MSKit.h"
#import "MSRemoteMacros.h"

#import "NetworkDeviceConnection.h"
#import "MSKit/MSKit.h"

@interface NetworkDeviceConnection ()

@property (nonatomic, strong, readwrite) dispatch_source_t   readSource;           // Receiving I/O source
@property (nonatomic, strong, readwrite) dispatch_source_t   writeSource;          // Sending I/O source
@property (nonatomic, assign, readwrite) BOOL                isConnecting;         // Connection in progress
@property (nonatomic, strong, readwrite) NetworkDevice     * device;               // Model for device
@property (nonatomic, strong, readwrite) MSQueue           * messageQueue;         // Message send buffer
@property (nonatomic, assign, readonly) dispatch_fd_t       sourceFileDescriptor;

@property (nonatomic, copy) void (^connectCallback)   (BOOL, NSError *);   // Executed on connect
@property (nonatomic, copy) void (^disconnectCallback)(BOOL, NSError *);   // Executed on disconnect


- (dispatch_queue_t)readSourceQueue;
- (dispatch_queue_t)writeSourceQueue;

- (dispatch_block_t)readEventHandler;
- (dispatch_block_t)writeEventHandler;
- (dispatch_block_t)readCancelHandler;
- (dispatch_block_t)writeCancelHandler;
- (dispatch_block_t)readRegistrationHandler;
- (dispatch_block_t)writeRegistrationHandler;

@end


/// Simple class to wrap up a message string with a completion block
////////////////////////////////////////////////////////////////////////////////


@interface MessageQueueEntry : NSObject

@property (nonatomic, copy) NSString * message;
@property (nonatomic, copy) void (^completion)(BOOL, NSError *);

+ (instancetype)entryWithMessage:(NSString *)message
                      completion:(void(^)(BOOL success, NSError * error))completion;

@end

