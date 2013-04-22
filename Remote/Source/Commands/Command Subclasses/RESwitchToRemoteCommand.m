//
// SwitchToRemoteCommand.m
// Remote
//
// Created by Jason Cardwell on 7/21/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "RECommand_Private.h"
#import "RERemoteController.h"
#import "RemoteElement.h"

static int ddLogLevel  = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_COMMAND|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);

@interface RESwitchToRemoteCommandOperation : RECommandOperation @end

@implementation RESwitchToRemoteCommand
@dynamic remote;

/// @name ￼Creating a SwitchToRemoteCommand

+ (RESwitchToRemoteCommand *)commandWithRemote:(RERemote *)remote
{
    RESwitchToRemoteCommand * command = [self commandInContext:remote.managedObjectContext];
    command.remote = remote;
    return command;
}

- (RECommandOperation *)operation
{
    return [RESwitchToRemoteCommandOperation operationForCommand:self];
}

- (NSString *)shortDescription { return $(@"remote:'%@'", self.remote.displayName); }

@end

@implementation RESwitchToRemoteCommandOperation

- (void)main
{
    @try
    {
        RERemote * remote = ((RESwitchToRemoteCommand *)_command).remote;
        _success = [remote.controller switchToRemote:remote];
        [super main];
    }
    @catch (NSException * exception)
    {
        MSLogDebugTag(@"wtf?");
    }
}

@end
