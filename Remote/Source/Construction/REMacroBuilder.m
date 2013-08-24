//
// MacroBuilder.m
// Remote
//
// Created by Jason Cardwell on 10/12/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteConstruction.h"

@implementation REMacroBuilder @end

@implementation REMacroBuilder (Developer)

+ (REMacroCommand *)activityMacroForActivity:(NSUInteger)activity
                             toInitiateState:(BOOL)isOnState
                                     context:(NSManagedObjectContext *)moc
{
    REMacroCommand * macroCommand = nil;
    switch (activity)
    {
        case 1:
            macroCommand = [self dvrActivityMacroToInitiateState:isOnState context:moc];
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

+ (REMacroCommand *)dvrActivityMacroToInitiateState:(BOOL)isOnState
                                            context:(NSManagedObjectContext *)moc
{
    // Macro sequence: A/V Power -> TV Power
    REMacroCommand * macroCommand = [REMacroCommand commandInContext:moc];

    BOComponentDevice * avReceiver = [BOComponentDevice fetchDeviceWithName:@"AV Receiver"
                                                                    context:moc];
    BOComponentDevice * samsungTV  = [BOComponentDevice fetchDeviceWithName:@"Samsung TV"
                                                                    context:moc];

    if (isOnState)
    {
        [macroCommand addCommandsObject:[RESendIRCommand commandWithIRCode:avReceiver[@"TV/SAT"]]];
        [macroCommand addCommandsObject:[REPowerCommand  onCommandForDevice:samsungTV]];
        [macroCommand addCommandsObject:[REDelayCommand  commandInContext:moc duration:6.0]];
        [macroCommand addCommandsObject:[RESendIRCommand commandWithIRCode:samsungTV[@"HDMI 4"]]];
    }

    else
    {
        [macroCommand addCommandsObject:[REPowerCommand offCommandForDevice:avReceiver]];
        [macroCommand addCommandsObject:[REPowerCommand offCommandForDevice:samsungTV]];
    }

    return macroCommand;
}

+ (REMacroCommand *)appleTVActivityMacroToInitiateState:(BOOL)isOnState
                                                context:(NSManagedObjectContext *)moc
{
    // Macro sequence: A/V Power -> TV Power
    REMacroCommand * macroCommand = [REMacroCommand commandInContext:moc];

    BOComponentDevice * avReceiver = [BOComponentDevice fetchDeviceWithName:@"AV Receiver"
                                                                    context:moc];
    BOComponentDevice * samsungTV  = [BOComponentDevice fetchDeviceWithName:@"Samsung TV"
                                                                    context:moc];

    if (isOnState)
    {
        [macroCommand addCommandsObject:[RESendIRCommand commandWithIRCode:avReceiver[@"DVD"]]];
        [macroCommand addCommandsObject:[REPowerCommand  onCommandForDevice:samsungTV]];
        [macroCommand addCommandsObject:[REDelayCommand  commandInContext:moc duration:6.0]];
        [macroCommand addCommandsObject:[RESendIRCommand commandWithIRCode:samsungTV[@"HDMI 2"]]];
    }

    else
    {
        [macroCommand addCommandsObject:[REPowerCommand offCommandForDevice:avReceiver]];
        [macroCommand addCommandsObject:[REPowerCommand offCommandForDevice:samsungTV]];
    }

    return macroCommand;
}

+ (REMacroCommand *)sonosActivityMacroToInitiateState:(BOOL)isOnState
                                              context:(NSManagedObjectContext *)moc
{
    // Macro sequence: A/V Power -> TV Power
    REMacroCommand * macroCommand = [REMacroCommand commandInContext:moc];

    BOComponentDevice * avReceiver = [BOComponentDevice fetchDeviceWithName:@"AV Receiver"
                                                                    context:moc];

    if (isOnState)
    {
        [macroCommand addCommandsObject:[RESendIRCommand commandWithIRCode:avReceiver[@"MD/Tape"]]];

    }

    else
    {
        [macroCommand addCommandsObject:[REPowerCommand offCommandForDevice:avReceiver]];

    }

    return macroCommand;
}

+ (REMacroCommand *)ps3ActivityMacroToInitiateState:(BOOL)isOnState
                                            context:(NSManagedObjectContext *)moc
{
    // Macro sequence: A/V Power -> TV Power
    REMacroCommand * macroCommand = [REMacroCommand commandInContext:moc];

    BOComponentDevice * avReceiver = [BOComponentDevice fetchDeviceWithName:@"AV Receiver"
                                                                    context:moc];
    BOComponentDevice * ps3        = [BOComponentDevice fetchDeviceWithName:@"PS3"
                                                                    context:moc];
    BOComponentDevice * samsungTV  = [BOComponentDevice fetchDeviceWithName:@"Samsung TV"
                                                                    context:moc];

    if (isOnState)
    {
        [macroCommand addCommandsObject:[RESendIRCommand commandWithIRCode:avReceiver[@"Video 2"]]];
        [macroCommand addCommandsObject:[REPowerCommand onCommandForDevice:samsungTV]];
        [macroCommand addCommandsObject:[REDelayCommand commandInContext:moc duration:6.0]];
        [macroCommand addCommandsObject:[RESendIRCommand commandWithIRCode:samsungTV[@"HDMI 3"]]];
        [macroCommand addCommandsObject:[REPowerCommand onCommandForDevice:ps3]];
    }

    else
    {
        [macroCommand addCommandsObject:[REPowerCommand offCommandForDevice:samsungTV]];
        [macroCommand addCommandsObject:[REPowerCommand offCommandForDevice:avReceiver]];
    }

    return macroCommand;
}

+ (NSSet *)deviceConfigsForActivity:(NSUInteger)activity context:(NSManagedObjectContext *)moc
{
    BOComponentDevice * avReceiver = [BOComponentDevice fetchDeviceWithName:@"AV Receiver"
                                                                    context:moc];
    BOComponentDevice * samsungTV  = [BOComponentDevice fetchDeviceWithName:@"Samsung TV"
                                                                    context:moc];

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
