//
// RemoteController.h
// Remote
//
// Created by Jason Cardwell on 7/21/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

@protocol CommandDelegate;

@class                RERemote, REActivityButton, REButtonGroup;
MSKIT_EXTERN_STRING   MSRemoteControllerHomeRemoteKeyName;
MSKIT_EXTERN_STRING   MSRemoteControllerTopToolbarKeyName;

/**
 * `RemoteController` is a subclass of `NSManagedObject` that coordinates multiple <Remote>
 * objects to give the user dynamic control over their home theater system. It serves as a model
 * for a <RemoteViewController>, which acts as the primary controller for views associated with
 * actually implenting the remote control functionality within the application. One remote can be
 * designated as the 'home' remote to serve as the base for loading other remotes.
 */
@interface RERemoteController : NSManagedObject

/**
 * Creates a new `RemoteController` object in the given context.
 * @param context `NSManagedObjectContext` with which to create the remote.
 * @return The newly created `RemoteController` object.
 */
+ (RERemoteController *)remoteControllerInContext:(NSManagedObjectContext *)context;

/**
 * Calls `remoteControllerInContext:` with the main object context returned by <CoreDataManager>.
 */
+ (RERemoteController *)remoteController;

/**
 * The `Remote` currently being displayed by the `RemoteViewController` utilizing the
 * `RemoteController`.
 */
@property (nonatomic, strong, readonly) RERemote * currentRemote;

/**
 * The `Remote` registered as the "home screen" for the remote control interface.
 */
@property (nonatomic, strong, readonly) RERemote * homeRemote;

/**
 * Top toolbar that can be toggled in and out of sight over the currently displayed remote.
 */
@property (nonatomic, strong) REButtonGroup * topToolbar;

/**
 * Sets <currentRemote> to the object retrieved for the specified key.
 * @param key The key of the remote to be set as the current remote.
 * @return `BOOL` indicating whether a remote with the specified key was found.
 */
- (BOOL)switchToRemoteWithKey:(NSString *)key;

/**
 * Retrieves the `Remote` object associated with the remote controller with the specified key.
 * @param key The key of the remote to fetch.
 * @return The remote with the specified key registered with the controller.
 */
- (RERemote *)remoteWithKey:(NSString *)key;

@property (nonatomic, readonly) NSArray * allRemotes;

/**
 * The current activity for the controller or nil if no activity has launched.
 */
@property (nonatomic, strong) NSString * currentActivity;

/**
 * Method for launching or exiting the activity represented by the specified button.
 * @param button The `ActivityButton` for determining what actions to take.
 * @return Whether the action executed successfully.
 */
- (void)activityActionForButton:(REActivityButton *)button;

- (RERemote *)objectForKeyedSubscript:(NSString *)key;

@end
