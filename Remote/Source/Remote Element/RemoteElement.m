//
// RemoteElement.m
// Remote
//
// Created by Jason Cardwell on 10/3/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteElement_Private.h"

static const int            ddLogLevel = LOG_LEVEL_DEBUG;
static const int            msLogContext = REMOTE_F_C;

static const NSDictionary * kEntityNameForType;
static const NSSet        * kLayoutConfigurationSelectors;
static const NSSet        * kLayoutConfigurationKeys;
static const NSSet        * kConfigurationDelegateKeys;
static const NSSet        * kConfigurationDelegateSelectors;
static const NSSet        * kConstraintManagerSelectors;

@implementation RemoteElement {
    NSString * __identifier;
}

@synthesize constraintManager = _constraintManager;

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

+ (instancetype)remoteElementInContext:(NSManagedObjectContext *)context
{
    return [self MR_createInContext:context];
}

+ (instancetype)remoteElementInContext:(NSManagedObjectContext *)context
                        withAttributes:(NSDictionary *)attributes
{
    __block RemoteElement * element = nil;
    [context performBlockAndWait:
     ^{
         element = [self remoteElementInContext:context];
         [element setValuesForKeysWithDictionary:attributes];
     }];

    return element;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    NSManagedObjectContext * context = self.managedObjectContext;
    [context performBlockAndWait:
     ^{
         self.layoutConfiguration   = [RELayoutConfiguration layoutConfigurationForElement:self];
         self.configurationDelegate = [REConfigurationDelegate delegateForRemoteElement:self];
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
        REConfigurationDelegate * delegate = nil;
        if ([parentElement isKindOfClass:[RERemote class]])
            delegate = parentElement.configurationDelegate;
        else if ([parentElement isKindOfClass:[REButtonGroup class]])
            delegate = parentElement.parentElement.configurationDelegate;

        self.configurationDelegate.delegate = delegate;
        [self.subelements setValue:delegate forKeyPath:@"configurationDelegate.delegate"];
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
    if (!_constraintManager)
        self.constraintManager = [REConstraintManager constraintManagerForRemoteElement:self];
    return _constraintManager;
}

- (void)setDisplayName:(NSString *)displayName
{
    [self willChangeValueForKey:@"displayName"];
    self.primitiveDisplayName = [displayName copy];
    [self didChangeValueForKey:@"displayName"];

    if (StringIsEmpty(self.key)) self.key = [displayName camelCaseString];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Derived Properties
////////////////////////////////////////////////////////////////////////////////

- (NSString *)camelCaseDisplayName { return [self.displayName camelCaseString]; }

- (RemoteElement *)objectForKeyedSubscript:(NSString *)key
{
    if (!self.subelements.count) return nil;

    return [self.subelements
            objectPassingTest:^BOOL (RemoteElement * obj, NSUInteger idx) {
                return (   [obj.uuid isEqualToString:key]
                        || [obj.key isEqualToString:key]);
            }];
}

- (RemoteElement *)objectAtIndexedSubscript:(NSUInteger)subscript
{
    return (subscript < self.subelements.count ? self.subelements[subscript] : nil);
}

@end

@implementation RemoteElement (Debugging)

- (NSString *)shortDescription { return self.displayName; }

- (NSString *)constraintsDescription
{
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
              16, _primitiveFlags, self.type, self.subtype, self.options, self.state, _primitiveAppearance,
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


