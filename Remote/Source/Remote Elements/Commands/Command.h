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

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Power Commands
////////////////////////////////////////////////////////////////////////////////

/**
 * `PowerCommand` subclasses `Command` for the sole purpose of telling a `ComponentDevice` to be
 * turned on or off.
 */
@interface PowerCommand : Command

/**
 * Default initializer for creating a new `PowerCommand` for turning on a component device.
 * @param device The device for which power should be switched on.
 * @return The newly created `PowerCommand` object.
 */
+ (PowerCommand *)onCommandForDevice:(ComponentDevice *)device;

/**
 * Default initializer for creating a new `PowerCommand` for turning off a component device.
 * @param device The device for which power should be switched off.
 * @return The newly created `PowerCommand` object.
 */
+ (PowerCommand *)offCommandForDevice:(ComponentDevice *)device;

/// Holds the `ComponentDevicePowerState` associated with the command. `NO` is equal to
/// `ComponentDevicePowerStateOff` and `YES` is equal to `ComponentDevicePowerStateOn`.
@property (nonatomic) BOOL state;

/// The device to which the command is directed.
@property (nonatomic, strong) ComponentDevice * device;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Macros
////////////////////////////////////////////////////////////////////////////////

/**
 * `MacroCommand` is a `Command` subclass that can execute a series of commands.
 */
@interface MacroCommand : Command

/**
 * Sets the `Command` object at the specified index sorted by order of execution.
 * @param obj The command to insert at the specified index
 * @param idx The index in order of execution at which the object should be placed
 */
- (void)setObject:(Command *)obj atIndexedSubscript:(NSUInteger)idx;

/// Total number of commands encapsulated by the macro.
@property (nonatomic, readonly) NSUInteger count;

/**
 * Inserts a new command at the specified index for setting the order of execution.
 * @param command The command to be added.
 * @param idx The index at which the command is to be placed.
 */
- (void)insertObject:(Command *)command inCommandsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCommandsAtIndex:(NSUInteger)idx;

- (void)insertCommands:(NSArray *)command atIndexes:(NSIndexSet *)indices;
- (void)removeCommandsAtIndexes:(NSIndexSet *)indices;

- (void)replaceObjectInCommandsAtIndex:(NSUInteger)idx withObject:(Command *)command;
- (void)replaceCommandsAtIndexes:(NSIndexSet *)indexes withCommands:(NSArray *)commands;

/**
 * Adds a new command to the collection of commands executed.
 * @param command The command to be added.
 */
- (void)addCommandsObject:(Command *)command;

/**
 * Removes the command at the specified index.
 * @param idx The index of the command to be removed.
 */
- (void)removeCommandsObject:(Command *)command;

- (void)addCommands:(NSOrderedSet *)commands;
- (void)removeCommands:(NSOrderedSet *)commands;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Delays
////////////////////////////////////////////////////////////////////////////////

/**
 * `DelayCommand` subclasses `Command` to provide a delay, usually in a chain of other commands.
 */
@interface DelayCommand : Command

/**
 * Default initializer for creating a `DelayCommand`.
 * @param duration The length of time to wait before execution is successful.
 * @param context `NSManagedObjectContext` in which to create the command.
 * @return The newly created `DelayCommand` object.
 */
+ (DelayCommand *)commandInContext:(NSManagedObjectContext *)context duration:(CGFloat)duration;

/// Length of the delay.
@property (nonatomic, strong) NSNumber * duration;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - System Commands
////////////////////////////////////////////////////////////////////////////////

@class   RemoteViewController;

/**
 * `SystemCommand` subclasses `Command` to perform tasks that interact with `UIKit` objects like
 * `UIDevice`. Currently it is capable of toggling proximity monitoring on and off; however,
 * this application as it stands does not use `SystemCommand` for anything.
 */
@interface SystemCommand : Command

/**
 * Retrieves the `SystemCommand` object for the specified key using the current thread's managed
 * object context, creating it if it does not already exist.
 * @param key `SystemCommandType` for the desired command.
 * @return The existing or newly created `SystemCommand` for the specified key.
 */
+ (SystemCommand *)commandWithType:(SystemCommandType)key;

/**
 * Retrieves the `SystemCommand` object for the specified key in the specified context, creating it
 * if it does not already exist.
 * @param key `SystemCommandType` for the desired command.
 * @param context Context from which the command will be retrieved.
 * @return The existing or newly created `SystemCommand` for the specified key.
 */
+ (SystemCommand *)commandWithType:(SystemCommandType)key inContext:(NSManagedObjectContext *)moc;

@property (nonatomic, assign, readonly) SystemCommandType type;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Send Command
////////////////////////////////////////////////////////////////////////////////
@interface SendCommand : Command @end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Sending IR Commands
////////////////////////////////////////////////////////////////////////////////
@class IRCode, NetworkDevice, ITachDevice;

/**
 * `SendIRCommand` subclasses `Command` to send IR commands via <ConnectionManager> to networked
 * IR receivers that control the user's home theater system. At this time, only
 * [iTach](http://www.globalcache.com/products/itach) devices from Global Caché are supported.
 */
@interface SendIRCommand : SendCommand

/**
 * Default intializer for creating a new `SendIRCommand`.
 * @param code IR code to send on execution.
 * @return The newly created `SendIRCommand`.
 */
+ (SendIRCommand *)commandWithIRCode:(IRCode *)code;

/// Cached value for port
@property (nonatomic, readonly) int16_t port;

/// Cached value for offset
@property (nonatomic, readonly) int16_t offset;

/// Cached value for repeatCount
@property (nonatomic, readonly) int16_t repeatCount;

/// Cached value for frequency
@property (nonatomic, readonly) int64_t frequency;

/// Cached value for on-off pattern
@property (nonatomic, readonly) NSString * pattern;

/// Cached value for code name
@property (nonatomic, readonly) NSString * name;

/// Forces sending over port regardless of port set for `ComponentDevice`.
@property (nonatomic, assign)  int16_t portOverride;

/// `IRCode` object that encapsulates the networked device information for sending the command.
@property (nonatomic, strong) IRCode * code;

/// The actual command delivered to the networked device via the `ConnectionManager`. It is derived
/// from the various attributes of the command's `IRCode`.
@property (nonatomic, strong, readonly) NSString * commandString;

/// Wrapper for the `code.device`
@property (nonatomic, readonly) ComponentDevice * device;

/// Wrapper for `code.device.networkDevice`
@property (nonatomic, readonly) ITachDevice * networkDevice;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - HTTP Commands
////////////////////////////////////////////////////////////////////////////////

/**
 * `HTTPCommand` subclasses `Command` to send a one way http request. Currently this can be use with
 * a networked device that receives commands via a server that parses url parameters such as Insteon
 * [SmartLinc](http://www.insteon.net/2412N-smartlinc-central-controller.html) controllers.
 */
@interface HTTPCommand : SendCommand

/**
 * Default initializer for creating a new `HTTPCommand` in the current thread context.
 * @param urlString String containing the url to be requested by `ConnectionManager`.
 * @return The newly created `HTTPCommand` object.
 */
+ (HTTPCommand *)commandWithURL:(NSString *)url;

/**
 * Default initializer for creating a new `HTTPCommand`.
 * @param urlString String containing the url to be requested by `ConnectionManager`.
 * @param context `NSManagedObjectContext` in which to create the command.
 * @return The newly created `HTTPCommand` object.
 */
+ (HTTPCommand *)commandWithURL:(NSString *)url context:(NSManagedObjectContext *)context;

/// The url for the http request sent by <ConnectionManager>.
@property (nonatomic, strong) NSURL * url;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Switching Activities
////////////////////////////////////////////////////////////////////////////////
@class Activity;

/**
 * `ActivityCommand` subclasses `Command` to launch or halt an activity.
 */
@interface ActivityCommand : Command

/**
 * Default initializer for creating an `ActivityCommand`.
 * @param activity The activity to launch or halt
 * @return The newly created `ActivityCommand`.
 */
+ (ActivityCommand *)commandWithActivity:(Activity *)activity;

/// The `REActivity` object to launch or halt.
@property (nonatomic, strong) Activity * activity;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Switching Configurations or Remotes
////////////////////////////////////////////////////////////////////////////////

@interface SwitchCommand : Command

@property (nonatomic, assign, readonly) SwitchCommandType type;
@property (nonatomic, copy, readonly)   NSString * target;

@end
