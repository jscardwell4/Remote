//
// PowerCommand.m
// Remote
//
// Created by Jason Cardwell on 3/16/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "Command_Private.h"
#import "ComponentDevice.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_COMMAND|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);

@interface PowerCommandOperation : CommandOperation @end

@implementation PowerCommand

@dynamic state, device;

+ (PowerCommand *)onCommandForDevice:(ComponentDevice *)device
{
    PowerCommand * powerCommand = [self commandInContext:device.managedObjectContext];
    powerCommand.state  = YES;
    powerCommand.device = device;
    return powerCommand;
}

+ (PowerCommand *)offCommandForDevice:(ComponentDevice *)device
{
    PowerCommand * powerCommand = [self commandInContext:device.managedObjectContext];
    powerCommand.state  = NO;
    powerCommand.device = device;
    return powerCommand;
}

- (void)setState:(BOOL)state
{
    [self willChangeValueForKey:@"state"];
    self.primitiveState = @(state);
    [self didChangeValueForKey:@"state"];
}

- (BOOL)state
{
    [self willAccessValueForKey:@"state"];
    NSNumber * state = self.primitiveState;
    [self didAccessValueForKey:@"state"];
    return [state boolValue];
}

- (CommandOperation *)operation { return [PowerCommandOperation operationForCommand:self]; }

- (NSString *)shortDescription
{
    return $(@"device:'%@', state:%@", self.primitiveDevice.name, (self.state ?@"On": @"Off"));
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Importing
////////////////////////////////////////////////////////////////////////////////


- (BOOL)shouldImportDevice:(id)data {return YES;}
- (BOOL)importState:(id)data
{
    if ([data isKindOfClass:[NSString class]])
    {
        self.state = [@"on" isEqualToString:(NSString *)data];
        return YES;
    }

    else if ([data isKindOfClass:[NSNumber class]])
    {
        self.state = BOOLValue(data);
        return YES;
    }

    else
        return NO;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Exporting
////////////////////////////////////////////////////////////////////////////////


- (MSDictionary *)JSONDictionary
{
    MSDictionary * dictionary = [super JSONDictionary];
    dictionary[@"uuid"] = NullObject;

    dictionary[@"device.uuid"] = CollectionSafe(self.device.uuid);
    dictionary[@"state"] = (self.state ? @"on" : @"off");

    [dictionary compact];
    [dictionary compress];

    return dictionary;
}


@end

@implementation PowerCommandOperation {
    BOOL _statusReceived;
}

- (void)main
{
    @try
    {
        PowerCommand * powerCommand = (PowerCommand *)_command;
        CommandCompletionHandler handler = ^(BOOL success, NSError * error)
                                             {
                                                 _success = success;
                                                 _error   = error;
                                                 [super main];
                                             };

        if (powerCommand.state == YES)
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
