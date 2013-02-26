//
// CoreDataManager.m
// iPhonto
//
// Created by Jason Cardwell on 3/21/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "MSKit/MSKit.h"
#import "CoreDataManager.h"
#import "MSRemoteAppController.h"

#define SCHEMA_LOG_CONTEXT COREDATA_F
#define DEBUG_CONTEXT      COREDATA_F

typedef NS_OPTIONS (NSUInteger, CoreDataObjectRemovalOptions) {
    CoreDataManagerRemoveNone                       = 0 << 0,
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

static int   ddLogLevel = LOG_LEVEL_DEBUG;

#define kCoreDataManagerModelName                @"Remote"
#define kCoreDataManagerPersistentStoreName      @"Remote"
#define kCoreDataManagerPersistentStoreExtension @"sqlite"
#define kCoreDataManagerSQLiteName         \
    [NSString stringWithFormat : @"%@.%@", \
     kCoreDataManagerPersistentStoreName,  \
     kCoreDataManagerPersistentStoreExtension]

@implementation CoreDataManager {
    struct   DatabaseFlags {
        NSUInteger   objectRemoval;
        BOOL         rebuildDatabase;
        BOOL         rebuildRemote;
        BOOL         removePreviousDatabase;
        BOOL         replacePreviousDatabase;
        BOOL         logSaves;
        BOOL         logCoreDataStackSetup;
    } _databaseFlags;
    NSManagedObjectContext       * _mainObjectContext;
    NSPersistentStoreCoordinator * _persistentStoreCoordinator;
    NSManagedObjectModel         * _objectModel;
}

/**
 * Initializes the main `NSManagedObjectContext` by setting up the core data stack
 *
 * @return Whether setup was successful
 */
+ (BOOL)setUpCoreDataStack {
    return ([[self sharedManager] mainObjectContext] != nil);
}

/**
 * Accessor for the shared instance of `CoreDataManager`
 *
 * @return The shared instance
 */
+ (CoreDataManager *)sharedManager {
    static dispatch_once_t            pred          = 0;
    __strong static CoreDataManager * _sharedObject = nil;

    dispatch_once(&pred, ^{
        BOOL rebuildDatabase = [UserDefaults boolForKey:@"rebuild"];
        BOOL rebuildRemote = ([UserDefaults boolForKey:@"remote"] || rebuildDatabase);
        BOOL replaceDatabase = [UserDefaults boolForKey:@"replace"];

        _sharedObject = [[self alloc] init];
        _sharedObject->_databaseFlags = (struct DatabaseFlags) {
            .logSaves = YES,
            .logCoreDataStackSetup = YES,
            .removePreviousDatabase = replaceDatabase | rebuildDatabase,
            .rebuildRemote = rebuildRemote,
            .rebuildDatabase = rebuildDatabase,
            .replacePreviousDatabase = replaceDatabase | rebuildDatabase,
            .objectRemoval = CoreDataManagerRemoveNone
        };
    });

    return _sharedObject;
}

/**
 * Accessor for the `NSManagedObjectModel` used to setup the core data stack
 *
 * @return The managed object model
 */
- (NSManagedObjectModel *)objectModel {
    if (_objectModel) return _objectModel;

    NSString * modelPath = [MainBundle pathForResource:kCoreDataManagerModelName
                                                ofType:@"momd"];

    _objectModel = [[NSManagedObjectModel alloc]
                    initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
    assert(_objectModel);

    NSOperationQueue * queue = [NSOperationQueue new];

    [queue addOperationWithBlock:^{
               __block NSMutableString * modelDescription =
               [NSMutableString stringWithFormat:@"%@  managed object model:\n", ClassTagSelectorString];
               [_objectModel.entities enumerateObjectsUsingBlock:
                ^(NSEntityDescription * obj, NSUInteger idx, BOOL * stop) {
                [modelDescription appendFormat:@"%@ {\n", obj.name];

                for (NSPropertyDescription * property in obj) {
                    [modelDescription
                     appendFormat:@"\n\t\tname: %@\n\t\toptional? %@\n\t\ttransient? %@\n"
                                  "\t\tvalidation predicates: %@\n\t\tstored in external record? %@\n",
                     property.name,
                     NSStringFromBOOL(property.isOptional),
                     NSStringFromBOOL(property.isTransient),
                     [property.validationPredicates
                      componentsJoinedByString:@", "],
                     NSStringFromBOOL(property.isStoredInExternalRecord)
                    ];

                    if ([property isKindOfClass:[NSAttributeDescription class]])
                        [modelDescription
                         appendFormat:@"\t\tattribute type: %@\n\t\tattribute value class name: %@\n"
                                      "\t\tdefault value: %@\n\t\tallows extern binary data storage: %@\n",
                         NSStringFromNSAttributeType(((NSAttributeDescription *)property).
                                                     attributeType),
                         ((NSAttributeDescription *)property).attributeValueClassName,
                         ((NSAttributeDescription *)property).defaultValue,
                         NSStringFromBOOL(((NSAttributeDescription *)property).
                                          allowsExternalBinaryDataStorage)
                        ];
                    else if ([property isKindOfClass:[NSRelationshipDescription class]])
                        [modelDescription
                         appendFormat:@"\t\tdestination: %@\n\t\tinverse: %@\n\t\tdelete rule: %@\n"
                                      "\t\tmax count: %u\n\t\tmin count: %u\n\t\tone-to-many? %@\n\t\tordered: %@\n\n",
                         ((NSRelationshipDescription *)property).destinationEntity.name,
                         ((NSRelationshipDescription *)property).inverseRelationship.name,
                         NSStringFromNSDeleteRule(((NSRelationshipDescription *)property).deleteRule),
                         ((NSRelationshipDescription *)property).maxCount,
                         ((NSRelationshipDescription *)property).minCount,
                         NSStringFromBOOL(((NSRelationshipDescription *)property).isToMany),
                         NSStringFromBOOL(((NSRelationshipDescription *)property).isOrdered)
                        ];
                }

                [modelDescription appendString:@"}\n\n"];
               }

               ];

               MSLogDebug(SCHEMA_LOG_CONTEXT, @"%@", modelDescription);
           }

    ];

    return _objectModel;
}  /* objectModel */

/**
 * Returns the `NSPersistentStoreCoordinatore` used to create the contexts, creating it if it does
 * not already exist.
 *
 * @return The persistent store coordinator
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator) return _persistentStoreCoordinator;

    // Persistent store location with read/write access
    NSString * filePath = [NSString stringWithFormat:@"%@/Library/Application Support/%@",
                           NSHomeDirectory(),
                           [MainBundle bundleIdentifier]];
    NSURL * destinationDirectoryURL = [NSURL fileURLWithPath:filePath isDirectory:YES];

        MSLogDebug(DEBUG_CONTEXT, @"%@ destination directory:%@",
               ClassTagSelectorString,
               destinationDirectoryURL);

    if (![destinationDirectoryURL checkResourceIsReachableAndReturnError:NULL]) {
        MSLogDebug(DEBUG_CONTEXT, @"%@ creating destination directory...",
                   ClassTagSelectorString);

        NSError * error = nil;

        [FileManager createDirectoryAtURL:destinationDirectoryURL
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:&error];

        if (error)
            MSLogError(DEBUG_CONTEXT,
                       @"%@ error creating destination directory:%@",
                       ClassTagSelectorString, [error localizedFailureReason]);
    }

    NSURL * dataFileDestinationURL = [destinationDirectoryURL
                                      URLByAppendingPathComponent:kCoreDataManagerSQLiteName];
    BOOL   fileExistsAtDestination = [dataFileDestinationURL
                                      checkResourceIsReachableAndReturnError:NULL];

    MSLogDebug(DEBUG_CONTEXT, @"%@  destination database url: %@\nfile exists? %@",
               ClassTagSelectorString, dataFileDestinationURL,
               NSStringFromBOOL(fileExistsAtDestination));

    // Remove existing database store if flag is set
    if (_databaseFlags.removePreviousDatabase && fileExistsAtDestination) {
        MSLogDebug(DEBUG_CONTEXT, @"%@  removing existing database",
                   ClassTagSelectorString);

        NSError * error = nil;

        if (![FileManager removeItemAtURL:dataFileDestinationURL error:&error])
            MSLogError(DEBUG_CONTEXT,
                       @"%@  problem encountered while removing existing persistent store %@, %@",
                       ClassTagSelectorString, error, [error localizedFailureReason]);

        fileExistsAtDestination =
            [dataFileDestinationURL checkResourceIsReachableAndReturnError:NULL];
        assert(!fileExistsAtDestination);
    }

    // Copy bundle resource to store destination if needed
    if (!fileExistsAtDestination && !_databaseFlags.rebuildDatabase) {
        MSLogDebug(DEBUG_CONTEXT,
                   @"%@  copying bundle database to destination url...",
                   ClassTagSelectorString);

        NSURL * storeBundleURL = [MainBundle URLForResource:kCoreDataManagerPersistentStoreName
                                              withExtension:kCoreDataManagerPersistentStoreExtension];

        // Copy the file
        NSError * error = nil;

        [FileManager copyItemAtURL:storeBundleURL toURL:dataFileDestinationURL error:&error];

        // Log error if operation failed
        if (error)
            MSLogWarn(DEBUG_CONTEXT,
                      @"%@  problem encountered while copying %@ to destination url: %@, %@",
                      ClassTagSelectorString,
                      [storeBundleURL lastPathComponent],
                      error,
                      [error localizedFailureReason]);

        fileExistsAtDestination =
            [dataFileDestinationURL checkResourceIsReachableAndReturnError:NULL];
        assert(fileExistsAtDestination);
        MSLogDebug(DEBUG_CONTEXT,
                   @"%@  bundle database copied to destination url successfully",
                   ClassTagSelectorString);
    }

    assert((fileExistsAtDestination ^ _databaseFlags.rebuildDatabase));

    MSLogDebug(DEBUG_CONTEXT,
               @"%@  database file operations complete, database %@ flagged for rebuilding",
               ClassTagSelectorString, _databaseFlags.rebuildDatabase ? @"is" : @"is not");

    NSDictionary * options = @{
        NSMigratePersistentStoresAutomaticallyOption : @YES,
        NSInferMappingModelAutomaticallyOption : @YES
    };

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self objectModel]];

    NSError * error = nil;

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:dataFileDestinationURL
                                                         options:options
                                                           error:&error])
    {
        // TODO: Replace with code to handle error appropriately
        MSLogError(DEBUG_CONTEXT,
                   @"%@  aborting due to unresolved error creating persistent store:%@, %@",
                   ClassTagSelectorString, error, [error localizedFailureReason]);
        abort();
    }

    return _persistentStoreCoordinator;
}  /* persistentStoreCoordinator */

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
- (NSManagedObjectContext *)childContextWithNametag:(NSString *)nametag undoManager:(BOOL)undoManager {
    return [self childContextWithNametag:nametag forContext:_mainObjectContext undoManager:undoManager];
}

/**
 * Creates and returns a new child context with the main object context as a parent, without an
 * undo manager, and with the specified `nametag`.
 *
 * @param nametag String to set as the nametag for the new context
 *
 * @return The new child context
 */
- (NSManagedObjectContext *)childContextWithNametag:(NSString *)nametag {
    return [self childContextWithNametag:nametag forContext:_mainObjectContext undoManager:NO];
}

/**
 * Creates and returns a new child context with the main object context as a parent
 *
 * @param undoManager Whether to attach an undo manager to the new context
 *
 * @return The new child context
 */
- (NSManagedObjectContext *)childContext:(BOOL)undoManager {
    return [self childContextWithNametag:nil forContext:_mainObjectContext undoManager:undoManager];
}

/**
 * Creates and returns a new child context with the main object context as a parent and without an
 * undo manager
 *
 * @return The new child context
 */
- (NSManagedObjectContext *)childContext {
    return [self childContextWithNametag:nil forContext:_mainObjectContext undoManager:NO];
}

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
                                        undoManager:(BOOL)undoManager
{
    if (ValueIsNil(context)) return nil;

    NSManagedObjectContext * parentContext = context;
    NSManagedObjectContext * childContext  =
        [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];

    [childContext performBlockAndWait:^{
                      childContext.parentContext = parentContext;
                      if (undoManager) {
                      childContext.undoManager = [NSUndoManager new];
                      childContext.undoManager.levelsOfUndo = 6;
                      }
                  }];

    return childContext;
}

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
                                         forContext:(NSManagedObjectContext *)context
{
    return [self childContextWithNametag:nametag forContext:context undoManager:NO];
}

/**
 * Creates and returns a new child context with the specified context as a parent
 *
 * @param context The parent context for the new child context
 *
 * @param undoManager Whether to attach an undo manager to the new context
 *
 * @return The new child context
 */
- (NSManagedObjectContext *)childContextForContext:(NSManagedObjectContext *)context
                                       undoManager:(BOOL)undoManager
{
    return [self childContextWithNametag:nil forContext:context undoManager:undoManager];
}

/**
 * Creates and returns a new child context with the specified context as a parent and without an
 *undo
 * manager
 *
 * @param context The parent context for the new child context
 *
 * @return The new child context
 */
- (NSManagedObjectContext *)childContextForContext:(NSManagedObjectContext *)context {
    return [self childContextWithNametag:nil forContext:context undoManager:NO];
}

/**
 * Accessor for the main `NSManagedObjectContext`
 *
 * @return The context
 */
- (NSManagedObjectContext *)mainObjectContext {
    if (_mainObjectContext) return _mainObjectContext;

    NSPersistentStoreCoordinator * coordinator = self.persistentStoreCoordinator;

    if (coordinator) {
        // MODIFIED QUEUE TYPE
        _mainObjectContext =
            [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];

        [_mainObjectContext performBlockAndWait:^{[_mainObjectContext setPersistentStoreCoordinator:coordinator];}];
    }

    return _mainObjectContext;
}

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
- (NSManagedObjectContext *)newContextWithNametag:(NSString *)nametag undoManager:(BOOL)undoManager {
    NSPersistentStoreCoordinator * coordinator = [self persistentStoreCoordinator];
    NSManagedObjectContext       * context     = nil;

    if (coordinator) {
        context = [[NSManagedObjectContext alloc]
                   initWithConcurrencyType:NSPrivateQueueConcurrencyType];

        [context
         performBlockAndWait:^{
             [context setPersistentStoreCoordinator:coordinator];
             if (undoManager) context.undoManager = [NSUndoManager new];
         }];
    }

    return context;
}

/**
 * Creates and returns a new managed object context with the same `NSPersistentStoreCoordinator` as
 * the main managed object context, no undo manager, and with the specified `nametag`.
 *
 * @param nametag String to set as the nametag for the new context
 *
 * @return The new context
 */
- (NSManagedObjectContext *)newContextWithNametag:(NSString *)nametag {
    return [self newContextWithNametag:nametag undoManager:NO];
}

/**
 * Creates and returns a new managed object context with the same `NSPersistentStoreCoordinator` as
 * the main managed object context and with an undo manager if specified.
 *
 * @param undoManager Whether the context should have an undo manager attached to it
 *
 * @return The new context
 */
- (NSManagedObjectContext *)newContext:(BOOL)undoManager {
    return [self newContextWithNametag:nil undoManager:undoManager];
}

/**
 * Creates and returns a new managed object context with the same `NSPersistentStoreCoordinator` as
 * the main managed object context and without an undo manager
 *
 * @return The new context
 */
- (NSManagedObjectContext *)newContext {
    return [self newContextWithNametag:nil undoManager:NO];
}

/**
 * Saves the main object context
 *
 * @return Whether the save was successful
 */
- (BOOL)saveMainContext {
    if (_databaseFlags.logSaves)
            MSLogDebug(DEBUG_CONTEXT,
                   @"%@  received request to save main object context",
                   ClassTagSelectorString);

    if (ValueIsNil(_mainObjectContext)) return NO;

    __block BOOL   savedOK = NO;

    if (![_mainObjectContext hasChanges]) {
        savedOK = YES;

        if (_databaseFlags.logSaves)
            MSLogDebug(DEBUG_CONTEXT,
                       @"%@  main object context has no changes to save",
                       ClassTagSelectorString);
    } else {
        if (_databaseFlags.logSaves)
            MSLogDebug(DEBUG_CONTEXT,
                       @"%@  saving main object context...", ClassTagSelectorString);

        __block NSError * error = nil;

        [_mainObjectContext performBlockAndWait:^{savedOK = [_mainObjectContext save:&error]; }];

        if (!savedOK)
            MSLogError(DEBUG_CONTEXT,
                       @"%@  problem encountered while saving main object context:%@, %@",
                       ClassTagSelectorString, error, [error localizedFailureReason]);
        else if (_databaseFlags.logSaves)
            MSLogDebug(DEBUG_CONTEXT,
                       @"%@  main object context saved successfully",
                       ClassTagSelectorString);
    }

    return savedOK;
}  /* saveMainContext */

/**
 * Saves the specified child context
 *
 * @param childContext The child context to save
 *
 * @return Whether the save was successful
 */
- (BOOL)saveChildContext:(NSManagedObjectContext *)childContext {
    if (_databaseFlags.logSaves)
            MSLogDebug(DEBUG_CONTEXT,
                   @"%@  received request to save child object context",
                   ClassTagSelectorString);

    if (!childContext) return NO;

    __block BOOL   savedOK = NO;

    if (![childContext hasChanges]) {
        savedOK = YES;

        if (_databaseFlags.logSaves)
            MSLogDebug(DEBUG_CONTEXT,
                       @"%@  child object context has no changes to save",
                       ClassTagSelectorString);
    } else {
        if (_databaseFlags.logSaves)
            MSLogDebug(DEBUG_CONTEXT,
                       @"%@  saving child object context...", ClassTagSelectorString);

        __block NSError * error = nil;

        [childContext performBlockAndWait:^{savedOK = [childContext save:&error]; }];

        if (!savedOK)
            MSLogError(DEBUG_CONTEXT,
                       @"%@  failed to save child object context:%@, %@",
                       ClassTagSelectorString, error, [error localizedFailureReason]);
        else if (_databaseFlags.logSaves)
                MSLogDebug(DEBUG_CONTEXT,
                       @"%@  child object context saved successfully", ClassTagSelectorString);
    }

    return savedOK;
}  /* saveChildContext */

/**
 * Saves the main object context with a completion block invoked afterwards
 *
 * @param completion The block to call after the save takes one parameter indication whether the
 * save was successful
 */
- (void)saveContextWithCompletion:(void (^)(BOOL success))completion {
    if (_databaseFlags.logSaves)
                MSLogDebug(DEBUG_CONTEXT,
                   @"%@  received request to save main object context", ClassTagSelectorString);

    // Return success if no changes need to be saved
    if (![_mainObjectContext hasChanges]) {
        if (_databaseFlags.logSaves)
                MSLogDebug(DEBUG_CONTEXT,
                       @"%@  main object context has no changes to save", ClassTagSelectorString);

        if (ValueIsNotNil(completion)) {
            if (_databaseFlags.logSaves)
                MSLogDebug(DEBUG_CONTEXT,
                           @"%@  executing completion callback, success? YES",
                           ClassTagSelectorString);

            completion(YES);
        }
    } else {
        // Otherwise save context and call completion block
        __block NSError * error   = nil;
        __block BOOL      savedOK = NO;

        [_mainObjectContext
         performBlock:^{
             savedOK = [_mainObjectContext save:&error];

             if (!savedOK) {
                NSArray * errors = error.userInfo[NSDetailedErrorsKey];

                if (errors)
                    MSLogError(DEBUG_CONTEXT,
                               @"%@  multiple errors occured while saving main object context",
                               ClassTagSelectorString);
                else
                    MSLogError(DEBUG_CONTEXT,
                               @"%@  problem encountered while saving main object context:%@",
                               ClassTagSelectorString, [error description]);
            } else
                MSLogDebug(DEBUG_CONTEXT,
                           @"%@  main object context saved successfully", ClassTagSelectorString);

             if (ValueIsNotNil(completion)) {
                MSLogDebug(DEBUG_CONTEXT,
                           @"%@  executing completion callback, success? %@",
                           ClassTagSelectorString,
                           NSStringFromBOOL(savedOK));
                completion(savedOK);
             }
         }

        ];
    }
}  /* saveContextWithCompletion */

/**
 * Resets the main managed object context
 */
- (void)emptyContext {
    [_mainObjectContext performBlockAndWait:^{[_mainObjectContext reset]; }];
}

@end