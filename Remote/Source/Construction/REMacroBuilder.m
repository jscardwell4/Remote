//
// MacroBuilder.m
// Remote
//
// Created by Jason Cardwell on 10/12/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteConstruction.h"

@implementation REMacroBuilder

+ (REMacroCommand *)activityMacroForActivity:(NSUInteger)activity toInitiateState:(BOOL)isOnState context:(NSManagedObjectContext *)context
{
    REMacroCommand * macroCommand = nil;
    switch (activity)
    {
        case 1:
            macroCommand = [self dvrActivityMacroToInitiateState:isOnState context:context];
            break;

        case 2:
            macroCommand = [self ps3ActivityMacroToInitiateState:isOnState context:context];
            break;

        case 3:
            macroCommand = [self appleTVActivityMacroToInitiateState:isOnState context:context];
            break;

        case 4:
            macroCommand = [self sonosActivityMacroToInitiateState:isOnState context:context];
            break;

        default:
            break;
    }
    return macroCommand;
}

+ (REMacroCommand *)dvrActivityMacroToInitiateState:(BOOL)isOnState context:(NSManagedObjectContext *)context
{
    // Macro sequence: A/V Power -> TV Power
    REMacroCommand * macroCommand = [REMacroCommand MR_createEntity];

    BOComponentDevice * avReceiver = [BOComponentDevice fetchDeviceWithName:@"AV Receiver"];
    BOComponentDevice * samsungTV  = [BOComponentDevice fetchDeviceWithName:@"Samsung TV"];

    if (isOnState)
    {
        [macroCommand addCommandsObject:MakeIRCommand(avReceiver, @"TV/SAT")];
        [macroCommand addCommandsObject:MakePowerOnCommand(samsungTV)];
        [macroCommand addCommandsObject:MakeDelayCommand(6.0)];
        [macroCommand addCommandsObject:MakeIRCommand(samsungTV, @"HDMI 4")];
    }

    else
    {
        [macroCommand addCommandsObject:MakePowerOffCommand(avReceiver)];
        [macroCommand addCommandsObject:MakePowerOffCommand(samsungTV)];
    }

    return macroCommand;
}

+ (REMacroCommand *)appleTVActivityMacroToInitiateState:(BOOL)isOnState context:(NSManagedObjectContext *)context
{
    // Macro sequence: A/V Power -> TV Power
    REMacroCommand * macroCommand = [REMacroCommand MR_createEntity];

    BOComponentDevice * avReceiver = [BOComponentDevice fetchDeviceWithName:@"AV Receiver"];
    BOComponentDevice * samsungTV  = [BOComponentDevice fetchDeviceWithName:@"Samsung TV"];

    if (isOnState)
    {
        [macroCommand addCommandsObject:MakeIRCommand(avReceiver, @"DVD")];
        [macroCommand addCommandsObject:MakePowerOnCommand(samsungTV)];
        [macroCommand addCommandsObject:MakeDelayCommand(6.0)];
        [macroCommand addCommandsObject:MakeIRCommand(samsungTV, @"HDMI 2")];
    }

    else
    {
        [macroCommand addCommandsObject:MakePowerOffCommand(avReceiver)];
        [macroCommand addCommandsObject:MakePowerOffCommand(samsungTV)];
    }

    return macroCommand;
}

+ (REMacroCommand *)sonosActivityMacroToInitiateState:(BOOL)isOnState context:(NSManagedObjectContext *)context
{
    // Macro sequence: A/V Power -> TV Power
    REMacroCommand * macroCommand = [REMacroCommand MR_createEntity];

    BOComponentDevice * avReceiver = [BOComponentDevice fetchDeviceWithName:@"AV Receiver"];

    if (isOnState)
    {
        [macroCommand addCommandsObject:MakeIRCommand(avReceiver, @"MD/Tape")];

    }

    else
    {
        [macroCommand addCommandsObject:MakePowerOffCommand(avReceiver)];

    }

    return macroCommand;
}

+ (REMacroCommand *)ps3ActivityMacroToInitiateState:(BOOL)isOnState context:(NSManagedObjectContext *)context
{
    // Macro sequence: A/V Power -> TV Power
    REMacroCommand * macroCommand = [REMacroCommand MR_createEntity];

    BOComponentDevice * avReceiver = [BOComponentDevice fetchDeviceWithName:@"AV Receiver"];
    BOComponentDevice * ps3        = [BOComponentDevice fetchDeviceWithName:@"PS3"];
    BOComponentDevice * samsungTV  = [BOComponentDevice fetchDeviceWithName:@"Samsung TV"];

    if (isOnState)
    {
        [macroCommand addCommandsObject:MakeIRCommand(avReceiver, @"Video 2")];
        [macroCommand addCommandsObject:MakePowerOnCommand(samsungTV)];
        [macroCommand addCommandsObject:MakeDelayCommand(6.0)];
        [macroCommand addCommandsObject:MakeIRCommand(samsungTV, @"HDMI 3")];
        [macroCommand addCommandsObject:MakePowerOnCommand(ps3)];
    }

    else
    {
        [macroCommand addCommandsObject:MakePowerOffCommand(samsungTV)];
        [macroCommand addCommandsObject:MakePowerOffCommand(avReceiver)];
    }

    return macroCommand;
}

+ (NSSet *)deviceConfigsForActivity:(NSUInteger)activity context:(NSManagedObjectContext *)context
{
    BOComponentDevice * avReceiver = [BOComponentDevice fetchDeviceWithName:@"AV Receiver"];
    BOComponentDevice * samsungTV  = [BOComponentDevice fetchDeviceWithName:@"Samsung TV"];

    NSDictionary * receiverConfigSettings = @{ REDeviceConfigurationPowerStateKey : @(NO) };

    REDeviceConfiguration * receiverConfig = [REDeviceConfiguration
                                              configurationForDevice:avReceiver
                                                            settings:receiverConfigSettings];

    NSDictionary          * tvOffConfigSettings = @{ REDeviceConfigurationPowerStateKey : @(NO) };
    REDeviceConfiguration * tvOffConfig         = [REDeviceConfiguration
                                                   configurationForDevice:samsungTV
                                                                 settings:tvOffConfigSettings];

    NSSet * configs = nil;

    switch (activity)
    {
        case 1:       // dvr
        case 2:       // samsung
        case 3:       // ps3
            configs = [NSSet setWithObjects:receiverConfig, tvOffConfig, nil]; break;

        case 4:
            // sonos
            configs = [NSSet setWithObject:receiverConfig]; break;

        default: break;
    }
    return configs;
}

@end
