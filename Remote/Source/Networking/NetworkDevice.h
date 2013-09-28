//
// NetworkDevice.h
// Remote
//
// Created by Jason Cardwell on 9/25/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "ModelObject.h"
// keys
MSEXTERN_STRING   NDDeviceMakeKey;
MSEXTERN_STRING   NDModelKey;
MSEXTERN_STRING   NDDeviceRevisionKey;
MSEXTERN_STRING   NDDeviceStatusKey;
MSEXTERN_STRING   NDDeviceUUIDKey;
MSEXTERN_STRING   NDDeviceURLKey;

@interface NetworkDevice : ModelObject <NamedModelObject>

+ (instancetype)device;
+ (instancetype)deviceInContext:(NSManagedObjectContext *)context;
+ (instancetype)deviceWithAttributes:(NSDictionary *)attributes;
+ (instancetype)deviceWithAttributes:(NSDictionary *)attributes
                             context:(NSManagedObjectContext *)context;

+ (BOOL)deviceExistsWithDeviceUUID:(NSString *)deviceUUID;

@property (nonatomic, copy, readonly ) NSString * deviceUUID;
@property (nonatomic, copy, readonly ) NSString * make;
@property (nonatomic, copy, readonly ) NSString * model;
@property (nonatomic, copy, readonly ) NSString * status;
@property (nonatomic, copy, readonly ) NSString * configURL;
@property (nonatomic, copy, readonly ) NSString * revision;
@property (nonatomic, copy, readwrite) NSString * name;

@end

// constants
MSEXTERN_STRING   NDiTachDeviceMulticastGroupAddress;
MSEXTERN_STRING   NDiTachDeviceMulticastGroupPort;
MSEXTERN_STRING   NDiTachDeviceTCPPort;

// keys
MSEXTERN_STRING   NDiTachDevicePCBKey;
MSEXTERN_STRING   NDiTachDevicePkgKey;
MSEXTERN_STRING   NDiTachDeviceSDKKey;

@interface NDiTachDevice : NetworkDevice

@property (nonatomic, strong) NSString * pcb_pn;
@property (nonatomic, strong) NSString * pkg_level;
@property (nonatomic, strong) NSString * sdkClass;

@end
