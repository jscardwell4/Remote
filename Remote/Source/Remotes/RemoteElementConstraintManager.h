//
// RemoteElementConstraintManager.h
// iPhonto
//
// Created by Jason Cardwell on 2/9/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "RemoteElementLayoutConstraint.h"


RELayoutConstraintAffiliation
remoteElementAffiliationWithConstraint(RemoteElement                 * element,
                                       RemoteElementLayoutConstraint * constraint);

NSString *NSStringFromRELayoutConstraintAffiliation(RELayoutConstraintAffiliation affiliation);
#define RELayoutConstraintAffiliationString(v) NSStringFromRELayoutConstraintAffiliation(v)

typedef NS_ENUM (uint8_t, RERelationshipType){
    REUnspecifiedRelation   = 0,
    REParentRelationship    = 1,
    REChildRelationship     = 2,
    RESiblingRelationship   = 3,
    REIntrinsicRelationship = 4
};

RERelationshipType
remoteElementRelationshipTypeForConstraint(RemoteElement                 * element,
                                           RemoteElementLayoutConstraint * constraint);

NSString *NSStringFromRERelationshipType(RERelationshipType relationship);
#define RERelationshipTypeString(v) NSStringFromRERelationshipType(v)

/// RELayoutAxisDimension
typedef NS_ENUM (uint8_t, RELayoutAxisDimension){
    RELayoutXAxis           = 0,
    RELayoutYAxis           = 1,
    RELayoutWidthDimension  = 2,
    RELayoutHeightDimension = 3
};

/// RELayoutAttribute
typedef NS_ENUM (uint8_t, RELayoutAttribute){
    RELayoutAttributeHeight  = 1 << 0,
    RELayoutAttributeWidth   = 1 << 1,
    RELayoutAttributeCenterY = 1 << 2,
    RELayoutAttributeCenterX = 1 << 3,
    RELayoutAttributeBottom  = 1 << 4,
    RELayoutAttributeTop     = 1 << 5,
    RELayoutAttributeRight   = 1 << 6,
    RELayoutAttributeLeft    = 1 << 7
};

///
UILayoutConstraintAxis UILayoutConstraintAxisForAttribute(NSLayoutAttribute attribute);

MSKIT_EXTERN_STRING   REConstraintsDidChangeNotification;

@class   RemoteElement, RemoteElementLayoutConstraint;

/*
 * RemoteElementConstraintManager
 */
@interface RemoteElementConstraintManager:NSObject

@property (nonatomic, weak,   readonly) RemoteElement * remoteElement;

@property (nonatomic, assign, getter = shouldShrinkWrap) BOOL   shrinkWrap;

/**
 * Creates a new `RemoteElementConstraintManager` to manage `RemoteElementLayoutConstraint` objects
 * for the specified `RemoteElement`.
 *
 * @param remoteElement The element whose constraints need managing
 *
 * @return A fresh manager for the `element`
 */
+ (RemoteElementConstraintManager *)constraintManagerForRemoteElement:(RemoteElement *)remoteElement;

/**
 * Creates and adds new `RemoteElementLayoutConstraint` objects for the managed element.
 *
 * @param constraints Extended visual format string from which the constraints should be parsed.
 */
- (void)setConstraintsFromString:(NSString *)constraints;

- (void)freezeSize:(CGSize)size
     forSubelement:(RemoteElement *)subelement
         attribute:(NSLayoutAttribute)attribute;

/**
 * Modifies constraints such that any sibling co-dependencies are converted to parent-dependencies.
 * To be frozen, the `firstAttribute` of a constraint must be included in the set of `attributes`.
 *
 * @param constraints Constraints to freeze
 *
 * @param attributes `NSSet` of `NSLayoutAttributes` used to filter whether a constraint is frozen
 *
 * @param metrics Dictionary of element frames keyed by their `identifier` property
 */
- (void)freezeConstraints:(NSSet *)constraints
            forAttributes:(NSSet *)attributes
                  metrics:(NSDictionary *)metrics;

- (void)resizeSubelements:(NSSet *)subelements
                toSibling:(RemoteElement *)sibling
                attribute:(NSLayoutAttribute)attribute
                  metrics:(NSDictionary *)metrics;

- (void)resizeElement:(RemoteElement *)element
             fromSize:(CGSize)currentSize
               toSize:(CGSize)newSize
              metrics:(NSDictionary *)metrics;

- (void)alignSubelements:(NSSet *)subelements
               toSibling:(RemoteElement *)sibling
               attribute:(NSLayoutAttribute)attribute
                 metrics:(NSDictionary *)metrics;

- (void)shrinkWrapSubelements:(NSDictionary *)metrics;

/**
 * Translates the specified subelements by the specified amount.
 *
 * @param subelements s to be translated
 *
 * @param translation Amount by which s will be translated
 *
 * @param metrics Dictionary of element frames keyed by their `identifier` property
 */
- (void)translateSubelements:(NSSet *)subelements
                 translation:(CGPoint)translation
                     metrics:(NSDictionary *)metrics;

- (void)removeMultipliers:(NSDictionary *)metrics;

/**
 * Modifies the constraints of an element such that width and height are not co-dependent.
 *
 * @param element The element whose constraints should be altered
 *
 * @param currentSize The size to use when calculating static width and height
 */
- (void)removeProportionLockForElement:(RemoteElement *)element currentSize:(CGSize)currentSize;

/**
 * Modifies `remoteElement` constraints to avoid unsatisfiable conditions when adding the
 * specified constraint.
 *
 * @param constraint `RemoteElementLayoutConstraint` whose addition may require conflict resolution
 *
 * @param metrics Dictionary of element frames keyed by their `identifier` property
 */
- (void)resolveConflictsForConstraint:(RemoteElementLayoutConstraint *)constraint
                              metrics:(NSDictionary *)metrics;

@end
