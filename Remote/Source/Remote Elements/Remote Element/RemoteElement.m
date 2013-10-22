//
// RemoteElement.m
// Remote
//
// Created by Jason Cardwell on 10/3/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteElement_Private.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static const int msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel, msLogContext)

static const NSDictionary * kEntityNameForType;
static const NSSet        * kLayoutConfigurationSelectors;
static const NSSet        * kLayoutConfigurationKeys;
static const NSSet        * kConfigurationDelegateKeys;
static const NSSet        * kConfigurationDelegateSelectors;
static const NSSet        * kConstraintManagerSelectors;
static const REThemeOverrideFlags   kToolbarButtonDefaultThemeFlags          = 0b0011111111101111;
static const REThemeOverrideFlags   kBatteryStatusButtonDefaultThemeFlags    = 0b0011111111111111;
static const REThemeOverrideFlags   kConnectionStatusButtonDefaultThemeFlags = 0b0011111111111111;


@implementation RemoteElement {
    NSString * __identifier;
    BOOL       _needsImportConstraints;
}

@synthesize constraintManager = __constraintManager;

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
@dynamic layoutConfiguration;
@dynamic theme;
@dynamic configurationDelegate;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initializers
////////////////////////////////////////////////////////////////////////////////

+ (void)initialize
{
    if (self == [RemoteElement class]) {
        kEntityNameForType = @{@(RETypeRemote)      : @"Remote",
                               @(RETypeButtonGroup) : @"ButtonGroup",
                               @(RETypeButton)      : @"Button"};

        kLayoutConfigurationSelectors = [@[NSValueWithPointer(@selector(proportionLock)),
                                           NSValueWithPointer(@selector(subelementConstraints)),
                                           NSValueWithPointer(@selector(dependentConstraints)),
                                           NSValueWithPointer(@selector(dependentChildConstraints)),
                                           NSValueWithPointer(@selector(dependentSiblingConstraints)),
                                           NSValueWithPointer(@selector(intrinsicConstraints))] set];

        kConstraintManagerSelectors = [@[NSValueWithPointer(@selector(setConstraintsFromString:))]
                                       set];

        kLayoutConfigurationKeys = [@[@"proportionLock",
                                      @"subelementConstraints",
                                      @"dependentConstraints",
                                      @"dependentChildConstraints",
                                      @"dependentSiblingConstraints",
                                      @"intrinsicConstraints"] set];

        kConfigurationDelegateSelectors = [@[NSValueWithPointer(@selector(currentMode)),
                                             NSValueWithPointer(@selector(addMode:)),
                                             NSValueWithPointer(@selector(hasMode:))] set];
        kConfigurationDelegateKeys = [@[@"currentMode"] set];
    }
}

+ (instancetype)remoteElement
{
    return [self remoteElementInContext:[CoreDataManager defaultContext]];
}

+ (instancetype)remoteElementWithAttributes:(NSDictionary *)attributes
{
    RemoteElement * element = [self remoteElement];
    [element setValuesForKeysWithDictionary:attributes];
    return element;
}

+ (instancetype)remoteElementInContext:(NSManagedObjectContext *)moc
{
    return [self MR_createInContext:moc];
}

+ (instancetype)remoteElementInContext:(NSManagedObjectContext *)moc
                            attributes:(NSDictionary *)attributes
{
    RemoteElement * element = [self remoteElementInContext:moc];
    [element setValuesForKeysWithDictionary:attributes];
    return element;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];

    if (ModelObjectShouldInitialize)
        [self.managedObjectContext performBlockAndWait:
         ^{
             self.layoutConfiguration = [LayoutConfiguration layoutConfigurationForElement:self];
         }];
}

- (void)prepareForDeletion
{
    if (self.configurationDelegate)
        [self.managedObjectContext performBlockAndWait:
         ^{
             [self.managedObjectContext deleteObject:self.configurationDelegate];
             self.configurationDelegate = nil;
             [self.managedObjectContext processPendingChanges];
         }];
}

- (NSString *)identifier
{
    if (!__identifier) __identifier = $(@"_%@", [self.uuid stringByRemovingCharacter:'-']);
    return __identifier;
}

- (void)setParentElement:(RemoteElement *)parentElement
{
    [self willChangeValueForKey:@"parentElement"];
    self.primitiveParentElement = parentElement;
    [self didChangeValueForKey:@"parentElement"];

    if (parentElement)
    {
        self.configurationDelegate.delegate = parentElement.configurationDelegate.delegate;
        [self.subelements setValue:self.configurationDelegate.delegate
                        forKeyPath:@"configurationDelegate.delegate"];
    }
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([kLayoutConfigurationSelectors containsObject:NSValueWithPointer(aSelector)])
        return self.layoutConfiguration;

    else if ([kConstraintManagerSelectors containsObject:NSValueWithPointer(aSelector)])
        return self.constraintManager;

    else if ([kConfigurationDelegateSelectors containsObject:NSValueWithPointer(aSelector)])
        return self.configurationDelegate;
    else
        return [super forwardingTargetForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSValue * selector = NSValueWithPointer(anInvocation.selector);
    if ([kLayoutConfigurationSelectors containsObject:selector])
        [anInvocation invokeWithTarget:self.layoutConfiguration];

    else if ([kConfigurationDelegateSelectors containsObject:selector])
        [anInvocation invokeWithTarget:self.configurationDelegate];

    else if ([kConstraintManagerSelectors containsObject:selector])
        [anInvocation invokeWithTarget:self.constraintManager];

    else
        [super forwardInvocation:anInvocation];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    if ([kLayoutConfigurationKeys containsObject:key])
        return [self.layoutConfiguration valueForKey:key];

    else if ([kConfigurationDelegateKeys containsObject:key])
        return [self.configurationDelegate valueForKey:key];

    else
        return [super valueForUndefinedKey:key];
}

- (ConstraintManager *)constraintManager
{
    if (!__constraintManager)
        self.constraintManager = [ConstraintManager constraintManagerForRemoteElement:self];
    return __constraintManager;
}

/*
- (NSString *)key
{
    [self willAccessValueForKey:@"key"];
    NSString * key = self.primitiveKey;
    [self didAccessValueForKey:@"key"];

    return (key ?: [self.name camelCaseString]);
}
*/

- (void)applyTheme:(Theme *)theme { [theme applyThemeToElement:self]; }

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Importing
////////////////////////////////////////////////////////////////////////////////

#define isString(OBJ) [OBJ isKindOfClass:[NSString class]]

- (BOOL)MR_importValuesForKeysWithObject:(id)objectData
{
    return YES;
}

- (BOOL)importRole:(id)data
{
    if (isString(data))
    {
        RERole role = remoteElementRoleFromImportKey(data);
        self.role = role;
        return YES;
    }

    else return NO;
}

- (BOOL)importElementType:(id)data
{

    if (isString(data))
    {
        REType type = remoteElementTypeFromImportKey(data);
        self.elementType = type;
        return YES;
    }

    else return NO;
}

- (BOOL)importSubtype:(id)data
{
    if (isString(data))
    {
        RESubtype subtype = remoteElementSubtypeFromImportKey(data);
        self.subtype = subtype;
        return YES;
    }

    else return NO;
}

- (BOOL)importOptions:(id)data
{
    if (isString(data))
    {
        REOptions options = remoteElementOptionsFromImportKey(data);
        self.options = options;
        return YES;
    }

    else return NO;
}

- (BOOL)importState:(id)data
{
    if (isString(data))
    {
        REState state = remoteElementStateFromImportKey(data);
        self.state = state;
        return YES;
    }

    else return NO;
}

- (BOOL)importShape:(id)data
{
    if (isString(data))
    {
        REShape shape = remoteElementShapeFromImportKey(data);
        self.shape = shape;
        return YES;
    }

    else return NO;
}

- (BOOL)importStyle:(id)data
{
    if (isString(data))
    {
        REStyle style = remoteElementStyleFromImportKey(data);
        self.style = style;
        return YES;
    }

    else return NO;
}

- (BOOL)importSubelements:(id)data
{
/*
    NSManagedObjectContext * moc = self.managedObjectContext;
    [moc performBlockAndWait:
     ^{
         for (NSDictionary * subelementData in data[@"subelements"])
         {
             NSString * typeString = subelementData[@"type"];
             if (StringIsEmpty(typeString)) continue;

             Class typeClass = remoteElementClassForImportKey(typeString);
             if (!typeClass) continue;

             RemoteElement * subelement = [typeClass remoteElementInContext:moc];
             [subelement MR_importValuesForKeysWithObject:subelementData];
             [self addSubelementsObject:subelement];

         }

         if (_needsImportConstraints) [self importConstraints:data];
     }];
*/

    return YES;
}

- (BOOL)importConstraints:(id)data
{
   /*
 NSDictionary * constraints = data[@"constraints"];
    if (constraints)
    {
        __block BOOL isInvalid = NO;
        NSDictionary * elementUUIDIndex = constraints[@"identifiers"];
        NSDictionary * elementIndex =
        [elementUUIDIndex dictionaryByMappingObjectsToBlock:
         ^id(NSString * label, NSString * uuid)
         {
             RemoteElement * element = ([uuid isEqualToString:self.uuid]
                                        ? self
                                        :(RemoteElement *)
                                        memberOfCollectionWithUUID(self.subelements, uuid));
             if (!element) isInvalid = YES;
             return (element ? element.identifier: NullObject);
         }];

        NSArray * formatComponents = constraints[@"format"];


        if (isInvalid) _needsImportConstraints = !_needsImportConstraints;

        else
        {
            NSString * format = [[formatComponents componentsJoinedByString:@"\n"]
                                 stringByReplacingOccurrencesWithDictionary:elementIndex];
            if (StringIsNotEmpty(format)) [self.constraintManager setConstraintsFromString:format];

        }
    }
*/

    return YES;
}

- (BOOL)importBackgroundColor:(id)data
{
    if (isString(data))
    {
        UIColor * backgroundColor = colorFromImportValue(data);
        self.backgroundColor = backgroundColor;
        return YES;
    }

    else return NO;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Exporting
////////////////////////////////////////////////////////////////////////////////


- (NSDictionary *)JSONDictionary
{

    id(^defaultForKey)(NSString *) = ^(NSString * key)
    {
        static const NSDictionary * index;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken,
                      ^{
                          NSDictionary * attributes           = [[self entity] attributesByName];
                          UIColor      * backgroundColor      = [attributes[@"backgroundColor"]
                                                                 defaultValue];
                          NSNumber     * state                = [attributes[@"state"] defaultValue];
                          NSNumber     * style                = [attributes[@"style"] defaultValue];
                          NSNumber     * options              = [attributes[@"options"] defaultValue];
                          NSNumber     * subtype              = [attributes[@"subtype"] defaultValue];
                          NSNumber     * themeFlags           = [attributes[@"themeFlags"] defaultValue];
                          NSNumber     * role                 = [attributes[@"role"] defaultValue];
                          NSNumber     * tag                  = [attributes[@"tag"] defaultValue];
                          NSNumber     * backgroundImageAlpha = [attributes[@"backgroundImageAlpha"]
                                                                 defaultValue];
                          NSNumber     * shape                = [attributes[@"shape"] defaultValue];

                          index = @{@"state"                : state,
                                    @"style"                : style,
                                    @"options"              : options,
                                    @"subtype"              : subtype,
                                    @"themeFlags"           : themeFlags,
                                    @"role"                 : role,
                                    @"tag"                  : tag,
                                    @"backgroundColor"      : backgroundColor,
                                    @"backgroundImageAlpha" : backgroundImageAlpha,
                                    @"shape"                : shape};
                      });
        
        id defaultValue = index[key];
        return defaultValue;
    };

    MSDictionary * dictionary = [[super JSONDictionary] mutableCopy];

    dictionary[@"name"] = CollectionSafeValue(self.name);
    dictionary[@"elementType"] = (typeJSONValueForRemoteElement(self) ?: @(self.elementType));

    dictionary[@"key"]  = CollectionSafeValue(self.primitiveKey);

    if (![@(self.tag) isEqual:defaultForKey(@"tag")])
        dictionary[@"tag"] = @(self.tag);

    if (![@(self.role) isEqualToNumber:defaultForKey(@"role")])
        dictionary[@"role"] = (roleJSONValueForRemoteElement(self) ?: @(self.role));

    if (![@(self.subtype) isEqual:defaultForKey(@"subtype")])
        dictionary[@"subtype"] = (subtypeJSONValueForRemoteElement(self) ?: @(self.subtype));

    if (![@(self.options) isEqual:defaultForKey(@"options")])
        dictionary[@"options"] = (optionsJSONValueForRemoteElement(self) ?: @(self.options));

    if (![@(self.state) isEqual:defaultForKey(@"state")])
        dictionary[@"state"] = (stateJSONValueForRemoteElement(self) ?: @(self.state));

    if (![@(self.shape) isEqual:defaultForKey(@"shape")])
        dictionary[@"shape"] = (shapeJSONValueForRemoteElement(self) ?: @(self.shape));

    if (![@(self.style) isEqual:defaultForKey(@"style")])
        dictionary[@"style"] = (styleJSONValueForRemoteElement(self) ?: @(self.style));

    if (![@(self.themeFlags) isEqual:defaultForKey(@"themeFlags")])
        dictionary[@"themeFlags"] = (themeFlagsJSONValueForRemoteElement(self)
                                     ?: @(self.themeFlags));

    if ([self.constraints count])
    {
        NSArray * constraintDictionaries = [[self valueForKeyPath:@"constraints.JSONDictionary"] allObjects];
        NSArray * firstItemUUIDs = [constraintDictionaries valueForKeyPath:@"@distinctUnionOfObjects.firstItem"];
        NSArray * secondItemUUIDs = [constraintDictionaries valueForKeyPath:@"@distinctUnionOfObjects.secondItem"];
        NSSet * uuids = [NSSet setWithArrays:@[firstItemUUIDs, secondItemUUIDs]];
        uuids = [uuids setByRemovingObject:NullObject];
        NSMutableDictionary * uuidIndex = [@{} mutableCopy];

        for (NSString * uuid in uuids)
        {
            RemoteElement * element = nil;
            if ([uuid isEqualToString:self.uuid])
                element = self;
            else
                element = (RemoteElement *)memberOfCollectionWithUUID(self.subelements, uuid);
            assert(element);
            assert(element.name);
            uuidIndex[[element.name camelCaseString]] = uuid;
        }
        NSSet * constraintDescriptions = [self valueForKeyPath:@"constraints.description"];
        NSDictionary * constraintsDictionary = @{@"index" : uuidIndex,
                                                 @"format": [constraintDescriptions allObjects]};
        dictionary[@"constraints"] = constraintsDictionary;
    }

    if (![self.backgroundColor isEqual:defaultForKey(@"backgroundColor")])
        dictionary[@"backgroundColor"] =
            CollectionSafeValue(normalizedColorJSONValueForColor(self.backgroundColor));

    if (![@(self.backgroundImageAlpha) isEqual:defaultForKey(@"backgroundImageAlpha")])
        dictionary[@"backgroundImageAlpha"]  = @(self.backgroundImageAlpha);

    if ([self.subelements count])
        dictionary[@"subelements"] = [self valueForKeyPath:@"subelements.JSONDictionary"];

    dictionary[@"theme"] = CollectionSafeValue(self.theme.name);

    [dictionary removeKeysWithNullObjectValues];

    return dictionary;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors for custom typedef properties
////////////////////////////////////////////////////////////////////////////////

- (void)setElementType:(REType)elementType
{
    [self willChangeValueForKey:@"elementType"];
    self.primitiveElementType = @(elementType);
    [self didChangeValueForKey:@"elementType"];
}

- (REType)elementType
{
    [self willAccessValueForKey:@"elementType"];
    NSNumber * elementType = self.primitiveElementType;
    [self didAccessValueForKey:@"elementType"];
    return (elementType ? [elementType shortValue] : RETypeUndefined);
}

- (void)setSubtype:(RESubtype)subtype
{
    [self willChangeValueForKey:@"subtype"];
    self.primitiveSubtype = @(subtype);
    [self didChangeValueForKey:@"subtype"];
}

- (RERole)role
{
    [self willAccessValueForKey:@"role"];
    NSNumber * role = self.primitiveRole;
    [self didAccessValueForKey:@"role"];
    return [role unsignedShortValue];
}

- (void)setRole:(RERole)role
{
    [self willChangeValueForKey:@"role"];
    self.primitiveRole = @(role);
    [self didChangeValueForKey:@"role"];
}

- (RESubtype)subtype
{
    [self willAccessValueForKey:@"subtype"];
    NSNumber * subtype = self.primitiveSubtype;
    [self didAccessValueForKey:@"subtype"];
    return (subtype ? [subtype shortValue] : RESubtypeUndefined);
}

- (void)setOptions:(REOptions)options
{
    [self willChangeValueForKey:@"options"];
    self.primitiveOptions = @(options);
    [self didChangeValueForKey:@"options"];
}

- (REOptions)options
{
    [self willAccessValueForKey:@"options"];
    NSNumber * options = self.primitiveOptions;
    [self didAccessValueForKey:@"options"];
    return (options ? [options shortValue] : REOptionsUndefined);
}

- (void)setState:(REState)state
{
    [self willChangeValueForKey:@"state"];
    self.primitiveState = @(state);
    [self didChangeValueForKey:@"state"];
}

- (REState)state
{
    [self willAccessValueForKey:@"state"];
    NSNumber * state = self.primitiveState;
    [self didAccessValueForKey:@"state"];
    return (state ? [state shortValue] : REStateDefault);
}

- (void)setShape:(REShape)shape
{
    [self willChangeValueForKey:@"shape"];
    self.primitiveShape = @(shape);
    [self didChangeValueForKey:@"shape"];
}

- (REShape)shape
{
    [self willAccessValueForKey:@"shape"];
    NSNumber * shape = self.primitiveShape;
    [self didAccessValueForKey:@"shape"];
    return (shape ? [shape shortValue] : REShapeUndefined);
}

- (void)setStyle:(REStyle)style
{
    [self willChangeValueForKey:@"style"];
    self.primitiveStyle = @(style);
    [self didChangeValueForKey:@"style"];
}

- (REStyle)style
{
    [self willAccessValueForKey:@"style"];
    NSNumber * style = self.primitiveStyle;
    [self didAccessValueForKey:@"style"];
    return (style ? [style shortValue] : REStyleUndefined);
}

- (void)setThemeFlags:(REThemeOverrideFlags)themeFlags
{
    [self willChangeValueForKey:@"themeFlags"];
    self.primitiveThemeFlags = @(themeFlags);
    [self didChangeValueForKey:@"themeFlags"];
}

- (REThemeOverrideFlags)themeFlags
{
    [self willAccessValueForKey:@"themeFlags"];
    NSNumber * themeFlags = self.primitiveThemeFlags;
    [self didAccessValueForKey:@"themeFlags"];
    return (themeFlags ? [themeFlags intValue] : REThemeNone);
}

- (NSString *)name
{
    static dispatch_once_t onceToken;
    static NSDictionary const * index;
    dispatch_once(&onceToken, ^{
        index = @{ @(RETypeRemote)                    : @"Remote",
                   @(RETypeButtonGroup)               : @"ButtonGroup",
                   @(RETypeButton)                    : @"Button" };//,
//                   @(REButtonGroupTypePanel)          : @"Panel",
//                   @(REButtonGroupTypeSelectionPanel) : @"SelectionPanel",
//                   @(REButtonGroupTypeToolbar)        : @"Toolbar",
//                   @(REButtonGroupTypeDPad)           : @"DPad",
//                   @(REButtonGroupTypeNumberpad)      : @"Numberpad",
//                   @(REButtonGroupTypeTransport)      : @"Transport",
//                   @(REButtonGroupTypePickerLabel)    : @"PickerLabel",
//                   @(REButtonTypeToolbar)             : @"Toolbar",
//                   @(REButtonTypeConnectionStatus)    : @"ConnectionStatus",
//                   @(REButtonTypeBatteryStatus)       : @"BatteryStatus",
//                   @(REButtonTypePickerLabel)         : @"PickerLabel",
//                   @(REButtonTypePickerLabelTop)      : @"PickerLabelTop",
//                   @(REButtonTypePickerLabelBottom)   : @"PickerLabelBottom",
//                   @(REButtonTypePanel)               : @"Panel",
//                   @(REButtonTypeTuck)                : @"Tuck",
//                   @(REButtonTypeSelectionPanel)      : @"SelectionPanel",
//                   @(REButtonTypeDPad)                : @"DPad",
//                   @(REButtonTypeDPadUp)              : @"Up",
//                   @(REButtonTypeDPadDown)            : @"Down",
//                   @(REButtonTypeDPadLeft)            : @"Left",
//                   @(REButtonTypeDPadRight)           : @"Right",
//                   @(REButtonTypeDPadCenter)          : @"Center",
//                   @(REButtonTypeNumberpad)           : @"Numberpad",
//                   @(REButtonTypeNumberpad1)          : @"1",
//                   @(REButtonTypeNumberpad2)          : @"2",
//                   @(REButtonTypeNumberpad3)          : @"3",
//                   @(REButtonTypeNumberpad4)          : @"4",
//                   @(REButtonTypeNumberpad5)          : @"5",
//                   @(REButtonTypeNumberpad6)          : @"6",
//                   @(REButtonTypeNumberpad7)          : @"7",
//                   @(REButtonTypeNumberpad8)          : @"8",
//                   @(REButtonTypeNumberpad9)          : @"9",
//                   @(REButtonTypeNumberpad0)          : @"0",
//                   @(REButtonTypeNumberpadAux1)       : @"Aux1",
//                   @(REButtonTypeNumberpadAux2)       : @"Aux2",
//                   @(REButtonTypeTransport)           : @"Transport",
//                   @(REButtonTypeTransportPlay)       : @"Play",
//                   @(REButtonTypeTransportStop)       : @"Stop",
//                   @(REButtonTypeTransportPause)      : @"Pause",
//                   @(REButtonTypeTransportSkip)       : @"Skip",
//                   @(REButtonTypeTransportReplay)     : @"Replay",
//                   @(REButtonTypeTransportFF)         : @"FF",
//                   @(REButtonTypeTransportRewind)     : @"Rewind",
//                   @(REButtonTypeTransportRecord)     : @"Record" };
    });

    [self willAccessValueForKey:@"name"];
    NSString * name = self.primitiveName;
    [self didAccessValueForKey:@"name"];
    if (!name)
    {
        name = (index[@(self.elementType)] ?: @"unnamed");
    }
    return name;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Derived Properties
////////////////////////////////////////////////////////////////////////////////

- (RemoteElement *)objectForKeyedSubscript:(NSString *)key
{
    if (!self.subelements.count) return nil;

    return [self.subelements objectPassingTest:
            ^BOOL (RemoteElement * obj, NSUInteger idx)
            {
                return REStringIdentifiesRemoteElement(key, obj);
            }];
}

- (void)setObject:(RemoteElement *)object atIndexedSubscript:(NSUInteger)idx
{
    NSUInteger count = self.subelements.count;

    if (!object)
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"object cannot be nil"
                                     userInfo:nil];

    else if (idx > count)
        @throw [NSException exceptionWithName:NSRangeException
                                       reason:@"index out of range"
                                     userInfo:nil];

    else if (idx == count)
        [self addSubelementsObject:object];

    else
        [self insertObject:object inSubelementsAtIndex:idx];

}

- (RemoteElement *)objectAtIndexedSubscript:(NSUInteger)subscript
{
    return (subscript < self.subelements.count ? self.subelements[subscript] : nil);
}

@end

@implementation RemoteElement (Debugging)

- (NSString *)shortDescription { return self.name; }

- (NSString *)recursiveDeepDescription
{
    NSMutableString * description = [[self deepDescription] mutableCopy];
    [description appendString:@"\n"];
    for (RemoteElement * subelement in self.subelements)
        [description appendFormat:@"\n%@\n", [subelement recursiveDeepDescription]];
    return description;
}

- (MSDictionary *)deepDescriptionDictionary
{
    RemoteElement * element = [self faultedObject];
    assert(element);

    NSString * typeString          = NSStringFromREType(element.elementType);
    NSString * subtypeString       = NSStringFromRESubtype(element.subtype);
    NSString * keyString           = element.key;
    NSString * nameString          = element.name;
    NSString * tagString           = [@(element.tag)stringValue];
    NSString * controllerString    = unnamedModelObjectDescription(element.controller);
    NSString * configurationString = $(@"%@-configurations:'%@'",
                                       unnamedModelObjectDescription(element.configurationDelegate),
                                       [element.configurationDelegate.modeKeys
                                            componentsJoinedByString:@", "]);
    NSString * parentString        = namedModelObjectDescription(element.parentElement);
    NSString * subelementsString   = ([[element.subelements setByMappingToBlock:
                                       ^NSString *(RemoteElement * subelement)
                                       {
                                           return namedModelObjectDescription(subelement);
                                       }] componentsJoinedByString:@"\n"] ?: @"nil");
    NSString * layoutString        = namedModelObjectDescription(element.layoutConfiguration);
    NSString * proportionString    = BOOLString(element.proportionLock);
    NSString * constraintsString   = [[element constraintsDescription]
                                                      stringByTrimmingLeadingWhitespace];
    NSString * themeString         = namedModelObjectDescription(element.theme);
    NSString * shapeString         = NSStringFromREShape(element.shape);
    NSString * styleString         = NSStringFromREStyle(element.style);
    NSString * themeFlagString     = NSStringFromREThemeFlags(element.themeFlags);
    NSString * optionsString       = NSStringFromREOptions(element.options, element.elementType);
    NSString * stateString         = NSStringFromREState(element.state);
    NSString * backgroundString    = namedModelObjectDescription(element.backgroundImage);
    NSString * bgAlphaString       = [@(element.backgroundImageAlpha) stringValue];
    NSString * bgColorString       = NSStringFromUIColor(element.backgroundColor);

    MSDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];
    dd[@"elementType"]           = (typeString ?: @"nil");
    dd[@"subtype"]               = (subtypeString ?: @"nil");
    dd[@"key"]                   = (keyString ?: @"nil");
    dd[@"name"]                  = (nameString ?: @"nil");
    dd[@"tag"]                   = (tagString ?: @"nil");
    dd[@"controller"]            = (controllerString ?: @"nil");
    dd[@"configurationDelegate"] = (configurationString ?: @"nil");
    dd[@"parentElement"]         = (parentString ?: @"nil");
    dd[@"subelements"]           = (subelementsString ?: @"nil");
    dd[@"layoutConfiguration"]   = (layoutString ?: @"nil");
    dd[@"proportionLock"]        = (proportionString ?: @"nil");
    dd[@"constraints"]           = (constraintsString ?: @"nil");
    dd[@"theme"]                 = (themeString ?: @"nil");
    dd[@"shape"]                 = (shapeString ?: @"nil");
    dd[@"style"]                 = (styleString ?: @"nil");
    dd[@"themeFlags"]            = (themeFlagString ?: @"nil");
    dd[@"options"]               = (optionsString ?: @"nil");
    dd[@"state"]                 = (stateString ?: @"nil");
    dd[@"backgroundImage"]       = (backgroundString ?: @"nil");
    dd[@"backgroundImageAlpha"]  = (bgAlphaString ?: @"nil");
    dd[@"backgroundColor"]       = (bgColorString ?: @"nil");

    return (MSDictionary *)dd;
}

- (NSString *)constraintsDescription
{
    NSMutableString * description = [@"" mutableCopy];

    NSSet * constraints                 = self.constraints;
    NSSet * subelementConstraints       = self.subelementConstraints;
    NSSet * intrinsicConstraints        = self.intrinsicConstraints;
    NSSet * childToParentConstraints    = self.dependentChildConstraints;
    NSSet * childToChildConstraints     = [subelementConstraints
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
             NSStringFromREType(self.elementType),
             NSStringFromRESubtype(self.subtype),
             NSStringFromREOptions(self.options, self.elementType),
             NSStringFromREState(self.state),
             NSStringFromREShape(self.shape),
             NSStringFromREStyle(self.style));
}

- (NSString *)dumpElementHierarchy
{
    NSMutableString * outstring = [[NSMutableString alloc] init];
    __block void (^ dumpElement)(RemoteElement *, int) = nil;
    __block void (__weak ^ weakDumpElement)(RemoteElement *, int) = dumpElement;
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

NSDictionary *
_NSDictionaryOfVariableBindingsToIdentifiers(NSString * commaSeparatedKeysString, id firstValue, ...)
{
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
    return (   StringIsNotEmpty(identifier)
            && (   [identifier isEqualToString:re.uuid]
                || [identifier isEqualToString:re.key]
                || [identifier isEqualToString:re.identifier]));
}

Class classForREType(REType type)
{
    switch (type)
    {
        case RETypeRemote:                    return [Remote class];

//        case REButtonGroupTypeToolbar:
//        case REButtonGroupTypeSelectionPanel:
//        case REButtonGroupTypePanel:
        case RETypeButtonGroup:               return [ButtonGroup class];

//        case REButtonGroupTypePickerLabel:    return [PickerLabelButtonGroup class];

//        case REButtonTypeBatteryStatus:
//        case REButtonTypeConnectionStatus:
        case RETypeButton:                    return [Button class];

        default:                              return [RemoteElement class];
    }
}

/*
Class baseClassForREType(REType type)
{
    return classForREType((type & RETypeBaseMask));
}
*/


