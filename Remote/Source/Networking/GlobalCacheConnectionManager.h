//
// GlobalCacheConnectionManager.h
// Remote
//
// Created by Jason Cardwell on 9/10/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
@class NDiTachDevice, SendIRCommand;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Global Caché Connection Manager
////////////////////////////////////////////////////////////////////////////////

@interface GlobalCacheConnectionManager : NSObject

/**

 Join multicast group and listen for beacons broadcast by iTach devices.

 @param completion Block to be executed upon completion of the task.

 */
+ (void)detectNetworkDevices:(void(^)(BOOL success, NSError *error))completion;

/**
 
 Cease listening for beacon broadcasts and release resources.

 @param completion Block to be executed upon completion of the task.

 */
+ (void)stopDetectingDevices:(void(^)(BOOL success, NSError *error))completion;

/**
 
 Attempts to connect with the device identified by the specified `uuid`.
 
 @param device The device with which to connect, or nil for the registered default device.
 
 @param completion Block to execute after attempt is made to connect with the device.

 */
+ (void)connectWithDevice:(NDiTachDevice *)device
               completion:(void(^)(BOOL success, NSError *error))completion;

/**

 Sends an IR command to the device identified by the specified `uuid`.

 @param command The command to execute

 @param completion The block to execute upon task completion

 */
+ (void)sendCommand:(SendIRCommand *)command completion:(void (^)(BOOL success, NSError *))completion;

/**
 Whether socket is open to receive multicast group broadcast messages.

 @return `YES` if detecting and `NO` otherwise.

 */
+ (BOOL)isDetectingNetworkDevices;


@end
