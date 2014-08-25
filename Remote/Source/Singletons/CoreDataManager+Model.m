//
//  CoreDataManager+Model.m
//  Remote
//
//  Created by Jason Cardwell on 10/17/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "CoreDataManager.h"
#import "MSKit/MSKit.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

@implementation CoreDataManager (Model)

+ (NSManagedObjectModel *)augmentModel:(NSManagedObjectModel *)model
{
    NSManagedObjectModel * augmentedModel = [model mutableCopy];
    if (!augmentedModel) return nil;

    // helper block for modifiying the class and default value for the same attribute on multiple
    // entities
    void (^modifyAttributeForEntities)(NSArray *, NSString *, NSString *, id, NSDictionary*) =
    ^(NSArray * entities, NSString * attribute, NSString * className, id defaultValue, NSDictionary *info)
    {
        for (NSEntityDescription * entity in entities)
        {
            NSAttributeDescription * description = [entity attributesByName][attribute];
            if (className) [description setAttributeValueClassName:className];
            if (defaultValue) [description setDefaultValue:defaultValue];
            if (info) description.userInfo = [description.userInfo
                                                  dictionaryByAddingEntriesFromDictionary:info];
        }
    };

    // helper block for modifying the class and default value of multiple attributes on the same entity
    void (^modifyAttributesForEntity)(NSEntityDescription*, NSArray*, NSString*, id, NSDictionary*) =
    ^(NSEntityDescription *entity, NSArray *attributes, NSString *className, id defaultValue, NSDictionary *info)
    {
        NSDictionary * attributeDescriptions = [entity attributesByName];
        for (NSString * attributeName in attributes)
        {
            NSAttributeDescription * description = attributeDescriptions[attributeName];
            [description setAttributeValueClassName:className];
            if (defaultValue != nil) [description setDefaultValue:defaultValue];
            if (info) description.userInfo = [description.userInfo
                                                  dictionaryByAddingEntriesFromDictionary:info];
        }
    };

    void (^overrideDefaultValueOfAttributeForSubentity)(NSEntityDescription*, NSString*, id) =
    ^(NSEntityDescription * entity, NSString * attribute, id defaultValue)
    {
        NSEntityDescription * superEntity = entity;
        while (superEntity.superentity) superEntity = superEntity.superentity;

        NSAttributeDescription * description = [superEntity attributesByName][attribute];
        assert(description);

        NSString     * key   = [@"." join : @[MSDefaultValueForContainingClassKey, entity.name]];
        NSDictionary * entry = @{ key : CollectionSafe(defaultValue) };
        NSDictionary * userInfo = [description.userInfo dictionaryByAddingEntriesFromDictionary:entry];

        description.userInfo = userInfo;

        NSString * keypath = $(@"attributesByName.%@.userInfo", attribute);
        NSArray * subentities = superEntity.subentities;

        while ([subentities count])
        {
            [subentities setValue:userInfo forKeyPath:keypath];
            subentities = [[subentities valueForKeyPath:@"@distinctUnionOfObjects.subentities"]
                           filteredArrayUsingPredicateWithBlock:
                           ^BOOL(NSArray * evaluatedObject, NSDictionary *bindings)
                           {
                               return [evaluatedObject count] > 0;
                           }];
        }

        [superEntity setValue:userInfo forKeyPath:keypath];

        NSArray * subentitiesOfSubentities = [[superEntity valueForKeyPath:@"subentities.subentities"]
                                              filteredArrayUsingPredicateWithBlock:
                                              ^BOOL(NSArray * evaluatedObject, NSDictionary *bindings)
                                              {
                                                  return [evaluatedObject count] > 0;
                                              }];

        printf("what");
    };
    
    void(^overrideDefaultValueOfRelatedEntityAttribute)(NSEntityDescription*,NSString*,NSString*,id) =
    ^(NSEntityDescription * entity, NSString *relationship, NSString *attribute, id defaultValue)
    {
        
        NSAttributeDescription * description =
            [entity valueForKeyPath:$(@"relationshipsByName.%@.destinationEntity.attributesByName.%@",
                                      relationship, attribute)];

        assert(description);

        NSString     * key   = [@"." join : @[MSDefaultValueForContainingClassKey, entity.name]];
        NSDictionary * entry = @{ key : CollectionSafe(defaultValue) };

        description.userInfo = [description.userInfo dictionaryByAddingEntriesFromDictionary:entry];
    };


    NSDictionary * entities = [augmentedModel entitiesByName];


    // add class specific attribute defaults
    overrideDefaultValueOfRelatedEntityAttribute(entities[@"ComponentDevice"], @"info", @"user", @YES);

    // indicator attribute on activity commands
    overrideDefaultValueOfAttributeForSubentity(entities[@"ActivityCommand"], @"indicator", @YES);

    // size attributes on images
    modifyAttributeForEntities([entities objectsForKeys:@[@"Image"]
                                         notFoundMarker:NullObject],
                               @"size",
                               @"NSValue",
                               NSValueWithCGSize(CGSizeZero),
                               nil);

    // background color attributes on remote elements
    modifyAttributeForEntities([entities objectsForKeys:@[@"RemoteElement",
                                                          @"Remote",
                                                          @"ButtonGroup",
                                                          @"Button"]
                                         notFoundMarker:NullObject],
                               @"backgroundColor",
                               @"UIColor",
                               ClearColor,
                               nil);

    // background color attributes on theme
    modifyAttributeForEntities([entities objectsForKeys:@[@"Theme",
                                                          @"BuiltinTheme",
                                                          @"CustomTheme"]
                                         notFoundMarker:NullObject],
                                @"remoteBackgroundColor",
                                @"UIColor",
                               ClearColor,
                               nil);

    modifyAttributeForEntities([entities objectsForKeys:@[@"Theme",
                                                          @"BuiltinTheme",
                                                          @"CustomTheme"]
                                         notFoundMarker:NullObject],
                               @"buttonGroupBackgroundColor",
                               @"UIColor",
                               ClearColor,
                               nil);

    // edge insets attributes on buttons
    modifyAttributeForEntities([entities objectsForKeys:@[@"Button"]
                                         notFoundMarker:NullObject],
                               @"titleEdgeInsets",
                               @"NSValue",
                               NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                               nil);

    modifyAttributeForEntities([entities objectsForKeys:@[@"Button"]
                                         notFoundMarker:NullObject],
                               @"contentEdgeInsets",
                               @"NSValue",
                               NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                               nil);

    modifyAttributeForEntities([entities objectsForKeys:@[@"Button"]
                                         notFoundMarker:NullObject],
                               @"imageEdgeInsets",
                               @"NSValue",
                               NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                               nil);

    // edge insets attributes on themes
    modifyAttributeForEntities([entities objectsForKeys:@[@"ThemeButtonSettings"]
                                         notFoundMarker:NullObject],
                               @"titleInsets",
                               @"NSValue",
                               nil,
                               nil);

    modifyAttributeForEntities([entities objectsForKeys:@[@"ThemeButtonSettings"]
                                         notFoundMarker:NullObject],
                               @"contentInsets",
                               @"NSValue",
                               nil,
                               nil);

    modifyAttributeForEntities([entities objectsForKeys:@[@"ThemeButtonSettings"]
                                         notFoundMarker:NullObject],
                               @"imageInsets",
                               @"NSValue",
                               nil,
                               nil);

    // configurations attribute on configuration delegates

    modifyAttributeForEntities([entities
                                objectsForKeys:@[@"RemoteElement",
                                                 @"Remote",
                                                 @"ButtonGroup",
                                                 @"Button"]
                                notFoundMarker:NullObject],
                               @"configurations",
                               @"NSDictionary",
                               @{},
                               nil);

    // panels for RERemote
    modifyAttributeForEntities([entities
                                objectsForKeys:@[@"Remote"]
                                notFoundMarker:NullObject],
                               @"panels",
                               @"NSDictionary",
                               @{},
                               nil);

    // label attribute on button groups
    modifyAttributeForEntities([entities objectsForKeys:@[@"ButtonGroup"]
                                         notFoundMarker:NullObject],
                               @"label",
                               @"NSAttributedString",
                               nil,
                               nil);

    modifyAttributeForEntities([entities objectsForKeys:@[@"ButtonGroup"]
                                         notFoundMarker:NullObject],
                               @"labelAttributes",
                               @"MSDictionary",
                               nil,
                               nil);

    // index attribute on command containers
    modifyAttributeForEntities([entities objectsForKeys:@[@"CommandContainer",
                                                          @"CommandSet",
                                                          @"CommandSetCollection"]
                                         notFoundMarker:NullObject],
                               @"index",
                               @"MSDictionary",
                               nil,
                               nil);

    // url attribute on http command
    modifyAttributeForEntities(@[entities[@"HTTPCommand"]],
                               @"url",
                               @"NSURL",
                               [NSURL URLWithString:@"http://about:blank"],
                               nil);


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
                              nil,
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
                              nil,
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
                              nil,
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
         MSDictionary * userInfo = [MSDictionary dictionaryWithDictionary:obj.userInfo];
         NSString * userInfoString = [userInfo formattedDescriptionWithOptions:0 levelIndent:2];
         [modelDescription appendFormat:@"\tuserInfo: {%@}\n", ([userInfo count]
                                                                ? $(@"\n%@\n\t", userInfoString)
                                                                : @"")];

         for (NSPropertyDescription * property in obj)
         {
             userInfo = [MSDictionary dictionaryWithDictionary:property.userInfo];
             userInfoString = [userInfo formattedDescriptionWithOptions:0 levelIndent:2];

             MSDictionary * d = [MSDictionary dictionary];
             d[@"optional"]                  = BOOLString(property.isOptional);
             d[@"transient"]                 = BOOLString(property.isTransient);
             d[@"validation predicates"]     = $(@"'%@'", [@", " join : property.validationPredicates]);
             d[@"stored in external record"] = BOOLString(property.isStoredInExternalRecord);
             d[@"userInfo"]                  = userInfoString;

             if ([property isKindOfClass:[NSAttributeDescription class]])
             {
                 NSAttributeDescription * ad = (NSAttributeDescription *)property;
                 d[@"attribute value  class name"]       = NSAttributeTypeString(ad.attributeType);
                 d[@"default value"]                     = CollectionSafe(ad.defaultValue);
                 d[@"allows extern binary data storage"] = BOOLString(ad.allowsExternalBinaryDataStorage);
             }

             else if ([property isKindOfClass:[NSRelationshipDescription class]])
             {
                 NSRelationshipDescription * rd = (NSRelationshipDescription *)property;
                 d[@"destination"] = rd.destinationEntity.name;
                 d[@"inverse"]     = rd.inverseRelationship.name;
                 d[@"delete rule"] = NSDeleteRuleString(rd.deleteRule);
                 d[@"max count"]   = @(rd.maxCount);
                 d[@"min count"]   = @(rd.minCount);
                 d[@"one-to-many"] = BOOLString(rd.isToMany);
                 d[@"ordered"]     = BOOLString(rd.isOrdered);
             }

             [modelDescription appendFormat:@"\t%@ {\n%@\n\t}\n",
                                            property.name,
                                            [d formattedDescriptionWithOptions:0
                                                                   levelIndent:2]];
         }

         [modelDescription appendString:@"}\n\n"];
     }];
    
    return modelDescription;
};

+ (NSString *)objectModelDescription:(NSManagedObjectModel *)model
{
    if (!model) model = [NSManagedObjectModel mergedModelFromBundles:@[MainBundle]];
    return descriptionForModel(model);
}

+ (void)logObjectModel:(NSManagedObjectModel *)model
{
    NSOperationQueue * queue = [NSOperationQueue operationQueueWithName:@"com.moondeerstudios.model"];

    if (!model) model = [NSManagedObjectModel mergedModelFromBundles:@[MainBundle]];

    [queue addOperationWithBlock:
     ^{
         NSString * modelDescription = descriptionForModel(model);

         MSLogDebugInContext((LOG_CONTEXT_COREDATA|LOG_CONTEXT_FILE),//|LOG_CONTEXT_CONSOLE),
                             @"%@",
                             modelDescription);
     }];
}

@end
