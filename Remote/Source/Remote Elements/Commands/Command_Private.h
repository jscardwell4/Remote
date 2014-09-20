//
// Command_Private.h
// Remote
//
// Created by Jason Cardwell on 3/17/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
@import MoonKit;
#import "MSRemoteMacros.h"

#import "Command.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Command Class Extension and Categories
////////////////////////////////////////////////////////////////////////////////
@interface CommandOperation : NSOperation {
    @protected
    BOOL      _executing;
    BOOL      _finished;
    BOOL      _success;
    Command * _command;
    NSError * _error;
}

@property (assign, readonly, getter = isExecuting)              BOOL      executing;
@property (assign, readonly, getter = isFinished)               BOOL      finished;
@property (nonatomic, strong, readonly)                         NSError * error;
@property (nonatomic, strong, readonly)                         Command * command;
@property (nonatomic, assign, readonly, getter = wasSuccessful) BOOL      success;
+ (instancetype)operationForCommand:(Command *)command;

@end


@interface Command () {
    @protected
    void (^_completion)(BOOL, NSError *);
}
/// `ComponentDevice` this command powers on.
@property (nonatomic, strong) ComponentDevice * onDevice;
/// `Button` object executing the command.
@property (nonatomic, strong) Button * button;
/// `ComponentDevice` this command powers off.
@property (nonatomic, strong) ComponentDevice * offDevice;
/// `CommandOperation` object that encapsulates the task performed by the command
@property (nonatomic, readonly) CommandOperation * operation;
@end

@interface Command (CoreDataGeneratedAccessors)
@property (nonatomic) ComponentDevice * primitiveOnDevice;
@property (nonatomic) ComponentDevice * primitiveOffDevice;
@end

