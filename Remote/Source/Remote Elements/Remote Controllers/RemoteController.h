//
// RemoteController.h
// Remote
//
// Created by Jason Cardwell on 7/21/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "ModelObject.h"
@protocol CommandDelegate;

@class Remote, ButtonGroup, Activity;

/**
 * `RemoteController` is a subclass of `NSManagedObject` that coordinates multiple <Remote>
 * objects to give the user dynamic control over their home theater system. It serves as a model
 * for a <RemoteViewController>, which acts as the primary controller for views associated with
 * actually implenting the remote control functionality within the application. One remote can be
 * designated as the 'home' remote to serve as the base for loading other remotes.
 */
@interface RemoteController : ModelObject

#pragma mark Getting the controller

/**
 * Calls `remoteControllerInContext:` with the main object context returned by <CoreDataManager>.
 */
+ (RemoteController *)remoteController;

/**
 * Creates a new `RemoteController` object in the given context.
 * @param context `NSManagedObjectContext` with which to create the remote.
 * @return The newly created `RemoteController` object.
 */
+ (RemoteController *)remoteControllerInContext:(NSManagedObjectContext *)context;

#pragma mark Remotes

/// The currently displayed remote
@property (nonatomic, strong, readonly) Remote * currentRemote;

/// The home remote from which activities are launched
@property (nonatomic, strong, readonly) Remote * homeRemote;

/**
 * Registers the specified `RERemote` as the controller's `homeRemote`.
 * @param The remote to register with the controller as the `homeRemote`
 * @return `YES` if remote validates and is set to be the home remote, `NO` otherwise
 */
- (BOOL)registerHomeRemote:(Remote *)remote;

/// All registered remotes
@property (nonatomic, strong, readonly) NSSet * remotes;

/**
 * Registers the specified `RERemote` with the controller.
 * @param The remote to register with the controller as a valid "switch-to" target
 */
- (void)registerRemote:(Remote *)remote;

/**
 * Retrieves the `Remote` object associated with the remote controller with the specified key.
 * @param key The `key`, `uuid`, or `identifier` of the remote to fetch.
 * @return The registered remote identified by `key` or nil
 */
- (Remote *)objectForKeyedSubscript:(NSString *)key;

#pragma mark Activities

/// The current activity for the controller or nil if no activity has launched.
@property (nonatomic, strong, readonly) Activity * currentActivity;

/// All registered activities
@property (nonatomic, strong, readonly) NSSet * activities;

/**
 * Registers an `REActivity` object with the controller
 * @param activity The activity to register with the controller
 * @return `YES` if the activity validates and is registered, `NO` otherwise
 */
- (BOOL)registerActivity:(Activity *)activity;

#pragma mark Top toolbar

/// Top toolbar that can be toggled in and out of sight over the currently displayed remote.
@property (nonatomic, strong, readonly) ButtonGroup * topToolbar;

/**
 * Registers the specified `REButtonGroup` as the controller's `topToolbar`.
 * @param The button group to be set as the controller's top toolbar
 * @return `YES` if the button group validates and is set as the top toolbar, `NO` otherwise
 */
- (BOOL)registerTopToolbar:(ButtonGroup *)buttonGroup;

#pragma mark Switching

/**
 * Sets <currentRemote> to the object retrieved for the specified key.
 * @param remote The remote to be set as the current remote.
 * @return `BOOL` indicating whether a remote with the specified key was found.
 */
- (BOOL)switchToRemote:(Remote *)remote;

/**
 * Updates the current activity, asking the existing activity, if set, to halt and allowing
 * the new activity to launch.
 * @param activity The new activity to be launched
 * @return Whether the specified activity could be made the current activity
 */
- (BOOL)switchToActivity:(Activity *)activity;

@end
