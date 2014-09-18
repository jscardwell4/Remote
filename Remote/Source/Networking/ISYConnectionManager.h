//
//  ISYConnectionManager.h
//  Remote
//
//  Created by Jason Cardwell on 9/3/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
@import Moonkit;
#import "MSRemoteMacros.h"

@import Foundation;

@class HTTPCommand;

@interface ISYConnectionManager : NSObject

/**

 Join multicast group and listen for beacons broadcast by iTach devices.

 @param completion Block to be executed upon completion of the task.

 */
+ (void)startDetectingDevices:(void(^)(BOOL success, NSError *error))completion;

/**

 Cease listening for beacon broadcasts and release resources.

 @param completion Block to be executed upon completion of the task.

 */
+ (void)stopDetectingDevices:(void(^)(BOOL success, NSError *error))completion;


/**

 Sends an IR command to the device identified by the specified `uuid`.

 @param command The command to execute

 @param completion The block to execute upon task completion

 */
+ (void)sendCommand:(HTTPCommand *)command completion:(void (^)(BOOL success, NSError *))completion;

/**
 Whether socket is open to receive multicast group broadcast messages.

 @return `YES` if detecting and `NO` otherwise.

 */
+ (BOOL)isDetectingNetworkDevices;


/// Suspend active connections
+ (void)suspend;

/// Resume previously active connections
+ (void)resume;

@end
