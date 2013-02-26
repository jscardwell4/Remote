//
// NetworkDevice.h
// iPhonto
//
// Created by Jason Cardwell on 9/25/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface NetworkDevice : NSManagedObject

+ (NetworkDevice *)networkDeviceInContext:(NSManagedObjectContext *)context;

+ (NetworkDevice *)networkDeviceForUUID:(NSString *)uuid
                                context:(NSManagedObjectContext *)context;

+ (BOOL)networkDeviceExistsForUUID:(NSString *)uuid;

@property (nonatomic, strong) NSString * uuid;

@end

MSKIT_EXTERN_STRING   kiTachDeviceMake;
MSKIT_EXTERN_STRING   kiTachDeviceModel;
MSKIT_EXTERN_STRING   kiTachDevicePCB;
MSKIT_EXTERN_STRING   kiTachDevicePkg;
MSKIT_EXTERN_STRING   kiTachDeviceRev;
MSKIT_EXTERN_STRING   kiTachDeviceSDK;
MSKIT_EXTERN_STRING   kiTachDeviceStatus;
MSKIT_EXTERN_STRING   kiTachDeviceUUID;
MSKIT_EXTERN_STRING   kiTachDeviceURL;
MSKIT_EXTERN_STRING   kiTachDeviceMulticastGroupAddress;
MSKIT_EXTERN_STRING   kiTachDeviceMulticastGroupPort;
MSKIT_EXTERN_STRING   kiTachDeviceTCPPort;

@interface ITachDevice : NetworkDevice

+ (ITachDevice *)iTachDeviceWithAttributes:(NSDictionary *)attributes context:(NSManagedObjectContext *)context;

+ (ITachDevice *)iTachDeviceForUUID:(NSString *)uuid
                            context:(NSManagedObjectContext *)context;

+ (NSArray *)allDevicesInContext:(NSManagedObjectContext *)context;

@property (nonatomic, strong) NSString * make;
@property (nonatomic, strong) NSString * model;
@property (nonatomic, strong) NSString * pcb_pn;
@property (nonatomic, strong) NSString * pkg_level;
@property (nonatomic, strong) NSString * sdkClass;
@property (nonatomic, strong) NSString * status;
@property (nonatomic, strong) NSString * configURL;
@property (nonatomic, strong) NSString * revision;

@end
