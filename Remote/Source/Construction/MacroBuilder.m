//
// MacroBuilder.m
// Remote
//
// Created by Jason Cardwell on 10/12/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteConstruction.h"

@implementation MacroBuilder @end

@implementation MacroBuilder (Developer)

+ (MacroCommand *)activityMacroForActivity:(NSUInteger)activity
                             toInitiateState:(BOOL)isOnState
                                     context:(NSManagedObjectContext *)moc
{
    MacroCommand * macroCommand = nil;
    switch (activity)
    {
        case 1:
            macroCommand = [self hopperActivityMacroToInitiateState:isOnState context:moc];
            break;

        case 2:
            macroCommand = [self ps3ActivityMacroToInitiateState:isOnState context:moc];
            break;

        case 3:
            macroCommand = [self appleTVActivityMacroToInitiateState:isOnState context:moc];
            break;

        case 4:
            macroCommand = [self sonosActivityMacroToInitiateState:isOnState context:moc];
            break;

        default:
            break;
    }
    return macroCommand;
}

+ (MacroCommand *)hopperActivityMacroToInitiateState:(BOOL)isOnState
                                            context:(NSManagedObjectContext *)moc
{
    // Macro sequence: A/V Power -> TV Power
    MacroCommand * macroCommand = [MacroCommand commandInContext:moc];

    ComponentDevice * avReceiver = [ComponentDevice fetchDeviceWithName:@"AV Receiver"
                                                                    context:moc];
    ComponentDevice * samsungTV  = [ComponentDevice fetchDeviceWithName:@"Samsung TV"
                                                                    context:moc];

    if (isOnState)
    {
        [macroCommand addCommandsObject:[SendIRCommand commandWithIRCode:avReceiver[@"TV/SAT"]]];
        [macroCommand addCommandsObject:[PowerCommand  onCommandForDevice:samsungTV]];
        [macroCommand addCommandsObject:[DelayCommand  commandInContext:moc duration:6.0]];
        [macroCommand addCommandsObject:[SendIRCommand commandWithIRCode:samsungTV[@"HDMI 4"]]];
    }

    else
    {
        [macroCommand addCommandsObject:[PowerCommand offCommandForDevice:avReceiver]];
        [macroCommand addCommandsObject:[PowerCommand offCommandForDevice:samsungTV]];
    }

    return macroCommand;
}

+ (MacroCommand *)appleTVActivityMacroToInitiateState:(BOOL)isOnState
                                                context:(NSManagedObjectContext *)moc
{
    // Macro sequence: A/V Power -> TV Power
    MacroCommand * macroCommand = [MacroCommand commandInContext:moc];

    ComponentDevice * avReceiver = [ComponentDevice fetchDeviceWithName:@"AV Receiver"
                                                                    context:moc];
    ComponentDevice * samsungTV  = [ComponentDevice fetchDeviceWithName:@"Samsung TV"
                                                                    context:moc];

    if (isOnState)
    {
        [macroCommand addCommandsObject:[SendIRCommand commandWithIRCode:avReceiver[@"DVD"]]];
        [macroCommand addCommandsObject:[PowerCommand  onCommandForDevice:samsungTV]];
        [macroCommand addCommandsObject:[DelayCommand  commandInContext:moc duration:6.0]];
        [macroCommand addCommandsObject:[SendIRCommand commandWithIRCode:samsungTV[@"HDMI 2"]]];
    }

    else
    {
        [macroCommand addCommandsObject:[PowerCommand offCommandForDevice:avReceiver]];
        [macroCommand addCommandsObject:[PowerCommand offCommandForDevice:samsungTV]];
    }

    return macroCommand;
}

+ (MacroCommand *)sonosActivityMacroToInitiateState:(BOOL)isOnState
                                              context:(NSManagedObjectContext *)moc
{
    // Macro sequence: A/V Power -> TV Power
    MacroCommand * macroCommand = [MacroCommand commandInContext:moc];

    ComponentDevice * avReceiver = [ComponentDevice fetchDeviceWithName:@"AV Receiver"
                                                                    context:moc];

    if (isOnState)
    {
        [macroCommand addCommandsObject:[SendIRCommand commandWithIRCode:avReceiver[@"MD/Tape"]]];

    }

    else
    {
        [macroCommand addCommandsObject:[PowerCommand offCommandForDevice:avReceiver]];

    }

    return macroCommand;
}

+ (MacroCommand *)ps3ActivityMacroToInitiateState:(BOOL)isOnState
                                            context:(NSManagedObjectContext *)moc
{
    // Macro sequence: A/V Power -> TV Power
    MacroCommand * macroCommand = [MacroCommand commandInContext:moc];

    ComponentDevice * avReceiver = [ComponentDevice fetchDeviceWithName:@"AV Receiver"
                                                                    context:moc];
    ComponentDevice * ps3        = [ComponentDevice fetchDeviceWithName:@"PS3"
                                                                    context:moc];
    ComponentDevice * samsungTV  = [ComponentDevice fetchDeviceWithName:@"Samsung TV"
                                                                    context:moc];

    if (isOnState)
    {
        [macroCommand addCommandsObject:[SendIRCommand commandWithIRCode:avReceiver[@"Video 2"]]];
        [macroCommand addCommandsObject:[PowerCommand onCommandForDevice:samsungTV]];
        [macroCommand addCommandsObject:[DelayCommand commandInContext:moc duration:6.0]];
        [macroCommand addCommandsObject:[SendIRCommand commandWithIRCode:samsungTV[@"HDMI 3"]]];
        [macroCommand addCommandsObject:[PowerCommand onCommandForDevice:ps3]];
    }

    else
    {
        [macroCommand addCommandsObject:[PowerCommand offCommandForDevice:samsungTV]];
        [macroCommand addCommandsObject:[PowerCommand offCommandForDevice:avReceiver]];
    }

    return macroCommand;
}

+ (NSSet *)deviceConfigsForActivity:(NSUInteger)activity context:(NSManagedObjectContext *)moc
{
    ComponentDevice * avReceiver = [ComponentDevice fetchDeviceWithName:@"AV Receiver"
                                                                    context:moc];
    ComponentDevice * samsungTV  = [ComponentDevice fetchDeviceWithName:@"Samsung TV"
                                                                    context:moc];

    NSDictionary * receiverConfigSettings = @{ REDeviceConfigurationPowerStateKey : @(NO) };

    ComponentDeviceConfiguration * receiverConfig = [ComponentDeviceConfiguration
                                              configurationForDevice:avReceiver
                                                            settings:receiverConfigSettings];

    NSDictionary          * tvOffConfigSettings = @{ REDeviceConfigurationPowerStateKey : @(NO) };
    ComponentDeviceConfiguration * tvOffConfig         = [ComponentDeviceConfiguration
                                                   configurationForDevice:samsungTV
                                                                 settings:tvOffConfigSettings];

    NSSet * configs = nil;

    switch (activity)
    {
        case 1:       // hopper
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
