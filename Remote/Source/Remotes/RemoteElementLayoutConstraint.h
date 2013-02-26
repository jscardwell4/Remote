//
// RemoteElementLayoutConstraint.h
// iPhonto
//
// Created by Jason Cardwell on 1/21/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
@class   RemoteElement;
@class   RemoteElementView;

@interface RemoteElementLayoutConstraint : NSManagedObject

@property (nonatomic, assign) int16_t                               tag;
@property (nonatomic, copy)   NSString                            * key;
@property (nonatomic, copy)   NSString                            * identifier;
@property (nonatomic, assign) int16_t                               firstAttribute;
@property (nonatomic, assign) int16_t                               secondAttribute;
@property (nonatomic, assign) int16_t                               relation;
@property (nonatomic, assign) float                                 multiplier;
@property (nonatomic, assign) float                                 constant;
@property (nonatomic, strong) RemoteElement                       * firstItem;
@property (nonatomic, strong) RemoteElement                       * secondItem;
@property (nonatomic, strong) RemoteElement                       * owner;
@property (nonatomic, assign) float                                 priority;
@property (nonatomic, readonly, getter = isStaticConstraint) BOOL   staticConstraint;

+ (RemoteElementLayoutConstraint *)constraintWithItem:(RemoteElement *)element1
                                            attribute:(NSLayoutAttribute)attr1
                                            relatedBy:(NSLayoutRelation)relation
                                               toItem:(RemoteElement *)element2
                                            attribute:(NSLayoutAttribute)attr2
                                           multiplier:(CGFloat)multiplier
                                             constant:(CGFloat)c
                                                owner:(RemoteElement *)owner;
- (BOOL)hasAttributeValues:(NSDictionary *)values;

@end
