//
// Command.h
// iPhonto
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "ConnectionManager.h"
#import "ComponentDevice.h"
#import "CommandDelegate.h"

typedef NS_ENUM (int16_t, SystemCommandKey) {
    SystemCommandToggleProximitySensor = 0,
    SystemCommandURLRequest            = 1,
    SystemCommandReturnToLaunchScreen  = 2,
    SystemCommandOpenSettings          = 3,
    SystemCommandOpenEditor            = 4
};

@class   Command, Button, ComponentDevice, IRCode, RemoteController;

#pragma mark - Command interface

/**
 * The `Command` class subclasses `NSManagedObject` to model a command to be executed. Most of the
 * time the command is executed as a result of the user pressing a button; however, some commands
 * execute other commands and chain the result back up to the command that initiated the execution.
 * `Command` objects are not intended to be created directly. Instead, there are many subclasses
 * that
 * customize behavior for particular tasks: <PowerCommand>, <MacroCommand>, <DelayCommand>,
 * <SystemCommand>, <SendIRCommand>, <HTTPCommand>, <SwitchToRemoteCommand>.
 */
@interface Command : NSManagedObject <MSDebugDescription, CommandDelegate>

+ (Command *)commandInContext:(NSManagedObjectContext *)context;

/// @name ￼Executing commands

/**
 * Executes the task associated with the command with the specified options.
 * @param sender Object to which the results of execution should be provided.
 * @param options `CommandOptions` to apply when executing the command.
 */
- (void)execute:(id <CommandDelegate> )sender;

/// @name ￼Tracking commands

/**
 * Number assignable to the command for various purposes.
 * @warn Not guaranteed to be unique.
 */
@property (nonatomic, assign) int16_t   tag;

@property (nonatomic, strong) Button * button;

@end

#pragma mark - PowerCommand interface

/**
 * `PowerCommand` subclasses `Command` for the sole purpose of telling a `ComponentDevice` to be
 * turned on or off.
 */
@interface PowerCommand : Command

/// @name ￼Creating a PowerCommand

+ (PowerCommand *)powerCommandInContext:(NSManagedObjectContext *)context;

/**
 * Default initializer for creating a new `PowerCommand`.
 * @param componentDevice The device for which power should be switched on or off.
 * @param state Whether the command should turn the device off or on.
 * @return The newly created `PowerCommand` object.
 */
+ (PowerCommand *)powerCommandForDevice:(ComponentDevice *)componentDevice
                               andState:(ComponentDevicePowerState)state;

/// @name ￼Executing the command

/**
 * Holds the `ComponentDevicePowerState` associated with the command. `NO` is equal to
 * `ComponentDevicePowerStateOff` and `YES` is equal to `ComponentDevicePowerStateOn`.
 */
@property (nonatomic) BOOL   powerState;

/**
 * The device to which the command is directed.
 */
@property (nonatomic, strong) ComponentDevice * device;

@end

#pragma mark - MacroCommand interface

/**
 * `MacroCommand` is a `Command` subclass that can execute a series of commands.
 */
@interface MacroCommand : Command

/// @name ￼Creating a MacroCommand

/**
 * Default initialize for creating a `MacroCommand`.
 */
+ (MacroCommand *)macroCommandInContext:(NSManagedObjectContext *)context;

/// @name Managing the collection of command objects

/**
 * Adds a new command to the collection of commands executed.
 * @param command The command to be added.
 */
- (void)addCommand:(Command *)command;

/**
 * Inserts a new command at the specified index for setting the order of execution.
 * @param command The command to be added.
 * @param index The index at which the command is to be placed.
 */
- (void)insertCommand:(Command *)command atIndex:(NSUInteger)index;

/**
 * Removes the command at the specified index.
 * @param index The index of the command to be removed.
 */
- (void)removeCommandAtIndex:(NSUInteger)index;

/**
 * Returns the command at the specified index.
 * @param index The index of the command to return.
 */
- (Command *)commandAtIndex:(NSUInteger)index;
- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;

@property (nonatomic, readonly) NSUInteger   numberOfCommands;

@end

#pragma mark - DelayCommand interface

/**
 * `DelayCommand` subclasses `Command` to provide a delay, usually in a chain of other commands.
 */
@interface DelayCommand : Command

/// @name ￼Creating a DelayCommand

+ (DelayCommand *)delayCommandInContext:(NSManagedObjectContext *)context;

/**
 * Default initializer for creating a `DelayCommand`.
 * @param duration The length of time to wait before execution is successful.
 * @param context `NSManagedObjectContext` in which to create the command.
 * @return The newly created `DelayCommand` object.
 */
+ (DelayCommand *)delayCommandWithDuration:(CGFloat)duration
                                 inContext:(NSManagedObjectContext *)context;

@property (nonatomic, assign) CGFloat   duration;
@end

#pragma mark - SystemCommand interface

@class   RemoteViewController;

/**
 * `SystemCommand` subclasses `Command` to perform tasks that interact with `UIKit` objects like
 * `UIDevice`. Currently it is capable of toggling proximity monitoring on and off; however,
 * this application as it stands does not use `SystemCommand` for anything.
 */
@interface SystemCommand : Command

/// @name ￼Getting a SystemCommand

/**
 * Retrieves the `SystemCommand` object for the specified key, creating it if it does not already
 * exist.
 * @param key `SystemCommandKey` for the desired command.
 * @param context Context from which the command will be retrieved.
 * @return The existing or newly created `SystemCommand` for the specified key.
 */
+ (SystemCommand *)systemCommandWithKey:(SystemCommandKey)key
                              inContext:(NSManagedObjectContext *)context;

+ (BOOL)registerRemoteViewController:(RemoteViewController *)remoteViewController;

@end

#pragma mark - SendIRCommand interface

/**
 * `SendIRCommand` subclasses `Command` to send IR commands via <ConnectionManager> to networked
 * IR receivers that control the user's home theater system. At this time, only
 * [iTach](http://www.globalcache.com/products/itach) devices from Global Caché are supported.
 */
@interface SendIRCommand : Command <ConnectionManagerDelegate>

/// @name ￼Creating a SendIRCommand

/**
 * Default intializer for creating a new `SendIRCommand`.
 * @param code IR code to send on execution.
 * @return The newly created `SendIRCommand`.
 */
+ (SendIRCommand *)sendIRCommandWithIRCode:(IRCode *)code;

+ (SendIRCommand *)sendIRCommandInContext:(NSManagedObjectContext *)context;

/// @name ￼Methods relating to the command's `IRCode` object

/**
 * Wrapper for the `IRCode` object's `port` property.
 */
@property (nonatomic, readonly) NSInteger   port;

@property (nonatomic, assign)  int16_t   portOverride;

/**
 * `IRCode` object that encapsulates the networked device information necessary for sending the
 * command.
 */
@property (nonatomic, strong) IRCode * code;

/**
 * The actual command delivered to the networked device via the `ConnectionManager`. It is derived
 * from the various attributes of the command's `IRCode`.
 */
@property (nonatomic, strong, readonly) NSString * commandString;

/**
 * Wrapper for the `IRCode` object's `device` property.
 */
@property (nonatomic, readonly) ComponentDevice * device;

/**
 * Whether the `ComponentDevice` object associtated with the command should be notified after
 * execution. This is set when `CommandOptions` include the `CommandOptionsNotifyComponentDevice`
 * flag.
 */
@property (nonatomic, assign) BOOL   notifyDevice;

@end

#pragma mark - HTTPCommand interface

/**
 * `HTTPCommand` subclasses `Command` to send a one way http request. Currently this can be use with
 * a networked device that receives commands via a server that parses url parameters such as Insteon
 * [SmartLinc](http://www.insteon.net/2412N-smartlinc-central-controller.html) controllers.
 */
@interface HTTPCommand : Command

/// @name ￼Creating an HTTPCommand

/**
 * Default initializer for creating a new `HTTPCommand`.
 * @param urlString String containing the url to be requested by `ConnectionManager`.
 * @param context `NSManagedObjectContext` in which to create the command.
 * @return The newly created `HTTPCommand` object.
 */
+ (HTTPCommand *)HTTPCommandWithURL:(NSString *)urlString
                          inContext:(NSManagedObjectContext *)context;

+ (HTTPCommand *)httpCommandInContext:(NSManagedObjectContext *)context;

/// @name ￼Managing the url of the request sent by the command

/**
 * The url for the http request sent by <ConnectionManager>.
 */
@property (nonatomic, retain) NSString * url;

@end

#pragma mark - SwitchToRemoteCommand interface

/**
 * `SwitchToRemoteCommand` subclasses `Command` to transition from one remote to another. When
 * the command is executed it invokes the <RemoteController> object's `makeCurrentRemoteWithKey:`
 * method which, in turn, prompts the <RemoteViewController> observing to switch out the current
 * remote for the new one.
 */
@interface SwitchToRemoteCommand : Command

/// @name ￼Creating a SwitchToRemoteCommand

+ (SwitchToRemoteCommand *)switchToRemoteCommandInContext:(NSManagedObjectContext *)context;

/**
 * Default initializer for creating a `SwitchToRemoteCommand`.
 * @param key The key for the remote to which the remote controller should switch.
 * @param controller The `RemoteController` to which the command will be directed.
 * @return The newly created `SwitchToRemoteCommand`.
 */
+ (SwitchToRemoteCommand *)switchToRemoteCommandInContext:(NSManagedObjectContext *)context
                                                      key:(NSString *)key;

/**
 * The key registered with the remote controller for the `Remote` object to switch to.
 */
@property (nonatomic, strong) NSString * remoteKey;

/**
 * `RemoteController` object managing the remote to switch to.
 */
@property (nonatomic, strong) RemoteController * remoteController;

@end
