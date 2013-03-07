//
// CoreDataManager.h
// iPhonto
//
// Created by Jason Cardwell on 3/21/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#define DataManager [CoreDataManager sharedManager]

@interface CoreDataManager : NSObject

///@name Core data stack

/**
 * Accessor for the shared instance of `CoreDataManager`
 *
 * @return The shared instance
 */
+ (CoreDataManager *)sharedManager;

/**
 * Initializes the main `NSManagedObjectContext` by setting up the core data stack
 *
 * @return Whether setup was successful
 */
+ (BOOL)setUpCoreDataStack;

/**
 * Accessor for the `NSManagedObjectModel` used to setup the core data stack
 *
 * @return The managed object model
 */
- (NSManagedObjectModel *)objectModel;

/**
 * Accessor for the main `NSManagedObjectContext`
 *
 * @return The context
 */
- (NSManagedObjectContext *)mainObjectContext;

///@name Creating a new managed object context

/**
 * Creates and returns a new managed object context with the same `NSPersistentStoreCoordinator` as
 * the main managed object context and with an undo manager if specified. Also sets the context's
 * `nametag` property if provided.
 *
 * @param nametag String to set as the nametag for the new context
 *
 * @param type Concurrency type to use when creating the new context
 *
 * @param undoManager Whether the context should have an undo manager attached to it
 *
 * @return The new context
 */
- (NSManagedObjectContext *)newContextWithNametag:(NSString *)nametag
                                  concurrencyType:(NSManagedObjectContextConcurrencyType)type
                                      undoManager:(BOOL)undoManager;

/**
 * Creates and returns a new managed object context with the same `NSPersistentStoreCoordinator` as
 * the main managed object context and with an undo manager if specified. Also sets the context's
 * `nametag` property if provided.
 *
 * @param nametag String to set as the nametag for the new context
 *
 * @param undoManager Whether the context should have an undo manager attached to it
 *
 * @return The new context
 */
- (NSManagedObjectContext *)newContextWithNametag:(NSString *)nametag undoManager:(BOOL)undoManager;

/**
 * Creates and returns a new managed object context with the same `NSPersistentStoreCoordinator` as
 * the main managed object context, no undo manager, and with the specified `nametag`.
 *
 * @param nametag String to set as the nametag for the new context
 *
 * @return The new context
 */
- (NSManagedObjectContext *)newContextWithNametag:(NSString *)nametag;

/**
 * Creates and returns a new managed object context with the same `NSPersistentStoreCoordinator` as
 * the main managed object context and with an undo manager if specified.
 *
 * @param undoManager Whether the context should have an undo manager attached to it
 *
 * @return The new context
 */
- (NSManagedObjectContext *)newContext:(BOOL)undoManager;

/**
 * Creates and returns a new managed object context with the same `NSPersistentStoreCoordinator` as
 * the main managed object context
 *
 * @return The new context
 */
- (NSManagedObjectContext *)newContext;

///@name Creating a new child managed object context


/**
 * Creates and returns a new child context with the main object context as a parent, undo support
 * as specified and with the specified `nametag`.
 *
 * @param nametag String to set as the nametag for the new context
 *
 * @param type Concurrency type to use when creating the new context
 *
 * @param undoManager Whether to attach an undo manager to the new context
 *
 * @return The new child context
 */
- (NSManagedObjectContext *)childContextWithNametag:(NSString *)nametag
                                         forContext:(NSManagedObjectContext *)context
                                    concurrencyType:(NSManagedObjectContextConcurrencyType)type
                                        undoManager:(BOOL)undoManager;

/**
 * Creates and returns a new child context with the main object context as a parent, undo support
 * as specified and with the specified `nametag`.
 *
 * @param nametag String to set as the nametag for the new context
 *
 * @param undoManager Whether to attach an undo manager to the new context
 *
 * @return The new child context
 */
- (NSManagedObjectContext *)childContextWithNametag:(NSString *)nametag undoManager:(BOOL)undoManager;

/**
 * Creates and returns a new child context with the main object context as a parent, without an
 * undo manager, and with the specified `nametag`.
 *
 * @param nametag String to set as the nametag for the new context
 *
 * @return The new child context
 */
- (NSManagedObjectContext *)childContextWithNametag:(NSString *)nametag;

/**
 * Creates and returns a new child context with the main object context as a parent
 *
 * @param undoManager Whether to attach an undo manager to the new context
 *
 * @return The new child context
 */
- (NSManagedObjectContext *)childContext:(BOOL)undoManager;

/**
 * Creates and returns a new child context with the main object context as a parent and without an
 * undo manager.
 *
 * @return The new child context
 */
- (NSManagedObjectContext *)childContext;

/**
 * Creates and returns a new child context with the specified context as a parent and with the
 *specified
 * `nametag`.
 *
 * @param nametag String to set as the nametag for the new context
 *
 * @param context The parent context for the new child context
 *
 * @param undoManager Whether to attach an undo manager to the new context
 *
 * @return The new child context
 */
- (NSManagedObjectContext *)childContextWithNametag:(NSString *)nametag
                                         forContext:(NSManagedObjectContext *)context
                                        undoManager:(BOOL)undoManager;

/**
 * Creates and returns a new child context with the specified context as a parent and without an
 *undo
 * manager and with the specified `nametag`.
 *
 * @param nametag String to set as the nametag for the new context
 *
 * @param context The parent context for the new child context
 *
 * @return The new child context
 */
- (NSManagedObjectContext *)childContextWithNametag:(NSString *)nametag
                                         forContext:(NSManagedObjectContext *)context;

/**
 * Creates and returns a new child context with the specified context as a parent.
 *
 * @param context The parent context for the new child context
 *
 * @param undoManager Whether to attach an undo manager to the new context
 *
 * @return The new child context
 */
- (NSManagedObjectContext *)childContextForContext:(NSManagedObjectContext *)context
                                       undoManager:(BOOL)undoManager;

/**
 * Creates and returns a new child context with the specified context as a parent and without an
 *undo
 * manager.
 *
 * @param context The parent context for the new child context
 *
 * @return The new child context
 */
- (NSManagedObjectContext *)childContextForContext:(NSManagedObjectContext *)context;

///@name Saving and resetting managed object contexts

/**
 * Saves the main object context
 *
 * @return Whether the save was successful
 */
- (BOOL)saveMainContext;

/**
 * Saves the specified child context
 *
 * @param childContext The child context to save
 *
 * @return Whether the save was successful
 */
- (BOOL)saveChildContext:(NSManagedObjectContext *)childContext;

/**
 * Saves the main object context with a completion block invoked afterwards
 *
 * @param completion The block to call after the save takes one parameter indication whether the
 * save was successful
 */
- (void)saveContextWithCompletion:(void (^)(BOOL success))completion;

/**
 * Resets the main managed object context
 */
- (void)emptyContext;

@end
