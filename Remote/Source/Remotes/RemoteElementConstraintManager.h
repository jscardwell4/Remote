//
// RemoteElementConstraintManager.h
// iPhonto
//
// Created by Jason Cardwell on 2/9/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

/// RELayoutConstraintOrder
typedef NS_ENUM (NSUInteger, RELayoutConstraintOrder) {
    RELayoutConstraintUnspecifiedOrder = 0,
    RELayoutConstraintFirstOrder       = 1,
    RELayoutConstraintSecondOrder      = 2
};

/// RemoteElementLayoutAxisDimension
typedef NS_ENUM (uint8_t, RemoteElementLayoutAxisDimension) {
    RemoteElementLayoutXAxis,
    RemoteElementLayoutYAxis,
    RemoteElementLayoutWidthDimension,
    RemoteElementLayoutHeightDimension
};

/// RemoteElementLayoutAttribute
typedef NS_ENUM (uint8_t, RemoteElementLayoutAttribute) {
    RemoteElementLayoutAttributeHeight      = 1 << 0,
        RemoteElementLayoutAttributeWidth   = 1 << 1,
        RemoteElementLayoutAttributeCenterY = 1 << 2,
        RemoteElementLayoutAttributeCenterX = 1 << 3,
        RemoteElementLayoutAttributeBottom  = 1 << 4,
        RemoteElementLayoutAttributeTop     = 1 << 5,
        RemoteElementLayoutAttributeRight   = 1 << 6,
        RemoteElementLayoutAttributeLeft    = 1 << 7
};

///
UILayoutConstraintAxis UILayoutConstraintAxisForAttribute(NSLayoutAttribute attribute);

@class   RemoteElement, RemoteElementLayoutConstraint, RemoteElementLayoutConfiguration;

/**
 * RemoteElementConstraintManager
 */
@interface RemoteElementConstraintManager : NSObject

///
@property (nonatomic, weak, readonly) RemoteElement * remoteElement;

///
@property (nonatomic, strong, readonly) RemoteElementLayoutConfiguration * layoutConfiguration;

///
@property (nonatomic, strong, readonly) NSHashTable * subelementConstraints;

///
@property (nonatomic, strong, readonly) NSHashTable * dependentConstraints;

///
@property (nonatomic, strong, readonly) NSHashTable * dependentChildConstraints;

///
@property (nonatomic, strong, readonly) NSHashTable * dependentSiblingConstraints;

/**
 * <#constraintManagerForRemoteElement:#>
 * @param remoteElement <#description#>
 * @return <#RemoteElementConstraintManager *#>
 */
+ (RemoteElementConstraintManager *)constraintManagerForRemoteElement:(RemoteElement *)remoteElement;

/**
 * <#constraintsAffectingAxis:order:#>
 * @param axis <#description#>
 * @param order <#description#>
 * @return <#NSSet *#>
 */
- (NSSet *)constraintsAffectingAxis:(UILayoutConstraintAxis)axis
                              order:(RELayoutConstraintOrder)order;

/**
 * <#constraintDidUpdate:#>
 * @param constraint <#description#>
 */
- (void)constraintDidUpdate:(RemoteElementLayoutConstraint *)constraint;

/**
 * <#removeConstraintFromCache:#>
 * @param constraint <#description#>
 */
- (void)removeConstraintFromCache:(RemoteElementLayoutConstraint *)constraint;

/**
 * <#processConstraint:#>
 * @param constraint <#description#>
 */
- (void)processConstraint:(RemoteElementLayoutConstraint *)constraint;

/**
 * <#processConstraints#>
 */
- (void)processConstraints;

/**
 * <#setConstraintsFromString:#>
 * @param constraints <#description#>
 */
- (void)setConstraintsFromString:(NSString *)constraints;

/**
 * <#freezeSize:forSubelement:attribute:#>
 * @param size <#description#>
 * @param subelement <#description#>
 * @param attribute <#description#>
 */
- (void)freezeSize:(CGSize)size
     forSubelement:(RemoteElement *)subelement
         attribute:(NSLayoutAttribute)attribute;

/**
 * <#replacementCandidatesForAddingAttribute:additions:#>
 * @param attribute <#description#>
 * @param additions <#description#>
 * @return <#NSArray *#>
 */
- (NSArray *)replacementCandidatesForAddingAttribute:(NSLayoutAttribute)attribute
                                           additions:(NSArray **)additions;

/**
 * <#constraintsForAttribute:#>
 * @param attribute <#description#>
 * @return <#NSSet *#>
 */
- (NSSet *)constraintsForAttribute:(NSLayoutAttribute)attribute;

/**
 * <#constraintsForAttribute:order:#>
 * @param attribute <#description#>
 * @param order <#description#>
 * @return <#NSSet *#>
 */
- (NSSet *)constraintsForAttribute:(NSLayoutAttribute)attribute order:(RELayoutConstraintOrder)order;

@end

@class   RemoteElementLayoutConstraint;

/**
 * RemoteElementLayoutConfiguration
 */
@interface RemoteElementLayoutConfiguration : NSObject <NSCopying>

/**
 * <#layoutConfigurationForRemoteElement:#>
 * @param element <#description#>
 * @return <#RemoteElementLayoutConfiguration *#>
 */
+ (RemoteElementLayoutConfiguration *)layoutConfigurationForRemoteElement:(RemoteElement *)element;

/**
 * <#binaryDescription#>
 * @return <#NSString *#>
 */
- (NSString *)binaryDescription;

/**
 * <#processConstraint:#>
 * @param constraint <#description#>
 */
- (void)processConstraint:(RemoteElementLayoutConstraint *)constraint;

/**
 * <#setObject:forKeyedSubscript:#>
 * @param object <#description#>
 * @param key <#description#>
 */
- (void)setObject:(NSNumber *)object forKeyedSubscript:(NSString *)key;

/**
 * <#objectForKeyedSubscript:#>
 * @param key <#description#>
 * @return <#NSNumber *#>
 */
- (NSNumber *)objectForKeyedSubscript:(NSString *)key;

/**
 * <#objectAtIndexedSubscript:#>
 * @param idx <#description#>
 * @return <#NSNumber *#>
 */
- (NSNumber *)objectAtIndexedSubscript:(NSLayoutAttribute)idx;

/**
 * <#setObject:atIndexedSubscript:#>
 * @param object <#description#>
 * @param idx <#description#>
 */
- (void)setObject:(NSNumber *)object atIndexedSubscript:(NSLayoutAttribute)idx;

@end
