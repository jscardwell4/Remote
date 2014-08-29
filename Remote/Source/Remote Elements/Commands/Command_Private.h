//
// Command_Private.h
// Remote
//
// Created by Jason Cardwell on 3/17/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

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

@property (nonatomic, assign, readonly)                         BOOL        executing;
@property (nonatomic, assign, readonly)                         BOOL        finished;
@property (nonatomic, strong, readonly)                         NSError   * error;
@property (nonatomic, strong, readonly)                         Command * command;
@property (nonatomic, assign, readonly, getter = wasSuccessful) BOOL        success;

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

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Macro Command Class Extension and Core Data Generated Accessors
////////////////////////////////////////////////////////////////////////////////

@interface MacroCommand () {
    NSOperationQueue * _queue;
    NSArray          * _operations;
}
/// Stores the `Command` objects to be executed in order when the `MacroCommand` is executed.
@property (nonatomic, strong) NSOrderedSet * commands;
/// Queue maintained for executing commands
@property (nonatomic, readonly) NSOperationQueue * queue;
@end

@interface MacroCommand (CoreDataGeneratedAccessors)
@property (nonatomic) NSMutableOrderedSet * primitiveCommands;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - SendIRCommand Class Extension
////////////////////////////////////////////////////////////////////////////////

@interface SendIRCommand ()
{
@private
    int16_t    __port;
    int16_t    __offset;
    int16_t    __repeatCount;
    int64_t    __frequency;
    NSString * __pattern;
    NSString * __name;
    int16_t    _portOverride;
}
@end

@interface SendIRCommand (CoreDataGeneratedAccessors)

@property (nonatomic) IRCode * primitiveCode;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - DelayCommand Core Data Generated Accessors
////////////////////////////////////////////////////////////////////////////////

@interface DelayCommand (CoreDataGeneratedAccessors)

@property (nonatomic) NSNumber * primitiveDuration;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - PowerCommand Core Data Generated Accessors
////////////////////////////////////////////////////////////////////////////////

@interface PowerCommand (CoreDataGeneratedAccessors)

@property (nonatomic) ComponentDevice * primitiveDevice;
@property (nonatomic) NSNumber        * primitiveState;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - SystemCommand Core Data Generated Accessors
////////////////////////////////////////////////////////////////////////////////

@interface SystemCommand (CoreDataGeneratedAccessors)

/// Specifies the action performed by the system command
@property (nonatomic) NSNumber * primitiveType;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - HTTPCommand Core Data Generated Accessors
////////////////////////////////////////////////////////////////////////////////

@interface HTTPCommand (CoreDataGeneratedAccessors)

@property (nonatomic) NSURL * primitiveUrl;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - SwitchCommand Class Extension
////////////////////////////////////////////////////////////////////////////////

@interface SwitchCommand ()

@property (nonatomic, copy, readwrite) NSString * target;

@end

#import "RemoteElementImportSupportFunctions.h"
#import "RemoteElementExportSupportFunctions.h"
