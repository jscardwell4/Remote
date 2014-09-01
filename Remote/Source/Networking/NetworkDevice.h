//
// NetworkDevice.h
// Remote
//
// Created by Jason Cardwell on 9/25/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "NamedModelObject.h"

// keys
MSEXTERN_KEY(NDDeviceMake);
MSEXTERN_KEY(NDModel);
MSEXTERN_KEY(NDDeviceRevision);
MSEXTERN_KEY(NDDeviceStatus);
MSEXTERN_KEY(NDDeviceUUID);
MSEXTERN_KEY(NDDeviceURL);

@interface NetworkDevice : NamedModelObject

+ (instancetype)device;
+ (instancetype)deviceInContext:(NSManagedObjectContext *)context;
+ (instancetype)deviceWithAttributes:(NSDictionary *)attributes;
+ (instancetype)deviceWithAttributes:(NSDictionary *)attributes
                             context:(NSManagedObjectContext *)context;

+ (BOOL)deviceExistsWithDeviceUUID:(NSString *)deviceUUID;

@property (nonatomic, strong) NSSet            * componentDevices;
@property (nonatomic, copy, readonly) NSString * deviceUUID;
@property (nonatomic, copy, readonly) NSString * make;
@property (nonatomic, copy, readonly) NSString * model;
@property (nonatomic, copy, readonly) NSString * status;
@property (nonatomic, copy, readonly) NSString * configURL;
@property (nonatomic, copy, readonly) NSString * revision;

@end

// constants
MSEXTERN_STRING NDiTachDeviceMulticastGroupAddress;
MSEXTERN_STRING NDiTachDeviceMulticastGroupPort;
MSEXTERN_STRING NDiTachDeviceTCPPort;

// keys
MSEXTERN_KEY(NDiTachDevicePCB);
MSEXTERN_KEY(NDiTachDevicePkg);
MSEXTERN_KEY(NDiTachDeviceSDK);

@interface NDiTachDevice : NetworkDevice

@property (nonatomic, strong) NSString * pcb_pn;
@property (nonatomic, strong) NSString * pkg_level;
@property (nonatomic, strong) NSString * sdkClass;

@end
