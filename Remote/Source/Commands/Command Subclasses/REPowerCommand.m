//
// PowerCommand.m
// Remote
//
// Created by Jason Cardwell on 3/16/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RECommand_Private.h"
#import "BankObject.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_COMMAND|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);

@interface REPowerCommandOperation : RECommandOperation @end

@implementation REPowerCommand

@dynamic state, device;

+ (REPowerCommand *)onCommandForDevice:(BOComponentDevice *)device
{
    REPowerCommand * powerCommand = [self commandInContext:device.managedObjectContext];
    powerCommand.state  = BOPowerStateOn;
    powerCommand.device = device;
    return powerCommand;
}

+ (REPowerCommand *)offCommandForDevice:(BOComponentDevice *)device
{
    REPowerCommand * powerCommand = [self commandInContext:device.managedObjectContext];
    powerCommand.state  = BOPowerStateOff;
    powerCommand.device = device;
    return powerCommand;
}

- (RECommandOperation *)operation { return [REPowerCommandOperation operationForCommand:self]; }

- (void)setState:(BOPowerState)state
{
    [self willChangeValueForKey:@"state"];
    _state = state;
    [self didChangeValueForKey:@"state"];
}

- (BOPowerState)state
{
    [self willAccessValueForKey:@"state"];
    BOPowerState state = _state;
    [self didAccessValueForKey:@"state"];
    return state;
}

- (NSString *)shortDescription
{
    return $(@"device:'%@', state:%@", self.primitiveDevice.name, (_state ?@"On": @"Off"));
}

@end

@implementation REPowerCommandOperation {
    BOOL _statusReceived;
}

- (void)main
{
    @try
    {
        REPowerCommand * powerCommand = (REPowerCommand *)_command;
        RECommandCompletionHandler handler = ^(BOOL success, NSError * error)
                                             {
                                                 _success = success;
                                                 _error   = error;
                                                 [super main];
                                             };

        if (powerCommand.state == BOPowerStateOn)
            [powerCommand.device powerOn:handler];

        else
            [powerCommand.device powerOff:handler];
    }

    @catch (NSException * exception)
    {
        MSLogErrorTag(@"wtf?");
    }
}

@end
