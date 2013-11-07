 //
// CoreDataManager.m
// Remote
//
// Created by Jason Cardwell on 3/21/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "CoreDataManager.h"
#import "MSRemoteAppController.h"
#import "RemoteController.h"

//#define LOG_OBJECT_MODEL

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Typedefs and Class Variables
////////////////////////////////////////////////////////////////////////////////

typedef NS_OPTIONS (NSUInteger, CoreDataObjectRemovalOptions) {
    CoreDataManagerRemoveNone                   = 0 << 0,
    CoreDataManagerRemoveIcons                  = 1 << 0,
    CoreDataManagerRemoveBackgrounds            = 1 << 1,
    CoreDataManagerRemoveCodes                  = 1 << 2,
    CoreDataManagerRemoveRemotes                = 1 << 3,
    CoreDataManagerRemoveRemoteController       = 1 << 4,
    CoreDataManagerRemoveRemoveButtonGroups     = 1 << 5,
    CoreDataManagerRemoveRemoveButtons          = 1 << 6,
    CoreDataManagerRemoveConfigurationDelegates = 1 << 7,
    CoreDataManagerRemoveControlStateSets       = 1 << 8
};

static MagicalRecordStack * kDefaultStack;

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static const int msLogContext = (LOG_CONTEXT_COREDATA|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
static const int magicalRecordContext = (LOG_CONTEXT_MAGICALRECORD);//|LOG_CONTEXT_CONSOLE);

struct DatabaseFlags_s {
    NSUInteger   objectRemoval;
    BOOL         rebuildDatabase;
    BOOL         rebuildRemote;
    BOOL         removePreviousDatabase;
    BOOL         replacePreviousDatabase;
    BOOL         logSaves;
    BOOL         logCoreDataStackSetup;
} kFlags;

NSString *(^getContextDescription)(NSManagedObjectContext *) =
^NSString *(NSManagedObjectContext * context)
{
    return (StringIsNotEmpty(context.nametag) ? $(@"%@", context.nametag) : $(@"%p", context));
};


MSSTATIC_STRING_CONST   kCoreDataManagerSQLiteName = @"Remote.sqlite";



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Model category interface
////////////////////////////////////////////////////////////////////////////////

@interface CoreDataManager (Model)

/**
 * Provides a detailed description of the specified managed object model suitable for logging.
 * @param model The model to describe, or nil for the default model
 * @return String containing a description of the managed object model
 */
+ (NSString *)objectModelDescription:(NSManagedObjectModel *)model;

/**
 * Makes a mutable copy of the specified managed object model and modifies various attribute
 * description class value names and default values.
 * @param model The editable managed object model to modify
 * @return The edited model or nil if the specified model was uneditable or incompatible
 */
+ (NSManagedObjectModel *)augmentModel:(NSManagedObjectModel *)model;

/**
 * Uses the logging framework to print out the object model description for the specified model.
 * @param model The model whose description will be logged
 */
+ (void)logObjectModel:(NSManagedObjectModel *)model;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - CoreDataManager Implementation
////////////////////////////////////////////////////////////////////////////////

@implementation CoreDataManager

+ (void)initialize
{
    if (self == [CoreDataManager class])
    {
        BOOL loadData = [UserDefaults boolForKey:@"loadData"];
        BOOL rebuildRemote   = [UserDefaults boolForKey:@"rebuildRemote"];
        BOOL replaceDatabase = [UserDefaults boolForKey:@"replace"];
        kFlags = (struct DatabaseFlags_s) {
            .logSaves                = YES,
            .logCoreDataStackSetup   = YES,
            .removePreviousDatabase  = replaceDatabase||loadData,
            .rebuildRemote           = (rebuildRemote||loadData),
            .rebuildDatabase         = loadData,
            .replacePreviousDatabase = replaceDatabase,
            .objectRemoval           = CoreDataManagerRemoveNone
        };
        assert(   (kFlags.replacePreviousDatabase && !(kFlags.rebuildDatabase || kFlags.rebuildRemote))
               || !kFlags.replacePreviousDatabase);
    }
}

+ (BOOL)initializeDatabase
{
    __block BOOL success = YES;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        [MagicalRecord setLogContext:magicalRecordContext];
        [MagicalRecord setLogLevel:ddLogLevel];

        NSManagedObjectModel * model = [self augmentModel:[NSManagedObjectModel
                                                           MR_mergedObjectModelFromMainBundle]];
        assert(model);

#ifdef LOG_OBJECT_MODEL
        [self logObjectModel:model];
#endif
        
        BOOL databaseStoreExists = [self databaseStoreExists];
        if (databaseStoreExists && kFlags.removePreviousDatabase)
        {
            success = [self removeExistingStore];
            assert(success);
        }

        // Copy bundle resource to store destination if needed
        if (!databaseStoreExists && kFlags.replacePreviousDatabase)
        {
            success = [self copyBundleDatabaseStore];
            assert(success);
        }

        assert(([self databaseStoreExists] ^ kFlags.rebuildDatabase));
        
        MSLogDebugTag(@"file operations complete, database %@ flagged for rebuilding",
                      kFlags.rebuildDatabase ? @"is" : @"is not");

        // Use Magical Record to create the coordinator with calculated store path
        // and intialize the default managed object context
        kDefaultStack =
            [MagicalRecord
                     setupAutoMigratingCoreDataStackWithSqliteStoreNamed:kCoreDataManagerSQLiteName
                                                                   model:model];

//        NSManagedObjectContext * moc = kDefaultStack.context;
//        if (moc.parentContext) [moc registerAsChildOfContext:moc.parentContext];
        if (databaseStoreExists && kFlags.rebuildRemote)
        {
            success = [self removeExistingRemote];
            assert(success);
        }
    });
    
    return success;
}

+ (void)makeContext:(NSManagedObjectContext *)moc performBlock:(void (^)(void))block
{
    if (moc.concurrencyType == NSConfinementConcurrencyType) block();
    else [moc performBlock:block];
}

+ (void)makeContext:(NSManagedObjectContext *)moc performBlockAndWait:(void (^)(void))block
{
    if (moc.concurrencyType == NSConfinementConcurrencyType) block();
    else [moc performBlockAndWait:block];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Objects
////////////////////////////////////////////////////////////////////////////////

+ (NSManagedObjectContext *)defaultContext
{
    return kDefaultStack.context;
}

+ (void)resetDefaultContext
{
    NSManagedObjectContext * moc = [self defaultContext];
    [moc performBlockAndWait:^{ [moc reset]; }];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Database File Operations
////////////////////////////////////////////////////////////////////////////////

+ (NSURL *)databaseStoreURL
{
    static NSURL * databaseStoreURL = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      NSMutableArray * path =
                          [[[MainBundle executablePath] pathComponents] mutableCopy];
                      [path replaceObjectsInRange:NSMakeRange([path count] - 2, 1)
                                       withObjectsFromArray:@[@"Library", @"Application Support"]];
                      [path addObject:kCoreDataManagerSQLiteName];
                      databaseStoreURL = [NSURL fileURLWithPath:[NSString pathWithComponents:path]];
                  });
    return databaseStoreURL;
}

+ (NSURL *)databaseBundleURL
{
    static NSURL * databaseBundleURL = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        databaseBundleURL = [MainBundle URLForResource:kCoreDataManagerSQLiteName withExtension:nil];
    });
    return databaseBundleURL;
}

+ (BOOL)databaseStoreExists
{
    return [[self databaseStoreURL] checkResourceIsReachableAndReturnError:NULL];
}

+ (BOOL)copyBundleDatabaseStore
{
    NSError * error = nil;

    [FileManager copyItemAtURL:[self databaseBundleURL] toURL:[self databaseStoreURL] error:&error];

    if (error)
    {
        MSHandleErrors(error);
        return NO;
    }

    else if (![self databaseStoreExists])
    {
        MSLogErrorTag(@"bundle database copied but not found at destination store location");
        return NO;
    }

    else
    {
        MSLogDebugTag(@"bundle database store copied to destination successfully");
        return YES;
    }
}

+ (BOOL)removeExistingStore
{
    NSError * error = nil;
    
    if (![self databaseStoreExists])
    {
        MSLogDebugTag(@"no previous database store found to remove");
        return YES;
    }

    else if (![FileManager removeItemAtURL:[self databaseStoreURL] error:&error])
    {
        MSHandleErrors(error);
        return NO;
    }

    else
    {
        MSLogDebugTag(@"previous database store has been removed");
        return YES;
    }
}

+ (BOOL)removeExistingRemote
{
    __block BOOL success = YES;
    NSManagedObjectContext * moc = kDefaultStack.context;
    [moc performBlockAndWait:
     ^{
         RemoteController * controller = [RemoteController MR_findFirstInContext:moc];
         MSLogDebugTag(@"existing remote? %@", NSStringFromBOOL((controller != nil)));
         if (controller)
         {
             [moc deleteObject:controller];
             MSLogDebugTag(@"existing remote has been deleted");
         }
         NSError * error = nil;
         [moc save:&error];
         if (error)
         {
             [CoreDataManager handleErrors:error];
             success = NO;
         }
     }];

    if (success)
        [moc performBlockAndWait:
         ^{
             RemoteController * controller = [RemoteController MR_findFirstInContext:moc];
             success = (controller == nil ? YES : NO);
         }];
    
    return success;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Error Handling
////////////////////////////////////////////////////////////////////////////////

+ (void)handleErrors:(NSError *)error
{
    NSMutableString * errorMessage = [@"" mutableCopy];
    if ([error isKindOfClass:[MSError class]])
    {
        NSString * message = ((MSError *)error).message;
        if (message) [errorMessage appendFormat:@"!!! %@ !!!", message];
        error = ((MSError *)error).error;
    }

    NSDictionary *userInfo = [error userInfo];
    for (NSArray *detailedError in [userInfo allValues])
    {
        if ([detailedError isKindOfClass:[NSArray class]])
        {
            for (NSError *e in detailedError)
            {
                if ([e respondsToSelector:@selector(userInfo)])
                    [errorMessage appendFormat:@"Error Details: %@\n", [e userInfo]];

                else
                    [errorMessage appendFormat:@"Error Details: %@\n", e];
            }
        }

        else
            [errorMessage appendFormat:@"Error: %@", detailedError];
    }
    [errorMessage appendFormat:@"Error Message: %@\n", [error localizedDescription]];
    [errorMessage appendFormat:@"Error Domain: %@\n", [error domain]];
    MSLogErrorTag(@"%@\nRecovery Suggestion: %@", errorMessage, [error localizedRecoverySuggestion]);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark MagicalRecord wrappers
////////////////////////////////////////////////////////////////////////////////

+ (void)saveWithBlock:(void(^)(NSManagedObjectContext *localContext))block
{
    [kDefaultStack saveWithBlock:block];
}

+ (void)saveWithBlock:(void(^)(NSManagedObjectContext *localContext))block
           completion:(MRSaveCompletionHandler)completion
{
    [kDefaultStack saveWithBlock:block completion:completion];
}

+ (void)saveWithBlock:(void (^)(NSManagedObjectContext *))block
           identifier:(NSString *)contextWorkingName
           completion:(MRSaveCompletionHandler)completion
{
    [kDefaultStack saveWithBlock:block identifier:contextWorkingName completion:completion];
}

+ (void)saveWithIdentifier:(NSString *)identifier block:(void(^)(NSManagedObjectContext *))block
{
    [kDefaultStack saveWithIdentifier:identifier block:block];
}

+ (void)saveWithBlockAndWait:(void(^)(NSManagedObjectContext *localContext))block
{
    [kDefaultStack saveWithBlockAndWait:block];
}


@end
