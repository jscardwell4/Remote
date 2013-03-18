//
// SwitchToRemoteCommand.m
// Remote
//
// Created by Jason Cardwell on 7/21/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "Command.h"
#import "Command_Private.h"
#import "RERemoteController.h"

static int   ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@implementation SwitchToRemoteCommand
@dynamic remoteKey;
@dynamic remoteController;

/// @name ￼Creating a SwitchToRemoteCommand

+ (SwitchToRemoteCommand *)switchToRemoteCommandInContext:(NSManagedObjectContext *)context {
    SwitchToRemoteCommand * command = (SwitchToRemoteCommand *)[super commandInContext:context];

    if (command) command.remoteController = [RERemoteController remoteControllerInContext:context];

    return command;
}

+ (SwitchToRemoteCommand *)switchToRemoteCommandInContext:(NSManagedObjectContext *)context
                                                      key:(NSString *)key {
    if (StringIsEmpty(key)) return nil;

    SwitchToRemoteCommand * command = [self switchToRemoteCommandInContext:context];

    if (command) command.remoteKey = key;

    return command;
}

/**
 * Invokes the `makeCurrentRemoteWithKey:` method of the command's `RemoteController` object and
 * pushes the result up the chain of command delegates.
 * @param sender Object to be notified upon completion.
 * @param options Options to apply when the command is executed.
 */
- (void)execute:(id <CommandDelegate> )sender {
    [super execute:sender];

    BOOL   success = [self.remoteController switchToRemoteWithKey:self.remoteKey];

    [super commandDidComplete:self success:success];
}

@end
