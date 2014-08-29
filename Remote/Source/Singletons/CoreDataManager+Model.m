//
//  CoreDataManager+Model.m
//  Remote
//
//  Created by Jason Cardwell on 10/17/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "CoreDataManager.h"
#import "MSKit/MSKit.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

@implementation CoreDataManager (Model)


/// Helper for modifiying the class and default value for the same attribute on multiple entities
/// @param entities NSArray * An array of `NSEntityDescription *` whose attribute shall be modified
/// @param attribute NSString * Name of attribute to modify
/// @param className NSString * Class name for the value of the attribute to modify
/// @param defaultValue id The default value for the attribute to modify
/// @param info NSDictionary * Entries to add to the user info dictionary of attribute to modify
+ (void)modifyAttributeForEntities:(NSArray *)entities
                         attribute:(NSString *)attribute
                         className:(NSString *)className
                      defaultValue:(id)defaultValue
                              info:(NSDictionary *)info
{
  for (NSEntityDescription * entity in entities) {
    NSAttributeDescription * description = [entity attributesByName][attribute];

    if (className) [description setAttributeValueClassName:className];

    if (defaultValue) [description setDefaultValue:defaultValue];

    if (info) description.userInfo = [description.userInfo
                                      dictionaryByAddingEntriesFromDictionary:info];
  }
}

/// Helper for modifying the class and default value of multiple attributes on the same entity
/// @param entity NSEntityDescription * The entity to modify
/// @param attributes NSArray * An array of `NSAttributeDescription *` objects to modify
/// @param className NSString * The class name of the value type of attributes to modify
/// @param defaultValue id The default value of the attributes to modify
/// @param info NSDictionary * Entries to add to the user info dictionary of attributes to modify
+ (void)modifyAttributesForEntity:(NSEntityDescription *)entity
                       attributes:(NSArray *)attributes
                        className:(NSString *)className
                     defaultValue:(id)defaultValue
                             info:(NSDictionary *)info
{
    NSDictionary * attributeDescriptions = [entity attributesByName];

    for (NSString * attributeName in attributes) {
      NSAttributeDescription * description = attributeDescriptions[attributeName];
      [description setAttributeValueClassName:className];

      if (defaultValue != nil) [description setDefaultValue:defaultValue];

      if (info) description.userInfo = [description.userInfo dictionaryByAddingEntriesFromDictionary:info];
    }
}

/// Helper for setting a different default value for an attribute of an entity than is set for its parent
/// @param entity NSEntityDescription * The entity whose attribute shall have its default value set.
/// @param attribute NSString * The name of the attribute of the entity whose attribute shall be modified.
/// @param defaultValue id The value to set as default for the specified attribute of the entity.
+ (void)overrideDefaultValueOfAttributeForSubentity:(NSEntityDescription *)entity
                                          attribute:(NSString *)attribute
                                       defaultValue:(id)defaultValue
{
    NSEntityDescription * superEntity = entity;

    while (superEntity.superentity) superEntity = superEntity.superentity;

    NSAttributeDescription * description = [superEntity attributesByName][attribute];
    assert(description);

    NSString     * key   = [@"." join:@[MSDefaultValueForContainingClassKey, entity.name]];
    NSDictionary * entry = @{
      key : CollectionSafe(defaultValue)
    };
    NSDictionary * userInfo = [description.userInfo dictionaryByAddingEntriesFromDictionary:entry];

    description.userInfo = userInfo;

    NSString * keypath     = $(@"attributesByName.%@.userInfo", attribute);
    NSArray  * subentities = superEntity.subentities;

    while ([subentities count]) {
      [subentities setValue:userInfo forKeyPath:keypath];
      subentities = [[subentities valueForKeyPath:@"@distinctUnionOfObjects.subentities"]
                     filteredArrayUsingPredicateWithBlock:
                     ^BOOL (NSArray * evaluatedObject, NSDictionary * bindings) {
                       return [evaluatedObject count] > 0;
                     }];
    }

    [superEntity setValue:userInfo forKeyPath:keypath];

    NSArray * subentitiesOfSubentities = [[superEntity valueForKeyPath:@"subentities.subentities"]
                                          filteredArrayUsingPredicateWithBlock:
                                          ^BOOL (NSArray * evaluatedObject, NSDictionary * bindings)
    {
      return [evaluatedObject count] > 0;
    }];

};

/// The method programatically modifies the specified model to add more detail to various attributes,
/// i.e. default values, class names, etc. The model passed to this method must be as-of-yet unused or
/// an internal inconsistency will be introduced and the application will crash.
///
/// @param model NSManagedObjectModel * The model to modify
/// @return NSManagedObjectModel * The augmented model
+ (NSManagedObjectModel *)augmentModel:(NSManagedObjectModel *)model {

  if (!model) ThrowInvalidNilArgument(model);

  NSManagedObjectModel * augmentedModel = [model mutableCopy];
  NSDictionary         * entities       = [augmentedModel entitiesByName];


  // set `user` default value
  [self modifyAttributeForEntities:@[entities[@"ComponentDevice"]]
                         attribute:@"user"
                         className:nil
                      defaultValue:@YES
                              info:nil];

  // indicator attribute on activity commands
  [self overrideDefaultValueOfAttributeForSubentity:entities[@"ActivityCommand"]
                                          attribute:@"indicator"
                                       defaultValue:@YES];

  // size attributes on images
  [self modifyAttributeForEntities:[entities objectsForKeys:@[@"Image"] notFoundMarker:NullObject]
                         attribute:@"size"
                         className:@"NSValue"
                      defaultValue:NSValueWithCGSize(CGSizeZero)
                              info:nil];

  // background color attributes on remote elements
  [self modifyAttributeForEntities:[entities objectsForKeys:@[@"RemoteElement",
                                                              @"Remote",
                                                              @"ButtonGroup",
                                                              @"Button"]
                                             notFoundMarker:NullObject]
                         attribute:@"backgroundColor"
                         className:@"UIColor"
                      defaultValue:ClearColor
                              info:nil];

  // background color attributes on theme
  [self modifyAttributeForEntities:[entities objectsForKeys:@[@"Theme", @"BuiltinTheme", @"CustomTheme"]
                                             notFoundMarker:NullObject]
                         attribute:@"remoteBackgroundColor"
                         className:@"UIColor"
                      defaultValue:ClearColor
                              info:nil];

  [self modifyAttributeForEntities:[entities objectsForKeys:@[@"Theme", @"BuiltinTheme", @"CustomTheme"]
                                             notFoundMarker:NullObject]
                         attribute:@"buttonGroupBackgroundColor"
                         className:@"UIColor"
                      defaultValue:ClearColor
                              info:nil];

  // edge insets attributes on buttons
  [self modifyAttributeForEntities:[entities objectsForKeys:@[@"Button"] notFoundMarker:NullObject]
                         attribute:@"titleEdgeInsets"
                         className:@"NSValue"
                      defaultValue:NSValueWithUIEdgeInsets(UIEdgeInsetsZero)
                              info:nil];

  [self modifyAttributeForEntities:[entities objectsForKeys:@[@"Button"] notFoundMarker:NullObject]
                         attribute:@"contentEdgeInsets"
                         className:@"NSValue"
                      defaultValue:NSValueWithUIEdgeInsets(UIEdgeInsetsZero)
                              info:nil];

  [self modifyAttributeForEntities:[entities objectsForKeys:@[@"Button"] notFoundMarker:NullObject]
                         attribute:@"imageEdgeInsets"
                         className:@"NSValue"
                      defaultValue:NSValueWithUIEdgeInsets(UIEdgeInsetsZero)
                              info:nil];

  // edge insets attributes on themes
  [self modifyAttributeForEntities:[entities objectsForKeys:@[@"ThemeButtonSettings"] notFoundMarker:NullObject]
                         attribute:@"titleInsets"
                         className:@"NSValue"
                      defaultValue:nil
                              info:nil];

  [self modifyAttributeForEntities:[entities objectsForKeys:@[@"ThemeButtonSettings"] notFoundMarker:NullObject]
                         attribute:@"contentInsets"
                         className:@"NSValue"
                      defaultValue:nil
                              info:nil];

  [self modifyAttributeForEntities:[entities objectsForKeys:@[@"ThemeButtonSettings"] notFoundMarker:NullObject]
                         attribute:@"imageInsets"
                         className:@"NSValue"
                      defaultValue:nil
                              info:nil];

  // configurations attribute on remote elements
  [self modifyAttributeForEntities:[entities objectsForKeys:@[@"RemoteElement",
                                                              @"Remote",
                                                              @"ButtonGroup",
                                                              @"Button"]
                                             notFoundMarker:NullObject]
                         attribute:@"configurations"
                         className:@"NSMutableDictionary"
                      defaultValue:[@{} mutableCopy]
                              info:nil];

  // panels for RERemote
  [self modifyAttributeForEntities:[entities objectsForKeys:@[@"Remote"] notFoundMarker:NullObject]
                         attribute:@"panels"
                         className:@"NSMutableDictionary"
                      defaultValue:[@{} mutableCopy]
                              info:nil];

  // label attribute on button groups
  [self modifyAttributeForEntities:[entities objectsForKeys:@[@"ButtonGroup"] notFoundMarker:NullObject]
                         attribute:@"label"
                         className:@"NSAttributedString"
                      defaultValue:nil
                              info:nil];

  [self modifyAttributeForEntities:[entities objectsForKeys:@[@"ButtonGroup"] notFoundMarker:NullObject]
                         attribute:@"labelAttributes"
                         className:@"MSDictionary"
                      defaultValue:[MSDictionary dictionary]
                              info:nil];

  [self modifyAttributeForEntities:[entities objectsForKeys:@[@"Button"] notFoundMarker:NullObject]
                         attribute:@"Title"
                         className:@"NSAttributedString"
                      defaultValue:nil
                              info:nil];

  // index attribute on command containers
  [self modifyAttributeForEntities:[entities objectsForKeys:@[@"CommandContainer", @"CommandSet", @"CommandSetCollection"] notFoundMarker:NullObject]
                         attribute:@"index"
                         className:@"MSDictionary"
                      defaultValue:[MSDictionary dictionary]
                              info:nil];

  // url attribute on http command
  [self modifyAttributeForEntities:@[entities[@"HTTPCommand"]]
                         attribute:@"url"
                         className:@"NSURL"
                      defaultValue:[NSURL URLWithString:@"http://about:blank"]
                              info:nil];

  // color attributes on control state color set
  [self modifyAttributesForEntity:entities[@"ControlStateColorSet"]
                       attributes:@[@"disabled",
                                    @"disabledSelected",
                                    @"highlighted",
                                    @"highlightedDisabled",
                                    @"highlightedSelected",
                                    @"normal",
                                    @"selected",
                                    @"selectedHighlightedDisabled"]
                        className:@"UIColor"
                     defaultValue:nil
                             info:nil];

  // color attribute on image view
  [self modifyAttributeForEntities:@[entities[@"ImageView"]]
                         attribute:@"color"
                         className:@"UIColor"
                      defaultValue:nil
                              info:nil];

  return augmentedModel;
}

/// Method for generating a detailed description of a model suitable for printing.
/// @param model NSManagedObjectModel * The model to describe. If nil, the merged bundle model is used.
/// @return NSString * The model's description
+ (NSString *)objectModelDescription:(NSManagedObjectModel *)model {

  if (!model) model = [NSManagedObjectModel mergedModelFromBundles:@[MainBundle]];
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

     for (NSPropertyDescription * property in obj) {
       userInfo = [MSDictionary dictionaryWithDictionary:property.userInfo];
       userInfoString = [userInfo formattedDescriptionWithOptions:0 levelIndent:2];

       MSDictionary * d = [MSDictionary dictionary];
       d[@"optional"]                  = BOOLString(property.isOptional);
       d[@"transient"]                 = BOOLString(property.isTransient);
       d[@"validation predicates"]     = $(@"'%@'", [@", " join:property.validationPredicates]);
       d[@"stored in external record"] = BOOLString(property.isStoredInExternalRecord);
       d[@"userInfo"]                  = userInfoString;

       if ([property isKindOfClass:[NSAttributeDescription class]]) {
         NSAttributeDescription * ad = (NSAttributeDescription *)property;
         d[@"attribute value  class name"]       = NSAttributeTypeString(ad.attributeType);
         d[@"default value"]                     = CollectionSafe(ad.defaultValue);
         d[@"allows extern binary data storage"] = BOOLString(ad.allowsExternalBinaryDataStorage);
       } else if ([property isKindOfClass:[NSRelationshipDescription class]]) {
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
}

/// Method for logging a model's description to file.
/// @param model NSManagedObjectModel * The model whose description shall be logged.
/// @seealso `objectModelDescription:`
+ (void)logObjectModel:(NSManagedObjectModel *)model {
  NSString * desc = [self objectModelDescription:model];
  NSOperationQueue * queue = [NSOperationQueue operationQueueWithName:@"com.moondeerstudios.model"];
  [queue addOperationWithBlock:^{
    MSLogDebugInContext((LOG_CONTEXT_COREDATA | LOG_CONTEXT_FILE), @"%@", desc);
  }];
}

@end
