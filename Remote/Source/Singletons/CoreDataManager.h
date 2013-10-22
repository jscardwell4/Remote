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


+ (void)handleErrors:(NSError *)error;

+ (NSManagedObjectContext *)defaultContext;

+ (void)resetDefaultContext;

+ (void)makeContext:(NSManagedObjectContext *)moc performBlock:(void (^)(void))block;

+ (void)makeContext:(NSManagedObjectContext *)moc performBlockAndWait:(void (^)(void))block;


////////////////////////////////////////////////////////////////////////////////
#pragma mark MagicalRecord wrappers
////////////////////////////////////////////////////////////////////////////////

+ (void)saveWithBlock:(void(^)(NSManagedObjectContext *localContext))block;
+ (void)saveWithBlock:(void(^)(NSManagedObjectContext *localContext))block
           completion:(MRSaveCompletionHandler)completion;
+ (void)saveWithBlock:(void (^)(NSManagedObjectContext *))block
           identifier:(NSString *)contextWorkingName
           completion:(MRSaveCompletionHandler)completion;

+ (void)saveWithIdentifier:(NSString *)identifier block:(void(^)(NSManagedObjectContext *))block;
+ (void)saveWithBlockAndWait:(void(^)(NSManagedObjectContext *localContext))block;


@end
