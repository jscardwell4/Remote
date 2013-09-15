//
// SwitchToRemoteCommand.m
// Remote
//
// Created by Jason Cardwell on 7/21/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "Command_Private.h"
#import "RemoteController.h"
#import "RemoteElement.h"

static int ddLogLevel  = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_COMMAND|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);

@interface SwitchToRemoteCommandOperation : RECommandOperation @end

@implementation SwitchToRemoteCommand
@dynamic remote;

/// @name ￼Creating a SwitchToRemoteCommand

+ (SwitchToRemoteCommand *)commandWithRemote:(Remote *)remote
{
    SwitchToRemoteCommand * command = [self commandInContext:remote.managedObjectContext];
    command.remote = remote;
    return command;
}

- (RECommandOperation *)operation
{
    return [SwitchToRemoteCommandOperation operationForCommand:self];
}

- (NSString *)shortDescription { return $(@"remote:'%@'", self.remote.name); }

@end

@implementation SwitchToRemoteCommandOperation

- (void)main
{
    @try
    {
        Remote * remote = ((SwitchToRemoteCommand *)_command).remote;
        _success = [remote.controller switchToRemote:remote];
        [super main];
    }
    @catch (NSException * exception)
    {
        MSLogDebugTag(@"wtf?");
    }
}

@end
