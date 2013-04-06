//
// Command.h
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "RETypedefs.h"
#import "BOTypedefs.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Command
////////////////////////////////////////////////////////////////////////////////

@class REButton, BOComponentDevice;

/**
 * The `Command` class subclasses `NSManagedObject` to model a command to be executed. Most of the
 * time the command is executed as a result of the user pressing a button; however, some commands
 * execute other commands and chain the result back up to the command that initiated the execution.
 * `Command` objects are not intended to be created directly. Instead, there are many subclasses
 * that customize behavior for particular tasks: <PowerCommand>, <MacroCommand>, <DelayCommand>,
 * <SystemCommand>, <SendIRCommand>, <HTTPCommand>, <SwitchToRemoteCommand>.
 */
@interface RECommand : NSManagedObject

/**
 * Create a new `Command` object in the specified `NSManagedObjectContext`.
 * @param context The context in which to create the new object.
 */
+ (instancetype)commandInContext:(NSManagedObjectContext *)context;

/**
 * Executes the task associated with the command with the specified options.
 * @param completion Block to execute after the command completes
 */
- (void)execute:(RECommandCompletionHandler)completion;

/// Show activity indicator while executing command.
@property (nonatomic, assign) BOOL indicator;

/// Unique identifier.
@property (nonatomic, copy, readonly) NSString * uuid;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Power Commands
////////////////////////////////////////////////////////////////////////////////

/**
 * `PowerCommand` subclasses `Command` for the sole purpose of telling a `ComponentDevice` to be
 * turned on or off.
 */
@interface REPowerCommand : RECommand

/**
 * Default initializer for creating a new `PowerCommand` for turning on a component device.
 * @param device The device for which power should be switched on.
 * @return The newly created `PowerCommand` object.
 */
+ (REPowerCommand *)onCommandForDevice:(BOComponentDevice *)device;

/**
 * Default initializer for creating a new `PowerCommand` for turning off a component device.
 * @param device The device for which power should be switched off.
 * @return The newly created `PowerCommand` object.
 */
+ (REPowerCommand *)offCommandForDevice:(BOComponentDevice *)device;

/// Holds the `ComponentDevicePowerState` associated with the command. `NO` is equal to
/// `ComponentDevicePowerStateOff` and `YES` is equal to `ComponentDevicePowerStateOn`.
@property (nonatomic) BOPowerState state;

/// The device to which the command is directed.
@property (nonatomic, strong) BOComponentDevice * device;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Macros
////////////////////////////////////////////////////////////////////////////////

/**
 * `MacroCommand` is a `Command` subclass that can execute a series of commands.
 */
@interface REMacroCommand : RECommand

/**
 * Returns the `Command` object with the specified uuid.
 * @param uuid The `uuid` of the command to retrieve
 * @return The `Command` object at the specified index
 */
- (RECommand *)objectAtKeyedSubscript:(NSString *)uuid;

/**
 * Returns the `Command` object at the specified index sorted by order of execution.
 * @param idx The index of the command to retrieve
 * @return The `Command` object at the specified index
 */
- (RECommand *)objectAtIndexedSubscript:(NSUInteger)idx;

/**
 * Sets the `Command` object at the specified index sorted by order of execution.
 * @param obj The command to insert at the specified index
 * @param idx The index in order of execution at which the object should be placed
 */
- (void)setObject:(RECommand *)obj atIndexedSubscript:(NSUInteger)idx;

/// Total number of commands encapsulated by the macro.
@property (nonatomic, readonly) NSUInteger count;

/**
 * Inserts a new command at the specified index for setting the order of execution.
 * @param command The command to be added.
 * @param idx The index at which the command is to be placed.
 */
- (void)insertObject:(RECommand *)command inCommandsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCommandsAtIndex:(NSUInteger)idx;

- (void)insertCommands:(NSArray *)command atIndexes:(NSIndexSet *)indices;
- (void)removeCommandsAtIndexes:(NSIndexSet *)indices;

- (void)replaceObjectInCommandsAtIndex:(NSUInteger)idx withObject:(RECommand *)command;
- (void)replaceCommandsAtIndexes:(NSIndexSet *)indexes withCommands:(NSArray *)commands;

/**
 * Adds a new command to the collection of commands executed.
 * @param command The command to be added.
 */
- (void)addCommandsObject:(RECommand *)command;

/**
 * Removes the command at the specified index.
 * @param idx The index of the command to be removed.
 */
- (void)removeCommandsObject:(RECommand *)command;

- (void)addCommands:(NSOrderedSet *)commands;
- (void)removeCommands:(NSOrderedSet *)commands;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Delays
////////////////////////////////////////////////////////////////////////////////

/**
 * `DelayCommand` subclasses `Command` to provide a delay, usually in a chain of other commands.
 */
@interface REDelayCommand : RECommand

/**
 * Default initializer for creating a `DelayCommand`.
 * @param duration The length of time to wait before execution is successful.
 * @param context `NSManagedObjectContext` in which to create the command.
 * @return The newly created `DelayCommand` object.
 */
+ (REDelayCommand *)commandInContext:(NSManagedObjectContext *)context duration:(CGFloat)duration;

/// Length of the delay.
@property (nonatomic, assign) CGFloat duration;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - System Commands
////////////////////////////////////////////////////////////////////////////////

@class   RERemoteViewController;

/**
 * `SystemCommand` subclasses `Command` to perform tasks that interact with `UIKit` objects like
 * `UIDevice`. Currently it is capable of toggling proximity monitoring on and off; however,
 * this application as it stands does not use `SystemCommand` for anything.
 */
@interface RESystemCommand : RECommand

/**
 * Retrieves the `SystemCommand` object for the specified key, creating it if it does not already
 * exist.
 * @param key `RESystemCommandType` for the desired command.
 * @param context Context from which the command will be retrieved.
 * @return The existing or newly created `SystemCommand` for the specified key.
 */
+ (RESystemCommand *)commandInContext:(NSManagedObjectContext *)context type:(RESystemCommandType)key;

+ (BOOL)registerRemoteViewController:(RERemoteViewController *)remoteViewController;

@end

MSKIT_STATIC_INLINE NSString * NSStringFromRESystemCommandType(RESystemCommandType type)
{
    switch (type) {
        case RESystemCommandOpenEditor: 			   return @"RESystemCommandOpenEditor";
        case RESystemCommandOpenSettings: 		   return @"RESystemCommandOpenSettings";
        case RESystemCommandReturnToLaunchScreen:  return @"RESystemCommandReturnToLaunchScreen";
        case RESystemCommandToggleProximitySensor: return @"RESystemCommandToggleProximitySensor";
        case RESystemCommandURLRequest:  			   return @"RESystemCommandURLRequest";
        default:  							 						   return nil;
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Send Command
////////////////////////////////////////////////////////////////////////////////
@interface RESendCommand : RECommand

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Sending IR Commands
////////////////////////////////////////////////////////////////////////////////
@class BOIRCode;

/**
 * `SendIRCommand` subclasses `Command` to send IR commands via <ConnectionManager> to networked
 * IR receivers that control the user's home theater system. At this time, only
 * [iTach](http://www.globalcache.com/products/itach) devices from Global Caché are supported.
 */
@interface RESendIRCommand : RESendCommand // <ConnectionManagerDelegate>

/**
 * Default intializer for creating a new `SendIRCommand`.
 * @param code IR code to send on execution.
 * @return The newly created `SendIRCommand`.
 */
+ (RESendIRCommand *)commandWithIRCode:(BOIRCode *)code;

/// Cached value for port
@property (nonatomic, readonly) BODevicePort port;

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
@property (nonatomic, assign)  BODevicePort portOverride;

/// `IRCode` object that encapsulates the networked device information necessary for sending the
/// command.
@property (nonatomic, strong) BOIRCode * code;

/// The actual command delivered to the networked device via the `ConnectionManager`. It is derived
/// from the various attributes of the command's `IRCode`.
@property (nonatomic, strong, readonly) NSString * commandString;

/// Wrapper for the `IRCode` object's `device` property.
@property (nonatomic, readonly) BOComponentDevice * device;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - HTTP Commands
////////////////////////////////////////////////////////////////////////////////

/**
 * `HTTPCommand` subclasses `Command` to send a one way http request. Currently this can be use with
 * a networked device that receives commands via a server that parses url parameters such as Insteon
 * [SmartLinc](http://www.insteon.net/2412N-smartlinc-central-controller.html) controllers.
 */
@interface REHTTPCommand : RESendCommand

/**
 * Default initializer for creating a new `HTTPCommand`.
 * @param urlString String containing the url to be requested by `ConnectionManager`.
 * @param context `NSManagedObjectContext` in which to create the command.
 * @return The newly created `HTTPCommand` object.
 */
+ (REHTTPCommand *)commandInContext:(NSManagedObjectContext *)context withURL:(NSString *)url;

/// The url for the http request sent by <ConnectionManager>.
@property (nonatomic, strong) NSURL * url;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Switching Remotes
////////////////////////////////////////////////////////////////////////////////
@class RERemoteController;
/**
 * `SwitchToRemoteCommand` subclasses `Command` to transition from one remote to another. When
 * the command is executed it invokes the <RemoteController> object's `makeCurrentRemoteWithKey:`
 * method which, in turn, prompts the <RemoteViewController> observing to switch out the current
 * remote for the new one.
 */
@interface RESwitchToRemoteCommand : RECommand

/**
 * Default initializer for creating a `SwitchToRemoteCommand`.
 * @param key The key for the remote to which the remote controller should switch.
 * @param controller The `RemoteController` to which the command will be directed.
 * @return The newly created `SwitchToRemoteCommand`.
 */
+ (RESwitchToRemoteCommand *)commandInContext:(NSManagedObjectContext *)context key:(NSString *)key;


/// The key registered with the remote controller for the `Remote` object to switch to.
@property (nonatomic, strong) NSString * remoteKey;

/// `RemoteController` object managing the remote to switch to.
@property (nonatomic, strong, readonly) RERemoteController * remoteController;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Switching Configurations
////////////////////////////////////////////////////////////////////////////////

@interface RESwitchToConfigCommand : RECommand

+ (RESwitchToConfigCommand *)configCommandInContext:(NSManagedObjectContext *)ctx
                                      configuration:(RERemoteConfiguration)config;

@property (nonatomic, strong, readonly) RERemoteController    * remoteController;
@property (nonatomic, copy)             RERemoteConfiguration   configuration;

@end
