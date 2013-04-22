//
// RemoteElement.m
// Remote
//
// Created by Jason Cardwell on 10/3/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteElement_Private.h"

static const int            ddLogLevel  = LOG_LEVEL_DEBUG;
static const int            msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);

static const NSDictionary * kEntityNameForType;
static const NSSet        * kLayoutConfigurationSelectors;
static const NSSet        * kLayoutConfigurationKeys;
static const NSSet        * kConfigurationDelegateKeys;
static const NSSet        * kConfigurationDelegateSelectors;
static const NSSet        * kConstraintManagerSelectors;

@implementation RemoteElement {
    NSString * __identifier;
}

@synthesize constraintManager = __constraintManager;

@dynamic constraints;
@dynamic displayName;
@dynamic key;
@dynamic tag;
@dynamic backgroundColor;
@dynamic subelements;
@dynamic backgroundImage;
@dynamic backgroundImageAlpha;
@dynamic firstItemConstraints;
@dynamic secondItemConstraints;
@dynamic layoutConfiguration;
@dynamic appliedTheme;
@dynamic configurationDelegate;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initializers
////////////////////////////////////////////////////////////////////////////////

+ (void)initialize
{
    if (self == [RemoteElement class]) {
        kEntityNameForType = @{@(RETypeRemote)                       : @"RERemote",
                               @(RETypeButtonGroup)                  : @"REButtonGroup",
                               @(REButtonGroupTypePickerLabel)       : @"REPickerLabelButtonGroup",
                               @(REButtonGroupTypeToolbar)           : @"REButtonGroup",
                               @(REButtonGroupTypeTransport)         : @"REButtonGroup",
                               @(REButtonGroupTypeDPad)              : @"REButtonGroup",
                               @(REButtonGroupTypeSelectionPanel)    : @"REButtonGroup",
                               @(REButtonGroupTypeCommandSetManager) : @"REButtonGroup",
                               @(REButtonGroupTypeRoundedPanel)      : @"REButtonGroup",
                               @(RETypeButton)                       : @"REButton",
                               @(REButtonTypeNumberPad)              : @"REButton",
                               @(REButtonTypeConnectionStatus)       : @"REButton",
                               @(REButtonTypeBatteryStatus)          : @"REButton",
                               @(REButtonTypeCommandManager)         : @"REButton"};

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

        kConfigurationDelegateSelectors = [@[NSValueWithPointer(@selector(currentConfiguration)),
                                             NSValueWithPointer(@selector(addConfiguration:)),
                                             NSValueWithPointer(@selector(hasConfiguration:))] set];
        kConfigurationDelegateKeys = [@[@"currentConfiguration"] set];
    }
}

+ (instancetype)remoteElement
{
    return [self remoteElementInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (instancetype)remoteElementWithAttributes:(NSDictionary *)attributes
{
    RemoteElement * element = [self remoteElement];
    [element setValuesForKeysWithDictionary:attributes];
    return element;
}

+ (instancetype)remoteElementInContext:(NSManagedObjectContext *)context
{
    return [self MR_createInContext:context];
}

+ (instancetype)remoteElementInContext:(NSManagedObjectContext *)context
                        withAttributes:(NSDictionary *)attributes
{
    RemoteElement * element = [self remoteElementInContext:context];
    [element setValuesForKeysWithDictionary:attributes];
    return element;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    [self.managedObjectContext performBlockAndWait:
     ^{
         self.layoutConfiguration = [RELayoutConfiguration layoutConfigurationForElement:self];
     }];
}

- (NSString *)identifier
{
    if (!__identifier)
        __identifier = $(@"_%@", [self.uuid stringByRemovingCharacter:'-']);
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

- (REConstraintManager *)constraintManager
{
    if (!__constraintManager)
        self.constraintManager = [REConstraintManager constraintManagerForRemoteElement:self];
    return __constraintManager;
}

- (NSString *)key
{
    [self willAccessValueForKey:@"key"];
    NSString * key = self.primitiveKey;
    [self didAccessValueForKey:@"key"];
    return (StringIsEmpty(key) ? [self.displayName camelCaseString] : key);
}

- (void)applyTheme:(RETheme *)theme { [theme applyThemeToElement:self]; }

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

- (RemoteElement *)objectAtIndexedSubscript:(NSUInteger)subscript
{
    return (subscript < self.subelements.count ? self.subelements[subscript] : nil);
}

@end

@implementation RemoteElement (Debugging)

- (NSString *)shortDescription { return self.displayName; }

- (MSDictionary *)deepDescriptionDictionary
{
    RemoteElement * element = [self faultedObject];
    assert(element);

    MSMutableDictionary * descriptionDictionary = [[super deepDescriptionDictionary] mutableCopy];
    descriptionDictionary[@"type"]        = (NSStringFromREType(element.type)     ? : @"nil");
    descriptionDictionary[@"baseType"]    = (NSStringFromREType(element.baseType) ? : @"nil");
    descriptionDictionary[@"key"]         = $(@"'%@'", element.key);
    descriptionDictionary[@"displayName"] = $(@"'%@'", element.displayName);
    descriptionDictionary[@"tag"]         = @(element.tag);

    descriptionDictionary[@"controller"]            = (element.controller
                                                       ? $(@"%@(%p)",
                                                           element.controller.uuid,
                                                           element.controller)
                                                       : @"nil");
    descriptionDictionary[@"configurationDelegate"] = (element.configurationDelegate
                                                       ? $(@"%@(%p)-configurations: %@",
                                                           element.configurationDelegate.uuid,
                                                           element.configurationDelegate,
                                                           [element.configurationDelegate.configurationKeys
                                                            componentsJoinedByString:@", "])
                                                       : @"nil");
    descriptionDictionary[@"parentElement"]         = (element.parentElement
                                                       ? $(@"%@:%@",
                                                           element.parentElement.key,
                                                           element.parentElement.uuid)
                                                       : @"nil");
    descriptionDictionary[@"subelements"]           = (!element.subelements.count
                                                       ? @"nil"
                                                       : [[element.subelements setByMappingToBlock:
                                                           ^NSString *(RemoteElement * subelement)
                                                           {
                                                               return $(@"%@:%@(%p)",
                                                                        subelement.key,
                                                                        subelement.uuid,
                                                                        subelement);
                                                           }] componentsJoinedByString:
                                                              [@"\n" stringByRightPaddingToLength:24
                                                                                    withCharacter:' ']]);

    descriptionDictionary[@"layoutConfiguration"]  = (element.layoutConfiguration
                                                      ? $(@"'%@':%@(%p)",
                                                          [element.layoutConfiguration layoutDescription],
                                                          element.layoutConfiguration.uuid,
                                                          element.layoutConfiguration)
                                                      : @"nil");
    descriptionDictionary[@"proportionLock"]       = BOOLString(element.proportionLock);
    descriptionDictionary[@"constraints"]          = [[element constraintsDescription]
                                                      stringByTrimmingLeadingWhitespace];

    descriptionDictionary[@"appliedTheme"]         = (element.appliedTheme
                                                      ? element.appliedTheme.name
                                                      : @"nil");
    descriptionDictionary[@"shape"]                = (NSStringFromREShape(element.shape) ? : @"nil");
    descriptionDictionary[@"style"]                = (NSStringFromREStyle(element.style) ? : @"nil");
    descriptionDictionary[@"backgroundImage"]      = (element.backgroundImage
                                                      ? element.backgroundImage.fileName
                                                      : @"nil");
    descriptionDictionary[@"backgroundImageAlpha"] = @(element.backgroundImageAlpha);
    descriptionDictionary[@"backgroundColor"]      = (element.backgroundColor
                                                      ? NSStringFromUIColor(element.backgroundColor)
                                                      : @"nil");

    return descriptionDictionary;
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
    return $(@"flags:%10$-15s0x%2$.*1$llX\n"
              "type:%10$-16s0x%3$.*1$llX\n"
              "subtype:%10$-13s0x%4$.*1$llX\n"
              "options:%10$-13s0x%5$.*1$llX\n"
              "state:%10$-15s0x%6$.*1$llX\n"
              "appearance:%10$-10s0x%7$.*1$llX\n"
              "shape:%10$-15s0x%8$.*1$llX\n"
              "style:%10$-15s0x%9$.*1$llX\n",
              16, _primitiveFlags, self.type, self.subtype, self.options, self.state, _primitiveAppearance,
              self.shape, self.style, " ");
}

- (NSString *)dumpElementHierarchy
{
    NSMutableString * outstring = [[NSMutableString alloc] init];
    __block void (__weak ^ dumpElement)(RemoteElement *, int) =
        ^(RemoteElement * element, int indent) {
        NSString * dashes = [NSString stringWithCharacter:'-' count:indent * 3];

        NSString * spacer = [NSString stringWithCharacter:' ' count:indent * 3 + 4];

        [outstring appendFormat:
         @"%@[%d] class:%@\n"
         "%@displayName:%@\n"
         "%@key:%@\n"
         "%@identifier:%@\n\n",
         dashes,
         indent,
         ClassString([element class]),
         spacer,
         element.displayName,
         spacer,
         element.key,
         spacer,
         element.uuid];

        for (RemoteElement * subelement in element.subelements)
            dumpElement(subelement, indent + 1);
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

NSString * EditingModeString(REEditingMode mode) {
    NSMutableString * modeString = [NSMutableString string];

    if (mode & RERemoteEditingMode) {
        [modeString appendString:@"RERemoteEditingMode"];
        if (mode & REButtonGroupEditingMode) {
            [modeString appendString:@"|REButtonGroupEditingMode"];
            if (mode & REButtonEditingMode) [modeString appendString:@"|REButtonEditingMode"];
        }
    }

    else
        [modeString appendString:@"REEditingModeNotEditing"];


    return modeString;
}

MSKIT_EXTERN NSString *NSStringFromREShape(REShape shape)
{
    switch (shape)
    {
        case REShapeUndefined:        return @"REShapeUndefined";
        case REShapeRoundedRectangle: return @"REShapeRoundedRectangle";
        case REShapeOval:             return @"REShapeOval";
        case REShapeRectangle:        return @"REShapeRectangle";
        case REShapeTriangle:         return @"REShapeTriangle";
        case REShapeDiamond:          return @"REShapeDiamond";
        case REShapeReserved:         return @"REShapeReserved";
        case REShapeMask:             return @"REShapeMask";
        default: return nil;
    }
}

MSKIT_EXTERN NSString *NSStringFromREStyle(REStyle style)
{
    NSMutableArray * stringArray = [@[] mutableCopy];

    if (style & REStyleApplyGloss)  [stringArray addObject:@"REStyleAppleGloss"];
    if (style & REStyleDrawBorder)  [stringArray addObject:@"REStyleDrawBorder"];
    if (style & REStyleStretchable) [stringArray addObject:@"REStyleStretchable"];
    if (!stringArray.count)         [stringArray addObject:@"REStyleUndefined"];
    return [stringArray componentsJoinedByString:@"|"];
}

MSKIT_EXTERN NSString *NSStringFromREType(REType type)
{
    switch (type)
    {
        case RETypeUndefined:   return @"RETypeUndefined";
        case RETypeRemote:      return @"RETypeRemote";
        case RETypeButtonGroup: return @"RETypeButtonGroup";
        case RETypeButton:      return @"RETypeButton";
        default: return nil;
    }
}

MSKIT_EXTERN NSString *NSStringFromREButtonGroupType(REButtonGroupType type)
{
    switch (type)
    {
        case REButtonGroupTypeDefault:           return @"REButtonGroupTypeDefault";
        case REButtonGroupTypeToolbar:           return @"REButtonGroupTypeToolbar";
        case REButtonGroupTypeTransport:         return @"REButtonGroupTypeTransport";
        case REButtonGroupTypeDPad:              return @"REButtonGroupTypeDPad";
        case REButtonGroupTypeSelectionPanel:    return @"REButtonGroupTypeSelectionPanel";
        case REButtonGroupTypeCommandSetManager: return @"REButtonGroupTypeCommandSetManager";
        case REButtonGroupTypeRoundedPanel:      return @"REButtonGroupTypeRoundedPanel";
        case REButtonGroupTypePickerLabel:       return @"REButtonGroupTypePickerLabel";
        default: return nil;
    }
}

MSKIT_EXTERN NSString *NSStringFromREButtonType(REButtonType type)
{
    switch (type)
    {
        case REButtonTypeDefault:          return @"REButtonTypeDefault";
        case REButtonTypeNumberPad:        return @"REButtonTypeNumberPad";
        case REButtonTypeConnectionStatus: return @"REButtonTypeConnectionStatus";
        case REButtonTypeBatteryStatus:    return @"REButtonTypeBatteryStatus";
        case REButtonTypeCommandManager:   return @"REButtonTypeCommandManager";
        default: return nil;
    }
}

MSKIT_EXTERN NSString *NSStringFromREButtonGroupSubtype(REButtonGroupSubtype type)
{
    switch (type)
    {
        case REButtonGroupSubtypeUndefined: return @"REButtonGroupSubtypeUndefined";
        case REButtonGroupTopPanel:         return @"REButtonGroupTopPanel";
        case REButtonGroupBottomPanel:      return @"REButtonGroupBottomPanel";
        case REButtonGroupLeftPanel:        return @"REButtonGroupLeftPanel";
        case REButtonGroupRightPanel:       return @"REButtonGroupRightPanel";
        default: return nil;
    }
}

MSKIT_EXTERN NSString *NSStringFromREButtonSubtype(REButtonSubtype type)
{
    switch (type)
    {
        case REButtonSubtypeUnspecified:      return @"REButtonSubtypeUnspecified";
        case REButtonSubtypeActivityOn:       return @"REButtonSubtypeActivityOn";
        case REButtonSubtypeReserved:         return @"REButtonSubtypeReserved";
        case REButtonSubtypeButtonGroupPiece: return @"REButtonSubtypeButtonGroupPiece";
        default: return nil;
    }
}


