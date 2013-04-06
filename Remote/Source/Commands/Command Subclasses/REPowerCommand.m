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
static int msLogContext = COMMAND_F_C;

@interface REPowerCommandOperation : RECommandOperation @end

@implementation REPowerCommand

@dynamic state, device;

+ (REPowerCommand *)onCommandForDevice:(BOComponentDevice *)device
{
    __block REPowerCommand * powerCommand = nil;

    [device.managedObjectContext performBlockAndWait:
     ^{
         powerCommand = [self commandInContext:device.managedObjectContext];
         powerCommand.state  = BOPowerStateOn;
         powerCommand.device = device;
     }];

    return powerCommand;
}

+ (REPowerCommand *)offCommandForDevice:(BOComponentDevice *)device
{
    __block REPowerCommand * powerCommand = nil;

    [device.managedObjectContext performBlockAndWait:
     ^{
         powerCommand = [self commandInContext:device.managedObjectContext];
         powerCommand.state  = BOPowerStateOff;
         powerCommand.device = device;
     }];

    return powerCommand;
}

- (RECommandOperation *)operation
{
    return [REPowerCommandOperation operationForCommand:self];
}

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
        __weak REPowerCommandOperation * weakself = self;
        RECommandCompletionHandler handler = ^(BOOL finished, BOOL success)
                                             {
                                                 [weakself statusReceivedWithFinished:finished
                                                                              success:success];
                                             };

        if (powerCommand.state == BOPowerStateOn)
            [powerCommand.device powerOn:handler];

        else
            [powerCommand.device powerOff:handler];

        while (!_statusReceived);

        [super main];
    }
    @catch (NSException * exception)
    {
        MSLogErrorTag(@"wtf?");
    }
}

- (void)statusReceivedWithFinished:(BOOL)finished success:(BOOL)success
{
    _success = (finished && success);
    _statusReceived = YES;
}
@end
