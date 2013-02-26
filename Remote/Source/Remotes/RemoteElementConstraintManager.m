//
// RemoteElementConstraintManager.m
// iPhonto
//
// Created by Jason Cardwell on 2/9/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "RemoteElementConstraintManager.h"
#import "RemoteElementLayoutConstraint.h"
#import "RemoteElement_Private.h"

@interface RemoteElementConstraintManager ()

@property (nonatomic, weak, readwrite) RemoteElement                      * remoteElement;
@property (nonatomic, strong, readwrite) RemoteElementLayoutConfiguration * layoutConfiguration;
@property (nonatomic, strong, readwrite) NSHashTable                      * dependentChildConstraints;
@property (nonatomic, strong, readwrite) NSHashTable                      * dependentConstraints;
@property (nonatomic, strong, readwrite) NSHashTable                      * subelementConstraints;
@property (nonatomic, strong, readwrite) NSHashTable                      * dependentSiblingConstraints;

@end

@implementation RemoteElementConstraintManager

/**
 * constraintManagerForRemoteElement:
 */
+ (RemoteElementConstraintManager *)constraintManagerForRemoteElement:(RemoteElement *)remoteElement {
    return [[self alloc] initWithRemoteElement:remoteElement];
}

/**
 * initWithRemoteElement:
 */
- (id)initWithRemoteElement:(RemoteElement *)remoteElement {
    if ((self = [super init])) {
        _remoteElement           = remoteElement;
        self.layoutConfiguration = [RemoteElementLayoutConfiguration layoutConfigurationForRemoteElement:_remoteElement];
    }

    return self;
}

/**
 * constraintsAffectingAxis:order:
 */
- (NSSet *)constraintsAffectingAxis:(UILayoutConstraintAxis)axis order:(RELayoutConstraintOrder)order {
    NSMutableSet * constraints = [NSMutableSet set];

    if (!order || order == RELayoutConstraintFirstOrder) {
        [constraints unionSet:[_remoteElement.firstItemConstraints
                               objectsPassingTest:^BOOL (RemoteElementLayoutConstraint * obj, BOOL * stop) {
                return (axis == UILayoutConstraintAxisForAttribute(obj.firstAttribute));
            }]];
    }
    if (!order || order == RELayoutConstraintSecondOrder) {
        [constraints unionSet:[_remoteElement.secondItemConstraints
                               objectsPassingTest:^BOOL (RemoteElementLayoutConstraint * obj, BOOL * stop) {
                return (axis == UILayoutConstraintAxisForAttribute(obj.secondAttribute));
            }]];
    }

    return (constraints.count
            ? constraints
            : nil);
}

/**
 * constraintDidUpdate:
 */
- (void)constraintDidUpdate:(RemoteElementLayoutConstraint *)constraint {
    _remoteElement.needsUpdateConstraints = YES;
    // if (self.managedObjectContext.hasChanges && [[self.managedObjectContext updatedObjects]
    // containsObject:constraint])
    [self processConstraint:constraint];
}

/**
 * subelementConstraints
 */
- (NSHashTable *)subelementConstraints {
    for (id object in _subelementConstraints) {
                assert(object != NULL);
    }
    if (!_subelementConstraints) {
        self.subelementConstraints = [NSHashTable weakObjectsHashTable];
        [_remoteElement.constraints
         enumerateObjectsUsingBlock:^(RemoteElementLayoutConstraint * obj, BOOL * stop) {
             if (obj.firstItem != _remoteElement) [_subelementConstraints addObject:obj];
         }];
    }

    return _subelementConstraints;
}

/**
 * dependentChildConstraints
 */
- (NSHashTable *)dependentChildConstraints {
    for (id object in _dependentChildConstraints) {
                assert(object != NULL);
    }
    if (!_dependentChildConstraints) {
        self.dependentChildConstraints = [NSHashTable weakObjectsHashTable];
        [_subelementConstraints enumerateObjectsUsingBlock:^(RemoteElementLayoutConstraint * obj, BOOL * stop) {
                                    if (obj.secondItem == _remoteElement) [_dependentChildConstraints addObject:obj];
                                }];
    }

    return _dependentChildConstraints;
}

/**
 * dependentConstraints
 */
- (NSHashTable *)dependentConstraints {
    for (id object in _dependentConstraints) {
                assert(object != NULL);
    }

    if (!_dependentConstraints) {
        self.dependentConstraints = [NSHashTable weakObjectsHashTable];
        [_remoteElement.secondItemConstraints
         enumerateObjectsUsingBlock:^(RemoteElementLayoutConstraint * obj, BOOL * stop) {
             if (obj.firstItem != _remoteElement) [_dependentConstraints addObject:obj];
         }

        ];
    }

    return _dependentConstraints;
}

/**
 * dependentSiblingConstraints
 */
- (NSHashTable *)dependentSiblingConstraints {
    for (id object in _dependentSiblingConstraints) {
                assert(object != NULL);
    }
    if (!_dependentSiblingConstraints) {
        self.dependentSiblingConstraints = [NSHashTable weakObjectsHashTable];
        [_remoteElement.secondItemConstraints
         enumerateObjectsUsingBlock:^(RemoteElementLayoutConstraint * obj, BOOL * stop) {
             if (  obj.firstItem != _remoteElement
               && obj.firstItem != _remoteElement.parentElement
               && obj.firstItem.parentElement == _remoteElement.parentElement) [_dependentSiblingConstraints addObject:obj];
         }];
    }

    return _dependentSiblingConstraints;
}

/**
 * removeConstraintFromCache:
 */
- (void)removeConstraintFromCache:(RemoteElementLayoutConstraint *)constraint {
    [_subelementConstraints removeObject:constraint];
    [_dependentChildConstraints removeObject:constraint];
    [_dependentConstraints removeObject:constraint];
    [_dependentSiblingConstraints removeObject:constraint];
}

/**
 * processConstraint:
 */
- (void)processConstraint:(RemoteElementLayoutConstraint *)constraint {
    [self removeConstraintFromCache:constraint];

    // check if this a constraint we own
    if (constraint.owner == _remoteElement) {
        // check that it is not intrinsic
        if (constraint.firstItem != _remoteElement) {
            [_subelementConstraints addObject:constraint];

            // check if it creates a child - parent dependency
            if (constraint.secondItem == _remoteElement) {
                // dependent child constraint
                [_dependentChildConstraints addObject:constraint];
                [_dependentConstraints addObject:constraint];
                [constraint.firstItem processConstraint:constraint];
            } else {
                [constraint.firstItem processConstraint:constraint];
                [constraint.secondItem processConstraint:constraint];
            }
        } else
            [self.layoutConfiguration processConstraint:constraint];
    }
    // check if this is a constraint owned by our parent
    else if (  constraint.owner == _remoteElement.parentElement
            && constraint.secondItem == _remoteElement)
    {
                assert(constraint.firstItem != _remoteElement);
        [_dependentSiblingConstraints addObject:constraint];
        [_dependentConstraints addObject:constraint];
    }
}

/**
 * processConstraints
 */
- (void)processConstraints {
    NSSet * equalityAttributes = [_remoteElement.firstItemConstraints
                                  objectsPassingTest:^BOOL (RemoteElementLayoutConstraint * obj, BOOL * stop) {
        return (obj.relation == NSLayoutRelationEqual);
    }];

    // was a short term assertion?
    // assert(equalityAttributes.count == [[equalityAttributes valueForKeyPath:@"firstAttribute"]
    // count]);

    _remoteElement.proportionLock = NO;
    for (RemoteElementLayoutConstraint * constraint in equalityAttributes) {
        RemoteElementRelationshipType   r = (constraint.secondItem == _remoteElement.parentElement
                                             ? RemoteElementParentRelationship
                                             : (constraint.secondItem == _remoteElement || !constraint.secondItem
                                                ? RemoteElementIntrinsicRelationship
                                                : RemoteElementSiblingRelationship));

        switch (constraint.firstAttribute) {
            case NSLayoutAttributeBaseline :
            case NSLayoutAttributeBottom :
            case NSLayoutAttributeTop :
            case NSLayoutAttributeLeft :
            case NSLayoutAttributeLeading :
            case NSLayoutAttributeRight :
            case NSLayoutAttributeTrailing :
            case NSLayoutAttributeCenterY :
            case NSLayoutAttributeCenterX :
                assert(r != RemoteElementIntrinsicRelationship);
                [_remoteElement setAppearanceBits:alignmentOptionForNSLayoutAttribute(constraint.firstAttribute, r)];
                break;

            case NSLayoutAttributeWidth :
            case NSLayoutAttributeHeight :
                if (constraint.secondItem == _remoteElement) _remoteElement.proportionLock = YES;

                [_remoteElement setAppearanceBits:sizingOptionForNSLayoutAttribute(constraint.firstAttribute, r)];
                break;

            case NSLayoutAttributeNotAnAttribute :
                break;
        }  /* switch */

        [self processConstraint:constraint];
    }
}

/**
 * setConstraintsFromString:
 */
- (void)setConstraintsFromString:(NSString *)constraints {
    if (_remoteElement.constraints.count) {
        [_remoteElement.managedObjectContext
         performBlockAndWait:^{
             [_remoteElement.managedObjectContext
              deleteObjects:_remoteElement.constraints];
             [_remoteElement.managedObjectContext
              save:nil];
         }

        ];
    }

    self.layoutConfiguration = nil;

    NSArray      * elements  = [[_remoteElement.subelements array] arrayByAddingObject:_remoteElement];
    NSDictionary * directory = [NSDictionary dictionaryWithObjects:elements forKeys:[elements valueForKeyPath:@"identifier"]];

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
         if ([@"-" isEqualToString : obj[MSExtendedVisualFormatConstantOperatorName]]) constant = -constant;

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
         if (ValueIsNotNil(obj[MSExtendedVisualFormatPriorityName])) constraint.priority = Float(obj[MSExtendedVisualFormatPriorityName]);
     }];

    [self processConstraints];
}  /* setConstraintsFromString */

/**
 * freezeSizeForSubelement:attribute:
 */
- (void)freezeSize:(CGSize)size
     forSubelement:(RemoteElement *)subelement
         attribute:(NSLayoutAttribute)attribute {
    RemoteElementLayoutConfiguration * config = subelement.layoutConfiguration;

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

                NSManagedObjectContext * ctx         = subelement.managedObjectContext;
                NSSet                  * constraints = [subelement.constraintManager constraintsForAttribute:NSLayoutAttributeBottom order:RELayoutConstraintFirstOrder];

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

                NSManagedObjectContext * ctx         = subelement.managedObjectContext;
                NSSet                  * constraints = [subelement.constraintManager constraintsForAttribute:NSLayoutAttributeRight order:RELayoutConstraintFirstOrder];

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

                NSManagedObjectContext * ctx         = subelement.managedObjectContext;
                NSSet                  * constraints = [subelement.constraintManager constraintsForAttribute:NSLayoutAttributeLeft order:RELayoutConstraintFirstOrder];

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
            if ([config[NSLayoutAttributeRight] boolValue] || [config[NSLayoutAttributeLeft] boolValue]) {
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
            if ([config[NSLayoutAttributeTop] boolValue] || [config[NSLayoutAttributeBottom] boolValue]) {
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
    } /* switch */
}     /* freezeSizeForSubelement */

////////////////////////////////////////////////////////////////////////////////
#pragma mark Manipulation Helper Methods
////////////////////////////////////////////////////////////////////////////////

/**
 * replacementCandidatesForAddingAttribute:additions:
 */
- (NSArray *)replacementCandidatesForAddingAttribute:(NSLayoutAttribute)attribute
                                           additions:(NSArray **)additions {
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
    } /* switch */
}     /* replacementCandidatesForAddingAttribute */

/**
 * constraintsForAttribute:
 */
- (NSSet *)constraintsForAttribute:(NSLayoutAttribute)attribute {
    return [self constraintsForAttribute:attribute
                                   order:RELayoutConstraintUnspecifiedOrder];
}

/**
 * constraintsForAttribute:order:
 */
- (NSSet *)constraintsForAttribute:(NSLayoutAttribute)attribute order:(RELayoutConstraintOrder)order {
    if (!_layoutConfiguration[[NSLayoutConstraint pseudoNameForAttribute:attribute]]) return nil;

    NSMutableSet * constraints = [NSMutableSet set];

    if (!order || order == RELayoutConstraintFirstOrder) {
        [constraints unionSet:[_remoteElement.firstItemConstraints
                               objectsPassingTest:^BOOL (RemoteElementLayoutConstraint * obj, BOOL * stop) {
                return (obj.firstAttribute == attribute);
            }]];
    }
    if (!order || order == RELayoutConstraintSecondOrder) {
        [constraints unionSet:[_remoteElement.secondItemConstraints
                               objectsPassingTest:^BOOL (RemoteElementLayoutConstraint * obj, BOOL * stop) {
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
    if ([horizontalAxisAttributes containsObject:@(attribute)]) return UILayoutConstraintAxisHorizontal;
    else if ([verticalAxisAttributes containsObject:@(attribute)]) return UILayoutConstraintAxisVertical;
    else return -1;
}

@implementation RemoteElementLayoutConfiguration {
    MSBitVector          * _bits;
    __weak RemoteElement * _element;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Initializers
////////////////////////////////////////////////////////////////////////////////

/**
 * layoutConfigurationForRemoteElement:
 */
+ (RemoteElementLayoutConfiguration *)layoutConfigurationForRemoteElement:(RemoteElement *)element {
    RemoteElementLayoutConfiguration * config = [[RemoteElementLayoutConfiguration alloc]initWithElement:element];

    config->_element = element;

    return config;
}

/**
 * initWithElement:
 */
- (id)initWithElement:(RemoteElement *)element {
    if ((self = [super init])) {
        assert(ValueIsNotNil(element));
        _bits    = [MSBitVector bitVectorWithSize:MSBitVectorSize8];
        _element = element;

        NSSet * constraints = [NSSet setWithSet:[_element valueForKey:@"firstItemConstraints"]];

        if (constraints && constraints.count)
            for (RemoteElementLayoutConstraint * constraint in _element.firstItemConstraints) {
                [self processConstraint:constraint];
            }
    }

    return self;
}

/**
 * copyWithZone:
 */
- (RemoteElementLayoutConfiguration *)copyWithZone:(NSZone *)zone {
    RemoteElementLayoutConfiguration * config = [RemoteElementLayoutConfiguration layoutConfigurationForRemoteElement:_element];
    uint8_t                            bits   = (uint8_t)[_bits.bits unsignedIntegerValue];

    config->_bits = [MSBitVector bitVectorWithBytes:&bits];

    return config;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Syntax Support
////////////////////////////////////////////////////////////////////////////////

/**
 * objectForKeyedSubscript:
 */
- (NSNumber *)objectForKeyedSubscript:(NSString *)key {
    switch ([NSLayoutConstraint attributeForPseudoName:key]) {
        case NSLayoutAttributeBaseline :
        case NSLayoutAttributeBottom :           return _bits[4];
        case NSLayoutAttributeTop :              return _bits[5];
        case NSLayoutAttributeLeft :
        case NSLayoutAttributeLeading :          return _bits[7];
        case NSLayoutAttributeRight :
        case NSLayoutAttributeTrailing :         return _bits[6];
        case NSLayoutAttributeCenterX :          return _bits[3];
        case NSLayoutAttributeCenterY :          return _bits[2];
        case NSLayoutAttributeWidth :            return _bits[1];
        case NSLayoutAttributeHeight :           return _bits[0];
        case NSLayoutAttributeNotAnAttribute :   return @NO;
    }  /* switch */
}

/**
 * setObject:forKeyedSubscript:
 */
- (void)setObject:(NSNumber *)object forKeyedSubscript:(NSString *)key {
    if (!object) object = @NO;
    switch ([NSLayoutConstraint attributeForPseudoName:key]) {
        case NSLayoutAttributeBaseline :
        case NSLayoutAttributeBottom :            _bits[4] = object; break;
        case NSLayoutAttributeTop :               _bits[5] = object; break;
        case NSLayoutAttributeLeft :
        case NSLayoutAttributeLeading :           _bits[7] = object; break;
        case NSLayoutAttributeRight :
        case NSLayoutAttributeTrailing :          _bits[6] = object; break;
        case NSLayoutAttributeCenterX :           _bits[3] = object; break;
        case NSLayoutAttributeCenterY :           _bits[2] = object; break;
        case NSLayoutAttributeWidth :             _bits[1] = object; break;
        case NSLayoutAttributeHeight :            _bits[0] = object; break;
        case NSLayoutAttributeNotAnAttribute :                       break;
    }  /* switch */
}

/**
 * objectAtIndexedSubscript:
 */
- (NSNumber *)objectAtIndexedSubscript:(NSLayoutAttribute)idx {
    switch (idx) {
        case NSLayoutAttributeBaseline :
        case NSLayoutAttributeBottom :           return _bits[4];
        case NSLayoutAttributeTop :              return _bits[5];
        case NSLayoutAttributeLeft :
        case NSLayoutAttributeLeading :          return _bits[7];
        case NSLayoutAttributeRight :
        case NSLayoutAttributeTrailing :         return _bits[6];
        case NSLayoutAttributeCenterX :          return _bits[3];
        case NSLayoutAttributeCenterY :          return _bits[2];
        case NSLayoutAttributeWidth :            return _bits[1];
        case NSLayoutAttributeHeight :           return _bits[0];
        case NSLayoutAttributeNotAnAttribute :   return @NO;
    }  /* switch */
}

/**
 * setObject:atIndexedSubscript:
 */
- (void)setObject:(NSNumber *)object atIndexedSubscript:(NSLayoutAttribute)idx {
    if (!object) object = @NO;
    switch (idx) {
        case NSLayoutAttributeBaseline :
        case NSLayoutAttributeBottom :           _bits[4] = object; break;
        case NSLayoutAttributeTop :              _bits[5] = object; break;
        case NSLayoutAttributeLeft :
        case NSLayoutAttributeLeading :          _bits[7] = object; break;
        case NSLayoutAttributeRight :
        case NSLayoutAttributeTrailing :         _bits[6] = object; break;
        case NSLayoutAttributeCenterX :          _bits[3] = object; break;
        case NSLayoutAttributeCenterY :          _bits[2] = object; break;
        case NSLayoutAttributeWidth :            _bits[1] = object; break;
        case NSLayoutAttributeHeight :           _bits[0] = object; break;
        case NSLayoutAttributeNotAnAttribute :                      break;
    }  /* switch */
}

/**
 * processConstraint:
 */
- (void)processConstraint:(RemoteElementLayoutConstraint *)constraint {
    if (constraint.firstItem == _element && constraint.relation == NSLayoutRelationEqual) self[[NSLayoutConstraint pseudoNameForAttribute:constraint.firstAttribute]] = @YES;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Logging
////////////////////////////////////////////////////////////////////////////////

/**
 * description
 */
- (NSString *)description {
    NSMutableString * s = [@"layout configuration: " mutableCopy];

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

/**
 * binaryDescription
 */
- (NSString *)binaryDescription {
    return [_bits binaryDescription];
}

@end
