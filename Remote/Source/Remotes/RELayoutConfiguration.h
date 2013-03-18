//
//  RemoteElementLayoutConfiguration.h
//  Remote
//
//  Created by Jason Cardwell on 3/7/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "REConstraint.h"
#import "REConstraintManager.h"

typedef NS_ENUM(uint8_t, RELayoutConfigurationDependencyType) {
    RELayoutConfigurationUnspecifiedDependency = REUnspecifiedRelation,
    RELayoutConfigurationParentDependency 	   = REChildRelationship,
    RELayoutConfigurationSiblingDependency 	   = RESiblingRelationship,
    RELayoutConfigurationIntrinsicDependency   = REIntrinsicRelationship
};

@class RemoteElement;

@interface RELayoutConfiguration : NSManagedObject

@property (nonatomic, strong, readonly) RemoteElement  *element;
@property (nonatomic, assign, readonly) BOOL            proportionLock;
@property (nonatomic, strong, readonly) NSSet         * subelementConstraints;
@property (nonatomic, strong, readonly) NSSet         * dependentConstraints;
@property (nonatomic, strong, readonly) NSSet         * dependentChildConstraints;
@property (nonatomic, strong, readonly) NSSet         * dependentSiblingConstraints;
@property (nonatomic, strong, readonly) NSSet         * intrinsicConstraints;


/**
 * Default method for creating a new `RemoteElementLayoutConfiguration` object.
 *
 * @param element The element for whose configuration is being represented
 *
 * @return The newly created configuration object
 */
+ (RELayoutConfiguration *)layoutConfigurationForElement:(RemoteElement *)element;

/**
 * Gives the configuration in binary format, i.e. "1100 0011" would be returned for a configuration
 * of "LRWH"
 *
 * @return The string with the binary description
 */
- (NSString *)binaryDescription;

/**
 * Cause the configuration to refresh itself from the element's current constraints.
 */
- (void)refreshConfig;

- (RELayoutConfigurationDependencyType)dependencyTypeForAttribute:(NSLayoutAttribute)attribute;

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
- (NSSet *)constraintsForAttribute:(NSLayoutAttribute)attribute
                             order:(RELayoutConstraintOrder)order;

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

- (REConstraint *)constraintWithValues:(NSDictionary *)attributes;

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
