//
// DeviceConfiguration.m
// Remote
//
// Created by Jason Cardwell on 3/16/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "REDeviceConfiguration.h"
#import "BankObjects.h"

MSKIT_STRING_CONST   REDeviceConfigurationInputKey      = @"REDeviceConfigurationInputKey";
MSKIT_STRING_CONST   REDeviceConfigurationPowerStateKey = @"REDeviceConfigurationPowerStateKey";

@interface REDeviceConfiguration (CoreDataGeneratedAccessors)

@property (nonatomic) NSNumber * primitivePowerState;
@property (nonatomic) BOIRCode * primitiveInput;

@end

@implementation REDeviceConfiguration

@dynamic powerState, device, input;

+ (REDeviceConfiguration *)configurationForDevice:(BOComponentDevice *)device
                                         settings:(NSDictionary *)settings
{
    assert(device);

    __block REDeviceConfiguration * config = nil;
    [device.managedObjectContext performBlockAndWait:
     ^{
         config = NSManagedObjectFromClass(device.managedObjectContext);
         config.device = device;

         if (settings)
         {
             config.primitivePowerState = settings[REDeviceConfigurationPowerStateKey];
             
             id   inputValue = settings[REDeviceConfigurationInputKey];

             if (   [inputValue isMemberOfClass:[BOIRCode class]]
                 && ((BOIRCode *)inputValue).device == device)
                 config.input = inputValue;
         }
     }];

    return config;
}

@end
