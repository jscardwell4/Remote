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


MSKIT_STATIC_STRING_CONST   kCoreDataManagerSQLiteName = @"Remote.sqlite";

////////////////////////////////////////////////////////////////////////////////
#pragma mark - CoreDataManager Implementation
////////////////////////////////////////////////////////////////////////////////

@implementation CoreDataManager

+ (void)initialize
{
    if (self == [CoreDataManager class])
    {
        BOOL rebuildDatabase = [UserDefaults boolForKey:@"rebuild"];
        BOOL rebuildRemote   = [UserDefaults boolForKey:@"remote"];
        BOOL replaceDatabase = [UserDefaults boolForKey:@"replace"];
        kFlags = (struct DatabaseFlags_s) {
            .logSaves                = YES,
            .logCoreDataStackSetup   = YES,
            .removePreviousDatabase  = replaceDatabase||rebuildDatabase,
            .rebuildRemote           = (rebuildRemote||rebuildDatabase),
            .rebuildDatabase         = rebuildDatabase,
            .replacePreviousDatabase = (replaceDatabase||rebuildDatabase),
            .objectRemoval           = CoreDataManagerRemoveNone
        };
    }
}

+ (BOOL)initializeDatabase
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // register error handler
        [MagicalRecord setErrorHandlerTarget:self action:@selector(handlerError:)];

        // Magical Record should autocreate the model by merging bundle files
        NSManagedObjectModel * model = [[NSManagedObjectModel
                                         MR_defaultManagedObjectModel] mutableCopy];
        assert(model);
        [self modifyObjectModel:model];

        BOOL databaseStoreExists = [self databaseStoreExists];
        if (databaseStoreExists && kFlags.removePreviousDatabase)
        {
            BOOL success = [self removeExistingStore];
            assert(success);
        }

        // Copy bundle resource to store destination if needed
        if (!databaseStoreExists && !kFlags.rebuildDatabase)
        {
            BOOL success = [self copyBundleDatabaseStore];
            assert(success);
        }

        assert(([self databaseStoreExists] ^ kFlags.rebuildDatabase));
        
        MSLogDebugTag(@"file operations complete, database %@ flagged for rebuilding",
                      kFlags.rebuildDatabase ? @"is" : @"is not");

        // Use Magical Record to create the coordinator with calculated store path
        // and intialize the default managed object context
        [MagicalRecord
         setupCoreDataStackWithAutoMigratingSqliteStoreNamed:kCoreDataManagerSQLiteName];
    });
    
    return YES;
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

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Object Model
////////////////////////////////////////////////////////////////////////////////

+ (void)modifyObjectModel:(NSManagedObjectModel *)model
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // helper block for modifiying the same attribute on multiple entities
        void   (^modifyAttributeForEntities)(NSArray *, NSString *, NSString *, id) =
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
        void   (^modifyAttributesForEntity)(NSEntityDescription *, NSArray *, NSString *, id) =
        ^(NSEntityDescription * e, NSArray * a, NSString * c, id d)
        {
            NSDictionary * attributeDescriptions = [e attributesByName];
            for (NSString * attributeName in a)
            {
                [attributeDescriptions[attributeName] setAttributeValueClassName:c];
                if (d != nil) [attributeDescriptions[attributeName] setDefaultValue:d];
            }
        };

        NSDictionary * entities = [model entitiesByName];

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
        modifyAttributeForEntities([entities
                                    objectsForKeys:@[@"REConfigurationDelegate",
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
        // Update Magical Record default model
        [NSManagedObjectModel MR_setDefaultManagedObjectModel:model];

        // Log the updated model
        [self logObjectModel:model];

    });
}

+ (void)logObjectModel:(NSManagedObjectModel *)model
{
    NSOperationQueue * queue = [NSOperationQueue operationQueueWithName:@"com.moondeerstudios.model"];

    if (!model) model = [NSManagedObjectModel MR_defaultManagedObjectModel];

    [queue addOperationWithBlock:
     ^{
         __block NSMutableString * modelDescription =
         [$(@"%@  managed object model:\n", ClassTagSelectorString) mutableCopy];

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

         MSLogDebugInContext(COREDATA_F_C, @"%@", modelDescription);
     }];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Error Handling
////////////////////////////////////////////////////////////////////////////////

+ (void)handlerError:(NSError *)error
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
