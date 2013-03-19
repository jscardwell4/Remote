//
// RemoteElement.m
// Remote
//
// Created by Jason Cardwell on 10/3/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteElement.h"
#import "RemoteElement_Private.h"
#import "RERemoteController.h"
#import "RERemote.h"
#import "REButtonGroup.h"
#import "REButton.h"

static const int            ddLogLevel = DefaultDDLogLevel;
static const int            msLogContext = COREDATA_F_C;

static const NSDictionary * kEntityNameForType;
static const NSSet        * kLayoutConfigurationSelectors;
static const NSSet        * kLayoutConfigurationKeys;

@implementation RemoteElement
@synthesize constraintManager = _constraintManager;

@dynamic constraints;
@dynamic displayName;
@dynamic uuid;
@dynamic key;
@dynamic tag;
@dynamic backgroundColor;
@dynamic subelements;
@dynamic parentElement;
@dynamic backgroundImage;
@dynamic backgroundImageAlpha;
@dynamic controller;
@dynamic firstItemConstraints;
@dynamic primitiveConstraints;
@dynamic primitiveFirstItemConstraints;
@dynamic primitiveSecondItemConstraints;
@dynamic secondItemConstraints;
@dynamic layoutConfiguration;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initializers
////////////////////////////////////////////////////////////////////////////////

+ (void)initialize {
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
                               @(REButtonTypeActivityButton)         : @"REActivityButton",
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
        kLayoutConfigurationKeys = [@[@"proportionLock",
                                      @"subelementConstraints",
                                      @"dependentConstraints",
                                      @"dependentChildConstraints",
                                      @"dependentSiblingConstraints",
                                      @"intrinsicConstraints"] set];
    }
}

+ (id)remoteElementOfType:(REType)type
                  subtype:(RESubtype)subtype
                  context:(NSManagedObjectContext *)context
{
    assert(context);

    NSString      * entityName = kEntityNameForType[@(type)];
    RemoteElement * element    = (entityName
                                  ?[NSEntityDescription insertNewObjectForEntityForName:entityName
                                                                 inManagedObjectContext:context]
                                  : nil);

    if (element) {
        element.type    = type;
        element.subtype = subtype;
    }

    return element;
}

+ (id)remoteElementOfType:(REType)type context:(NSManagedObjectContext *)context
{
    return [self remoteElementOfType:type subtype:RESubtypeUndefined context:context];
}

+ (id)remoteElementInContext:(NSManagedObjectContext *)context
              withAttributes:(NSDictionary *)attributes
{
    assert(attributes[@"type"]);

    RemoteElement * element =
        [self remoteElementOfType:[attributes[@"type"] unsignedLongLongValue]
                          context:context];

    if (element) [element setValuesForKeysWithDictionary:attributes];

    return element;
}

- (void)awakeFromInsert {
    [super awakeFromInsert];
    self.controller      = [RERemoteController remoteControllerInContext:self.managedObjectContext];
    self.backgroundColor = ClearColor;
    self.uuid      = [@"_" stringByAppendingString :[MSNonce() stringByRemovingCharacter:'-']];
    self.layoutConfiguration = [RELayoutConfiguration layoutConfigurationForElement:self];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([kLayoutConfigurationSelectors containsObject:NSValueWithPointer(aSelector)])
        return self.layoutConfiguration;
    else
        return [super forwardingTargetForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([kLayoutConfigurationSelectors containsObject:NSValueWithPointer(aSelector)])
        return YES;
    else
        return [super respondsToSelector:aSelector];
}

- (id)valueForUndefinedKey:(NSString *)key {
    if ([kLayoutConfigurationKeys containsObject:key])
        return [self.layoutConfiguration valueForKey:key];
    else
        return [super valueForUndefinedKey:key];
}

- (REConstraintManager *)constraintManager {
    if (!_constraintManager)
        self.constraintManager = [REConstraintManager constraintManagerForRemoteElement:self];
    return _constraintManager;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Model-backed Properties
////////////////////////////////////////////////////////////////////////////////


/*
- (void)dealloc {
    [NotificationCenter removeObserver:self];
}
*/

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Derived Properties
////////////////////////////////////////////////////////////////////////////////

- (NSString *)camelCaseDisplayName {
    return [self.displayName camelCaseString];
}

- (RemoteElement *)objectForKeyedSubscript:(NSString *)key
{
    if (!self.subelements.count) return nil;

    return [self.subelements
            objectPassingTest:^BOOL (RemoteElement * obj, NSUInteger idx, BOOL * stop) {
                return (   [obj.uuid isEqualToString:key]
                        || [obj.key isEqualToString:key]);
            }];
}

@end

@implementation RemoteElement (Debugging)

- (NSString *)shortDescription { return self.displayName; }

- (NSString *)constraintsDescription {
    NSMutableString * description = [$(@"configuration: %@\nproportion lock? %@",
                                       self.layoutConfiguration,
                                       BOOLString(self.layoutConfiguration.proportionLock)) mutableCopy];

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
              16, _flags, self.type, self.subtype, self.options, self.state, _appearance,
              self.shape, self.style, " ");
}

- (NSString *)dumpElementHierarchy
{
    NSMutableString * outstring = [[NSMutableString alloc] init];
    __block void (__weak ^ dumpElement)(RemoteElement *, int) =
        ^(RemoteElement * element, int indent) {
        NSString * dashes = [NSString stringFilledWithCharacter:'-' count:indent * 3];

        NSString * spacer = [NSString stringFilledWithCharacter:' ' count:indent * 3 + 4];

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
            [values addObject:element.uuid];
            element = va_arg(arglist, RemoteElement *);
        } while (element);
    }
    va_end(arglist);

    return [NSDictionary dictionaryWithObjects:values forKeys:keys];
}

