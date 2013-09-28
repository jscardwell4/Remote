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
static const int   msLogContext = (LOG_CONTEXT_COREDATA|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);

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
        // register error handler
        [MagicalRecord setErrorHandlerTarget:self action:@selector(handleErrors:)];

        // register log handler
        LogHandlerBlock handler = ^(id _self, id object, NSString * format, va_list args)
        {
            if (format)
            {
                [DDLog log:YES
                     level:ddLogLevel
                      flag:LOG_FLAG_MAGICALRECORD
                   context:msLogContext
                      file:__FILE__
                  function:sel_getName(_cmd)
                      line:__LINE__
                       tag:@{ MSLogClassNameKey  : CollectionSafeValue(ClassString([_self class])) }
                    format:format
                      args:args];
            }
        };
        [MagicalRecord setLogHandler:handler];

        // Magical Record should autocreate the model by merging bundle files
        NSManagedObjectModel * model = [self augmentModel:
                                        [NSManagedObjectModel MR_defaultManagedObjectModel]];
        assert(model);
        [NSManagedObjectModel MR_setDefaultManagedObjectModel:model];

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
        [MagicalRecord
         setupCoreDataStackWithAutoMigratingSqliteStoreNamed:kCoreDataManagerSQLiteName];
        NSManagedObjectContext * moc = [NSManagedObjectContext MR_defaultContext];
        if (moc.parentContext) [moc registerAsChildOfContext:moc.parentContext];
        if (databaseStoreExists && kFlags.rebuildRemote)
        {
            success = [self removeExistingRemote];
            assert(success);
        }
    });
    
    return success;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Database File Operations
////////////////////////////////////////////////////////////////////////////////

+ (NSURL *)databaseStoreURL
{
    static NSURL * databaseStoreURL = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        databaseStoreURL = [NSURL fileURLWithPath:
                            [[NSPersistentStore MR_applicationStorageDirectory]
                             stringByAppendingPathComponent:kCoreDataManagerSQLiteName]];
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
        [MagicalRecord handleErrors:error];
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
        [MagicalRecord handleErrors:error];
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
    NSManagedObjectContext * moc = [NSManagedObjectContext MR_defaultContext];
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
#pragma mark - Object Model
////////////////////////////////////////////////////////////////////////////////

+ (NSManagedObjectModel *)augmentModel:(NSManagedObjectModel *)model
{
    NSManagedObjectModel * augmentedModel = [model mutableCopy];
    if (!augmentedModel) return nil;

    // helper block for modifiying the same attribute on multiple entities
    void (^modifyAttributeForEntities)(NSArray *, NSString *, NSString *, id) =
    ^(NSArray * e, NSString * a, NSString * c, id d)
    {
        for (NSEntityDescription * entity in e)
        {
            NSAttributeDescription * description = [entity attributesByName][a];
            [description setAttributeValueClassName:c];
            if (d != nil) [description setDefaultValue:d];
        }
    };

    // helper block for modifying multiple attributes on the same entity
    void (^modifyAttributesForEntity)(NSEntityDescription *, NSArray *, NSString *, id) =
    ^(NSEntityDescription * e, NSArray * a, NSString * c, id d)
    {
        NSDictionary * attributeDescriptions = [e attributesByName];
        for (NSString * attributeName in a)
        {
            [attributeDescriptions[attributeName] setAttributeValueClassName:c];
            if (d != nil) [attributeDescriptions[attributeName] setDefaultValue:d];
        }
    };

    NSDictionary * entities = [augmentedModel entitiesByName];

    // size attributes on images
    modifyAttributeForEntities([entities objectsForKeys:@[@"Image"]
                                         notFoundMarker:NullObject],
                               @"size",
                               @"NSValue",
                               NSValueWithCGSize(CGSizeZero));

    // background color attributes on remote elements
    modifyAttributeForEntities([entities objectsForKeys:@[@"RemoteElement",
                                                          @"Remote",
                                                          @"ButtonGroup",
                                                          @"PickerLabelButtonGroup",
                                                          @"Button"]
                                         notFoundMarker:NullObject],
                               @"backgroundColor",
                               @"UIColor",
                               ClearColor);

    // background color attributes on theme
    modifyAttributeForEntities([entities objectsForKeys:@[@"Theme",
                                                          @"BuiltinTheme",
                                                          @"CustomTheme"]
                                         notFoundMarker:NullObject],
                                @"remoteBackgroundColor",
                                @"UIColor",
                                ClearColor);

    modifyAttributeForEntities([entities objectsForKeys:@[@"Theme",
                                                          @"BuiltinTheme",
                                                          @"CustomTheme"]
                                         notFoundMarker:NullObject],
                               @"buttonGroupBackgroundColor",
                               @"UIColor",
                               ClearColor);

    // edge insets attributes on buttons
    modifyAttributeForEntities([entities objectsForKeys:@[@"Button"]
                                         notFoundMarker:NullObject],
                               @"titleEdgeInsets",
                               @"NSValue",
                               NSValueWithUIEdgeInsets(UIEdgeInsetsZero));
    modifyAttributeForEntities([entities objectsForKeys:@[@"Button"]
                                         notFoundMarker:NullObject],
                               @"contentEdgeInsets",
                               @"NSValue",
                               NSValueWithUIEdgeInsets(UIEdgeInsetsZero));
    modifyAttributeForEntities([entities objectsForKeys:@[@"Button"]
                                         notFoundMarker:NullObject],
                               @"imageEdgeInsets",
                               @"NSValue",
                               NSValueWithUIEdgeInsets(UIEdgeInsetsZero));

    // edge insets attributes on themes
    modifyAttributeForEntities([entities objectsForKeys:@[@"ThemeButtonSettings"]
                                         notFoundMarker:NullObject],
                               @"titleInsets",
                               @"NSValue",
                               nil);
    modifyAttributeForEntities([entities objectsForKeys:@[@"ThemeButtonSettings"]
                                         notFoundMarker:NullObject],
                               @"contentInsets",
                               @"NSValue",
                               nil);
    modifyAttributeForEntities([entities objectsForKeys:@[@"ThemeButtonSettings"]
                                         notFoundMarker:NullObject],
                               @"imageInsets",
                               @"NSValue",
                               nil);

    // configurations attribute on configuration delegates
    modifyAttributeForEntities([entities
                                objectsForKeys:@[@"ConfigurationDelegate",
                                                 @"RemoteConfigurationDelegate",
                                                 @"ButtonGroupConfigurationDelegate",
                                                 @"ButtonConfigurationDelegate"]
                                notFoundMarker:NullObject],
                               @"configurations",
                               @"NSDictionary",
                               @{});

    // panels for RERemote
    modifyAttributeForEntities([entities
                                objectsForKeys:@[@"Remote"]
                                notFoundMarker:NullObject],
                               @"panels",
                               @"NSDictionary",
                               @{});

    // label attribute on button groups
    modifyAttributeForEntities([entities objectsForKeys:@[@"ButtonGroup",
                                                          @"PickerLabelButtonGroup"]
                                         notFoundMarker:NullObject],
                               @"label",
                               @"NSAttributedString",
                               nil);

    // index attribute on command containers
    modifyAttributeForEntities([entities objectsForKeys:@[@"CommandContainer",
                                                          @"CommandSet",
                                                          @"CommandSetCollection"]
                                         notFoundMarker:NullObject],
                               @"index",
                               @"NSDictionary",
                               @{});

    // url attribute on http command
    modifyAttributeForEntities(@[entities[@"HTTPCommand"]],
                               @"url",
                               @"NSURL",
                               [NSURL URLWithString:@"http://about:blank"]);

    // bitVector attribute on layout configuration
    modifyAttributeForEntities(@[entities[@"LayoutConfiguration"]],
                               @"bitVector",
                               @"MSBitVector",
                               BitVector8);

    // color attributes on control state color set
    modifyAttributesForEntity(entities[@"ControlStateColorSet"],
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
    modifyAttributesForEntity(entities[@"ControlStateImageSet"],
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
    modifyAttributesForEntity(entities[@"ControlStateTitleSet"],
                              @[@"disabled",
                                @"disabledAndSelected",
                                @"highlighted",
                                @"highlightedAndDisabled",
                                @"highlightedAndSelected",
                                @"normal",
                                @"selected",
                                @"selectedHighlightedAndDisabled"],
                              @"NSDictionary",
                              nil);
    return augmentedModel;
}

NSString * (^descriptionForModel)(NSManagedObjectModel *) = ^NSString *(NSManagedObjectModel * model)
{
    __block NSMutableString * modelDescription = [@"" mutableCopy];

    [model.entities enumerateObjectsUsingBlock:
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
    
    return modelDescription;
};

+ (NSString *)objectModelDescription:(NSManagedObjectModel *)model
{
    if (!model) model = [NSManagedObjectModel MR_defaultManagedObjectModel];
    return descriptionForModel(model);
}

+ (void)logObjectModel:(NSManagedObjectModel *)model
{
    NSOperationQueue * queue = [NSOperationQueue operationQueueWithName:@"com.moondeerstudios.model"];

    if (!model) model = [NSManagedObjectModel MR_defaultManagedObjectModel];

    [queue addOperationWithBlock:
     ^{
         NSString * modelDescription = descriptionForModel(model);

         MSLogDebugInContext((LOG_CONTEXT_COREDATA|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE),
                             @"%@",
                             modelDescription);
     }];
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


@end
