//
// CoreDataManager.h
// Remote
//
// Created by Jason Cardwell on 3/21/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

@interface CoreDataManager : NSObject

/**
 * Accessor for singleton instance
 */
 + (CoreDataManager const *)sharedManager;

/**
 * Initializes the main `NSManagedObjectContext` by setting up the core data stack
 * @return Whether setup was successful
 */
+ (BOOL)initializeCoreDataStack;
- (BOOL)initializeCoreDataStack;

/**
 * Accessor for the `NSManagedObjectModel` used to setup the core data stack
 * @return The managed object model
 */
+ (NSManagedObjectModel *)objectModel;
- (NSManagedObjectModel *)objectModel;

/**
 * Accessor for the main `NSManagedObjectContext`
 * @return The context
 */
+ (NSManagedObjectContext *)mainObjectContext;
- (NSManagedObjectContext *)mainObjectContext;

/**
 * Creates and returns a new managed object context with the same `NSPersistentStoreCoordinator` as
 * the main managed object context and with an undo manager if specified. Also sets the context's
 * `nametag` property if provided.
 * @param nametag String to set as the nametag for the new context
 * @param type Concurrency type to use when creating the new context
 * @param undoSupport Whether the context should have an undo manager attached to it
 * @return The new context
 */
+ (NSManagedObjectContext *)newContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)type
                                              undoSupport:(BOOL)undoSupport
                                                  nametag:(NSString *)nametag;
- (NSManagedObjectContext *)newContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)type
                                              undoSupport:(BOOL)undoSupport
                                                  nametag:(NSString *)nametag;

/**
 * Creates and returns a new child context with the main object context as a parent, undo support
 * as specified and with the specified `nametag`.
 * @param context The parent context for the new child context
 * @param type Concurrency type to use when creating the new context
 * @param undoSupport Whether to attach an undo manager to the new context
 * @param nametag String to set as the nametag for the new context
 * @return The new child context
 */
+ (NSManagedObjectContext *)childContextForContext:(NSManagedObjectContext *)context
                                   concurrencyType:(NSManagedObjectContextConcurrencyType)type
                                       undoSupport:(BOOL)undoSupport
                                           nametag:(NSString *)nametag;
- (NSManagedObjectContext *)childContextForContext:(NSManagedObjectContext *)context
                                   concurrencyType:(NSManagedObjectContextConcurrencyType)type
                                       undoSupport:(BOOL)undoSupport
                                           nametag:(NSString *)nametag;


/**
 * Saves the main object context with a completion block invoked afterwards
 * @param context The context to save
 * @param asyncrhonous Whether save should be executed inside `performBlock:` or `performBlockAndWait:`
 * @param completion The block takes one parameter for indicating whether the save was successful
 * @return `YES` if save executed or queued successfully, depending on the value of `asynchronous`
 */
+ (BOOL)saveContext:(NSManagedObjectContext *)context
       asynchronous:(BOOL)asynchronous
         completion:(void (^)(BOOL success))completion;
- (BOOL)saveContext:(NSManagedObjectContext *)context
       asynchronous:(BOOL)asynchronous
         completion:(void (^)(BOOL success))completion;

/**
 * Resets the specified managed object context
 * @param context The context to reset
 */
+ (void)resetContext:(NSManagedObjectContext *)context;
- (void)resetContext:(NSManagedObjectContext *)context;

@end
