//
// Command.h
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "NamedModelObject.h"
#import "RETypedefs.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Command
////////////////////////////////////////////////////////////////////////////////

@class Button, ComponentDevice;

/**
 * The `Command` class subclasses `NSManagedObject` to model a command to be executed. Most of the
 * time the command is executed as a result of the user pressing a button; however, some commands
 * execute other commands and chain the result back up to the command that initiated the execution.
 * `Command` objects are not intended to be created directly. Instead, there are many subclasses
 * that customize behavior for particular tasks: <PowerCommand>, <MacroCommand>, <DelayCommand>,
 * <SystemCommand>, <SendIRCommand>, <HTTPCommand>, <SwitchToRemoteCommand>.
 */
@interface Command : NamedModelObject

/**
 * Create a new `Command` object in the current thread's managed object context.
 */
+ (instancetype)command;

/**
 * Create a new `Command` object in the specified `NSManagedObjectContext`.
 * @param context The context in which to create the new object.
 */
+ (instancetype)commandInContext:(NSManagedObjectContext *)context;

/**
 * Executes the task associated with the command with the specified options.
 * @param completion Block to execute after the command completes
 */
- (void)execute:(void (^)(BOOL success, NSError *))completion;

/// Show activity indicator while executing command.
@property (nonatomic, assign) BOOL indicator;

@end

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
