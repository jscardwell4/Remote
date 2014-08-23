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


////////////////////////////////////////////////////////////////////////////////
#pragma mark MagicalRecord wrappers
////////////////////////////////////////////////////////////////////////////////

+ (void)saveWithBlock:(void(^)(NSManagedObjectContext *localContext))block;
+ (void)saveWithBlock:(void(^)(NSManagedObjectContext *localContext))block
           completion:(void(^)(BOOL success, NSError *error))completion;
+ (void)saveWithBlockAndWait:(void(^)(NSManagedObjectContext *localContext))block;


@end
