//
// CoreDataManager.m
// Remote
//
// Created by Jason Cardwell on 3/21/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "MSKit/MSKit.h"
#import "CoreDataManager.h"
#import "MSRemoteAppController.h"

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

static const int   ddLogLevel   = LOG_LEVEL_DEBUG;
static const int   msLogContext = COREDATA_F;
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

+ (BOOL)setUpCoreDataStack {
    return ([[self sharedManager] mainObjectContext] != nil);
}

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
                     BOOLString(property.isOptional),
                     BOOLString(property.isTransient),
                     [property.validationPredicates
                      componentsJoinedByString:@", "],
                     BOOLString(property.isStoredInExternalRecord)
                    ];

                    if ([property isKindOfClass:[NSAttributeDescription class]])
                        [modelDescription
                         appendFormat:@"\t\tattribute type: %@\n\t\tattribute value class name: %@\n"
                                      "\t\tdefault value: %@\n\t\tallows extern binary data storage: %@\n",
                         NSAttributeTypeString(((NSAttributeDescription *)property).
                                                     attributeType),
                         ((NSAttributeDescription *)property).attributeValueClassName,
                         ((NSAttributeDescription *)property).defaultValue,
                         BOOLString(((NSAttributeDescription *)property).
                                          allowsExternalBinaryDataStorage)
                        ];
                    else if ([property isKindOfClass:[NSRelationshipDescription class]])
                        [modelDescription
                         appendFormat:@"\t\tdestination: %@\n\t\tinverse: %@\n\t\tdelete rule: %@\n"
                                      "\t\tmax count: %u\n\t\tmin count: %u\n\t\tone-to-many? %@\n\t\tordered: %@\n\n",
                         ((NSRelationshipDescription *)property).destinationEntity.name,
                         ((NSRelationshipDescription *)property).inverseRelationship.name,
                         NSDeleteRuleString(((NSRelationshipDescription *)property).deleteRule),
                         ((NSRelationshipDescription *)property).maxCount,
                         ((NSRelationshipDescription *)property).minCount,
                         BOOLString(((NSRelationshipDescription *)property).isToMany),
                         BOOLString(((NSRelationshipDescription *)property).isOrdered)
                        ];
                }

                [modelDescription appendString:@"}\n\n"];
               }

               ];

               MSLogDebug(@"%@", modelDescription);
           }

    ];

    return _objectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator) return _persistentStoreCoordinator;

    // Persistent store location with read/write access
    NSString * filePath = [NSString stringWithFormat:@"%@/Library/Application Support/%@",
                           NSHomeDirectory(),
                           [MainBundle bundleIdentifier]];
    NSURL * destinationDirectoryURL = [NSURL fileURLWithPath:filePath isDirectory:YES];

        MSLogDebug(@"%@ destination directory:%@",
               ClassTagSelectorString,
               destinationDirectoryURL);

    if (![destinationDirectoryURL checkResourceIsReachableAndReturnError:NULL]) {
        MSLogDebug(@"%@ creating destination directory...",
                   ClassTagSelectorString);

        NSError * error = nil;

        [FileManager createDirectoryAtURL:destinationDirectoryURL
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:&error];

        if (error)
            MSLogError(
                       @"%@ error creating destination directory:%@",
                       ClassTagSelectorString, [error localizedFailureReason]);
    }

    NSURL * dataFileDestinationURL = [destinationDirectoryURL
                                      URLByAppendingPathComponent:kCoreDataManagerSQLiteName];
    BOOL   fileExistsAtDestination = [dataFileDestinationURL
                                      checkResourceIsReachableAndReturnError:NULL];

    MSLogDebug(@"%@  destination database url: %@\nfile exists? %@",
               ClassTagSelectorString, dataFileDestinationURL,
               BOOLString(fileExistsAtDestination));

    // Remove existing database store if flag is set
    if (_databaseFlags.removePreviousDatabase && fileExistsAtDestination) {
        MSLogDebug(@"%@  removing existing database",
                   ClassTagSelectorString);

        NSError * error = nil;

        if (![FileManager removeItemAtURL:dataFileDestinationURL error:&error])
            MSLogError(
                       @"%@  problem encountered while removing existing persistent store %@, %@",
                       ClassTagSelectorString, error, [error localizedFailureReason]);

        fileExistsAtDestination =
            [dataFileDestinationURL checkResourceIsReachableAndReturnError:NULL];
        assert(!fileExistsAtDestination);
    }

    // Copy bundle resource to store destination if needed
    if (!fileExistsAtDestination && !_databaseFlags.rebuildDatabase) {
        MSLogDebug(
                   @"%@  copying bundle database to destination url...",
                   ClassTagSelectorString);

        NSURL * storeBundleURL = [MainBundle URLForResource:kCoreDataManagerPersistentStoreName
                                              withExtension:kCoreDataManagerPersistentStoreExtension];

        // Copy the file
        NSError * error = nil;

        [FileManager copyItemAtURL:storeBundleURL toURL:dataFileDestinationURL error:&error];

        // Log error if operation failed
        if (error)
            MSLogWarn(@"%@  problem encountered while copying %@ to destination url: %@, %@",
                      ClassTagSelectorString,
                      [storeBundleURL lastPathComponent],
                      error,
                      [error localizedFailureReason]);

        fileExistsAtDestination =
            [dataFileDestinationURL checkResourceIsReachableAndReturnError:NULL];
        assert(fileExistsAtDestination);
        MSLogDebug(@"%@  bundle database copied to destination url successfully",
                   ClassTagSelectorString);
    }

    assert((fileExistsAtDestination ^ _databaseFlags.rebuildDatabase));

    MSLogDebug(@"%@  database file operations complete, database %@ flagged for rebuilding",
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
        MSLogError(@"%@  aborting due to unresolved error creating persistent store:%@, %@",
                   ClassTagSelectorString, error, [error localizedFailureReason]);
        abort();
    }

    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)childContextWithNametag:(NSString *)nametag undoManager:(BOOL)undoManager {
    return [self childContextWithNametag:nametag forContext:_mainObjectContext undoManager:undoManager];
}

- (NSManagedObjectContext *)childContextWithNametag:(NSString *)nametag {
    return [self childContextWithNametag:nametag forContext:_mainObjectContext undoManager:NO];
}

- (NSManagedObjectContext *)childContext:(BOOL)undoManager {
    return [self childContextWithNametag:nil forContext:_mainObjectContext undoManager:undoManager];
}

- (NSManagedObjectContext *)childContext {
    return [self childContextWithNametag:nil forContext:_mainObjectContext undoManager:NO];
}

- (NSManagedObjectContext *)childContextWithNametag:(NSString *)nametag
                                         forContext:(NSManagedObjectContext *)context
                                    concurrencyType:(NSManagedObjectContextConcurrencyType)type
                                        undoManager:(BOOL)undoManager
{
    if (ValueIsNil(context)) return nil;

    NSManagedObjectContext * parentContext = context;
    NSManagedObjectContext * childContext  =
    [[NSManagedObjectContext alloc] initWithConcurrencyType:type];

    [childContext performBlockAndWait:^{
        childContext.parentContext = parentContext;
        if (undoManager) {
            childContext.undoManager = [NSUndoManager new];
            childContext.undoManager.levelsOfUndo = 6;
        }
    }];

    return childContext;
}
- (NSManagedObjectContext *)childContextWithNametag:(NSString *)nametag
                                         forContext:(NSManagedObjectContext *)context
                                        undoManager:(BOOL)undoManager
{
    return [self childContextWithNametag:nametag
                              forContext:context
                         concurrencyType:NSPrivateQueueConcurrencyType
                             undoManager:undoManager];
}

- (NSManagedObjectContext *)childContextWithNametag:(NSString *)nametag
                                         forContext:(NSManagedObjectContext *)context
{
    return [self childContextWithNametag:nametag forContext:context undoManager:NO];
}

- (NSManagedObjectContext *)childContextForContext:(NSManagedObjectContext *)context
                                       undoManager:(BOOL)undoManager
{
    return [self childContextWithNametag:nil forContext:context undoManager:undoManager];
}

- (NSManagedObjectContext *)childContextForContext:(NSManagedObjectContext *)context {
    return [self childContextWithNametag:nil forContext:context undoManager:NO];
}

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

- (NSManagedObjectContext *)newContextWithNametag:(NSString *)nametag
                                  concurrencyType:(NSManagedObjectContextConcurrencyType)type
                                      undoManager:(BOOL)undoManager
{
    NSPersistentStoreCoordinator * coordinator = [self persistentStoreCoordinator];
    NSManagedObjectContext       * context     = nil;

    if (coordinator) {
        context = [[NSManagedObjectContext alloc]
                   initWithConcurrencyType:type];

        [context
         performBlockAndWait:^{
             [context setPersistentStoreCoordinator:coordinator];
             if (undoManager) context.undoManager = [NSUndoManager new];
         }];
    }

    return context;
}

- (NSManagedObjectContext *)newContextWithNametag:(NSString *)nametag undoManager:(BOOL)undoManager {
    return [self newContextWithNametag:nametag
                       concurrencyType:NSPrivateQueueConcurrencyType
                           undoManager:undoManager];
}

- (NSManagedObjectContext *)newContextWithNametag:(NSString *)nametag {
    return [self newContextWithNametag:nametag undoManager:NO];
}

- (NSManagedObjectContext *)newContext:(BOOL)undoManager {
    return [self newContextWithNametag:nil undoManager:undoManager];
}

- (NSManagedObjectContext *)newContext {
    return [self newContextWithNametag:nil undoManager:NO];
}

- (BOOL)saveMainContext {
    if (_databaseFlags.logSaves)
            MSLogDebug(@"%@  received request to save main object context",
                   ClassTagSelectorString);

    if (ValueIsNil(_mainObjectContext)) return NO;

    __block BOOL   savedOK = NO;

    if (![_mainObjectContext hasChanges]) {
        savedOK = YES;

        if (_databaseFlags.logSaves)
            MSLogDebug(
                       @"%@  main object context has no changes to save",
                       ClassTagSelectorString);
    } else {
        if (_databaseFlags.logSaves)
            MSLogDebug(@"%@  saving main object context...", ClassTagSelectorString);

        __block NSError * error = nil;

        [_mainObjectContext performBlockAndWait:^{savedOK = [_mainObjectContext save:&error]; }];

        if (!savedOK)
            MSLogError(@"%@  problem encountered while saving main object context:%@, %@",
                       ClassTagSelectorString, error, [error localizedFailureReason]);
        else if (_databaseFlags.logSaves)
            MSLogDebug(@"%@  main object context saved successfully",
                       ClassTagSelectorString);
    }

    return savedOK;
}

- (BOOL)saveChildContext:(NSManagedObjectContext *)childContext {
    if (_databaseFlags.logSaves)
            MSLogDebug(@"%@  received request to save child object context",
                   ClassTagSelectorString);

    if (!childContext) return NO;

    __block BOOL   savedOK = NO;

    if (![childContext hasChanges]) {
        savedOK = YES;

        if (_databaseFlags.logSaves)
            MSLogDebug(@"%@  child object context has no changes to save",
                       ClassTagSelectorString);
    } else {
        if (_databaseFlags.logSaves)
            MSLogDebug(@"%@  saving child object context...", ClassTagSelectorString);

        __block NSError * error = nil;

        [childContext performBlockAndWait:^{savedOK = [childContext save:&error]; }];

        if (!savedOK)
            MSLogError(@"%@  failed to save child object context:%@, %@",
                       ClassTagSelectorString, error, [error localizedFailureReason]);
        else if (_databaseFlags.logSaves)
                MSLogDebug(@"%@  child object context saved successfully", ClassTagSelectorString);
    }

    return savedOK;
}

- (void)saveContextWithCompletion:(void (^)(BOOL success))completion {
    if (_databaseFlags.logSaves)
                MSLogDebug(@"%@  received request to save main object context",
                           ClassTagSelectorString);

    // Return success if no changes need to be saved
    if (![_mainObjectContext hasChanges]) {
        if (_databaseFlags.logSaves)
                MSLogDebug(@"%@  main object context has no changes to save",
                           ClassTagSelectorString);

        if (ValueIsNotNil(completion)) {
            if (_databaseFlags.logSaves)
                MSLogDebug(@"%@  executing completion callback, success? YES",
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
                    MSLogError(@"%@  multiple errors occured while saving main object context",
                               ClassTagSelectorString);
                else
                    MSLogError(@"%@  problem encountered while saving main object context:%@",
                               ClassTagSelectorString, [error description]);
            } else
                MSLogDebug(@"%@  main object context saved successfully", ClassTagSelectorString);

             if (ValueIsNotNil(completion)) {
                MSLogDebug(@"%@  executing completion callback, success? %@",
                           ClassTagSelectorString,
                           BOOLString(savedOK));
                completion(savedOK);
             }
         }

        ];
    }
}

- (void)emptyContext {
    [_mainObjectContext performBlockAndWait:^{[_mainObjectContext reset]; }];
}

@end
