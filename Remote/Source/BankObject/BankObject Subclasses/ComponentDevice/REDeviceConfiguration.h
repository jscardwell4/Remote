//
// REDeviceConfiguration.h
// Remote
//
// Created by Jason Cardwell on 3/16/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "BOTypedefs.h"

MSKIT_EXTERN_STRING   REDeviceConfigurationInputKey;
MSKIT_EXTERN_STRING   REDeviceConfigurationPowerStateKey;

@class BOComponentDevice, BOIRCode;

@interface REDeviceConfiguration : NSManagedObject

+ (REDeviceConfiguration *)configurationForDevice:(BOComponentDevice *)device
                                         settings:(NSDictionary *)settings;

@property (nonatomic) BOPowerState                powerState;
@property (nonatomic, strong) BOComponentDevice * device;
@property (nonatomic, strong) BOIRCode          * input;

@end
