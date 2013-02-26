//
// CommandDelegate.h
// iPhonto
//
// Created by Jason Cardwell on 10/6/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#pragma mark - CommandDelegate protocol

@class   Command;

/**
 * The `CommandDelegate` protocol is implemented by an object to receive feedback about the
 * execution
 * of a command.
 */
@protocol CommandDelegate <NSObject>

/**
 * Called by a `Command` after it his completed the execution of its task.
 * @param command The command that has completed execution.
 * @param success Whether the command was successful.
 */
- (void)commandDidComplete:(Command *)command success:(BOOL)success;

@end
