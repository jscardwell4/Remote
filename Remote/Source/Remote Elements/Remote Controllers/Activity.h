//
//  Activity.h
//  Remote
//
//  Created by Jason Cardwell on 4/10/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "ModelObject.h"
@class REActivityButton, Remote, RemoteController, MacroCommand;

@interface Activity : ModelObject <NamedModelObject>

@property (nonatomic, strong)           Remote * remote;
@property (nonatomic, copy, readonly)   NSString * name;

/**
 * Default initializer for creating an `REActivity` using the current thread context.
 * @param name The name to use when identifying the activity
 * @return The new activity
 */
+ (instancetype)activityWithName:(NSString *)name;

/**
 * Default initializer for creating an `REActivity` using the specified context.
 * @param name The name to use when identifying the activity
 * @param context The context in which the activity shall be created
 * @return The new activity
 */
+ (instancetype)activityWithName:(NSString *)name inContext:(NSManagedObjectContext *)context;

/**
 * Changes the name of the activity, if the specified name does not conflict with an existing activity.
 * @param name The new name for the activity
 * @return Whether the name was changed successfully
 */
- (BOOL)updateName:(NSString *)name;

/**
 * Launches the activity by invoking the launch macro and switching to the activity's remote.
 * @return Whether the activity launched successfully
 */
- (BOOL)launchActivity;

/// macro executed to commence activity
@property (nonatomic, strong) MacroCommand * launchMacro;

/**
 * Halts the activity by invoking the halt macro and switching to the home remote.
 * @return Whether the activity halted successfully
 */
- (BOOL)haltActivity;


/**
 * If activity is active, this method calls `haltActivity`, otherwise it calls `launchActvity`.
 * @return Whether the activity launched or halted successfully
 */
- (BOOL)launchOrHault;

/// macro executed to cease activity
@property (nonatomic, strong) MacroCommand * haltMacro;

/**
 * Launches the activity by invoking the launch macro and switching to the activity's remote.
 * @param completion Block to execute upon completing the task
 */
- (void)launchActivity:(void (^)(BOOL success, NSError * error))completion;

/**
 * Halts the activity by invoking the halt macro and switching to the home remote.
 * @param completion Block to execute upon completing the task
 */
- (void)haltActivity:(void (^)(BOOL success, NSError * error))completion;

/**
 * If activity is active, this method calls `haltActivity:`, otherwise it calls `launchActvity:`.
 * @param completion The completion block to pass through to the halting or launching method
 */
- (void)launchOrHault:(void (^)(BOOL success, NSError * error))completion;

@end
