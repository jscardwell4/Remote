//
// CoreDataManager.m
// Remote
//
// Created by Jason Cardwell on 3/21/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "CoreDataManager.h"
#import "MSRemoteAppController.h"

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

static const int   ddLogLevel   = LOG_LEVEL_DEBUG;
static const int   msLogContext = COREDATA_F_C;

NSString *(^getContextDescription)(NSManagedObjectContext *) =
^NSString *(NSManagedObjectContext * context)
{
    return (StringIsNotEmpty(context.nametag) ? $(@"%@", context.nametag) : $(@"%p", context));
};


MSKIT_STATIC_STRING_CONST   kCoreDataManagerModelName                = @"Remote";
MSKIT_STATIC_STRING_CONST   kCoreDataManagerPersistentStoreName      = @"Remote";
MSKIT_STATIC_STRING_CONST   kCoreDataManagerPersistentStoreExtension = @"sqlite";

#define kCoreDataManagerSQLiteName \
    $(@"%@.%@", kCoreDataManagerPersistentStoreName, kCoreDataManagerPersistentStoreExtension)

////////////////////////////////////////////////////////////////////////////////
#pragma mark - CoreDataManager Implementation
////////////////////////////////////////////////////////////////////////////////

@implementation CoreDataManager {
    struct DatabaseFlags_s {
        NSUInteger   objectRemoval;
        BOOL         rebuildDatabase;
        BOOL         rebuildRemote;
        BOOL         removePreviousDatabase;
        BOOL         replacePreviousDatabase;
        BOOL         logSaves;
        BOOL         logCoreDataStackSetup;
    } _flags;
    NSManagedObjectContext       * __mainObjectContext;
    NSPersistentStoreCoordinator * __persistentStoreCoordinator;
    NSManagedObjectModel         * __objectModel;
}

+ (CoreDataManager const *)sharedManager
{
    static CoreDataManager const * sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [CoreDataManager new];
        BOOL rebuildDatabase = [UserDefaults boolForKey:@"rebuild"];
        BOOL rebuildRemote   = ([UserDefaults boolForKey:@"remote"] || rebuildDatabase);
        BOOL replaceDatabase = [UserDefaults boolForKey:@"replace"];
        sharedManager->_flags = (struct DatabaseFlags_s) {
            .logSaves = YES,
            .logCoreDataStackSetup = YES,
            .removePreviousDatabase = replaceDatabase | rebuildDatabase,
            .rebuildRemote = rebuildRemote,
            .rebuildDatabase = rebuildDatabase,
            .replacePreviousDatabase = replaceDatabase | rebuildDatabase,
            .objectRemoval = CoreDataManagerRemoveNone
        };
    });
    return sharedManager;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Core Data Stack
////////////////////////////////////////////////////////////////////////////////

+ (BOOL)initializeCoreDataStack { return [[self sharedManager] initializeCoreDataStack]; }
- (BOOL)initializeCoreDataStack
{
    return ([self mainObjectContext] != nil);
}

+ (void)logObjectModel { [[self sharedManager] logObjectModel]; }
- (void)logObjectModel
{
    NSOperationQueue * queue = [NSOperationQueue operationQueueWithName:@"com.moondeerstudios.model"];

    [queue addOperationWithBlock:
     ^{
         __block NSMutableString * modelDescription =
         [$(@"%@  managed object model:\n", ClassTagSelectorString) mutableCopy];

         [__objectModel.entities enumerateObjectsUsingBlock:
          ^(NSEntityDescription * obj, NSUInteger idx, BOOL * stop)
          {
              [modelDescription appendFormat:@"%@ {\n", obj.name];

              for (NSPropertyDescription * property in obj)
              {
                  [modelDescription   appendFormat:@"\n\t\tname: %@\n"
                                                    "\t\toptional? %@\n"
                                                    "\t\ttransient? %@\n"
                                                    "\t\tvalidation predicates: %@\n"
                                                    "\t\tstored in external record? %@\n",
                                                    property.name,
                                                    BOOLString(property.isOptional),
                                                    BOOLString(property.isTransient),
                                                    [property.validationPredicates
                                                         componentsJoinedByString:@", "],
                                                    BOOLString(property.isStoredInExternalRecord)];

                  if ([property isKindOfClass:[NSAttributeDescription class]])
                  {
                      NSAttributeDescription * ad = (NSAttributeDescription *)property;
                      [modelDescription appendFormat:@"\t\tattribute type: %@\n"
                                                     "\t\tattribute value class name: %@\n"
                                                     "\t\tdefault value: %@\n"
                                                     "\t\tallows extern binary data storage: %@\n",
                                                     NSAttributeTypeString(ad.attributeType),
                                                     ad.attributeValueClassName,
                                                     ad.defaultValue,
                                                     BOOLString(ad.allowsExternalBinaryDataStorage)];
                  }

                  else if ([property isKindOfClass:[NSRelationshipDescription class]])
                  {
                      NSRelationshipDescription * rd = (NSRelationshipDescription *)property;
                      [modelDescription appendFormat:@"\t\tdestination: %@\n"
                                                      "\t\tinverse: %@\n"
                                                      "\t\tdelete rule: %@\n"
                                                      "\t\tmax count: %u\n"
                                                      "\t\tmin count: %u\n"
                                                      "\t\tone-to-many? %@\n"
                                                      "\t\tordered: %@\n\n",
                                                      rd.destinationEntity.name,
                                                      rd.inverseRelationship.name,
                                                      NSDeleteRuleString(rd.deleteRule),
                                                      rd.maxCount,
                                                      rd.minCount,
                                                      BOOLString(rd.isToMany),
                                                      BOOLString(rd.isOrdered)];
                  }
              }

              [modelDescription appendString:@"}\n\n"];
          }];

         MSLogDebugInContext(COREDATA_F_C, @"%@", modelDescription);
     }];
}

+ (NSManagedObjectModel *)objectModel { return [[self sharedManager] objectModel]; }
- (NSManagedObjectModel *)objectModel
{

    void(^modifyAttributeForEntities)(NSArray *, NSString *, NSString *, id) =
    ^(NSArray * entities, NSString * attributeName, NSString * classValueName, id defaultValue)
    {
        for (NSEntityDescription * entity in entities)
        {
            NSAttributeDescription * description = [entity attributesByName][attributeName];
            [description setAttributeValueClassName:classValueName];
            if (defaultValue != nil) [description setDefaultValue:defaultValue];
        }
    };

    void(^modifyAttributesForEntity)(NSEntityDescription *, NSArray *, NSString *, id) =
    ^(NSEntityDescription * entity, NSArray * attributeNames, NSString * classValueName, id defaultValue)
    {
        NSDictionary * attributeDescriptions = [entity attributesByName];
        for (NSString * attributeName in attributeNames)
        {
            [attributeDescriptions[attributeName] setAttributeValueClassName:classValueName];
            if (defaultValue != nil) [attributeDescriptions[attributeName] setDefaultValue:defaultValue];
        }
    };

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      __objectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] mutableCopy];
                      assert(__objectModel);
                      
                      NSDictionary * entities = [__objectModel entitiesByName];

                      // size attributes on images
                      modifyAttributeForEntities([entities objectsForKeys:@[@"BOImage",
                                                                            @"BOBackgroundImage",
                                                                            @"BOButtonImage",
                                                                            @"BOIconImage"]
                                                           notFoundMarker:NullObject],
                                                 @"size",
                                                 @"NSValue",
                                                 NSValueWithCGSize(CGSizeZero));

                      // background color attributes on remote elements
                      modifyAttributeForEntities([entities objectsForKeys:@[@"RemoteElement",
                                                                            @"RERemote",
                                                                            @"REButtonGroup",
                                                                            @"REPickerLabelButtonGroup",
                                                                            @"REButton",
                                                                            @"REActivityButton"]
                                                           notFoundMarker:NullObject],
                                                 @"backgroundColor",
                                                 @"UIColor",
                                                 ClearColor);

                      // edge insets attributes on buttons
                      modifyAttributeForEntities([entities objectsForKeys:@[@"REButton",
                                                                            @"REActivityButton"]
                                                           notFoundMarker:NullObject],
                                                 @"titleEdgeInsets",
                                                 @"NSValue",
                                                 NSValueWithUIEdgeInsets(UIEdgeInsetsZero));
                      modifyAttributeForEntities([entities objectsForKeys:@[@"REButton",
                                                                            @"REActivityButton"]
                                                           notFoundMarker:NullObject],
                                                 @"contentEdgeInsets",
                                                 @"NSValue",
                                                 NSValueWithUIEdgeInsets(UIEdgeInsetsZero));
                      modifyAttributeForEntities([entities objectsForKeys:@[@"REButton",
                                                                            @"REActivityButton"]
                                                           notFoundMarker:NullObject],
                                                 @"imageEdgeInsets",
                                                 @"NSValue",
                                                 NSValueWithUIEdgeInsets(UIEdgeInsetsZero));

                      // configurations attribute on configuration delegates
                      modifyAttributeForEntities([entities objectsForKeys:@[@"REConfigurationDelegate",
                                                                            @"RERemoteConfigurationDelegate",
                                                                            @"REButtonGroupConfigurationDelegate",
                                                                            @"REButtonConfigurationDelegate"]
                                                           notFoundMarker:NullObject],
                                                 @"configurations",
                                                 @"NSDictionary",
                                                 @{});

                      // label attribute on button groups
                      modifyAttributeForEntities([entities objectsForKeys:@[@"REButtonGroup",
                                                                            @"REPickerLabelButtonGroup"]
                                                           notFoundMarker:NullObject],
                                                 @"label",
                                                 @"NSAttributedString",
                                                 nil);

                      // index attribute on command containers
                      modifyAttributeForEntities([entities objectsForKeys:@[@"RECommandContainer",
                                                                            @"RECommandSet",
                                                                            @"RECommandSetCollection"]
                                                           notFoundMarker:NullObject],
                                                 @"index",
                                                 @"NSDictionary",
                                                 @{});

                      // url attribute on http command
                      modifyAttributeForEntities(@[entities[@"REHTTPCommand"]],
                                                 @"url",
                                                 @"NSURL",
                                                 [NSURL URLWithString:@"http://about:blank"]);

                      // bitVector attribute on layout configuration
                      modifyAttributeForEntities(@[entities[@"RELayoutConfiguration"]],
                                                 @"bitVector",
                                                 @"MSBitVector",
                                                 BitVector8);


                      // color attributes on control state color set
                      modifyAttributesForEntity(entities[@"REControlStateColorSet"],
                                                @[@"disabled",
                                                  @"disabledAndSelected",
                                                  @"highlighted",
                                                  @"highlightedAndDisabled",
                                                  @"highlightedAndSelected",
                                                  @"normal",
                                                  @"selected",
                                                  @"selectedHighlightedAndDisabled"],
                                                @"UIColor",
                                                nil);

                      // url attributes on control state image sets
                      modifyAttributesForEntity(entities[@"REControlStateImageSet"],
                                                @[@"disabled",
                                                  @"disabledAndSelected",
                                                  @"highlighted",
                                                  @"highlightedAndDisabled",
                                                  @"highlightedAndSelected",
                                                  @"normal",
                                                  @"selected",
                                                  @"selectedHighlightedAndDisabled"],
                                                @"NSURL",
                                                nil);
                      modifyAttributesForEntity(entities[@"REControlStateButtonImageSet"],
                                                @[@"disabled",
                                                  @"disabledAndSelected",
                                                  @"highlighted",
                                                  @"highlightedAndDisabled",
                                                  @"highlightedAndSelected",
                                                  @"normal",
                                                  @"selected",
                                                  @"selectedHighlightedAndDisabled"],
                                                @"NSURL",
                                                nil);
                      modifyAttributesForEntity(entities[@"REControlStateIconImageSet"],
                                                @[@"disabled",
                                                  @"disabledAndSelected",
                                                  @"highlighted",
                                                  @"highlightedAndDisabled",
                                                  @"highlightedAndSelected",
                                                  @"normal",
                                                  @"selected",
                                                  @"selectedHighlightedAndDisabled"],
                                                @"NSURL",
                                                nil);

                      // attributed string attributes on control state title set
                      modifyAttributesForEntity(entities[@"REControlStateTitleSet"],
                                                @[@"disabled",
                                                  @"disabledAndSelected",
                                                  @"highlighted",
                                                  @"highlightedAndDisabled",
                                                  @"highlightedAndSelected",
                                                  @"normal",
                                                  @"selected",
                                                  @"selectedHighlightedAndDisabled"],
                                                @"NSAttributedString",
                                                nil);

                      [self logObjectModel];

                  });

    return __objectModel;
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    return [[self sharedManager] persistentStoreCoordinator];
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        // Persistent store location with read/write access
        NSString * filePath = $(@"%@/Library/Application Support/%@",
                                NSHomeDirectory(),
                                MainBundle.bundleIdentifier);

        NSURL * directoryURL = [NSURL fileURLWithPath:filePath isDirectory:YES];

        MSLogDebugTag(@"destination directory:%@", directoryURL);

        if (![directoryURL checkResourceIsReachableAndReturnError:NULL])
        {
            MSLogDebugTag(@"creating destination directory...");

            NSError * error = nil;

            [FileManager createDirectoryAtURL:directoryURL
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:&error];

            if (error)
                MSLogErrorTag(@"error creating destination directory:%@", [error localizedFailureReason]);
        }

        NSURL * destinationURL = [directoryURL URLByAppendingPathComponent:kCoreDataManagerSQLiteName];

        BOOL   fileExists = [destinationURL checkResourceIsReachableAndReturnError:NULL];

        MSLogDebugTag(@"database url: %@\nfile exists? %@", destinationURL, BOOLString(fileExists));

        // Remove existing database store if flag is set
        if (_flags.removePreviousDatabase && fileExists)
        {
            MSLogDebugTag(@"removing existing database");

            NSError * error = nil;

            if (![FileManager removeItemAtURL:destinationURL error:&error])
                MSLogErrorTag(@"problem encountered while removing existing persistent store %@, %@",
                              error, [error localizedFailureReason]);

            fileExists = [destinationURL checkResourceIsReachableAndReturnError:NULL];
            assert(!fileExists);
        }

        // Copy bundle resource to store destination if needed
        if (!fileExists && !_flags.rebuildDatabase)
        {
            MSLogDebugTag(@"copying bundle database to destination url...");

            NSURL * bundleURL = [MainBundle URLForResource:kCoreDataManagerPersistentStoreName
                                             withExtension:kCoreDataManagerPersistentStoreExtension];

            // Copy the file
            NSError * error = nil;

            [FileManager copyItemAtURL:bundleURL toURL:destinationURL error:&error];

            // Log error if operation failed
            if (error)
                MSLogWarnTag(@"problem encountered while copying %@ to destination url: %@, %@",
                          [bundleURL lastPathComponent],
                          error,
                          [error localizedFailureReason]);

            fileExists = [destinationURL checkResourceIsReachableAndReturnError:NULL];
            assert(fileExists);
            MSLogDebugTag(@"bundle database copied to destination url successfully");
        }

        assert((fileExists ^ _flags.rebuildDatabase));

        MSLogDebugTag(@"database file operations complete, database %@ flagged for rebuilding",
                      _flags.rebuildDatabase ? @"is" : @"is not");

        NSDictionary * options = @{ NSMigratePersistentStoresAutomaticallyOption : @YES,
                                    NSInferMappingModelAutomaticallyOption       : @YES };

        __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                       initWithManagedObjectModel:[self objectModel]];

        NSError * error = nil;

        if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                        configuration:nil
                                                                  URL:destinationURL
                                                              options:options
                                                                error:&error])
        {
            // TODO: Replace with code to handle error appropriately
            MSLogErrorTag(@"aborting due to unresolved error creating persistent store:%@, %@",
                          error, [error localizedFailureReason]);
            abort();
        }

    });


    return __persistentStoreCoordinator;
}

+ (NSManagedObjectContext *)mainObjectContext { return [[self sharedManager] mainObjectContext]; }
- (NSManagedObjectContext *)mainObjectContext
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
        
                      if ([self persistentStoreCoordinator])
                      {
                          __mainObjectContext = [[NSManagedObjectContext alloc]
                                                 initWithConcurrencyType:NSMainQueueConcurrencyType];
            
                          [__mainObjectContext performBlockAndWait:
                           ^{
                               [__mainObjectContext
                                setPersistentStoreCoordinator:__persistentStoreCoordinator];
                               __mainObjectContext.nametag = @"main";
                           }];
                      }
                      assert(__mainObjectContext);
                  });

    return __mainObjectContext;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Making a new NSManagedObjectContext
////////////////////////////////////////////////////////////////////////////////

+ (NSManagedObjectContext *)newContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)type
                                              undoSupport:(BOOL)undoSupport
                                                  nametag:(NSString *)nametag
{
    return [[self sharedManager] newContextWithConcurrencyType:type
                                                   undoSupport:undoSupport
                                                       nametag:nametag];
}
- (NSManagedObjectContext *)newContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)type
                                              undoSupport:(BOOL)undoSupport
                                                  nametag:(NSString *)nametag
{
    assert(__persistentStoreCoordinator);
    NSManagedObjectContext * context = nil;

    context = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];

    [context performBlockAndWait:
     ^{
         context.nametag = nametag;
         [context setPersistentStoreCoordinator:__persistentStoreCoordinator];
         if (undoSupport) context.undoManager = [NSUndoManager new];
     }];

    [NotificationCenter addObserverForName:NSManagedObjectContextDidSaveNotification
                                    object:context
                                     queue:nil
                                usingBlock:^(NSNotification *note) {
                                    [__mainObjectContext performBlockAndWait:
                                     ^{
                                         MSLogDebugTag(@"merging changes from saved context '%@'",
                                                       getContextDescription(context));
                                         [__mainObjectContext
                                          mergeChangesFromContextDidSaveNotification:note];
                                         [self saveContext:__mainObjectContext
                                              asynchronous:NO
                                                completion:nil];
                                     }];
                                }];


    return context;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Making a new child NSManagedObjectContext
////////////////////////////////////////////////////////////////////////////////

+ (NSManagedObjectContext *)childContextForContext:(NSManagedObjectContext *)context
                                   concurrencyType:(NSManagedObjectContextConcurrencyType)type
                                       undoSupport:(BOOL)undoSupport
                                           nametag:(NSString *)nametag
{
    return [[self sharedManager] childContextForContext:context
                                        concurrencyType:type
                                            undoSupport:undoSupport
                                                nametag:nametag];
}
- (NSManagedObjectContext *)childContextForContext:(NSManagedObjectContext *)context
                                   concurrencyType:(NSManagedObjectContextConcurrencyType)type
                                       undoSupport:(BOOL)undoSupport
                                           nametag:(NSString *)nametag
{

    NSManagedObjectContext * parent = (context ? context : __mainObjectContext);
    NSManagedObjectContext * child  = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];

    [child performBlockAndWait:
     ^{
         child.nametag = nametag;
         child.parentContext = parent;
         if (undoSupport)
         {
             child.undoManager = [NSUndoManager new];
             child.undoManager.levelsOfUndo = 6;
         }
     }];

    return child;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Saving and Resetting an NSManagedObjectContext
////////////////////////////////////////////////////////////////////////////////

+ (BOOL)saveContext:(NSManagedObjectContext *)context
       asynchronous:(BOOL)asynchronous
         completion:(void (^)(BOOL success))completion
{
    return [[self sharedManager] saveContext:context
                                asynchronous:asynchronous
                                  completion:completion];
}
- (BOOL)saveContext:(NSManagedObjectContext *)context
       asynchronous:(BOOL)asynchronous
         completion:(void (^)(BOOL success))completion
{
    if (!context) context = __mainObjectContext;
    
    void(^SaveOperation)(NSManagedObjectContext *, BOOL *) =
    ^(NSManagedObjectContext * ctx, BOOL * success)
    {
        [ctx performBlockAndWait:
         ^{
             if (ctx != __mainObjectContext)
                 [NotificationCenter
                  addObserverForName:NSManagedObjectContextDidSaveNotification
                              object:ctx
                               queue:MainQueue
                          usingBlock:^(NSNotification *note)
                                     {
                                         [__mainObjectContext performBlock:
                                          ^{
                                              [__mainObjectContext
                                               mergeChangesFromContextDidSaveNotification:note];
//                                              [CoreDataManager saveContext:nil
//                                                              asynchronous:YES
//                                                                completion:nil];
                                          }];

                                         [NotificationCenter
                                          removeObserver:[CoreDataManager sharedManager]
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:ctx];
                                     }];

             NSError * error = nil;
             *success = [ctx save:&error];
             
             if (!success)
             {
                 NSArray * errors = error.userInfo[NSDetailedErrorsKey];
                 
                 if (errors)
                     MSLogErrorTag(@"multiple errors while saving context '%@':%@",
                                   getContextDescription(ctx),
                                   [[errors valueForKeyPath:@"description"]
                                    componentsJoinedByString:@"\n\n"]);
                 else if (error)
                     MSLogErrorTag(@"error saving context '%@':%@",
                                   getContextDescription(ctx),
                                   [error description]);
                 else
                     MSLogErrorTag(@"not sure why save failed for context '%@'",
                                   getContextDescription(ctx));
             }
             
             else
                 MSLogDebugTag(@"save successful for context '%@'", getContextDescription(context));
             
             if (completion) MSRunSyncOnMain(^{completion(*success);});
             
            }];
    };

    MSLogDebugTag(@"save requested for context '%@'", getContextDescription(context));

    if (![context hasChanges])
    { // Return success if no changes need to be saved
        MSLogDebugTag(@"save requested but context '%@' has no changes to save",
                      getContextDescription(context));
        if (completion) MSRunSyncOnMain(^{completion(YES);});
        return YES;
    }

    else
    { // Otherwise save context and call completion block
        __block BOOL success = NO;

        if (asynchronous)
            [context performBlock:^{ SaveOperation(context, &success); }];

        else
            [context performBlockAndWait:^{ SaveOperation(context, &success); }];

        return (asynchronous ? YES : success);
    }

}

+ (void)resetContext:(NSManagedObjectContext *)context { [[self sharedManager] resetContext:context]; }
- (void)resetContext:(NSManagedObjectContext *)context
{
    if (!context) context = __mainObjectContext;
    
    MSLogDebugTag(@"resetting context '%@'", getContextDescription(context));
    [context performBlockAndWait:^{[context reset]; }];
}

@end
