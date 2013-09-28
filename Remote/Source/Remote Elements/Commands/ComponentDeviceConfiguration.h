//
// ComponentDeviceConfiguration.h
// Remote
//
// Created by Jason Cardwell on 3/16/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "ModelObject.h"

MSEXTERN_STRING   REDeviceConfigurationInputKey;
MSEXTERN_STRING   REDeviceConfigurationPowerStateKey;

@class ComponentDevice, IRCode;

@interface ComponentDeviceConfiguration : ModelObject

+ (ComponentDeviceConfiguration *)configurationForDevice:(ComponentDevice *)device
                                         settings:(NSDictionary *)settings;

@property (nonatomic) BOOL                powerState;
@property (nonatomic, strong) ComponentDevice * device;
@property (nonatomic, strong) IRCode          * input;

@end
