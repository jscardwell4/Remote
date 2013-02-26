//
// PowerCommand.m
// iPhonto
//
// Created by Jason Cardwell on 3/16/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "Command.h"
#import "Command_Private.h"
#import "ComponentDevice.h"

static int   ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@implementation PowerCommand

@dynamic powerState, device;

/// @name ￼Creating a PowerCommand

+ (PowerCommand *)powerCommandInContext:(NSManagedObjectContext *)context {
    return (PowerCommand *)[super commandInContext:context];
}

+ (PowerCommand *)powerCommandForDevice:(ComponentDevice *)componentDevice
                               andState:(ComponentDevicePowerState)state {
    if (ValueIsNil(componentDevice)) return nil;

    PowerCommand * powerCommand =
        [NSEntityDescription insertNewObjectForEntityForName:@"PowerCommand"
                                      inManagedObjectContext:componentDevice.managedObjectContext];

    powerCommand.powerState = state;
    powerCommand.device     = componentDevice;

    return powerCommand;
}

/// @name ￼Command overrides

/**
 * Sends `setPowerStateToState:sender:` to the device associated with the command.
 * @param sender Object to receive feedback after execution.
 * @param options Options to apply when executing the command.
 */
- (void)execute:(id <CommandDelegate> )sender {
    [super execute:sender];
    [self.device setPowerStateToState:self.powerState sender:self];
}

@end
