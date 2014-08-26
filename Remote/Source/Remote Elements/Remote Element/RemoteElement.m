//
// RemoteElement.m
// Remote
//
// Created by Jason Cardwell on 10/3/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteElement_Private.h"
#import "ConstraintManager.h"

static int       ddLogLevel   = LOG_LEVEL_DEBUG;
static const int msLogContext = (LOG_CONTEXT_CONSOLE);

#pragma unused(ddLogLevel, msLogContext)

MSSTRING_CONST REDefaultMode = @"default";


static const REThemeOverrideFlags kToolbarButtonDefaultThemeFlags          = 0b0011111111101111;
static const REThemeOverrideFlags kBatteryStatusButtonDefaultThemeFlags    = 0b0011111111111111;
static const REThemeOverrideFlags kConnectionStatusButtonDefaultThemeFlags = 0b0011111111111111;


@implementation RemoteElement

@synthesize constraintManager = __constraintManager, currentMode = _currentMode;

@dynamic constraints;
@dynamic name;
@dynamic key;
@dynamic tag;
@dynamic backgroundColor;
@dynamic subelements;
@dynamic backgroundImage;
@dynamic backgroundImageAlpha;
@dynamic firstItemConstraints;
@dynamic secondItemConstraints;
@dynamic theme;
@dynamic configurations;
@dynamic parentElement;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initializers
////////////////////////////////////////////////////////////////////////////////

+ (REType)elementType { return RETypeUndefined; }

//+ (instancetype)remoteElement { return [self remoteElementInContext:[CoreDataManager defaultContext]]; }

//+ (instancetype)remoteElementWithAttributes:(NSDictionary *)attributes {
//  return [self remoteElementInContext:[CoreDataManager defaultContext] attributes:attributes];
//}

//+ (instancetype)remoteElementInContext:(NSManagedObjectContext *)moc { return [self createInContext:moc]; }

/*
+ (instancetype)remoteElementInContext:(NSManagedObjectContext *)moc
                            attributes:(NSDictionary *)attributes {
  RemoteElement * element = [self remoteElementInContext:moc];

  [element setValuesForKeysWithDictionary:attributes];

  return element;
}
*/

- (void)prepareForDeletion {
  // TODO: Fill out stub

/*
    if (self.configurationDelegate)
        [self.managedObjectContext performBlockAndWait:
         ^{
             [self.managedObjectContext deleteObject:self.configurationDelegate];
             self.configurationDelegate = nil;
             [self.managedObjectContext processPendingChanges];
         }];
 */
}

- (NSString *)identifier { return $(@"_%@", [self.uuid stringByRemovingCharacter:'-']); }

- (ConstraintManager *)constraintManager {
  if (!__constraintManager) self.constraintManager = [ConstraintManager constraintManagerForRemoteElement:self];

  return __constraintManager;
}

- (void)applyTheme:(Theme *)theme { [theme applyThemeToElement:self]; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Importing
////////////////////////////////////////////////////////////////////////////////


- (void)updateWithData:(NSDictionary *)data {

  /*
     {
              "uuid": "3D15E6CA-A182-476D-87D1-8E2CE774346E",
              "name": "Sonos Activity Rocker",
              "elementType": "button-group",
              "role": "rocker",
              "key": "someKey",
              "backgroundImage": **Image**,
              "backgroundImageAlpha": 0.5,
              "theme": **Theme**,
              "themeFlags": "not parsed yet",
              "options": "autohide",
              "tag": 23,
              "shape": "rounded-rectangle",
              "style": "border gloss1",
              "constraints": {
                  "index": {
                      "buttonTop": "B9C7296F-E1C1-4425-98AF-E67740F64CFE",
                      "buttonBottom": "04A0CAB9-1EFF-46FC-864A-6C00759DD0BD",
                      "sonosActivityRocker": "3D15E6CA-A182-476D-87D1-8E2CE774346E"
                  },
                  "format": [
                          "buttonBottom.height = buttonTop.height",
                          "buttonBottom.left = sonosActivityRocker.left",
                          "buttonBottom.right = sonosActivityRocker.right",
                          "buttonBottom.top = buttonTop.bottom",
                          "buttonTop.height = sonosActivityRocker.height * 0.5",
                          "buttonTop.left = sonosActivityRocker.left",
                          "buttonTop.right = sonosActivityRocker.right",
                          "buttonTop.top = sonosActivityRocker.top",
                          "sonosActivityRocker.height ≥ 150",
                          "sonosActivityRocker.width = 70"
                  ]
              },
              "backgroundColor": "black",
              "subelements": [ **RemoteElement** ]
          }
   */

  [super updateWithData:data];

  self.name       = data[@"name"]                                                ?: self.name;
  self.role       = remoteElementRoleFromImportKey(data[@"role"])                ?: self.role;
  self.key        = data[@"key"]                                                 ?: self.key;
  self.subtype    = remoteElementSubtypeFromImportKey(data[@"subtype"])          ?: self.subtype;
  self.options    = remoteElementOptionsFromImportKey(data[@"options"])          ?: self.options;
  self.state      = remoteElementStateFromImportKey(data[@"state"])              ?: self.state;
  self.shape      = remoteElementShapeFromImportKey(data[@"shape"])              ?: self.shape;
  self.style      = remoteElementStyleFromImportKey(data[@"style"])              ?: self.style;
  self.tag        = data[@"tag"]                                                 ?: @0;
  self.themeFlags = remoteElementThemeFlagsFromImportKey(data[@"theme-flags"])   ?: self.themeFlags;


  NSDictionary           * backgroundColor      = data[@"background-color"];
  NSDictionary           * backgroundImageAlpha = data[@"background-image-alpha"];
  NSDictionary           * backgroundImage      = data[@"background-image"];
  NSDictionary           * theme                = data[@"theme"];
  NSArray                * subelements          = data[@"subelements"];
  NSDictionary           * constraints          = data[@"constraints"];
  NSManagedObjectContext * moc                  = self.managedObjectContext;


  if (backgroundColor)
    for (NSString * mode in backgroundColor) {
      UIColor * color = colorFromImportValue(backgroundColor[mode]);
      if (color) self[modePropertyKey(mode, @"backgroundColor")] = color;
    }

  if (backgroundImage)
    for (NSString * mode in backgroundImage) {
      id value = backgroundImage[mode];
      if (isDictionaryKind(value))
        self[modePropertyKey(mode, @"backgroundImage")] = [Image importObjectFromData:value context:moc];
    }

  if (backgroundImageAlpha)
    for (NSString * mode in backgroundImageAlpha) {
      id value = backgroundImageAlpha[mode];
      if (isNumberKind(value))
        self[modePropertyKey(mode, @"backgroundImageAlpha")] = value;
    }


  if (theme) self.theme = [Theme importObjectFromData:theme context:moc];

  if (subelements) {
    NSMutableArray * subelementObjects = [subelements mutableCopy];

    [subelementObjects filter:^BOOL (id obj) { return isDictionaryKind(obj); }];
    [subelementObjects map:^id (NSDictionary * objData, NSUInteger idx) {
      switch ([[self class] elementType]) {
        case RETypeRemote:
          return [ButtonGroup importObjectFromData:objData context:moc];

        case RETypeButtonGroup:
          return [Button importObjectFromData:objData context:moc];

        default:
          return NullObject;
      }
    }];
    [subelementObjects removeNullObjects];
    self.subelements = [subelementObjects orderedSet];
  }

  if (constraints)
    self.constraints = [[Constraint importObjectsFromData:constraints context:moc] set];

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Exporting
////////////////////////////////////////////////////////////////////////////////


- (MSDictionary *)JSONDictionary {

  MSDictionary * dictionary = [super JSONDictionary];

  NSManagedObjectContext * moc = self.managedObjectContext;

  dictionary[@"name"]    = CollectionSafe(self.name);
  dictionary[@"key"]     = CollectionSafe(self.primitiveKey);
  dictionary[@"tag"]     = CollectionSafe(self.tag);
  dictionary[@"role"]    = CollectionSafe(roleJSONValueForRemoteElement(self));
  dictionary[@"subtype"] = CollectionSafe(subtypeJSONValueForRemoteElement(self));
  dictionary[@"options"] = CollectionSafe(optionsJSONValueForRemoteElement(self));
  dictionary[@"state"]   = CollectionSafe(stateJSONValueForRemoteElement(self));
  dictionary[@"shape"]   = CollectionSafe(shapeJSONValueForRemoteElement(self));
  dictionary[@"style"]   = CollectionSafe(styleJSONValueForRemoteElement(self));
  //TODO: Add theme flags when themes are live

  if ([self.constraints count]) {

    NSSet * constraintDictionaries = [self valueForKeyPath:@"constraints.JSONDictionary"];
    NSSet * firstItemUUIDs = [constraintDictionaries valueForKeyPath:@"@distinctUnionOfObjects.firstItem"];
    NSSet * secondItemUUIDs = [constraintDictionaries valueForKeyPath:@"@distinctUnionOfObjects.secondItem"];
    NSSet * uuids = [[firstItemUUIDs setByAddingObjectsFromSet:secondItemUUIDs]
                     setByRemovingObject:NullObject];

    MSDictionary * uuidIndex = [MSDictionary dictionary];

    for (NSString * uuid in uuids) {
      RemoteElement * element = ([uuid isEqualToString:self.uuid]
                                 ? self
                                 : (RemoteElement *)memberOfCollectionWithUUID(self.subelements, uuid));

      assert(element && element.name);
      uuidIndex[[element.name camelCase]] = uuid;
    }


    MSDictionary * constraints = [MSDictionary dictionary];

    if ([uuidIndex count] == 1)
      constraints[[@"." join:@[@"index", [uuidIndex keyAtIndex:0]]]] = uuidIndex[0];

    else {
      [uuidIndex sortKeysUsingSelector:@selector(caseInsensitiveCompare:)];
      constraints[@"index"] = uuidIndex;
    }

    NSArray * format = [[[self valueForKeyPath:@"constraints.description"] allObjects]
                        sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

    constraints[@"format"]     = ([format count] == 1 ? format[0] : format);
    dictionary[@"constraints"] = constraints;
  }

  dictionary[@"background-color"] = ({
    MSDictionary * colors = [MSDictionary dictionary];
    [self.configurations enumerateKeysAndObjectsUsingBlock:
     ^(NSString * mode, NSDictionary * entry, BOOL *stop) {
       colors[mode] = CollectionSafe(normalizedColorJSONValueForColor(entry[@"backgroundColor"]));
     }];
    colors;
  });

  dictionary[@"background-image"] = ({
    MSDictionary * images = [MSDictionary dictionary];
    [self.configurations enumerateKeysAndObjectsUsingBlock:
     ^(NSString * mode, NSDictionary * entry, BOOL *stop) {
      images[mode] = CollectionSafe(((Image *)[moc objectForURI:entry[@"backgroundImage"]]).commentedUUID);
    }];
    images;
  });

  dictionary[@"background-image-alpha"] = ({
    MSDictionary * alphas = [MSDictionary dictionary];
    [self.configurations enumerateKeysAndObjectsUsingBlock:
     ^(NSString * mode, NSDictionary * entry, BOOL *stop) {
       alphas[mode] = CollectionSafe(entry[@"backgroundImageAlpha"]);
     }];
    alphas;
  });

  if ([self.subelements count])
    dictionary[@"subelements"] = [self valueForKeyPath:@"subelements.JSONDictionary"];

  //TODO: Add theme export once ready

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Derived Properties
////////////////////////////////////////////////////////////////////////////////

- (id)objectForKeyedSubscript:(NSString *)key {

  NSString * mode, * property;

  if (getModePropertyFromKey(key, &mode, &property)) {
    return NilSafe(([self hasMode:mode]
                    ? self.configurations[mode][property]
                    : self.configurations[REDefaultMode][property]));
  } else {

    if (!self.subelements.count) return nil;

    return [self.subelements objectPassingTest:
            ^BOOL (RemoteElement * obj, NSUInteger idx)
    {
      return REStringIdentifiesRemoteElement(key, obj);
    }];
  }
}

- (void)setObject:(id)object forKeyedSubscript:(id)key {

  NSString * mode, * property;

  if (getModePropertyFromKey(key, &mode, &property)) {
    if (![self hasMode:mode]) [self addMode:mode];

    NSMutableDictionary * configurations = [self.configurations mutableCopy];
    NSMutableDictionary * registration   = [configurations[mode] mutableCopy];

    if (object) registration[property] = [object copy];
    else [registration removeObjectForKey:property];

    configurations[mode] = registration;
    self.configurations  = configurations;
  }
}

- (void)setObject:(RemoteElement *)object atIndexedSubscript:(NSUInteger)idx {
  NSUInteger count = self.subelements.count;

  if (!object) ThrowInvalidNilArgument(object);
  else if (idx > count) ThrowInvalidIndexArgument(idx);
  else if (idx == count) [self addSubelementsObject:object];
  else [self insertObject:object inSubelementsAtIndex:idx];

}

- (RemoteElement *)objectAtIndexedSubscript:(NSUInteger)subscript {
  return (subscript < self.subelements.count ? self.subelements[subscript] : nil);
}

- (NSArray *)modes { return [self.configurations allKeys]; }

- (BOOL)proportionLock                 { return self.constraintManager.proportionLock;              }
- (NSSet *)subelementConstraints       { return self.constraintManager.subelementConstraints;       }
- (NSSet *)dependentConstraints        { return self.constraintManager.dependentConstraints;        }
- (NSSet *)dependentChildConstraints   { return self.constraintManager.dependentChildConstraints;   }
- (NSSet *)dependentSiblingConstraints { return self.constraintManager.dependentSiblingConstraints; }
- (NSSet *)intrinsicConstraints        { return self.constraintManager.intrinsicConstraints;        }

////////////////////////////////////////////////////////////////////////////////
/// MARK: - Configurations
////////////////////////////////////////////////////////////////////////////////

- (NSString *)currentMode {
  [self willAccessValueForKey:@"currentMode"];
  NSString * currentMode = _currentMode;

  [self didAccessValueForKey:@"currentMode"];

  if (!currentMode) {
    _currentMode = REDefaultMode;
    currentMode  = _currentMode;
    assert(currentMode);
  }

  return currentMode;
}

- (BOOL)addMode:(NSString *)mode {
  if (![self hasMode:mode]) {
    NSMutableDictionary * configurations = [self.configurations mutableCopy];

    configurations[mode] = @{};    /*
                                      (  ![mode isEqualToString:REDefaultMode]
                                      && self.autoPopulateFromDefaultMode
                                      && configurations[REDefaultMode]
                                      ? [configurations[REDefaultMode] copy]
                                      : [MSDictionary dictionary]);
                                    */

    self.configurations = configurations;

    return YES;
  } else
    return YES;
}

/// Calls `updateForMode:` intended for subclass overriding after setting the element's `currentMode`
/// @param currentMode description
- (void)setCurrentMode:(NSString *)currentMode {
  MSLogDebugTag(@"currentMode:%@ ⇒ %@\nmodeKeys:%@", _currentMode, currentMode, self.modes);

  [self willChangeValueForKey:@"currentMode"];
  _currentMode = currentMode;

  if (![self hasMode:currentMode]) [self addMode:currentMode];

  [self updateForMode:currentMode];
  [self didChangeValueForKey:@"currentMode"];
  [self.subelements setValue:_currentMode forKeyPath:@"currentMode"];
}

- (BOOL)hasMode:(NSString *)key { return [self.configurations hasKey:key]; }

- (void)updateForMode:(NSString *)mode {
  self.backgroundColor = (self[modePropertyKey(mode, @"backgroundColor")]
                          ?: self[modePropertyKey(REDefaultMode, @"backgroundColor")]);
  self.backgroundImage = [self.managedObjectContext
                          objectForURI:(self[modePropertyKey(mode, @"backgroundImage")]
                                        ?: self[modePropertyKey(REDefaultMode, @"backgroundImage")])];
  self.backgroundImageAlpha = (self[modePropertyKey(mode, @"backgroundImageAlpha")]
                               ?: self[modePropertyKey(REDefaultMode, @"backgroundImageAlpha")]);
}


- (void)refresh { [self updateForMode:_currentMode]; }

@end


@implementation RemoteElement (Debugging)

- (NSString *)shortDescription { return self.name; }

- (NSString *)recursiveDeepDescription {
  NSMutableString * description = [[self deepDescription] mutableCopy];

  [description appendString:@"\n"];

  for (RemoteElement * subelement in self.subelements)
    [description appendFormat:@"\n%@\n", [subelement recursiveDeepDescription]];

  return description;
}

- (MSDictionary *)deepDescriptionDictionary {
  RemoteElement * element = [self faultedObject];

  assert(element);

  NSString * typeString    = NSStringFromREType([[self class] elementType]);
  NSString * subtypeString = NSStringFromRESubtype(element.subtype);
  NSString * roleString    = NSStringFromRERole(element.role);
  NSString * keyString     = element.key;
  NSString * nameString    = element.name;
  NSString * tagString     = [element.tag stringValue];
//    NSString * configurationString = $(@"%@-configurations:'%@'",
//                                       unnamedModelObjectDescription(element.configurationDelegate),
//                                       [element.configurationDelegate.modeKeys
//                                            componentsJoinedByString:@", "]);
  NSString * parentString      = namedModelObjectDescription(element.parentElement);
  NSString * subelementsString = ([element.subelements count]
                                  ? [[element.subelements setByMappingToBlock:
                                      ^NSString *(RemoteElement * subelement)
  {
    return namedModelObjectDescription(subelement);
  }] componentsJoinedByString:@"\n"]
                                  : @"nil");
  NSString * layoutString      = [element.constraintManager layoutDescription];
  NSString * proportionString  = BOOLString(element.proportionLock);
  NSString * constraintsString = [[element constraintsDescription]
                                  stringByTrimmingLeadingWhitespace];
  NSString * themeString      = namedModelObjectDescription(element.theme);
  NSString * shapeString      = NSStringFromREShape(element.shape);
  NSString * styleString      = NSStringFromREStyle(element.style);
  NSString * themeFlagString  = NSStringFromREThemeFlags(element.themeFlags);
  NSString * optionsString    = NSStringFromREOptions(element.options, [[self class] elementType]);
  NSString * stateString      = NSStringFromREState(element.state);
  NSString * backgroundString = namedModelObjectDescription(element.backgroundImage);
  NSString * bgAlphaString    = [element.backgroundImageAlpha stringValue];
  NSString * bgColorString    = NSStringFromUIColor(element.backgroundColor);

  MSDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];

  dd[@"elementType"] = (typeString ?: @"nil");
  dd[@"subtype"]     = (subtypeString ?: @"nil");
  dd[@"role"]        = (roleString ?: @"nil");
  dd[@"key"]         = (keyString ?: @"nil");
  dd[@"name"]        = (nameString ?: @"nil");
  dd[@"tag"]         = (tagString ?: @"nil");
//    dd[@"configurationDelegate"] = (configurationString ?: @"nil");
  dd[@"parentElement"]        = (parentString ?: @"nil");
  dd[@"subelements"]          = (subelementsString ?: @"nil");
  dd[@"layout"]               = (layoutString ?: @"nil");
  dd[@"proportionLock"]       = (proportionString ?: @"nil");
  dd[@"constraints"]          = (constraintsString ?: @"nil");
  dd[@"theme"]                = (themeString ?: @"nil");
  dd[@"shape"]                = (shapeString ?: @"nil");
  dd[@"style"]                = (styleString ?: @"nil");
  dd[@"themeFlags"]           = (themeFlagString ?: @"nil");
  dd[@"options"]              = (optionsString ?: @"nil");
  dd[@"state"]                = (stateString ?: @"nil");
  dd[@"backgroundImage"]      = (backgroundString ?: @"nil");
  dd[@"backgroundImageAlpha"] = (bgAlphaString ?: @"nil");
  dd[@"backgroundColor"]      = (bgColorString ?: @"nil");

  return (MSDictionary *)dd;
}

- (NSString *)constraintsDescription {
  NSMutableString * description = [@"" mutableCopy];

  NSSet * constraints              = self.constraints;
  NSSet * subelementConstraints    = self.subelementConstraints;
  NSSet * intrinsicConstraints     = self.intrinsicConstraints;
  NSSet * childToParentConstraints = self.dependentChildConstraints;
  NSSet * childToChildConstraints  = [subelementConstraints
                                         setByRemovingObjectsFromSet:childToParentConstraints];
  NSSet * dependentSiblingConstraints = self.dependentSiblingConstraints;
  NSSet * ancestorOwnedConstraints    = [self.firstItemConstraints
                                         setByRemovingObjectsFromSet:self.constraints];

  // owned constraints
  if (constraints.count) {
    if (intrinsicConstraints.count)
      [description appendFormat:@"\n\nintrinsic constraints:\n\t%@",
       [intrinsicConstraints componentsJoinedByString:@"\n\t"]];

    if (childToParentConstraints.count)
      [description appendFormat:@"\n\nchild to parent constraints:\n\t%@",
       [childToParentConstraints componentsJoinedByString:@"\n\t"]];

    if (childToChildConstraints.count)
      [description appendFormat:@"\n\nchild to child constraints:\n\t%@",
       [childToChildConstraints componentsJoinedByString:@"\n\t"]];
  }

  // dependent sibling constraints
  if (dependentSiblingConstraints.count)
    [description appendFormat:@"\n\ndependent sibling constraints:\n\t%@",
     [dependentSiblingConstraints componentsJoinedByString:@"\n\t"]];

  if (ancestorOwnedConstraints.count)
    [description appendFormat:@"\n\nancestor owned constraints:\n\t%@",
     [ancestorOwnedConstraints componentsJoinedByString:@"\n\t"]];

  // no constraints
  if (description.length == 0) [description appendString:@"\nno constraints"];

  return description;
}

- (NSString *)flagsAndAppearanceDescription {
  return $(@"type:%@\nsubtype:%@\noptions:%@\nstate:%@\nshape:%@\nstyle:%@\n",
           NSStringFromREType([[self class] elementType]),
           NSStringFromRESubtype(self.subtype),
           NSStringFromREOptions(self.options, [[self class] elementType]),
           NSStringFromREState(self.state),
           NSStringFromREShape(self.shape),
           NSStringFromREStyle(self.style));
}

- (NSString *)dumpElementHierarchy {
  NSMutableString * outstring = [[NSMutableString alloc] init];
  __block void      (^dumpElement)(RemoteElement *, int) = nil;

  __block void(__weak ^ weakDumpElement)(RemoteElement *, int) = dumpElement;
  dumpElement =
    ^(RemoteElement * element, int indent) {
    NSString * dashes = [NSString stringWithCharacter:'-' count:indent * 3];

    NSString * spacer = [NSString stringWithCharacter:' ' count:indent * 3 + 4];

    [outstring appendFormat:
     @"%@[%d] class:%@\n"
     "%@name:%@\n"
     "%@key:%@\n"
     "%@identifier:%@\n\n",
     dashes,
     indent,
     ClassString([element class]),
     spacer,
     element.name,
     spacer,
     element.key,
     spacer,
     element.uuid];

    for (RemoteElement * subelement in element.subelements)
      weakDumpElement(subelement, indent + 1);
  };

  dumpElement(self, 0);

  return outstring;
}

@end

NSString*modePropertyKey(NSString * m, NSString * p) { return [@"." join:@[m, p]]; }

BOOL getModePropertyFromKey(NSString * key, NSString ** mode, NSString ** property) {
  if (StringIsEmpty(key)) return NO;

  NSArray * components = [key componentsSeparatedByString:@"."];

  if (![components count] == 2 || StringIsEmpty(components[0]) || StringIsEmpty(components[1])) return NO;

  if (mode != NULL) *mode = components[0];

  if (property != NULL) *property = components[1];

  return YES;
}

NSDictionary*_NSDictionaryOfVariableBindingsToIdentifiers(NSString * commaSeparatedKeysString, id firstValue, ...)               {
  // TODO: Handle replacement order by determining if a key string is matched in another key string
  if (!commaSeparatedKeysString || !firstValue) return nil;

  NSArray        * keys   = [commaSeparatedKeysString componentsSeparatedByRegEx:@",[ ]*"];
  NSMutableArray * values = [NSMutableArray arrayWithCapacity:keys.count];
  va_list          arglist;

  va_start(arglist, firstValue);
  {
    RemoteElement * element = firstValue;

    do {
      [values addObject:element.identifier];
      element = va_arg(arglist, RemoteElement *);
    } while (element);
  }
  va_end(arglist);

  return [NSDictionary dictionaryWithObjects:values forKeys:keys];
}

BOOL REStringIdentifiesRemoteElement(NSString * identifier, RemoteElement * re) {
  return (  StringIsNotEmpty(identifier)
         && (  [identifier isEqualToString:re.uuid]
            || [identifier isEqualToString:re.key]
            || [identifier isEqualToString:re.identifier]));
}

Class classForREType(REType type) {
  switch (type) {
    case RETypeRemote:      return [Remote class];

    case RETypeButtonGroup: return [ButtonGroup class];

    case RETypeButton:      return [Button class];

    default:                return [RemoteElement class];
  }
}
