//
// ComponentDeviceConfiguration.m
// Remote
//
// Created by Jason Cardwell on 3/16/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "ComponentDeviceConfiguration.h"
#import "BankObjects.h"

MSKIT_STRING_CONST   REDeviceConfigurationInputKey      = @"REDeviceConfigurationInputKey";
MSKIT_STRING_CONST   REDeviceConfigurationPowerStateKey = @"REDeviceConfigurationPowerStateKey";

@interface ComponentDeviceConfiguration (CoreDataGeneratedAccessors)

@property (nonatomic) NSNumber * primitivePowerState;
@property (nonatomic) IRCode * primitiveInput;

@end

@implementation ComponentDeviceConfiguration

@dynamic powerState, device, input;

+ (ComponentDeviceConfiguration *)configurationForDevice:(ComponentDevice *)device
                                         settings:(NSDictionary *)settings
{
    assert(device);

    __block ComponentDeviceConfiguration * config = nil;
    [device.managedObjectContext performBlockAndWait:
     ^{
         config = NSManagedObjectFromClass(device.managedObjectContext);
         config.device = device;

         if (settings)
         {
             config.primitivePowerState = settings[REDeviceConfigurationPowerStateKey];
             
             id   inputValue = settings[REDeviceConfigurationInputKey];

             if (   [inputValue isMemberOfClass:[IRCode class]]
                 && ((IRCode *)inputValue).device == device)
                 config.input = inputValue;
         }
     }];

    return config;
}

@end
