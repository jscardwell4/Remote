//
// MacroBuilder.m
// Remote
//
// Created by Jason Cardwell on 10/12/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteConstruction.h"

@implementation REMacroBuilder

+ (REMacroCommand *)activityMacroForActivity:(NSUInteger)activity
                             toInitiateState:(BOOL)isOnState
                                 switchIndex:(NSInteger *)switchIndex
{
    REMacroCommand * macroCommand = nil;
    switch (activity)
    {
        case 1:
            macroCommand = [self dvrActivityMacroToInitiateState:isOnState
                                                     switchIndex:switchIndex];
            break;

        case 2:
            macroCommand = [self ps3ActivityMacroToInitiateState:isOnState
                                                     switchIndex:switchIndex];
            break;

        case 3:
            macroCommand = [self appleTVActivityMacroToInitiateState:isOnState
                                                         switchIndex:switchIndex];
            break;

        case 4:
            macroCommand = [self sonosActivityMacroToInitiateState:isOnState
                                                       switchIndex:switchIndex];
            break;

        default:
            break;
    }
    return macroCommand;
}

+ (REMacroCommand *)dvrActivityMacroToInitiateState:(BOOL)isOnState
                                        switchIndex:(NSInteger *)switchIndex
{
    NSManagedObjectContext * context      = [NSManagedObjectContext MR_contextForCurrentThread];
    REMacroCommand         * macroCommand = nil;
    // Macro sequence: A/V Power -> TV Power
    macroCommand = [REMacroCommand commandInContext:context];
    BOComponentDevice * avReceiver = [BOComponentDevice   fetchDeviceWithName:@"AV Receiver"
                                                                      context:context];
    BOComponentDevice * samsungTV = [BOComponentDevice    fetchDeviceWithName:@"Samsung TV"
                                                                      context:context];

    if (isOnState)
    {
        [macroCommand addCommandsObject:MakeIRCommand(avReceiver, @"TV/SAT")];
        [macroCommand addCommandsObject:MakePowerOnCommand(samsungTV)];
        [macroCommand addCommandsObject:MakeDelayCommand(6.0)];
        [macroCommand addCommandsObject:MakeIRCommand(samsungTV, @"HDMI 4")];
        [macroCommand addCommandsObject:MakeSwitchCommand(@"activity1")];

        if (switchIndex != NULL) *switchIndex = 4;
    }

    else
    {
        [macroCommand addCommandsObject:MakePowerOffCommand(avReceiver)];
        [macroCommand addCommandsObject:MakePowerOffCommand(samsungTV)];
        [macroCommand addCommandsObject:MakeSwitchCommand(MSRemoteControllerHomeRemoteKeyName)];
        if (switchIndex != NULL) *switchIndex = 2;
    }

    return macroCommand;
}

+ (REMacroCommand *)appleTVActivityMacroToInitiateState:(BOOL)isOnState
                                            switchIndex:(NSInteger *)switchIndex
{
    NSManagedObjectContext * context = [NSManagedObjectContext MR_contextForCurrentThread];
    REMacroCommand * macroCommand = nil;
    // Macro sequence: A/V Power -> TV Power
    macroCommand = [REMacroCommand commandInContext:context];
    BOComponentDevice * avReceiver = [BOComponentDevice   fetchDeviceWithName:@"AV Receiver"
                                                                      context:context];
    BOComponentDevice * samsungTV = [BOComponentDevice fetchDeviceWithName:@"Samsung TV"
                                                                   context:context];

    if (isOnState)
    {
        [macroCommand addCommandsObject:MakeIRCommand(avReceiver, @"DVD")];
        [macroCommand addCommandsObject:MakePowerOnCommand(samsungTV)];
        [macroCommand addCommandsObject:MakeDelayCommand(6.0)];
        [macroCommand addCommandsObject:MakeIRCommand(samsungTV, @"HDMI 2")];

        if (switchIndex != NULL) *switchIndex = -2;
    }

    else
    {
        [macroCommand addCommandsObject:MakePowerOffCommand(avReceiver)];
        [macroCommand addCommandsObject:MakePowerOffCommand(samsungTV)];
        [macroCommand addCommandsObject:MakeSwitchCommand(MSRemoteControllerHomeRemoteKeyName)];

        if (switchIndex != NULL) *switchIndex = 2;
    }

    return macroCommand;
}

+ (REMacroCommand *)sonosActivityMacroToInitiateState:(BOOL)isOnState
                                          switchIndex:(NSInteger *)switchIndex
{
    NSManagedObjectContext * context = [NSManagedObjectContext MR_contextForCurrentThread];
    REMacroCommand * macroCommand = nil;
    // Macro sequence: A/V Power -> TV Power
    macroCommand = [REMacroCommand commandInContext:context];
    BOComponentDevice * avReceiver = [BOComponentDevice   fetchDeviceWithName:@"AV Receiver"
                                                                      context:context];

    if (isOnState)
    {
        [macroCommand addCommandsObject:MakeIRCommand(avReceiver, @"MD/Tape")];
        [macroCommand addCommandsObject:MakeSwitchCommand(@"activity4")];

        if (switchIndex != NULL) *switchIndex = 1;
    }

    else
    {
        [macroCommand addCommandsObject:MakePowerOffCommand(avReceiver)];
        [macroCommand addCommandsObject:MakeSwitchCommand(MSRemoteControllerHomeRemoteKeyName)];

        if (switchIndex != NULL) *switchIndex = 1;
    }

    return macroCommand;
}

+ (REMacroCommand *)ps3ActivityMacroToInitiateState:(BOOL)isOnState
                                        switchIndex:(NSInteger *)switchIndex
{
    NSManagedObjectContext * context = [NSManagedObjectContext MR_contextForCurrentThread];
    REMacroCommand * macroCommand = nil;
    // Macro sequence: A/V Power -> TV Power
    macroCommand = [REMacroCommand commandInContext:context];
    BOComponentDevice * avReceiver = [BOComponentDevice   fetchDeviceWithName:@"AV Receiver"
                                                                      context:context];
    BOComponentDevice * ps3 = [BOComponentDevice fetchDeviceWithName:@"PS3"
                                                             context:context];
    BOComponentDevice * samsungTV = [BOComponentDevice fetchDeviceWithName:@"Samsung TV"
                                                                   context:context];

    if (isOnState)
    {
        [macroCommand addCommandsObject:MakeIRCommand(avReceiver, @"Video 2")];
        [macroCommand addCommandsObject:MakePowerOnCommand(samsungTV)];
        [macroCommand addCommandsObject:MakeDelayCommand(6.0)];
        [macroCommand addCommandsObject:MakeIRCommand(samsungTV, @"HDMI 3")];
        [macroCommand addCommandsObject:MakePowerOnCommand(ps3)];
        [macroCommand addCommandsObject:MakeSwitchCommand(@"activity2")];

        if (switchIndex != NULL) *switchIndex = 5;
    }

    else
    {
        [macroCommand addCommandsObject:MakePowerOffCommand(samsungTV)];
        [macroCommand addCommandsObject:MakePowerOffCommand(avReceiver)];
        [macroCommand addCommandsObject:MakeSwitchCommand(MSRemoteControllerHomeRemoteKeyName)];

        if (switchIndex != NULL) *switchIndex = 2;
    }

    return macroCommand;
}

+ (NSSet *)deviceConfigsForActivity:(NSUInteger)activity
{
    NSManagedObjectContext * context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSSet             * configs    = nil;
    BOComponentDevice * avReceiver = [BOComponentDevice fetchDeviceWithName:@"AV Receiver"
                                                                    context:context];
    BOComponentDevice * samsungTV = [BOComponentDevice  fetchDeviceWithName:@"Samsung TV"
                                                                    context:context];

    NSDictionary * receiverConfigSettings = @{ REDeviceConfigurationPowerStateKey : @(NO) };

    REDeviceConfiguration * receiverConfig = [REDeviceConfiguration
                                              configurationForDevice:avReceiver
                                                            settings:receiverConfigSettings];

    NSDictionary          * tvOffConfigSettings = @{ REDeviceConfigurationPowerStateKey : @(NO) };
    REDeviceConfiguration * tvOffConfig         = [REDeviceConfiguration
                                           configurationForDevice:samsungTV
                                                         settings:tvOffConfigSettings];

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
