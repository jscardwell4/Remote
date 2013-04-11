//
// Command_Private.h
// Remote
//
// Created by Jason Cardwell on 3/17/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "RECommand.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Command Class Extension and Categories
////////////////////////////////////////////////////////////////////////////////
@interface RECommandOperation : NSOperation {
    @protected
    BOOL        _executing;
    BOOL        _finished;
    BOOL        _success;
    RECommand * _command;
}

@property (nonatomic, getter = wasSuccessful) BOOL        success;
@property (nonatomic, readonly)               RECommand * command;

+ (instancetype)operationForCommand:(RECommand *)command;

@end


@interface RECommand () {
    @protected
    RECommandCompletionHandler _completion;
}
/// `ComponentDevice` this command powers on.
@property (nonatomic, strong) BOComponentDevice * onDevice;
/// `Button` object executing the command.
@property (nonatomic, strong) REButton * button;
/// `ComponentDevice` this command powers off.
@property (nonatomic, strong) BOComponentDevice * offDevice;
/// `RECommandOperation` object that encapsulates the task performed by the command
@property (nonatomic, readonly) RECommandOperation * operation;
@end

@interface RECommand (CoreDataGeneratedAccessors)
@property (nonatomic) BOComponentDevice * primitiveOnDevice;
@property (nonatomic) BOComponentDevice * primitiveOffDevice;
@property (nonatomic) NSNumber          * primitiveIndicator;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Macro Command Class Extension and Core Data Generated Accessors
////////////////////////////////////////////////////////////////////////////////

@interface REMacroCommand () {
    NSOperationQueue * _queue;
    NSArray          * _operations;
}
/// Stores the `Command` objects to be executed in order when the `MacroCommand` is executed.
@property (nonatomic, strong) NSOrderedSet * commands;
/// Queue maintained for executing commands
@property (nonatomic, readonly) NSOperationQueue * queue;
@end

@interface REMacroCommand (CoreDataGeneratedAccessors)
@property (nonatomic) NSMutableOrderedSet * primitiveCommands;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - SendIRCommand Class Extension
////////////////////////////////////////////////////////////////////////////////

@interface RESendIRCommand () {
    @private
    int16_t        __port;
    int16_t        __offset;
    int16_t        __repeatCount;
    int64_t        __frequency;
    NSString     * __pattern;
    NSString     * __name;
    BODevicePort   _portOverride;
}
@end

@interface RESendIRCommand (CoreDataGeneratedAccessors)
@property (nonatomic) BOIRCode * primitiveCode;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - DelayCommand Core Data Generated Accessors
////////////////////////////////////////////////////////////////////////////////
@interface REDelayCommand (CoreDataGeneratedAccessors)
@property (nonatomic) NSNumber * primitiveDuration;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - PowerCommand Core Data Generated Accessors
////////////////////////////////////////////////////////////////////////////////
@interface REPowerCommand () {
    BOPowerState _state;
}
@end
@interface REPowerCommand (CoreDataGeneratedAccessors)
@property (nonatomic) BOComponentDevice * primitiveDevice;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - SystemCommand Class Extension and Core Data Generated Accessors
////////////////////////////////////////////////////////////////////////////////

@interface RESystemCommand () {
    @private
    RESystemCommandType _type;
}
/// Specifies the action performed by the system command
@property (nonatomic, assign) RESystemCommandType   type;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - HTTPCommand Core Data Generated Accessors
////////////////////////////////////////////////////////////////////////////////

@interface REHTTPCommand (CoreDataGeneratedAccessors)
@property (nonatomic) NSURL * primitiveUrl;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - SwitchToRemoteCommand Core Data Generated Accessors
////////////////////////////////////////////////////////////////////////////////

@interface RESwitchToRemoteCommand (CoreDataGeneratedAccessors)
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - SwitchToConfigCommand Core Data Generated Accessors
////////////////////////////////////////////////////////////////////////////////

@interface RESwitchToConfigCommand (CoreDataGeneratedAccessors)
@property (nonatomic) RERemoteController    * primitiveRemoteController;
@property (nonatomic) RERemoteConfiguration   primitiveConfiguration;
@end
