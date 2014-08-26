//
// CoreDataManager.h
// Remote
//
// Created by Jason Cardwell on 3/21/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

@interface CoreDataManager : NSObject

/**
 * Sets up the core data stack using the Magical Record framework.
 * @return Whether setup was successful
 */
+ (BOOL)initializeDatabase;

+ (NSManagedObjectContext *)defaultContext;

+ (NSManagedObjectContext *)childContextOfType:(NSManagedObjectContextConcurrencyType)type;
+ (NSManagedObjectContext *)childContextOfType:(NSManagedObjectContextConcurrencyType)type forContext:(NSManagedObjectContext *)moc;

+ (void)resetDefaultContext;

+ (void)makeContext:(NSManagedObjectContext *)moc performBlock:(void (^)(void))block;

+ (void)makeContext:(NSManagedObjectContext *)moc performBlockAndWait:(void (^)(void))block;

+ (void)saveWithBlock:(void(^)(NSManagedObjectContext *localContext))block;
+ (void)saveWithBlock:(void(^)(NSManagedObjectContext *localContext))block
           completion:(void(^)(BOOL success, NSError *error))completion;
+ (void)saveWithBlockAndWait:(void(^)(NSManagedObjectContext *localContext))block;

@end

@interface CoreDataManager (Model)

/// Method for generating a detailed description of a model suitable for printing.
/// @param model NSManagedObjectModel * The model to describe. If nil, the merged bundle model is used.
/// @return NSString * The model's description
+ (NSString *)objectModelDescription:(NSManagedObjectModel *)model;

/// Helper for setting a different default value for an attribute of an entity than is set for its parent
/// @param entity NSEntityDescription * The entity whose attribute shall have its default value set.
/// @param attribute NSString * The name of the attribute of the entity whose attribute shall be modified.
/// @param defaultValue id The value to set as default for the specified attribute of the entity.
+ (NSManagedObjectModel *)augmentModel:(NSManagedObjectModel *)model;

/// Method for logging a model's description to file.
/// @param model NSManagedObjectModel * The model whose description shall be logged.
/// @seealso `objectModelDescription:`
+ (void)logObjectModel:(NSManagedObjectModel *)model;

@end


