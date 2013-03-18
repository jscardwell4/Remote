//
// MacroBuilder.m
// Remote
//
// Created by Jason Cardwell on 10/12/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteConstruction.h"
#import "MacroBuilder.h"
#import "Command.h"
#import "RERemoteController.h"
#import "DeviceConfiguration.h"
#import "RemoteBuilder.h"

@implementation MacroBuilder
+ (MacroBuilder *)macroBuilderWithContext:(NSManagedObjectContext *)context {
    MacroBuilder * mb = [self new];

    mb.buildContext = context;

    return mb;
}

- (MacroCommand *)activityMacroForActivity:(NSUInteger)activity
                           toInitiateState:(BOOL)isOnState
                               switchIndex:(NSInteger *)switchIndex {
    MacroCommand * macro = nil;

    switch (activity) {
        case 1 :
            macro = [self dvrActivityMacroToInitiateState:isOnState switchIndex:switchIndex];
            break;

        case 2 :
            macro = [self ps3ActivityMacroToInitiateState:isOnState switchIndex:switchIndex];
            break;

        case 3 :
            macro = [self appleTVActivityMacroToInitiateState:isOnState switchIndex:switchIndex];
            break;

        case 4 :
            macro = [self sonosActivityMacroToInitiateState:isOnState switchIndex:switchIndex];
            break;

        default :
            break;
    }  /* switch */

    return macro;
}

- (MacroCommand *)dvrActivityMacroToInitiateState:(BOOL)isOnState
                                      switchIndex:(NSInteger *)switchIndex {
    // Macro sequence: A/V Power -> TV Power
    MacroCommand    * macroCommand = [MacroCommand macroCommandInContext:self.buildContext];
    ComponentDevice * avReceiver   = [ComponentDevice fetchComponentDeviceWithName:@"AV Receiver" inContext:self.buildContext];
    ComponentDevice * samsungTV    = [ComponentDevice fetchComponentDeviceWithName:@"Samsung TV" inContext:self.buildContext];

    if (isOnState) {
        [macroCommand addCommand:MakeIRCommand(avReceiver, @"TV/SAT")];
        [macroCommand addCommand:MakePowerCommand(samsungTV, ComponentDevicePowerOn)];
        [macroCommand addCommand:MakeDelayCommand(6.0)];
        [macroCommand addCommand:MakeIRCommand(samsungTV, @"HDMI 4")];
        [macroCommand addCommand:MakeSwitchCommand(@"activity1")];

        if (switchIndex != NULL) *switchIndex = 4;
    } else {
        [macroCommand addCommand:MakePowerCommand(avReceiver, ComponentDevicePowerOff)];
        [macroCommand addCommand:MakePowerCommand(samsungTV, ComponentDevicePowerOff)];
        [macroCommand addCommand:MakeSwitchCommand(MSRemoteControllerHomeRemoteKeyName)];
        if (switchIndex != NULL) *switchIndex = 2;
    }

    return macroCommand;
}

- (MacroCommand *)appleTVActivityMacroToInitiateState:(BOOL)isOnState
                                          switchIndex:(NSInteger *)switchIndex {
    // Macro sequence: A/V Power -> TV Power
    MacroCommand    * macroCommand = [MacroCommand macroCommandInContext:self.buildContext];
    ComponentDevice * avReceiver   = [ComponentDevice fetchComponentDeviceWithName:@"AV Receiver" inContext:self.buildContext];
    ComponentDevice * samsungTV    = [ComponentDevice fetchComponentDeviceWithName:@"Samsung TV" inContext:self.buildContext];

    if (isOnState) {
        [macroCommand addCommand:MakeIRCommand(avReceiver, @"DVD")];
        [macroCommand addCommand:MakePowerCommand(samsungTV, ComponentDevicePowerOn)];
        [macroCommand addCommand:MakeDelayCommand(6.0)];
        [macroCommand addCommand:MakeIRCommand(samsungTV, @"HDMI 2")];
        if (switchIndex != NULL) *switchIndex = -2;
    } else {
        [macroCommand addCommand:MakePowerCommand(avReceiver, ComponentDevicePowerOff)];
        [macroCommand addCommand:MakePowerCommand(samsungTV, ComponentDevicePowerOff)];
        [macroCommand addCommand:MakeSwitchCommand(MSRemoteControllerHomeRemoteKeyName)];
        if (switchIndex != NULL) *switchIndex = 2;
    }

    return macroCommand;
}

- (MacroCommand *)sonosActivityMacroToInitiateState:(BOOL)isOnState
                                        switchIndex:(NSInteger *)switchIndex {
    // Macro sequence: A/V Power -> TV Power
    MacroCommand    * macroCommand = [MacroCommand macroCommandInContext:self.buildContext];
    ComponentDevice * avReceiver   = [ComponentDevice fetchComponentDeviceWithName:@"AV Receiver" inContext:self.buildContext];

    if (isOnState) {
        [macroCommand addCommand:MakeIRCommand(avReceiver, @"MD/Tape")];
        [macroCommand addCommand:MakeSwitchCommand(@"activity4")];
        if (switchIndex != NULL) *switchIndex = 1;
    } else {
        [macroCommand addCommand:MakePowerCommand(avReceiver, ComponentDevicePowerOff)];
        [macroCommand addCommand:MakeSwitchCommand(MSRemoteControllerHomeRemoteKeyName)];
        if (switchIndex != NULL) *switchIndex = 1;
    }

    return macroCommand;
}

- (MacroCommand *)ps3ActivityMacroToInitiateState:(BOOL)isOnState
                                      switchIndex:(NSInteger *)switchIndex {
    // Macro sequence: A/V Power -> TV Power
    MacroCommand    * macroCommand = [MacroCommand macroCommandInContext:self.buildContext];
    ComponentDevice * avReceiver   = [ComponentDevice fetchComponentDeviceWithName:@"AV Receiver" inContext:self.buildContext];
    ComponentDevice * ps3          = [ComponentDevice fetchComponentDeviceWithName:@"PS3" inContext:self.buildContext];
    ComponentDevice * samsungTV    = [ComponentDevice fetchComponentDeviceWithName:@"Samsung TV" inContext:self.buildContext];

    if (isOnState) {
        [macroCommand addCommand:MakeIRCommand(avReceiver, @"Video 2")];
        [macroCommand addCommand:MakePowerCommand(samsungTV, ComponentDevicePowerOn)];
        [macroCommand addCommand:MakeDelayCommand(6.0)];
        [macroCommand addCommand:MakeIRCommand(samsungTV, @"HDMI 3")];
        [macroCommand addCommand:MakePowerCommand(ps3, ComponentDevicePowerOn)];
        [macroCommand addCommand:MakeSwitchCommand(@"activity2")];
        if (switchIndex != NULL) *switchIndex = 5;
    } else {
        [macroCommand addCommand:MakePowerCommand(samsungTV, ComponentDevicePowerOff)];
        [macroCommand addCommand:MakePowerCommand(avReceiver, ComponentDevicePowerOff)];
        [macroCommand addCommand:MakeSwitchCommand(MSRemoteControllerHomeRemoteKeyName)];
        if (switchIndex != NULL) *switchIndex = 2;
    }

    return macroCommand;
}

- (NSSet *)deviceConfigsForActivity:(NSUInteger)activity {
    NSSet           * setOfConfigs           = nil;
    ComponentDevice * avReceiver             = [ComponentDevice fetchComponentDeviceWithName:@"AV Receiver" inContext:self.buildContext];
    ComponentDevice * samsungTV              = [ComponentDevice fetchComponentDeviceWithName:@"Samsung TV" inContext:self.buildContext];
    NSDictionary    * receiverConfigSettings = @{
        kDeviceConfigurationPowerStateKey : @(ComponentDevicePowerOff)
    };
    DeviceConfiguration * receiverConfig =
        [DeviceConfiguration newDeviceConfigurationForDevice:avReceiver
                                                withSettings:receiverConfigSettings];
    NSDictionary * tvOffConfigSettings = @{
        kDeviceConfigurationPowerStateKey : @(ComponentDevicePowerOff)
    };
    DeviceConfiguration * tvOffConfig =
        [DeviceConfiguration newDeviceConfigurationForDevice:samsungTV
                                                withSettings:tvOffConfigSettings];

    switch (activity) {
        case 1 :  // dvr
        case 2 :  // samsung
        case 3 :  // ps3
            setOfConfigs = [NSSet setWithObjects:receiverConfig, tvOffConfig, nil];
            break;

        case 4 :
            // sonos
            setOfConfigs = [NSSet setWithObject:receiverConfig];

        default :
            break;
    }

    return setOfConfigs;
}

@end
