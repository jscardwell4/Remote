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
#import "RemoteElementLayoutConstraint.h"

// static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int            ddLogLevel = DefaultDDLogLevel;
static const NSDictionary * kEntityNameForType;

@implementation RemoteElement
@synthesize constraintManager      = _constraintManager;
@synthesize needsUpdateConstraints = _needsUpdateConstraints;

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

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initializers
////////////////////////////////////////////////////////////////////////////////

+ (void)initialize {
    if (self == [RemoteElement class]) {
        kEntityNameForType = @{
            @(RemoteElementRemoteType) : @"Remote",
            @(RemoteElementButtonGroupType) : @"ButtonGroup",
            @(ButtonGroupTypePickerLabel) : @"PickerLabelButtonGroup",
            @(ButtonGroupTypeToolbar) : @"ButtonGroup",
            @(ButtonGroupTypeTransport) : @"ButtonGroup",
            @(ButtonGroupTypeDPad) : @"ButtonGroup",
            @(ButtonGroupTypeSelectionPanel) : @"ButtonGroup",
            @(ButtonGroupTypeCommandSetManager) : @"ButtonGroup",
            @(ButtonGroupTypeRoundedPanel) : @"ButtonGroup",
            @(RemoteElementButtonType) : @"Button",
            @(ButtonTypeActivityButton) : @"ActivityButton",
            @(ButtonTypeNumberPad) : @"Button",
            @(ButtonTypeConnectionStatus) : @"Button",
            @(ButtonTypeBatteryStatus) : @"Button",
            @(ButtonTypeCommandManager) : @"Button"
        };
    }
}

+ (id)remoteElementOfType:(RemoteElementType)type
                  subtype:(RemoteElementSubtype)subtype
                  context:(NSManagedObjectContext *)context {
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
              withAttributes:(NSDictionary *)attributes {
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
    [self registerForNotifications];
}

- (void)willTurnIntoFault {
    // This method is the companion of the didTurnIntoFault method. You can use it to (re)set state
    // which
    // requires access to property values (for example, observers across keypaths). The default
    // implementation
    // does nothing.
    [super willTurnIntoFault];
}

- (void)didTurnIntoFault {
    // You use this method to clear out custom data caches—transient values declared as entity
    // properties
    // are typically already cleared out by the time this method is invoked (see, for example,
    // refreshObject:mergeChanges:).
    [super didTurnIntoFault];
}

- (void)awakeFromFetch {
    /*
     * You typically use this method to compute derived values or to recreate transient
     * relationships from the receiver’s persistent properties. The managed object context’s
     * change processing is explicitly disabled around this method so that you can use public
     * setters to establish transient values and other caches without dirtying the object or
     * its context. Because of this, however, you should not modify relationships in this
     * method as the inverse will not be set.
     *
     */
    [super awakeFromFetch];
    [self registerForNotifications];
    [self.constraintManager processConstraints];
}

- (BOOL)validateForInsert:(NSError **)error {
    // Subclasses should invoke super’s implementation before performing their own validation, and
    // should
    // combine any error returned by super’s implementation with their own (see “Model Object
    // Validation”).

    if (![super validateForInsert:error]) {
        NSArray * errors = (*error).userInfo[NSDetailedErrorsKey];

        MSLogError(COREDATA_F_C, @"%@ validation failed%@", ClassTagSelectorString, errors ? @" with multipler errors" : @"");

        return NO;
    } else
// RemoteElementLayoutConfiguration config = self.layoutConfiguration;
// BOOL validConfiguration = isValidLayoutConfiguration(config);
// DDLogDebug(@"%@ layout configuration: %@, valid? %@",
// ClassTagSelectorStringForInstance(self.displayName),
// NSStringFromRemoteElementLayoutConfiguration(config),

// NSStringFromBOOL(validConfiguration));
        return YES;  // validConfiguration;
}

- (BOOL)validateForUpdate:(NSError **)error {
    // NSManagedObject’s implementation iterates through all of the receiver’s properties validating
    // each
    // in turn. If this results in more than one error, the userInfo dictionary in the NSError
    // returned in
    // error contains a key NSDetailedErrorsKey; the corresponding value is an array containing the
    // individual
    // validation errors. If you pass NULL as the error, validation will abort after the first
    // failure.

    if (![super validateForUpdate:error]) {
        MSLogError(COREDATA_F_C, @"%@ validation failed: %@", ClassTagSelectorString, [*error description]);

        return NO;
    } else
// RemoteElementLayoutConfiguration config = self.layoutConfiguration;
// BOOL validConfiguration = isValidLayoutConfiguration(config);
// DDLogDebug(@"%@ layout configuration: %@, valid? %@",
// ClassTagSelectorStringForInstance(self.displayName),
// NSStringFromRemoteElementLayoutConfiguration(config),

// NSStringFromBOOL(validConfiguration));
        return YES;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    id   target = (self.constraintManager && [_constraintManager respondsToSelector:aSelector]
                   ? _constraintManager
                   :[super forwardingTargetForSelector:aSelector]);

    return target;
}

- (id)valueForUndefinedKey:(NSString *)key {
    return (_constraintManager
            ?[_constraintManager valueForKey:key]
            :[super valueForUndefinedKey:key]);
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

- (void)registerForNotifications {
    [NotificationCenter addObserverForName:NSManagedObjectContextObjectsDidChangeNotification
                                    object:self.managedObjectContext
                                     queue:[NSOperationQueue mainQueue]
                                usingBlock:^(NSNotification * note)
    {
        __weak RemoteElement * weakSelf = self;
        NSSet * insertedObjects = [note.userInfo[NSInsertedObjectsKey]
                                   objectsPassingTest:^BOOL (id obj, BOOL * stop) {
                return [weakSelf.constraints
                        containsObject:obj];
            }

                                  ];
        NSSet * deletedObjects = [note.userInfo[NSDeletedObjectsKey]
                                  objectsPassingTest:^BOOL (id obj, BOOL * stop) {
                return [weakSelf.constraints
                        containsObject:obj];
            }

                                 ];
        NSSet * updatedObjects = [note.userInfo[NSUpdatedObjectsKey]
                                  objectsPassingTest:^BOOL (id obj, BOOL * stop) {
                return [weakSelf.constraints
                        containsObject:obj];
            }

                                 ];

        if (insertedObjects.count || deletedObjects.count || updatedObjects.count) {
            [self.constraintManager processConstraints];
            MSLogDebug(REMOTE_F,
                       @"%@\ninserted objects:\n\t%@\ndeleted objects:\n\t%@\nupdated objects:\n\t%@",
                       ClassTagSelectorStringForInstance(self.displayName),
                       (insertedObjects.count
                        ?[[[insertedObjects valueForKeyPath:@"description"] allObjects] componentsJoinedByString:@"\n\t"]
                        : @""),
                       (deletedObjects.count
                        ?[[[deletedObjects valueForKeyPath:@"description"] allObjects] componentsJoinedByString:@"\n\t"]
                        : @""),
                       (updatedObjects.count
                        ?[[[updatedObjects valueForKeyPath:@"description"] allObjects] componentsJoinedByString:@"\n\t"]
                        : @""));
        }
    }

    ];
}

- (void)dealloc {
    [NotificationCenter removeObserver:self];
}

- (void)clearAlignmentOptions {
    self.alignmentOptions = RemoteElementAlignmentOptionUndefined;
}

- (void)clearSizingOptions {
    self.sizingOptions = RemoteElementSizingOptionWidthUnspecified | RemoteElementSizingOptionHeightUnspecified;
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

- (NSString *)constraintsDescription {
    NSMutableString * description = [@"" mutableCopy];

    if (self.constraints.count)
        [description appendFormat:@"\nowned:\n\t%@",
         [[[self.constraints allObjects] valueForKeyPath:@"description"]
          componentsJoinedByString:@"\n\t"]];
    if (self.subelementConstraints.count)
        [description appendFormat:@"\nsubelements:\n\t%@",
         [[[self.subelementConstraints allObjects] valueForKeyPath:@"description"]
          componentsJoinedByString:@"\n\t"]];
    if (self.dependentConstraints.count)
        [description appendFormat:@"\ndependent constraints:\n\t%@",
         [[[self.dependentConstraints allObjects] valueForKeyPath:@"description"]
          componentsJoinedByString:@"\n\t"]];
    if (self.dependentChildConstraints.count)
        [description appendFormat:@"\ndependent children:\n\t%@",
         [[[self.dependentChildConstraints allObjects] valueForKeyPath:@"description"]
          componentsJoinedByString:@"\n\t"]];
    if (self.dependentSiblingConstraints.count)
        [description appendFormat:@"\ndependent siblings:\n\t%@",
         [[[self.dependentSiblingConstraints allObjects] valueForKeyPath:@"description"]
          componentsJoinedByString:@"\n\t"]];
    if (description.length == 0) [description appendString:@"\nno constraints"];

    return description;
}

- (NSString *)sizingOptionsDescription {
    NSMutableString * s = [@"sizingOptions: {\n" mutableCopy];

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

    [s appendFormat:@"\tproportion lock? %@\n", NSStringFromBOOL(self.proportionLock)];

    [s appendString:@"}"];

    return s;
}

- (NSString *)alignmentOptionsDescription {
    NSMutableString * returnString = [@"alignmentOptions:{\n" mutableCopy];

    if ((_appearance & RemoteElementAlignmentOptionMaskParent)) {
        if ((_appearance & RemoteElementAlignmentOptionCenterXParent)) [returnString appendString:@"\tcenterX: RemoteElementAlignmentOptionCenterXParent\n"];

        if ((_appearance & RemoteElementAlignmentOptionCenterYParent)) [returnString appendString:@"\tcenterY: RemoteElementAlignmentOptionCenterYParent\n"];

        if ((_appearance & RemoteElementAlignmentOptionTopParent)) [returnString appendString:@"\ttop: RemoteElementAlignmentOptionTopParent\n"];

        if ((_appearance & RemoteElementAlignmentOptionBottomParent)) [returnString appendString:@"\tbottom: RemoteElementAlignmentOptionBottomParent\n"];

        if ((_appearance & RemoteElementAlignmentOptionLeftParent)) [returnString appendString:@"\tleft: RemoteElementAlignmentOptionLeftParent\n"];

        if ((_appearance & RemoteElementAlignmentOptionRightParent)) [returnString appendString:@"\tright: RemoteElementAlignmentOptionRightParent\n"];

        if ((_appearance & RemoteElementAlignmentOptionBaselineParent)) [returnString appendString:@"\tbaseline: RemoteElementAlignmentOptionBaselineParent\n"];
    }

    if ((_appearance & RemoteElementAlignmentOptionMaskFocus)) {
        if ((_appearance & RemoteElementAlignmentOptionCenterXFocus)) [returnString appendString:@"\tcenterX: RemoteElementAlignmentOptionCenterXFocus\n"];

        if ((_appearance & RemoteElementAlignmentOptionCenterYFocus)) [returnString appendString:@"\tcenterY: RemoteElementAlignmentOptionCenterYFocus\n"];

        if ((_appearance & RemoteElementAlignmentOptionTopFocus)) [returnString appendString:@"\ttop: RemoteElementAlignmentOptionTopFocus\n"];

        if ((_appearance & RemoteElementAlignmentOptionBottomFocus)) [returnString appendString:@"\tbottom: RemoteElementAlignmentOptionBottomFocus\n"];

        if ((_appearance & RemoteElementAlignmentOptionLeftFocus)) [returnString appendString:@"\tleft: RemoteElementAlignmentOptionLeftFocus\n"];

        if ((_appearance & RemoteElementAlignmentOptionRightFocus)) [returnString appendString:@"\tright: RemoteElementAlignmentOptionRightFocus\n"];

        if ((_appearance & RemoteElementAlignmentOptionBaselineFocus)) [returnString appendString:@"\tbaseline: RemoteElementAlignmentOptionBaselineFocus\n"];
    }

    [returnString appendString:@"}"];

    return returnString;
}

- (NSString *)flagsAndAppearanceDescription {
    return [NSString
            stringWithFormat:
            @"flags:%12$-15s0x%2$.*1$llX\ntype:%12$-16s0x%3$.*1$llX\nsubtype:%12$-13s0x%4$.*1$llX\noptions:%12$-13s0x%5$.*1$llX\nstate:%12$-15s0x%6$.*1$llX\n"
            "appearance:%12$-10s0x%7$.*1$llX\nalignment:%12$-11s0x%8$.*1$llX\nsizing:%12$-14s0x%9$.*1$llX\nshape:%12$-15s0x%10$.*1$llX\nstyle:%12$-15s0x%11$.*1$llX\n",
            16, _flags, self.type, self.subtype, self.options, self.state,
            _appearance, self.alignmentOptions, self.sizingOptions, self.shape, self.style, " "];
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
         NSStringFromClass([element class]),
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

