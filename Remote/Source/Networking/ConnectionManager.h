//
// ConnectionManager.h
// Remote
//
// Created by Jason Cardwell on 7/15/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

typedef NS_ENUM (NSInteger, ConnectionCommandType) {
    IRConnectionCommandType  = 0,
    URLConnectionCommandType = 1
};
typedef NS_ENUM (NSInteger, NetworkDeviceType) {
    iTachNetworkDeviceType   = 0,
    InsteonNetworkDeviceType = 1
};

@protocol ConnectionManagerDelegate <NSObject>

@optional
- (void)commandWithTag:(NSUInteger)tag didCompleteWithStatus:(BOOL)success;

@end

/* dictionary keys */

MSKIT_EXTERN_STRING   kConnectionStatusNotification;
MSKIT_EXTERN_STRING   kConnectionStatusWifiAvailable;
MSKIT_EXTERN_STRING   kNetworkDeviceTypeKey;
MSKIT_EXTERN_STRING   kNetworkDeviceKey;
MSKIT_EXTERN_STRING   kDefaultiTachDeviceKey;
MSKIT_EXTERN_STRING   kDevicesUserDefaultsKey;
MSKIT_EXTERN_STRING   kCommandDidCompleteNotification;
MSKIT_EXTERN_STRING   kLearnerStatusDidChangeNotification;
MSKIT_EXTERN_STRING   kCommandCapturedNotification;

@interface ConnectionManager : NSObject

- (void)logStatus;

- (NSUInteger)sendCommand:(NSString *)commandString
                   ofType:(ConnectionCommandType)type
                 toDevice:(NSString *)device;

- (NSUInteger)sendCommand:(NSString *)commandString
                   ofType:(ConnectionCommandType)type
                 toDevice:(NSString *)index
                   sender:(id <ConnectionManagerDelegate> )sender;

- (BOOL)isWifiAvailable;

+ (ConnectionManager *)sharedConnectionManager;

@end

#define ConnManager [ConnectionManager sharedConnectionManager]
