//
// RemoteElementConstraintManager.m
// iPhonto
//
// Created by Jason Cardwell on 2/9/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "RemoteElementConstraintManager.h"
#import "RemoteElement_Private.h"


static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = CONSTRAINT_F_C;
#pragma unused(ddLogLevel, msLogContext)

MSKIT_STRING_CONST REConstraintsDidChangeNotification = @"REConstraintsDidChangeNotification";

RELayoutConstraintAffiliation
remoteElementAffiliationWithConstraint(RemoteElement                 * element,
                                       RemoteElementLayoutConstraint * constraint)
{
    RELayoutConstraintAffiliation affiliation = RELayoutConstraintUnspecifiedAffiliation;

    RemoteElement * owner, * firstItem, * secondItem;

    if ([constraint isDeleted]) {
        NSDictionary * dict = [constraint committedValuesForKeys:@[@"owner",
                                                                   @"firstItem",
                                                                   @"secondItem"]];
        owner = dict[@"owner"];
        firstItem = dict[@"firstItem"];
        secondItem = dict[@"secondItem"];
    } else {
        owner = constraint.owner;
        firstItem = constraint.firstItem;
        secondItem = constraint.secondItem;
    }

    if (owner == element)      affiliation |= RELayoutConstraintOwnerAffiliation;
    if (firstItem == element)  affiliation |= RELayoutConstraintFirstItemAffiliation;
    if (secondItem == element) affiliation |= RELayoutConstraintSecondItemAffiliation;

    return affiliation;
}

NSString * NSStringFromRELayoutConstraintAffiliation(RELayoutConstraintAffiliation affiliation)
{
    if (!affiliation) return @"RELayoutConstraintUnspecifiedAffiliation";
    NSMutableArray * affiliations = [@[] mutableCopy];
    if (affiliation & RELayoutConstraintFirstItemAffiliation)
        [affiliations addObject:@"RELayoutConstraintFirstItemAffiliation"];
    if (affiliation & RELayoutConstraintSecondItemAffiliation)
        [affiliations addObject:@"RELayoutConstraintSecondItemAffiliation"];
    if (affiliation & RELayoutConstraintOwnerAffiliation)
        [affiliations addObject:@"RELayoutConstraintOwnerAffiliation"];
    return [affiliations componentsJoinedByString:@"|"];
}

RERelationshipType
remoteElementRelationshipTypeForConstraint(RemoteElement                 * element,
                                           RemoteElementLayoutConstraint * constraint)
{
    RemoteElement * firstItem, * secondItem;
    if ([constraint isDeleted]) {
        NSDictionary * dict = [constraint committedValuesForKeys:@[@"firstItem", @"secondItem"]];
        firstItem = dict[@"firstItem"];
        secondItem = dict[@"secondItem"];
    } else {
        firstItem = constraint.firstItem;
        secondItem = constraint.secondItem;
    }

    RELayoutConstraintAffiliation affiliation = remoteElementAffiliationWithConstraint(firstItem,
                                                                                       constraint);

    if (  (affiliation & RELayoutConstraintFirstItemAffiliation)
       && (!secondItem || (affiliation & RELayoutConstraintSecondItemAffiliation)))
        return REIntrinsicRelationship;
    else if (  (affiliation & RELayoutConstraintFirstItemAffiliation)
             && firstItem.parentElement == secondItem)
        return REChildRelationship;
    else if (   (affiliation & RELayoutConstraintSecondItemAffiliation)
             && firstItem.parentElement == secondItem)
        return REParentRelationship;
    else if (firstItem.parentElement == secondItem.parentElement)
        return RESiblingRelationship;
    else
        return REUnspecifiedRelation;
}

NSString * NSStringFromRERelationshipType(RERelationshipType relationship) {
    switch (relationship) {
        case REUnspecifiedRelation:
            return @"REUnspecifiedRelation";

        case REParentRelationship:
            return @"REParentRelationship";

        case REChildRelationship:
            return @"REChildRelationship";

        case RESiblingRelationship:
            return @"RESiblingRelationship";

        case REIntrinsicRelationship:
            return @"REIntrinsicRelationship";
    }
}

@interface RemoteElementConstraintManager ()

@property (nonatomic, weak,   readwrite) RemoteElement                    * remoteElement;
@property (nonatomic, strong, readwrite) RemoteElementLayoutConfiguration * layoutConfiguration;

@end

@implementation RemoteElementConstraintManager {
    struct {
        BOOL constraintsNotificationScheduled;
    } _flags;
}

+ (RemoteElementConstraintManager *)constraintManagerForRemoteElement:(RemoteElement *)element {
    return [[self alloc] initWithRemoteElement:element];
}

- (id)initWithRemoteElement:(RemoteElement *)remoteElement {
    if ((self = [super init]))
    {
        _remoteElement           = remoteElement;
        self.layoutConfiguration = [RemoteElementLayoutConfiguration
                                         layoutConfigurationForElement:_remoteElement];
    }

    return self;
}

- (NSSet *)constraintsAffectingAxis:(UILayoutConstraintAxis)axis
                              order:(RELayoutConstraintOrder)order
{
    NSMutableSet * constraints = [NSMutableSet set];

    if (!order || order == RELayoutConstraintFirstOrder) {
        [constraints
         unionSet:[_remoteElement.firstItemConstraints objectsPassingTest:
                   ^BOOL (RemoteElementLayoutConstraint * obj, BOOL * stop) {
                       return (axis == UILayoutConstraintAxisForAttribute(obj.firstAttribute));
                   }]];
    }
    if (!order || order == RELayoutConstraintSecondOrder) {
        [constraints
         unionSet:[_remoteElement.secondItemConstraints objectsPassingTest:
                   ^BOOL (RemoteElementLayoutConstraint * obj, BOOL * stop) {
                       return (axis == UILayoutConstraintAxisForAttribute(obj.secondAttribute));
                   }]];
    }

    return (constraints.count
            ? constraints
            : nil);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constraint Change Notification
////////////////////////////////////////////////////////////////////////////////

- (void)postConstraintsDidChangeNotification {
    _flags.constraintsNotificationScheduled = YES;
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,
                                            (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [NotificationCenter postNotificationName:$(@"%@-%@",
                                                   REConstraintsDidChangeNotification,
                                                   _remoteElement.identifier)
                                          object:_remoteElement];
        _flags.constraintsNotificationScheduled = NO;
    });
}

- (void)didAddConstraint:(RemoteElementLayoutConstraint *)constraint
{
    assert(constraint.owner == _remoteElement);
    MSLogDebug(@"%@ '%@'",
               ClassTagSelectorStringForInstance(_remoteElement.displayName),
               constraint);

    [constraint.firstItem.layoutConfiguration refreshConfig];
    if (!_flags.constraintsNotificationScheduled) [self postConstraintsDidChangeNotification];
}

- (void)didRemoveConstraint:(RemoteElementLayoutConstraint *)constraint
{
    assert([constraint committedValueForKey:@"owner"] == _remoteElement);
    MSLogDebug(@"%@ '%@'",
               ClassTagSelectorStringForInstance(_remoteElement.displayName),
               constraint);

    [[(RemoteElement *)[constraint committedValueForKey:@"firstItem"]
      layoutConfiguration] refreshConfig];
    if (!_flags.constraintsNotificationScheduled) [self postConstraintsDidChangeNotification];
}

- (void)didUpdateConstraint:(RemoteElementLayoutConstraint *)constraint
{
    assert(constraint.owner == _remoteElement);
    MSLogDebug(@"%@ '%@' \u2192 '%@'",
               ClassTagSelectorStringForInstance(_remoteElement.displayName),
               [constraint committedValuesDescription],
               constraint);
    if (!_flags.constraintsNotificationScheduled) [self postConstraintsDidChangeNotification];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Cached Constraints
////////////////////////////////////////////////////////////////////////////////

- (NSSet *)intrinsicConstraints {
    return [_remoteElement.constraints
            filteredSetUsingPredicateWithBlock:
            ^BOOL(RemoteElementLayoutConstraint * constraint, NSDictionary *bindings) {
                return (   constraint.firstItem == _remoteElement
                        && (!constraint.secondItem || constraint.secondItem == _remoteElement));
            }];
}

- (NSSet *)subelementConstraints {
    return [_remoteElement.constraints setByRemovingObjectsFromSet:self.intrinsicConstraints];
}

- (NSSet *)dependentChildConstraints {
    return [self.dependentConstraints
            objectsPassingTest:
            ^BOOL(RemoteElementLayoutConstraint * constraint, BOOL *stop) {
                return [_remoteElement.subelements containsObject:constraint.firstItem];
            }];
}

- (NSSet *)dependentConstraints {
    return [_remoteElement.secondItemConstraints
            setByRemovingObjectsFromSet:self.intrinsicConstraints];
}

- (NSSet *)dependentSiblingConstraints {
    return [self.dependentConstraints
            setByRemovingObjectsFromSet:self.dependentChildConstraints];
}

- (RemoteElementLayoutConstraint *)constraintWithAttributes:(NSDictionary *)attributes {
    return [_remoteElement.firstItemConstraints firstObjectPassingTest:
            ^BOOL (RemoteElementLayoutConstraint * obj, BOOL * stop) {
                return ([obj hasAttributeValues:attributes] && (*stop = YES));}];
}

- (void)processOwnedConstraints {
    assert(IsMainQueue);
    [_remoteElement.constraints
     enumerateObjectsUsingBlock:^(RemoteElementLayoutConstraint * constraint, BOOL *stop) {
         constraint.firstItem.layoutConfiguration[constraint.firstAttribute] = @YES;
     }];
}

- (void)setConstraintsFromString:(NSString *)constraints {
    if (_remoteElement.constraints.count) {
        [_remoteElement.managedObjectContext
         performBlockAndWait:^{
             [_remoteElement.managedObjectContext
              deleteObjects:_remoteElement.constraints];
         }];
    }


    NSArray * elements  = [[_remoteElement.subelements array] arrayByAddingObject:_remoteElement];
    NSDictionary * directory = [NSDictionary
                                dictionaryWithObjects:elements
                                forKeys:[elements valueForKeyPath:@"identifier"]];

    [[NSLayoutConstraint constraintDictionariesByParsingString:constraints]
     enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * stop) {
         RemoteElement * element1ID = obj[MSExtendedVisualFormatItem1Name];
         RemoteElement * element1 = directory[element1ID];
         RemoteElement * element2ID = obj[MSExtendedVisualFormatItem2Name];
         RemoteElement * element2 = (ValueIsNotNil(element2ID)
                                    ? directory[element2ID]
                                    : nil);
         CGFloat multiplier = (ValueIsNotNil(obj[MSExtendedVisualFormatMultiplierName])
                              ? Float(obj[MSExtendedVisualFormatMultiplierName])
                              : 1.0f);
         CGFloat constant = (ValueIsNotNil(obj[MSExtendedVisualFormatConstantName])
                            ? Float(obj[MSExtendedVisualFormatConstantName])
                            : 0.0f);
         if ([@"-" isEqualToString:obj[MSExtendedVisualFormatConstantOperatorName]])
             constant = -constant;

         NSLayoutAttribute attr1 = [NSLayoutConstraint
                                   attributeForPseudoName:obj[MSExtendedVisualFormatAttribute1Name]];
         NSLayoutAttribute attr2 = [NSLayoutConstraint
                                   attributeForPseudoName:obj[MSExtendedVisualFormatAttribute2Name]];
         NSLayoutRelation relation = [NSLayoutConstraint
                                     relationForPseudoName:obj[MSExtendedVisualFormatRelationName]];
         RemoteElementLayoutConstraint * constraint =
            [RemoteElementLayoutConstraint constraintWithItem:element1
                                                    attribute:attr1
                                                    relatedBy:relation
                                                       toItem:element2
                                                    attribute:attr2
                                                   multiplier:multiplier
                                                     constant:constant
                                                        owner:_remoteElement];
         if (ValueIsNotNil(obj[MSExtendedVisualFormatPriorityName]))
             constraint.priority = Float(obj[MSExtendedVisualFormatPriorityName]);
     }];

    [self.layoutConfiguration refreshConfig];
}

- (void)removeProportionLockForElement:(RemoteElement *)element currentSize:(CGSize)currentSize {
    if (element.proportionLock) {
        element.proportionLock = NO;
        [element.managedObjectContext performBlockAndWait:^{

            RemoteElementLayoutConstraint * c =
            [element.firstItemConstraints
             firstObjectPassingTest:^BOOL (RemoteElementLayoutConstraint * obj, BOOL * stop) {
                 return (obj.secondItem == element && (*stop = YES));
             }];

            assert(c);
            c.multiplier      = 1.0f;
            c.secondItem      = nil;
            c.secondAttribute = NSLayoutAttributeNotAnAttribute;
            c.constant        = (c.firstAttribute == NSLayoutAttributeHeight
                                 ? currentSize.height
                                 : currentSize.width);
            [element.managedObjectContext processPendingChanges];
        }];
    }
}

- (void)resizeSubelements:(NSSet *)subelements
                toSibling:(RemoteElement *)sibling
                attribute:(NSLayoutAttribute)attribute
                  metrics:(NSDictionary *)metrics
{
    static NSDictionary const * kAttributeDependencies = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kAttributeDependencies = @{@(NSLayoutAttributeWidth): [@[@(NSLayoutAttributeWidth),
                                                               @(NSLayoutAttributeLeft),
                                                               @(NSLayoutAttributeRight)] set],
                                   @(NSLayoutAttributeHeight): [@[@(NSLayoutAttributeHeight),
                                                                @(NSLayoutAttributeTop),
                                                                @(NSLayoutAttributeBottom)] set]
                                   };
    });

    assert(   [subelements isSubsetOfSet:[_remoteElement.subelements set]]
           && [_remoteElement.subelements containsObject:sibling]);


    // enumerate the views to adjust their constraints
    for (RemoteElement * element in subelements) {

        // adjust constraints that depend on the view being moved
        [self freezeConstraints:element.dependentSiblingConstraints
                  forAttributes:kAttributeDependencies[@(attribute)]
                        metrics:metrics];

        [self removeProportionLockForElement:element
                                 currentSize:Rect(metrics[element.identifier]).size];

        // get the constraints for the attribute to align already present on the subelement
        NSSet * constraintsForAttribute =
        [[element constraintsAffectingAxis:UILayoutConstraintAxisForAttribute(attribute)
                                     order:RELayoutConstraintFirstOrder]
         objectsPassingTest:^BOOL (RemoteElementLayoutConstraint * obj, BOOL * stop) {
             return (obj.firstAttribute == attribute);
         }];

        // handle constraints already present for the attribute to align
        if (!constraintsForAttribute.count) {
            __block RemoteElementLayoutConstraint * c = nil;
            [element.managedObjectContext performBlockAndWait:^{
                // Remove conflicting constraint and add new constraint for attribute
                c = [RemoteElementLayoutConstraint
                     constraintWithItem:element
                     attribute:attribute
                     relatedBy:NSLayoutRelationEqual
                     toItem:sibling
                     attribute:attribute
                     multiplier:1.0f
                     constant:0.0f
                     owner:_remoteElement];
                assert(c);
                [element.managedObjectContext save:nil];
                [self resolveConflictsForConstraint:c metrics:metrics];
            }];


        } else {
            assert(constraintsForAttribute.count == 1);
            // just adjust the current constraint
            [element.managedObjectContext performBlockAndWait:^{
                [[constraintsForAttribute anyObject]
                 setValuesForKeysWithDictionary:@{@"secondItem"      : sibling,
                                                  @"multiplier"      : @1,
                                                  @"secondAttribute" : @(attribute),
                                                  @"constant"        : @0}];
                [element.managedObjectContext processPendingChanges];
            }];
        }
    }
}

- (void)translateSubelements:(NSSet *)subelements
                 translation:(CGPoint)translation
                     metrics:(NSDictionary *)metrics
{
    static NSSet * kAttributeDependencies = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kAttributeDependencies = [@[@(NSLayoutAttributeBottom),
                                   @(NSLayoutAttributeTop),
                                   @(NSLayoutAttributeLeft),
                                   @(NSLayoutAttributeRight),
                                   @(NSLayoutAttributeCenterX),
                                   @(NSLayoutAttributeCenterY)] set];
    });
    
    for (RemoteElement * subelement in subelements) {
        [self freezeConstraints:subelement.dependentSiblingConstraints
                  forAttributes:kAttributeDependencies
                        metrics:metrics];

        for (RemoteElementLayoutConstraint * constraint in subelement.firstItemConstraints)
        {
            switch (constraint.firstAttribute)
            {
                case NSLayoutAttributeBaseline:
                case NSLayoutAttributeBottom:
                case NSLayoutAttributeTop:
                case NSLayoutAttributeCenterY:
                    constraint.constant += translation.y;
                    break;

                case NSLayoutAttributeLeft:
                case NSLayoutAttributeLeading:
                case NSLayoutAttributeRight:
                case NSLayoutAttributeTrailing:
                case NSLayoutAttributeCenterX:
                    constraint.constant += translation.x;
                    break;

                case NSLayoutAttributeWidth:
                case NSLayoutAttributeHeight:
                case NSLayoutAttributeNotAnAttribute:
                    break;
            }
        }
    }

}

- (void)alignSubelements:(NSSet *)subelements
               toSibling:(RemoteElement *)sibling
               attribute:(NSLayoutAttribute)attribute
                 metrics:(NSDictionary *)metrics
{
    // assert the views are all subelement views
    assert([[subelements setByAddingObject:sibling]
            isSubsetOfSet:[_remoteElement.subelements set]]);

    static NSDictionary const * kAttributeDependencies = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kAttributeDependencies =
        @{
          @(UILayoutConstraintAxisHorizontal): [@[@(NSLayoutAttributeCenterX),
                                                @(NSLayoutAttributeLeft),
                                                @(NSLayoutAttributeRight)] set],
          @(UILayoutConstraintAxisVertical)  : [@[@(NSLayoutAttributeCenterY),
                                                @(NSLayoutAttributeTop),
                                                @(NSLayoutAttributeBottom)] set]
          };
    });

    UILayoutConstraintAxis axis = UILayoutConstraintAxisForAttribute(attribute);

    // enumerate the views to adjust their constraints
    for (RemoteElement * element in subelements) {

        // adjust constraints that depend on the view being moved
        [self freezeConstraints:element.dependentSiblingConstraints
                           forAttributes:kAttributeDependencies[@(axis)]
                                 metrics:metrics];

        // adjust size constraints to prevent move altering size calculations
        [self freezeSize:Rect(metrics[element.identifier]).size
           forSubelement:element
               attribute:attribute];

        // get the constraints for the attribute to align already present on the subelement
        NSSet * constraintsForAttribute =
        [[element constraintsAffectingAxis:axis
                                     order:RELayoutConstraintFirstOrder]
         objectsPassingTest:^BOOL (RemoteElementLayoutConstraint * obj, BOOL * stop) {
             return (obj.firstAttribute == attribute);
         }];

        // handle constraints already present for the attribute to align
        if (!constraintsForAttribute.count) {
            // Remove conflicting constraint and add new constraint for attribute
            __block RemoteElementLayoutConstraint * c = nil;


            [element.managedObjectContext performBlockAndWait:^{
                c = [RemoteElementLayoutConstraint
                     constraintWithItem:element
                     attribute:attribute
                     relatedBy:NSLayoutRelationEqual
                     toItem:sibling
                     attribute:attribute
                     multiplier:1.0f
                     constant:0.0f
                     owner:_remoteElement];

                assert(c);
                [element.managedObjectContext save:nil];
                [self resolveConflictsForConstraint:c metrics:metrics];
            }];

        } else {
            assert(constraintsForAttribute.count == 1);
            // just adjust the current constraint
            [[constraintsForAttribute anyObject]
             setValuesForKeysWithDictionary:@{@"secondItem"      : sibling,
                                              @"multiplier"      : @1,
                                              @"secondAttribute" : @(attribute),
                                              @"constant"        : @0}

             ];
            [element.managedObjectContext performBlockAndWait:^{
                [element.managedObjectContext processPendingChanges];
            }];
        }
    }
}

/**
 * Normalizes `remoteElementView.remoteElement.dependentChildConstraints` to have a multiplier of
 * `1.0`.
 */
- (void)removeMultipliers:(NSDictionary *)metrics
{

    for (RemoteElementLayoutConstraint * constraint in _remoteElement.dependentChildConstraints)
    {
        if (constraint.multiplier != 1) {
            constraint.multiplier = 1.0f;
            CGRect frame = Rect(metrics[constraint.firstItem.identifier]);
            CGRect bounds = (CGRect){.size = Rect(metrics[_remoteElement.identifier]).size};
            switch (constraint.firstAttribute) {
                    // TODO: Handle top, left, right and bottom alignment cases
                case NSLayoutAttributeBaseline :
                case NSLayoutAttributeBottom :
                    constraint.constant =   CGRectGetMaxY(frame)
                    - bounds.size.height;
                    break;

                case NSLayoutAttributeTop :
                    constraint.constant = frame.origin.y;
                    break;

                case NSLayoutAttributeCenterY :
                    constraint.constant =   CGRectGetMidY(frame) - bounds.size.height / 2.0;
                    break;

                case NSLayoutAttributeLeft :
                case NSLayoutAttributeLeading :
                    constraint.constant = frame.origin.x;
                    break;

                case NSLayoutAttributeCenterX :
                    constraint.constant =   CGRectGetMidX(frame) - bounds.size.width / 2.0;
                    break;

                case NSLayoutAttributeRight :
                case NSLayoutAttributeTrailing :
                    constraint.constant =   CGRectGetMaxX(frame) - bounds.size.width;
                    break;

                case NSLayoutAttributeWidth :
                    constraint.constant =   frame.size.width - bounds.size.width;
                    break;

                case NSLayoutAttributeHeight :
                    constraint.constant =   frame.size.height - bounds.size.height;
                    break;

                case NSLayoutAttributeNotAnAttribute :
                default :
                    assert(NO);
                    break;
            }
        }
    }
}

- (void)resizeElement:(RemoteElement *)element
             fromSize:(CGSize)currentSize
               toSize:(CGSize)newSize
              metrics:(NSDictionary *)metrics
{
    static NSSet * kAttributeDependencies = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kAttributeDependencies = [@[@(NSLayoutAttributeBottom),
                                  @(NSLayoutAttributeTop),
                                  @(NSLayoutAttributeLeft),
                                  @(NSLayoutAttributeRight),
                                  @(NSLayoutAttributeCenterX),
                                  @(NSLayoutAttributeCenterY)] set];
    });
    if (  element.proportionLock
        && currentSize.width / currentSize.height
        != newSize.width / newSize.height)
    {
        [self removeProportionLockForElement:element currentSize:currentSize];
    }

    [self freezeConstraints:element.dependentSiblingConstraints
              forAttributes:kAttributeDependencies
                    metrics:metrics];

    CGSize   deltaSize = CGSizeGetDelta(currentSize, newSize);

    for (RemoteElementLayoutConstraint * constraint in element.firstItemConstraints)
    {
        switch (constraint.firstAttribute)
        {
            case NSLayoutAttributeLeft:
            case NSLayoutAttributeLeading:
            case NSLayoutAttributeRight:
            case NSLayoutAttributeTrailing:
                constraint.constant -= deltaSize.width / 2.0f;
                break;

            case NSLayoutAttributeWidth:

                if (constraint.isStaticConstraint)
                    constraint.constant = newSize.width;
                else if (constraint.firstItem != constraint.secondItem)
                    constraint.constant -= deltaSize.width;

                break;

            case NSLayoutAttributeCenterX:
                break;

            case NSLayoutAttributeBaseline:
            case NSLayoutAttributeBottom:
            case NSLayoutAttributeTop:
                constraint.constant -= deltaSize.height / 2.0f;
                break;

            case NSLayoutAttributeHeight:

                if (constraint.isStaticConstraint)
                    constraint.constant = newSize.height;
                else if (constraint.firstItem != constraint.secondItem)
                    constraint.constant -= deltaSize.height;

                break;

            case NSLayoutAttributeCenterY:
                break;
                
            case NSLayoutAttributeNotAnAttribute:
            default:
                assert(NO);
                break;
        }
    }
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Manipulation Helper Methods
////////////////////////////////////////////////////////////////////////////////

- (void)freezeConstraints:(NSSet *)constraints
            forAttributes:(NSSet *)attributes
                  metrics:(NSDictionary *)metrics
{
    for (RemoteElementLayoutConstraint * constraint in constraints) {


        if (![attributes containsObject:@(constraint.firstAttribute)]) continue;

        constraint.secondItem = constraint.firstItem.parentElement;
        constraint.multiplier = 1.0f;
        CGRect bounds = (CGRect){.size = Rect(metrics[_remoteElement.identifier]).size};
        CGRect frame  = Rect(metrics[constraint.firstItem.identifier]);

        switch (constraint.firstAttribute) {
            case NSLayoutAttributeBottom :
                constraint.constant =   CGRectGetMaxY(frame) - bounds.size.height;
                constraint.secondAttribute = NSLayoutAttributeBottom;
                break;

            case NSLayoutAttributeTop :
                constraint.constant        = frame.origin.y;
                constraint.secondAttribute = NSLayoutAttributeTop;
                break;

            case NSLayoutAttributeLeft :
            case NSLayoutAttributeLeading :
                constraint.constant        = frame.origin.x;
                constraint.secondAttribute = NSLayoutAttributeLeft;
                break;

            case NSLayoutAttributeRight :
            case NSLayoutAttributeTrailing :
                constraint.constant        = CGRectGetMaxX(frame) - bounds.size.width;
                constraint.secondAttribute = NSLayoutAttributeRight;
                break;

            case NSLayoutAttributeCenterX :
                constraint.constant        = CGRectGetMidX(frame) - CGRectGetMidX(bounds);
                constraint.secondAttribute = NSLayoutAttributeCenterX;
                break;

            case NSLayoutAttributeCenterY :
                constraint.constant        = CGRectGetMidY(frame) - CGRectGetMidY(bounds);
                constraint.secondAttribute = NSLayoutAttributeCenterY;
                break;

            case NSLayoutAttributeWidth :
                constraint.constant        = frame.size.width - bounds.size.width;
                constraint.secondAttribute = NSLayoutAttributeWidth;
                break;

            case NSLayoutAttributeHeight :
                constraint.constant        = frame.size.height - bounds.size.height;
                constraint.secondAttribute = NSLayoutAttributeHeight;
                break;

            case NSLayoutAttributeBaseline :
            case NSLayoutAttributeNotAnAttribute :
                assert(NO);
                break;
        }
    }
}

- (void)freezeSize:(CGSize)size
     forSubelement:(RemoteElement *)subelement
         attribute:(NSLayoutAttribute)attribute
{
    RemoteElementLayoutConfiguration * config = subelement.layoutConfiguration;
    UILayoutConstraintAxis axis = UILayoutConstraintAxisForAttribute(attribute);
    if (   (axis == UILayoutConstraintAxisHorizontal && [config[NSLayoutAttributeWidth] boolValue])
        || (axis == UILayoutConstraintAxisVertical && [config[NSLayoutAttributeHeight] boolValue]))
        return;

    switch (attribute) {
        case NSLayoutAttributeBaseline :
        case NSLayoutAttributeBottom :

            // remove top
            if ([config[NSLayoutAttributeTop] boolValue]) {
                assert(![config[NSLayoutAttributeHeight] boolValue]);

                NSManagedObjectContext * ctx         = subelement.managedObjectContext;
                NSSet                  * constraints = [subelement.constraintManager
                                                        constraintsForAttribute:NSLayoutAttributeTop
                                                        order:RELayoutConstraintFirstOrder];

                [ctx performBlockAndWait:^{[ctx deleteObjects:constraints]; }];

                config[NSLayoutAttributeTop] = @NO;

                RemoteElementLayoutConstraint * c =
                [RemoteElementLayoutConstraint constraintWithItem:subelement
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0f
                                                         constant:size.height
                                                            owner:subelement];

                assert(c);
                config[NSLayoutAttributeHeight] = @YES;
            }

            break;

        case NSLayoutAttributeTop :

            // remove bottom
            if ([config[NSLayoutAttributeBottom] boolValue]) {
                assert(![config[NSLayoutAttributeHeight] boolValue]);

                NSManagedObjectContext * ctx = subelement.managedObjectContext;
                NSSet * constraints = [subelement.constraintManager
                                       constraintsForAttribute:NSLayoutAttributeBottom
                                       order:RELayoutConstraintFirstOrder];

                [ctx performBlockAndWait:^{[ctx deleteObjects:constraints]; }];

                config[NSLayoutAttributeBottom] = @NO;

                RemoteElementLayoutConstraint * c =
                [RemoteElementLayoutConstraint constraintWithItem:subelement
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0f
                                                         constant:size.height
                                                            owner:subelement];

                assert(c);
                config[NSLayoutAttributeHeight] = @YES;
            }

            break;

        case NSLayoutAttributeLeft :
        case NSLayoutAttributeLeading :

            // remove right
            if ([config[NSLayoutAttributeRight] boolValue]) {
                assert(![config[NSLayoutAttributeWidth] boolValue]);

                NSManagedObjectContext * ctx = subelement.managedObjectContext;
                NSSet * constraints = [subelement.constraintManager
                                       constraintsForAttribute:NSLayoutAttributeRight
                                       order:RELayoutConstraintFirstOrder];

                [ctx performBlockAndWait:^{[ctx deleteObjects:constraints]; }];

                config[NSLayoutAttributeRight] = @NO;

                RemoteElementLayoutConstraint * c =
                [RemoteElementLayoutConstraint constraintWithItem:subelement
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0f
                                                         constant:size.width
                                                            owner:subelement];

                assert(c);
                config[NSLayoutAttributeWidth] = @YES;
            }

            break;

        case NSLayoutAttributeRight :
        case NSLayoutAttributeTrailing :

            // remove left
            if ([config[NSLayoutAttributeLeft] boolValue]) {
                assert(![config[NSLayoutAttributeWidth] boolValue]);

                NSManagedObjectContext * ctx = subelement.managedObjectContext;
                NSSet * constraints = [subelement.constraintManager
                                       constraintsForAttribute:NSLayoutAttributeLeft
                                       order:RELayoutConstraintFirstOrder];

                [ctx performBlockAndWait:^{[ctx deleteObjects:constraints]; }];

                config[NSLayoutAttributeLeft] = @NO;

                RemoteElementLayoutConstraint * c =
                [RemoteElementLayoutConstraint constraintWithItem:subelement
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0f
                                                         constant:size.width
                                                            owner:subelement];

                assert(c);
                config[NSLayoutAttributeWidth] = @YES;
            }

            break;

        case NSLayoutAttributeCenterX :

            // remove left and right
            if (   [config[NSLayoutAttributeRight] boolValue]
                || [config[NSLayoutAttributeLeft] boolValue])
            {
                //FIXME: assertion fails
                assert(![config[NSLayoutAttributeWidth] boolValue]);

                NSManagedObjectContext * ctx         = subelement.managedObjectContext;
                NSSet                  * constraints =
                [[subelement.constraintManager
                  constraintsForAttribute:NSLayoutAttributeRight
                  order:RELayoutConstraintFirstOrder]
                 setByAddingObjectsFromSet:[subelement.constraintManager
                                            constraintsForAttribute:NSLayoutAttributeLeft
                                            order:RELayoutConstraintFirstOrder]];

                [ctx performBlockAndWait:^{[ctx deleteObjects:constraints]; }];

                config[NSLayoutAttributeLeft]  = @NO;
                config[NSLayoutAttributeRight] = @NO;

                RemoteElementLayoutConstraint * c =
                [RemoteElementLayoutConstraint constraintWithItem:subelement
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0f
                                                         constant:size.width
                                                            owner:subelement];

                assert(c);
                config[NSLayoutAttributeWidth] = @YES;
            }

            break;

        case NSLayoutAttributeCenterY :

            // remove top and bottom
            if (   [config[NSLayoutAttributeTop] boolValue]
                || [config[NSLayoutAttributeBottom] boolValue])
            {
                assert(![config[NSLayoutAttributeHeight] boolValue]);

                NSManagedObjectContext * ctx         = subelement.managedObjectContext;
                NSSet                  * constraints =
                [[subelement.constraintManager
                  constraintsForAttribute:NSLayoutAttributeTop
                  order:RELayoutConstraintFirstOrder]
                 setByAddingObjectsFromSet:[subelement.constraintManager
                                            constraintsForAttribute:NSLayoutAttributeBottom
                                            order:RELayoutConstraintFirstOrder]];

                [ctx performBlockAndWait:^{[ctx deleteObjects:constraints]; }];

                config[NSLayoutAttributeTop]    = @NO;
                config[NSLayoutAttributeBottom] = @NO;

                RemoteElementLayoutConstraint * c =
                [RemoteElementLayoutConstraint constraintWithItem:subelement
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0f
                                                         constant:size.height
                                                            owner:subelement];

                assert(c);
                config[NSLayoutAttributeHeight] = @YES;
            }

            break;

        case NSLayoutAttributeWidth :
        case NSLayoutAttributeHeight :
        case NSLayoutAttributeNotAnAttribute :
        default :
            assert(NO);
            break;
    }
}

- (void)resolveConflictsForConstraint:(RemoteElementLayoutConstraint *)constraint
                              metrics:(NSDictionary *)metrics
{
    NSArray * additions = nil;

    NSArray * replacements = [constraint.firstItem
                              replacementCandidatesForAddingAttribute:constraint.firstAttribute
                              additions:&additions];

    NSSet * removal = [constraint.firstItem.firstItemConstraints
                       objectsPassingTest:^BOOL (RemoteElementLayoutConstraint * obj, BOOL * stop) {
                           return [replacements containsObject:@(obj.firstAttribute)];
                       }];

    CGRect frame = Rect(metrics[constraint.firstItem.identifier]);
    CGRect bounds =
        (CGRect){.size = Rect(metrics[constraint.firstItem.parentElement.identifier]).size};

    if (removal.count) {
        [constraint.managedObjectContext performBlock:^{
            [constraint.managedObjectContext deleteObjects:removal];
            [constraint.managedObjectContext save:nil];
        }];
    }

    if (additions)
        [constraint.managedObjectContext performBlock:^{
            for (NSNumber * n in additions)
            {
                switch ([n integerValue])
                {
                    case NSLayoutAttributeCenterX:
                    {
                        RemoteElementLayoutConstraint * c =
                        [RemoteElementLayoutConstraint
                         constraintWithItem:constraint.firstItem
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:_remoteElement
                         attribute:NSLayoutAttributeCenterX
                         multiplier:1.0f
                         constant:CGRectGetMidX(frame) - CGRectGetMidX(bounds)
                         owner:_remoteElement];

                        assert(c);
                    }
                        break;

                    case NSLayoutAttributeCenterY:
                    {
                        RemoteElementLayoutConstraint * c =
                        [RemoteElementLayoutConstraint
                         constraintWithItem:constraint.firstItem
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:_remoteElement
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1.0f
                         constant:CGRectGetMidY(frame) - CGRectGetMidY(bounds)
                         owner:_remoteElement];

                        assert(c);
                    }
                        break;

                    case NSLayoutAttributeWidth:
                    {
                        RemoteElementLayoutConstraint * c =
                        [RemoteElementLayoutConstraint
                         constraintWithItem:constraint.firstItem
                         attribute:NSLayoutAttributeWidth
                         relatedBy:NSLayoutRelationEqual
                         toItem:nil
                         attribute:NSLayoutAttributeNotAnAttribute
                         multiplier:1.0f
                         constant:frame.size.width
                         owner:constraint.firstItem];

                        assert(c);
                    }
                        break;

                    case NSLayoutAttributeHeight:
                    {
                        RemoteElementLayoutConstraint * c =
                        [RemoteElementLayoutConstraint
                         constraintWithItem:constraint.firstItem
                         attribute:NSLayoutAttributeHeight
                         relatedBy:NSLayoutRelationEqual
                         toItem:_remoteElement
                         attribute:NSLayoutAttributeNotAnAttribute
                         multiplier:1.0f
                         constant:frame.size.height
                         owner:constraint.firstItem];

                        assert(c);
                    }
                        break;

                    default:
                        assert(NO);
                        break;
                }
            }
            [constraint.managedObjectContext save:nil];
        }];
}

- (NSArray *)replacementCandidatesForAddingAttribute:(NSLayoutAttribute)attribute
                                           additions:(NSArray **)additions
{
    switch (attribute) {
        case NSLayoutAttributeBaseline :
        case NSLayoutAttributeBottom :
            if (_layoutConfiguration[@"height"])
                return (_layoutConfiguration[@"centerY"]
                        ? @[@(NSLayoutAttributeCenterY)]
                        : @[@(NSLayoutAttributeTop)]);
            else {
                *additions = @[@(NSLayoutAttributeHeight)];

                return @[@(NSLayoutAttributeCenterY), @(NSLayoutAttributeTop)];
            }

        case NSLayoutAttributeTop :
            if (_layoutConfiguration[@"height"])
                return (_layoutConfiguration[@"centerY"]
                        ? @[@(NSLayoutAttributeCenterY)]
                        : @[@(NSLayoutAttributeBottom)]);
            else {
                *additions = @[@(NSLayoutAttributeHeight)];

                return @[@(NSLayoutAttributeCenterY), @(NSLayoutAttributeBottom)];
            }

        case NSLayoutAttributeLeft :
        case NSLayoutAttributeLeading :
            if (_layoutConfiguration[@"width"])
                return (_layoutConfiguration[@"centerX"]
                        ? @[@(NSLayoutAttributeCenterX)]
                        : @[@(NSLayoutAttributeRight)]);
            else {
                *additions = @[@(NSLayoutAttributeWidth)];

                return @[@(NSLayoutAttributeCenterX), @(NSLayoutAttributeRight)];
            }

        case NSLayoutAttributeRight :
        case NSLayoutAttributeTrailing :
            if (_layoutConfiguration[@"width"])
                return (_layoutConfiguration[@"centerX"]
                        ? @[@(NSLayoutAttributeCenterX)]
                        : @[@(NSLayoutAttributeLeft)]);
            else {
                *additions = @[@(NSLayoutAttributeWidth)];

                return @[@(NSLayoutAttributeCenterX), @(NSLayoutAttributeLeft)];
            }

        case NSLayoutAttributeCenterX :
            if (_layoutConfiguration[@"width"])
                return (_layoutConfiguration[@"left"]
                        ? @[@(NSLayoutAttributeLeft)]
                        : @[@(NSLayoutAttributeRight)]);
            else {
                *additions = @[@(NSLayoutAttributeWidth)];

                return @[@(NSLayoutAttributeLeft), @(NSLayoutAttributeRight)];
            }

        case NSLayoutAttributeCenterY :
            if (_layoutConfiguration[@"height"])
                return (_layoutConfiguration[@"top"]
                        ? @[@(NSLayoutAttributeTop)]
                        : @[@(NSLayoutAttributeBottom)]);
            else {
                *additions = @[@(NSLayoutAttributeHeight)];

                return @[@(NSLayoutAttributeTop), @(NSLayoutAttributeBottom)];
            }

        case NSLayoutAttributeWidth :
            if (_layoutConfiguration[@"centerX"])
                return (_layoutConfiguration[@"left"]
                        ? @[@(NSLayoutAttributeLeft)]
                        : @[@(NSLayoutAttributeRight)]);
            else {
                *additions = @[@(NSLayoutAttributeWidth)];

                return @[@(NSLayoutAttributeLeft), @(NSLayoutAttributeRight)];
            }

        case NSLayoutAttributeHeight :
            if (_layoutConfiguration[@"centerY"])
                return (_layoutConfiguration[@"top"]
                        ? @[@(NSLayoutAttributeTop)]
                        : @[@(NSLayoutAttributeBottom)]);
            else {
                *additions = @[@(NSLayoutAttributeHeight)];

                return @[@(NSLayoutAttributeTop), @(NSLayoutAttributeBottom)];
            }

        case NSLayoutAttributeNotAnAttribute :
        default :

            return nil;
    }
}

- (NSSet *)constraintsForAttribute:(NSLayoutAttribute)attribute {
    return [self constraintsForAttribute:attribute
                                   order:RELayoutConstraintUnspecifiedOrder];
}

- (NSSet *)constraintsForAttribute:(NSLayoutAttribute)attribute
                             order:(RELayoutConstraintOrder)order
{
    if (!_layoutConfiguration[attribute]) return nil;

    NSMutableSet * constraints = [NSMutableSet set];

    if (!order || order == RELayoutConstraintFirstOrder) {
        [constraints unionSet:[_remoteElement.firstItemConstraints
                               objectsPassingTest:
                               ^BOOL (RemoteElementLayoutConstraint * obj, BOOL * stop) {
                                   return (obj.firstAttribute == attribute);
                               }]];
    }
    if (!order || order == RELayoutConstraintSecondOrder) {
        [constraints unionSet:[_remoteElement.secondItemConstraints
                               objectsPassingTest:
                               ^BOOL (RemoteElementLayoutConstraint * obj, BOOL * stop) {
                                   return (obj.secondAttribute == attribute);
                               }]];
    }

    return (constraints.count ? constraints : nil);
}

@end

UILayoutConstraintAxis UILayoutConstraintAxisForAttribute(NSLayoutAttribute attribute) {
    static dispatch_once_t   onceToken;
    static const NSSet     * horizontalAxisAttributes = nil, * verticalAxisAttributes = nil;

    dispatch_once(&onceToken, ^{
        horizontalAxisAttributes = [NSSet setWithObjects:
                                    @(NSLayoutAttributeWidth),
                                    @(NSLayoutAttributeLeft),
                                    @(NSLayoutAttributeLeading),
                                    @(NSLayoutAttributeRight),
                                    @(NSLayoutAttributeTrailing),
                                    @(NSLayoutAttributeCenterX), nil];
        verticalAxisAttributes = [NSSet setWithObjects:
                                  @(NSLayoutAttributeHeight),
                                  @(NSLayoutAttributeTop),
                                  @(NSLayoutAttributeBottom),
                                  @(NSLayoutAttributeBaseline),
                                  @(NSLayoutAttributeCenterY), nil];
    }

                  );
    if ([horizontalAxisAttributes containsObject:@(attribute)])
        return UILayoutConstraintAxisHorizontal;
    else if ([verticalAxisAttributes containsObject:@(attribute)])
        return UILayoutConstraintAxisVertical;
    else return -1;
}

@interface RemoteElementLayoutConfiguration ()

@property (nonatomic, weak) RemoteElement * element;
@property (nonatomic, strong) MSBitVector * bits;

@end

@implementation RemoteElementLayoutConfiguration

////////////////////////////////////////////////////////////////////////////////
#pragma mark Initializers
////////////////////////////////////////////////////////////////////////////////

+ (RemoteElementLayoutConfiguration *)layoutConfigurationForElement:(RemoteElement *)element {
    return [[RemoteElementLayoutConfiguration alloc]initWithElement:element];
}

- (id)initWithElement:(RemoteElement *)element {
    if ((self = [super init])) {
        assert(ValueIsNotNil(element));
        self.bits    = [MSBitVector bitVectorWithSize:MSBitVectorSize8];
        self.element = element;
    }

    return self;
}

- (RemoteElementLayoutConfiguration *)copyWithZone:(NSZone *)zone {
    RemoteElementLayoutConfiguration * config =
        [RemoteElementLayoutConfiguration layoutConfigurationForElement:_element];
    uint8_t bits   = (uint8_t)[_bits.bits unsignedIntegerValue];

    config.bits = [MSBitVector bitVectorWithBytes:&bits];

    return config;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Element Config
////////////////////////////////////////////////////////////////////////////////

- (void)refreshConfig {
    assert(_element);
    [_bits setBits:0];
    [_element.firstItemConstraints
     enumerateObjectsUsingBlock:^(RemoteElementLayoutConstraint * constraint, BOOL *stop) {
         self[constraint.firstAttribute] = @YES;
     }];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Syntax Support
////////////////////////////////////////////////////////////////////////////////

- (NSNumber *)objectForKeyedSubscript:(NSString *)key {
    return self[[NSLayoutConstraint attributeForPseudoName:key]];
}

- (void)setObject:(NSNumber *)object forKeyedSubscript:(NSString *)key {
    self[[NSLayoutConstraint attributeForPseudoName:key]] = object;
}

- (NSNumber *)objectAtIndexedSubscript:(NSLayoutAttribute)idx {
    switch (idx) {
        case NSLayoutAttributeBaseline:
        case NSLayoutAttributeBottom:           return _bits[4];
        case NSLayoutAttributeTop:              return _bits[5];
        case NSLayoutAttributeLeft:
        case NSLayoutAttributeLeading:          return _bits[7];
        case NSLayoutAttributeRight:
        case NSLayoutAttributeTrailing:         return _bits[6];
        case NSLayoutAttributeCenterX:          return _bits[3];
        case NSLayoutAttributeCenterY:          return _bits[2];
        case NSLayoutAttributeWidth:            return _bits[1];
        case NSLayoutAttributeHeight:           return _bits[0];
        case NSLayoutAttributeNotAnAttribute:   return @NO;
    }
}

- (void)setObject:(NSNumber *)object atIndexedSubscript:(NSLayoutAttribute)idx {
    if (!object) object = @NO;
        switch (idx) {
            case NSLayoutAttributeBaseline:
            case NSLayoutAttributeBottom:           _bits[4] = object; break;
            case NSLayoutAttributeTop:              _bits[5] = object; break;
            case NSLayoutAttributeLeft:
            case NSLayoutAttributeLeading:          _bits[7] = object; break;
            case NSLayoutAttributeRight:
            case NSLayoutAttributeTrailing:         _bits[6] = object; break;
            case NSLayoutAttributeCenterX:          _bits[3] = object; break;
            case NSLayoutAttributeCenterY:          _bits[2] = object; break;
            case NSLayoutAttributeWidth:            _bits[1] = object; break;
            case NSLayoutAttributeHeight:           _bits[0] = object; break;
            case NSLayoutAttributeNotAnAttribute:                      break;
        }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Logging
////////////////////////////////////////////////////////////////////////////////

- (NSString *)description {
    NSMutableString * s = [@"" mutableCopy];

    if ([_bits[7] boolValue]) [s appendString:@"L"];
    if ([_bits[6] boolValue]) [s appendString:@"R"];
    if ([_bits[5] boolValue]) [s appendString:@"T"];
    if ([_bits[4] boolValue]) [s appendString:@"B"];
    if ([_bits[3] boolValue]) [s appendString:@"X"];
    if ([_bits[2] boolValue]) [s appendString:@"Y"];
    if ([_bits[1] boolValue]) [s appendString:@"W"];
    if ([_bits[0] boolValue]) [s appendString:@"H"];

    return s;
}

- (NSString *)binaryDescription {
    return [_bits binaryDescription];
}

@end
