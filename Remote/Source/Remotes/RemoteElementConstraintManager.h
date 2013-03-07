//
// RemoteElementConstraintManager.h
// iPhonto
//
// Created by Jason Cardwell on 2/9/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "RemoteElementLayoutConstraint.h"

typedef NS_ENUM (NSUInteger, RELayoutConstraintOrder){
    RELayoutConstraintUnspecifiedOrder = 0,
    RELayoutConstraintFirstOrder       = 1,
    RELayoutConstraintSecondOrder      = 2
};

typedef NS_OPTIONS (NSUInteger, RELayoutConstraintAffiliation){
    RELayoutConstraintUnspecifiedAffiliation    = 0,
    RELayoutConstraintFirstItemAffiliation      = 1 << 0,
        RELayoutConstraintSecondItemAffiliation = 1 << 1,
        RELayoutConstraintOwnerAffiliation      = 1 << 2
};

RELayoutConstraintAffiliation
remoteElementAffiliationWithConstraint(RemoteElement                 * element,
                                       RemoteElementLayoutConstraint * constraint);

NSString *NSStringFromRELayoutConstraintAffiliation(RELayoutConstraintAffiliation affiliation);

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

@class   RemoteElement, RemoteElementLayoutConstraint, RemoteElementLayoutConfiguration;

/*
 * RemoteElementConstraintManager
 */
@interface RemoteElementConstraintManager:NSObject

@property (nonatomic, weak, readonly) RemoteElement                      * remoteElement;
@property (nonatomic, strong, readonly) RemoteElementLayoutConfiguration * layoutConfiguration;
@property (nonatomic, strong, readonly) NSSet                            * subelementConstraints;
@property (nonatomic, strong, readonly) NSSet                            * dependentConstraints;
@property (nonatomic, strong, readonly) NSSet                            * dependentChildConstraints;
@property (nonatomic, strong, readonly) NSSet                            * dependentSiblingConstraints;
@property (nonatomic, strong, readonly) NSSet                            * intrinsicConstraints;

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
 * This method can be used to retrieve the set of constraints attached to the managed
 *`RemoteElement` for the specified axis.
 *
 * @param axis `UILayoutConstraintAxisHorizontal` for constraints whose first attribute is left,
 * right, center x, or width, `UILayoutConstraintAxisVertical` for constraints whose first attribute
 * is top, bottom, center y or height
 *
 * @param order `RELayoutConstraintFirstOrder` to include only constraints for which the managed
 * element is the `firstItem`, `RELayoutConstraintSecondOrder` to include only constraints for which
 * the managed element is the `secondItem`. `RELayoutConstraintUnspecifiedOrder` to include
 * constraints for which the element is either the `firstItem` or the `secondItem`
 *
 * @return The set of constraints that match the specifications provided.
 */
- (NSSet *)constraintsAffectingAxis:(UILayoutConstraintAxis)axis
                              order:(RELayoutConstraintOrder)order;

- (RemoteElementLayoutConstraint *)constraintWithAttributes:(NSDictionary *)attributes;

/**
 * Called to notify the constraint manager that one of the managed element's constraints has been
 *updated.
 *
 * @param constraint The constraint that has been updated
 */
- (void)didUpdateConstraint:(RemoteElementLayoutConstraint *)constraint;

/**
 * Called to notify the constraint manager that a new constraint has been added to the managed
 * element.
 *
 * @param constraint The constraint that has been added
 */
- (void)didAddConstraint:(RemoteElementLayoutConstraint *)constraint;

/**
 * Called to notify the constraint manager that one of the managed element's constraints has been
 * removed.
 *
 * @param constraint The constraint that has been removed
 */
- (void)didRemoveConstraint:(RemoteElementLayoutConstraint *)constraint;

/**
 * Called during initialization to parse existing constraints from the persistent store.
 */
- (void)processOwnedConstraints;

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

- (void)resizeSubelements:(NSSet *)subelementViews
                toSibling:(RemoteElement *)siblingView
                attribute:(NSLayoutAttribute)attribute
                  metrics:(NSDictionary *)metrics;

- (void)alignSubelements:(NSSet *)subelementViews
               toSibling:(RemoteElement *)siblingView
               attribute:(NSLayoutAttribute)attribute
                 metrics:(NSDictionary *)metrics;

- (void)resizeElement:(RemoteElement *)element
             fromSize:(CGSize)currentSize
               toSize:(CGSize)newSize
              metrics:(NSDictionary *)metrics;

/**
 * Translates the specified subelements by the specified amount.
 *
 * @param subelementViews Views to be translated
 *
 * @param translation Amount by which views will be translated
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
 * Modifies `remoteElementView` constraints to avoid unsatisfiable conditions when adding the
 * specified constraint.
 *
 * @param constraint `RemoteElementLayoutConstraint` whose addition may require conflict resolution
 *
 * @param metrics Dictionary of element frames keyed by their `identifier` property
 */
- (void)resolveConflictsForConstraint:(RemoteElementLayoutConstraint *)constraint
                              metrics:(NSDictionary *)metrics;
/**
 * This method returns an array of attributes that should be replaced to preserve the specified
 * attribute without conflict. On return, `NSArray` passed as `additions` parameter will hold any
 * attributes that should be added to support the removal of the replacement candidates returned
 * from the method.
 *
 * @param attribute The attribute to keep, usually the attribute of a newly added constraint
 *
 * @param additions Array in which any additional attributes that should be added will be placed
 *
 * @return The array of replacement candidates
 */
- (NSArray *)replacementCandidatesForAddingAttribute:(NSLayoutAttribute)attribute
                                           additions:(NSArray **)additions;

/**
 * Convenience method that calls `constraintsForAttribute:order:` with
 *`RELayoutConstraintUnspecifiedOrder`.
 *
 * @param attribute Attribute for which any constraints held by the managed element should be
 * returned
 *
 * @return The set of constraints for the specified attribute
 */
- (NSSet *)constraintsForAttribute:(NSLayoutAttribute)attribute;

/**
 * This method will return any constraints on the managed element for the specified `attribute`.
 * Results returned may be filtered by passing the desired `RELayoutConstraintOrder`.
 *
 * @param attribute Attribute for which any constraints held by the managed element should be
 * returned
 *
 * @param order `RELayoutConstraintUnspecifiedOrder` any constraints of the specified attribute in
 * which the managed element participates, `RELayoutConstraintFirstOrder` to return only constraints
 * in which the managed element is the `firstItem`, and `RELayoutConstraintSecondOrder` to return
 * only constraints in which the managed element is the `secondItem`
 *
 * @return The set of constraints for the specified attribute
 */
- (NSSet *)constraintsForAttribute:(NSLayoutAttribute)attribute order:(RELayoutConstraintOrder)order;

@end

@class   RemoteElementLayoutConstraint;

/*
 * RemoteElementLayoutConfiguration
 */
@interface RemoteElementLayoutConfiguration:NSObject <NSCopying>

/**
 * Default method for creating a new `RemoteElementLayoutConfiguration` object.
 *
 * @param element The element for whose configuration is being represented
 *
 * @return The newly created configuration object
 */
+ (RemoteElementLayoutConfiguration *)layoutConfigurationForElement:(RemoteElement *)element;

/**
 * Gives the configuration in binary format, i.e. "1100 0011" would be returned for a configuration
 * of "LRWH"
 *
 * @return The string with the binary description
 */
- (NSString *)binaryDescription;

- (void)refreshConfig;

/**
 * Setter implementation for supporting dictionary-style literal syntax
 *
 * @param object Number holding the bool value to use
 *
 * @param key Attribute "pseudo" name. Acceptable values are left, right, top, bottom, centerX,
 * centerY, width, and height
 *
 */
- (void)setObject:(NSNumber *)object forKeyedSubscript:(NSString *)key;

/**
 * Getter implementation for supporting dictionary-style literal syntax
 *
 * @param key Attribute "pseudo" name. Acceptable values are left, right, top, bottom, centerX,
 * centerY, width, and height
 *
 * @return Number holding the bool value for the specified attribute
 *
 */
- (NSNumber *)objectForKeyedSubscript:(NSString *)key;

/**
 * Getter implementation for supporting array-style literal syntax
 *
 * @param idx The attribute to retrieve
 *
 * @return Number holding the bool value for the specified attribute
 *
 */
- (NSNumber *)objectAtIndexedSubscript:(NSLayoutAttribute)idx;

/**
 * Setter implementation for supporting array-style literal syntax
 *
 * @param object Number holding the bool value to use
 *
 * @param idx The attribute to set
 *
 */
- (void)setObject:(NSNumber *)object atIndexedSubscript:(NSLayoutAttribute)idx;

@end
