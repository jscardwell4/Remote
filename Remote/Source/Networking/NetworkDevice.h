//
// NetworkDevice.h
// Remote
//
// Created by Jason Cardwell on 9/25/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

// keys
MSKIT_EXTERN_STRING   NDDeviceMakeKey;
MSKIT_EXTERN_STRING   NDModelKey;
MSKIT_EXTERN_STRING   NDDeviceRevisionKey;
MSKIT_EXTERN_STRING   NDDeviceStatusKey;
MSKIT_EXTERN_STRING   NDDeviceUUIDKey;
MSKIT_EXTERN_STRING   NDDeviceURLKey;

@interface NetworkDevice : NSManagedObject

+ (instancetype)deviceInContext:(NSManagedObjectContext *)context;

+ (instancetype)deviceWithAttributes:(NSDictionary *)attributes
                             context:(NSManagedObjectContext *)context;

+ (instancetype)fetchDeviceWithUUID:(NSString *)uuid context:(NSManagedObjectContext *)context;

+ (NSArray *)fetchAllInContext:(NSManagedObjectContext *)context;

+ (BOOL)deviceExistsWithUUID:(NSString *)uuid;

@property (nonatomic, readonly) NSString * uuid;
@property (nonatomic, copy) 		NSString * make;
@property (nonatomic, copy)  	NSString * model;
@property (nonatomic, copy)  	NSString * status;
@property (nonatomic, copy)  	NSString * configURL;
@property (nonatomic, copy)  	NSString * revision;

@end

// constants
MSKIT_EXTERN_STRING   NDiTachDeviceMulticastGroupAddress;
MSKIT_EXTERN_STRING   NDiTachDeviceMulticastGroupPort;
MSKIT_EXTERN_STRING   NDiTachDeviceTCPPort;

// keys
MSKIT_EXTERN_STRING   NDiTachDevicePCBKey;
MSKIT_EXTERN_STRING   NDiTachDevicePkgKey;
MSKIT_EXTERN_STRING   NDiTachDeviceSDKKey;

@interface NDiTachDevice : NetworkDevice

@property (nonatomic, strong) NSString * pcb_pn;
@property (nonatomic, strong) NSString * pkg_level;
@property (nonatomic, strong) NSString * sdkClass;

@end
