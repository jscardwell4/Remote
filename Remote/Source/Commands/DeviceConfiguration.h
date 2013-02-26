//
// DeviceConfiguration.h
// iPhonto
//
// Created by Jason Cardwell on 3/16/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
@class                ComponentDevice, IRCode;
MSKIT_EXTERN_STRING   kDeviceConfigurationInputKey;
MSKIT_EXTERN_STRING   kDeviceConfigurationPowerStateKey;

@interface DeviceConfiguration : NSManagedObject

+ (DeviceConfiguration *)newDeviceConfigurationForDevice:(ComponentDevice *)componentDevice
                                            withSettings:(NSDictionary *)settings;

@property (nonatomic) int16_t                   powerState;
@property (nonatomic, strong) ComponentDevice * device;
@property (nonatomic, strong) IRCode          * input;

@end
