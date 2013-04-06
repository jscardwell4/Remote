//
// SwitchToRemoteCommand.m
// Remote
//
// Created by Jason Cardwell on 7/21/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "RECommand_Private.h"
#import "RERemoteController.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = COMMAND_F_C;

@interface RESwitchToRemoteCommandOperation : RECommandOperation @end

@implementation RESwitchToRemoteCommand
@dynamic remoteKey;
@dynamic remoteController;

/// @name ￼Creating a SwitchToRemoteCommand

+ (RESwitchToRemoteCommand *)commandInContext:(NSManagedObjectContext *)context key:(NSString *)key
{
    __block RESwitchToRemoteCommand * command = nil;
    [context performBlockAndWait:^{
        command = [self commandInContext:context];
        command.primitiveRemoteKey = key;
        command.primitiveRemoteController = [RERemoteController remoteControllerInContext:context];
    }];

    return command;
}

- (RECommandOperation *)operation
{
    return [RESwitchToRemoteCommandOperation operationForCommand:self];
}

- (NSString *)shortDescription { return $(@"remote:'%@'", self.primitiveRemoteKey); }

@end

@implementation RESwitchToRemoteCommandOperation

- (void)main
{
    @try
    {
        RERemoteController * remoteController = ((RESwitchToRemoteCommand *)_command).remoteController;
        NSString * remoteKey = ((RESwitchToRemoteCommand *)_command).remoteKey;
        _success = [remoteController switchToRemoteWithKey:remoteKey];
        [super main];
    }
    @catch (NSException * exception)
    {
        MSLogDebugTag(@"wtf?");
    }
}

@end
