//
// Command_Private.h
// Remote
//
// Created by Jason Cardwell on 3/17/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "Command.h"

@class CommandOperation;

@interface Command () {
    @protected
    void (^_completion)(BOOL, NSError *);
}
/// `Button` object executing the command.
@property (nonatomic, strong) Button * button;

/// `CommandOperation` object that encapsulates the task performed by the command
@property (nonatomic, readonly) CommandOperation * operation;

@end
