//
// DeviceConfiguration.m
// iPhonto
//
// Created by Jason Cardwell on 3/16/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "DeviceConfiguration.h"
#import "ComponentDevice.h"
#import "IRCode.h"

MSKIT_STRING_CONST   kDeviceConfigurationInputKey      = @"kDeviceConfigurationInputKey";
MSKIT_STRING_CONST   kDeviceConfigurationPowerStateKey = @"kDeviceConfigurationPowerStateKey";
static int         ddLogLevel                        = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@implementation DeviceConfiguration

@dynamic powerState;
@dynamic device;
@dynamic input;

+ (DeviceConfiguration *)newDeviceConfigurationForDevice:(ComponentDevice *)componentDevice
                                            withSettings:(NSDictionary *)settings {
    if (ValueIsNil(componentDevice)) return nil;

    DeviceConfiguration * config =
        [NSEntityDescription insertNewObjectForEntityForName:@"DeviceConfiguration"
                                      inManagedObjectContext:componentDevice.managedObjectContext];

    config.device = componentDevice;

    if (ValueIsNotNil(settings)) {
        // process power state
        NSNumber * powerStateValue = settings[kDeviceConfigurationPowerStateKey];

        if (ValueIsNotNil(powerStateValue)) {
            int16_t   ps = [powerStateValue intValue];

            if (ps == ComponentDevicePowerOn || ps == ComponentDevicePowerOff) config.powerState = ps;
        }

        // process input
        id   inputValue = settings[kDeviceConfigurationInputKey];

        if (ValueIsNotNil(inputValue) && [inputValue isMemberOfClass:[IRCode class]]) {
            IRCode * code = (IRCode *)inputValue;

            if (code.device == componentDevice) config.input = code;
        }
    }

    return config;
}

@end
