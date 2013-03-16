//
// RemoteElement.m
// iPhonto
//
// Created by Jason Cardwell on 10/3/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteElement.h"
#import "RemoteElement_Private.h"
#import "RemoteController.h"
#import "Remote.h"
#import "ButtonGroup.h"
#import "Button.h"

// static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int            ddLogLevel = DefaultDDLogLevel;
static const int            msLogContext = COREDATA_F_C;
static const NSDictionary * kEntityNameForType;

@implementation RemoteElement
@synthesize constraintManager      = _constraintManager;

@dynamic constraints;
@dynamic displayName;
@dynamic identifier;
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
        kEntityNameForType = @{
            @(RemoteElementRemoteType)          : @"Remote",
            @(RemoteElementButtonGroupType)     : @"ButtonGroup",
            @(ButtonGroupTypePickerLabel)       : @"PickerLabelButtonGroup",
            @(ButtonGroupTypeToolbar)           : @"ButtonGroup",
            @(ButtonGroupTypeTransport)         : @"ButtonGroup",
            @(ButtonGroupTypeDPad)              : @"ButtonGroup",
            @(ButtonGroupTypeSelectionPanel)    : @"ButtonGroup",
            @(ButtonGroupTypeCommandSetManager) : @"ButtonGroup",
            @(ButtonGroupTypeRoundedPanel)      : @"ButtonGroup",
            @(RemoteElementButtonType)          : @"Button",
            @(ButtonTypeActivityButton)         : @"ActivityButton",
            @(ButtonTypeNumberPad)              : @"Button",
            @(ButtonTypeConnectionStatus)       : @"Button",
            @(ButtonTypeBatteryStatus)          : @"Button",
            @(ButtonTypeCommandManager)         : @"Button"
        };
    }
}

+ (id)remoteElementOfType:(RemoteElementType)type
                  subtype:(RemoteElementSubtype)subtype
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

+ (id)remoteElementOfType:(RemoteElementType)type context:(NSManagedObjectContext *)context {
    return [self remoteElementOfType:type subtype:RemoteElementUnspecifiedSubtype context:context];
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
    /*
     * You typically use this method to initialize special default property values. This method
     * is invoked only once in the object's lifetime. If you want to set attribute values in an
     * implementation of this method, you should typically use primitive accessor methods (either
     * setPrimitiveValue:forKey: or—better—the appropriate custom primitive accessors). This
     * ensures that the new values are treated as baseline values rather than being recorded as
     * undoable changes for the properties in question.
     */
    [super awakeFromInsert];
    self.controller      = [RemoteController remoteControllerInContext:self.managedObjectContext];
    self.backgroundColor = ClearColor;
    self.identifier      = [@"_" stringByAppendingString :[MSNonce() stringByRemovingCharacter:'-']];
    self.layoutConfiguration = [RemoteElementLayoutConfiguration layoutConfigurationForElement:self];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    id   target = (self.constraintManager && [_constraintManager respondsToSelector:aSelector]
                   ? _constraintManager
                   : [super forwardingTargetForSelector:aSelector]);

    return target;
}

- (id)valueForUndefinedKey:(NSString *)key {
    return (_constraintManager
            ? [_constraintManager valueForKey:key]
            : [super valueForUndefinedKey:key]);
}

- (RemoteElementConstraintManager *)constraintManager {
    if (!_constraintManager)
        self.constraintManager = [RemoteElementConstraintManager
                                  constraintManagerForRemoteElement:self];

    return _constraintManager;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Model-backed Properties
////////////////////////////////////////////////////////////////////////////////


- (void)dealloc {
    [NotificationCenter removeObserver:self];
}

- (void)clearAlignmentOptions {
//    self.alignmentOptions = RemoteElementAlignmentOptionUndefined;
}

- (void)clearSizingOptions {
//    self.sizingOptions = RemoteElementSizingOptionWidthUnspecified | RemoteElementSizingOptionHeightUnspecified;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constraints
////////////////////////////////////////////////////////////////////////////////

+ (BOOL)automaticallyNotifiesObserversOfNeedsUpdateConstraints {
    return YES;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Derived Properties
////////////////////////////////////////////////////////////////////////////////

- (NSString *)camelCaseDisplayName {
    return [self.displayName camelCaseString];
}

- (RemoteElement *)objectForKeyedSubscript:(NSString *)key {
    if (!self.subelements.count) return nil;

    return [self.subelements
            objectPassingTest:^BOOL (RemoteElement * obj, NSUInteger idx, BOOL * stop) {
        return ([obj.identifier
                 isEqualToString:key] && (*stop = YES));
    }

    ];
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
    NSSet * childToChildConstraints     = [subelementConstraints setByRemovingObjectsFromSet:childToParentConstraints];
    NSSet * dependentSiblingConstraints = self.dependentSiblingConstraints;
    NSSet * ancestorOwnedConstraints    = [self.firstItemConstraints setByRemovingObjectsFromSet:self.constraints];

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

- (NSString *)sizingOptionsDescription {
    NSMutableString * s = [@"sizingOptions: {\n" mutableCopy];

/*
    switch (self.sizingOptions & RemoteElementSizingOptionWidthMask) {
        case RemoteElementSizingOptionWidthIntrinsic :
            [s appendString:@"\twidth: RemoteElementSizingOptionWidthIntrinsic\n"];
            break;

        case RemoteElementSizingOptionWidthParent :
            [s appendString:@"\twidth: RemoteElementSizingOptionWidthParent\n"];
            break;

        case RemoteElementSizingOptionWidthFocus :
            [s appendString:@"\twidth: RemoteElementSizingOptionWidthFocus\n"];
            break;

        default :
            break;
    }

    switch (self.sizingOptions & RemoteElementSizingOptionHeightMask) {
        case RemoteElementSizingOptionHeightIntrinsic :
            [s appendString:@"\theight: RemoteElementSizingOptionHeightIntrinsic\n"];
            break;

        case RemoteElementSizingOptionHeightParent :
            [s appendString:@"\theight: RemoteElementSizingOptionHeightParent\n"];
            break;

        case RemoteElementSizingOptionHeightFocus :
            [s appendString:@"\theight: RemoteElementSizingOptionHeightFocus\n"];
            break;

        default :
            break;
    }
*/

    [s appendFormat:@"\tproportion lock? %@\n", BOOLString(self.layoutConfiguration.proportionLock)];

    [s appendString:@"}"];

    return s;
}

- (NSString *)alignmentOptionsDescription {
    NSMutableString * returnString = [@"alignmentOptions:{\n" mutableCopy];

   /*
 if ((_appearance & RemoteElementAlignmentOptionMaskParent)) {
        if ((_appearance & RemoteElementAlignmentOptionCenterXParent))
          [returnString appendString:@"\tcenterX: RemoteElementAlignmentOptionCenterXParent\n"];

        if ((_appearance & RemoteElementAlignmentOptionCenterYParent))
          [returnString appendString:@"\tcenterY: RemoteElementAlignmentOptionCenterYParent\n"];

        if ((_appearance & RemoteElementAlignmentOptionTopParent))
          [returnString appendString:@"\ttop: RemoteElementAlignmentOptionTopParent\n"];

        if ((_appearance & RemoteElementAlignmentOptionBottomParent))
          [returnString appendString:@"\tbottom: RemoteElementAlignmentOptionBottomParent\n"];

        if ((_appearance & RemoteElementAlignmentOptionLeftParent))
          [returnString appendString:@"\tleft: RemoteElementAlignmentOptionLeftParent\n"];

        if ((_appearance & RemoteElementAlignmentOptionRightParent))
          [returnString appendString:@"\tright: RemoteElementAlignmentOptionRightParent\n"];

        if ((_appearance & RemoteElementAlignmentOptionBaselineParent))
          [returnString appendString:@"\tbaseline: RemoteElementAlignmentOptionBaselineParent\n"];
    }

    if ((_appearance & RemoteElementAlignmentOptionMaskFocus)) {
        if ((_appearance & RemoteElementAlignmentOptionCenterXFocus))
          [returnString appendString:@"\tcenterX: RemoteElementAlignmentOptionCenterXFocus\n"];

        if ((_appearance & RemoteElementAlignmentOptionCenterYFocus))
          [returnString appendString:@"\tcenterY: RemoteElementAlignmentOptionCenterYFocus\n"];

        if ((_appearance & RemoteElementAlignmentOptionTopFocus))
          [returnString appendString:@"\ttop: RemoteElementAlignmentOptionTopFocus\n"];

        if ((_appearance & RemoteElementAlignmentOptionBottomFocus))
          [returnString appendString:@"\tbottom: RemoteElementAlignmentOptionBottomFocus\n"];

        if ((_appearance & RemoteElementAlignmentOptionLeftFocus))
          [returnString appendString:@"\tleft: RemoteElementAlignmentOptionLeftFocus\n"];

        if ((_appearance & RemoteElementAlignmentOptionRightFocus))
          [returnString appendString:@"\tright: RemoteElementAlignmentOptionRightFocus\n"];

        if ((_appearance & RemoteElementAlignmentOptionBaselineFocus))
          [returnString appendString:@"\tbaseline: RemoteElementAlignmentOptionBaselineFocus\n"];
    }

    [returnString appendString:@"}"];
*/


    return returnString;
}

- (NSString *)flagsAndAppearanceDescription {
    return $(@"flags:%10$-15s0x%2$.*1$llX\n"
              "type:%10$-16s0x%3$.*1$llX\n"
              "subtype:%10$-13s0x%4$.*1$llX\n"
              "options:%10$-13s0x%5$.*1$llX\n"
              "state:%10$-15s0x%6$.*1$llX\n"
              "appearance:%10$-10s0x%7$.*1$llX\n"
//              "alignment:%12$-11s0x%8$.*1$llX\n"
//              "sizing:%12$-14s0x%9$.*1$llX\n"
              "shape:%10$-15s0x%8$.*1$llX\n"
              "style:%10$-15s0x%9$.*1$llX\n",
              16, _flags, self.type, self.subtype, self.options, self.state, _appearance,
              /*self.alignmentOptions, self.sizingOptions, */self.shape, self.style, " ");
}

- (NSString *)dumpElementHierarchy {
    NSMutableString * outstring = [[NSMutableString alloc] init];
    __block void (__weak ^ dumpElement)(RemoteElement *, int) =
        ^(RemoteElement * element, int indent) {
        NSString * dashes = [NSString stringFilledWithCharacter:'-' count:indent * 3];

        NSString * spacer = [NSString stringFilledWithCharacter:' ' count:indent * 3 + 4];

        [outstring appendFormat:
         @"%@[%d] class:%@\n"
         "%@displayName:%@\n"
         "%@key:%@\n"
         "%@identifier:%@\n"
         "%@\n%@\n\n",
         dashes,
         indent,
         ClassString([element class]),
         spacer,
         element.displayName,
         spacer,
         element.key,
         spacer,
         element.identifier,
         [element alignmentOptionsDescription],
         [element sizingOptionsDescription]];

        for (RemoteElement * subelement in element.subelements) {
            dumpElement(subelement, indent + 1);
        }
    };

            dumpElement(self, 0);

    return outstring;
}

@end

NSDictionary * _NSDictionaryOfVariableBindingsToIdentifiers(NSString * commaSeparatedKeysString,
                                                            id firstValue, ...) {
    // TODO: Handle replacement order by determining if a key string is matched in another key
    // string
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

