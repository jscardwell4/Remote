//
// ComponentDeviceConfiguration.h
// Remote
//
// Created by Jason Cardwell on 3/16/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "ModelObject.h"
#import "BOTypedefs.h"

MSKIT_EXTERN_STRING   REDeviceConfigurationInputKey;
MSKIT_EXTERN_STRING   REDeviceConfigurationPowerStateKey;

@class ComponentDevice, IRCode;

@interface ComponentDeviceConfiguration : ModelObject

+ (ComponentDeviceConfiguration *)configurationForDevice:(ComponentDevice *)device
                                         settings:(NSDictionary *)settings;

@property (nonatomic) BOPowerState                powerState;
@property (nonatomic, strong) ComponentDevice * device;
@property (nonatomic, strong) IRCode          * input;

@end
