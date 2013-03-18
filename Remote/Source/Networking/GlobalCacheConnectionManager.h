//
// GlobalCacheConnectionManager.h
// Remote
//
// Created by Jason Cardwell on 9/10/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

MSKIT_EXTERN_STRING   kiTachDeviceDiscoveryNotification;

@interface GlobalCacheConnectionManager : NSObject

+ (GlobalCacheConnectionManager *)sharedInstance;
- (BOOL)                          detectNetworkDevices;
- (void)                          stopNetworkDeviceDetection;
- (BOOL)                          connectWithDevice:(NSString *)deviceUUID;
- (BOOL)                          connectWithDefaultDevice;
- (BOOL)                          isDetectingNetworkDevices;
- (BOOL)                          isDefaultDeviceConnected;
- (BOOL)sendCommandToDefaultiTachDevice:(NSString *)command withTag:(NSUInteger)tag;
- (BOOL)sendCommand:(NSString *)command withTag:(NSUInteger)tag toDevice:(NSString *)device;
- (NSString *)                    statusDescription;

@property (nonatomic, copy) NSString * defaultDeviceUUID;

@end
