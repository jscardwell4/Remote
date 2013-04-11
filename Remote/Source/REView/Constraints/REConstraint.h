//
// REConstraint.h
// Remote
//
// Created by Jason Cardwell on 1/21/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "MSModelObject.h"
#import "RETypedefs.h"
@class   RemoteElement;
@class   REView;
@class   RELayoutConfiguration;

@interface REConstraint : MSModelObject

@property (nonatomic, assign)           int16_t         tag;
@property (nonatomic, copy)             NSString      * key;
@property (nonatomic, assign, readonly) int16_t         firstAttribute;
@property (nonatomic, assign, readonly) int16_t         secondAttribute;
@property (nonatomic, assign, readonly) int16_t         relation;
@property (nonatomic, assign, readonly) float           multiplier;
@property (nonatomic, assign)           float           constant;
@property (nonatomic, strong, readonly) RemoteElement * firstItem;
@property (nonatomic, strong, readonly) RemoteElement * secondItem;
@property (nonatomic, strong)           RemoteElement * owner;
@property (nonatomic, assign)           float           priority;

@property (nonatomic, weak, readonly)   RELayoutConfiguration * configuration;
@property (nonatomic, readonly, getter = isStaticConstraint) BOOL        staticConstraint;

+ (REConstraint *)constraintWithItem:(RemoteElement *)element1
                                            attribute:(NSLayoutAttribute)attr1
                                            relatedBy:(NSLayoutRelation)relation
                                               toItem:(RemoteElement *)element2
                                            attribute:(NSLayoutAttribute)attr2
                                           multiplier:(CGFloat)multiplier
                                             constant:(CGFloat)c;
+ (REConstraint *)constraintWithAttributeValues:(NSDictionary *)attributes;
- (BOOL)hasAttributeValues:(NSDictionary *)values;

- (NSString *)committedValuesDescription;

@end

MSKIT_EXTERN_STRING   RemoteElementModelConstraintNametag;

/*
 * RELayoutConstraint
 */
@interface RELayoutConstraint:NSLayoutConstraint

@property (nonatomic, strong) REConstraint                     * modelConstraint;
@property (readonly, weak)    REView                           * firstItem;
@property (readonly, weak)    REView                           * secondItem;
@property (nonatomic, weak)   REView                           * owner;
@property (nonatomic, weak, readonly)   NSString               * uuid;
@property (nonatomic, assign, readonly, getter = isValid) BOOL   valid;

/**
 * Constructor for new `RELayoutConstraint` objects.
 *
 * @param modelConstraint Model to be represented by the `RELayoutConstraint`
 *
 * @param view View to which the constraint will be added
 *
 * @return Newly created constraint for the specified view
 */
+ (RELayoutConstraint *)constraintWithModel:(REConstraint *)modelConstraint
                                    forView:(REView *)view;

@end


