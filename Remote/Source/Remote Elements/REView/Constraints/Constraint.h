//
// Constraint.h
// Remote
//
// Created by Jason Cardwell on 1/21/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "ModelObject.h"
#import "RETypedefs.h"
@class   RemoteElement;
@class   RemoteElementView;
@class   ConstraintManager;

@interface Constraint : ModelObject

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

@property (nonatomic, weak, readonly)   ConstraintManager * manager;
@property (nonatomic, readonly, getter = isStaticConstraint) BOOL        staticConstraint;

+ (Constraint *)constraintWithItem:(RemoteElement *)element1
                                            attribute:(NSLayoutAttribute)attr1
                                            relatedBy:(NSLayoutRelation)relation
                                               toItem:(RemoteElement *)element2
                                            attribute:(NSLayoutAttribute)attr2
                                           multiplier:(CGFloat)multiplier
                                             constant:(CGFloat)c;
+ (Constraint *)constraintWithAttributeValues:(NSDictionary *)attributes;
- (BOOL)hasAttributeValues:(NSDictionary *)values;

- (NSString *)committedValuesDescription;

@end

MSEXTERN_STRING   RemoteElementModelConstraintNametag;


