//
// RemoteElement_Private.h
// iPhonto
//
// Created by Jason Cardwell on 10/20/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "RemoteElement.h"

@class   RemoteElementLayoutConstraint;

@interface RemoteElement () {
    @protected
    uint64_t   _flags;
    uint64_t   _appearance;
    uint64_t   _index;
}
@property (nonatomic, strong) RemoteElementConstraintManager * constraintManager;
@property (nonatomic, strong) NSMutableSet                   * primitiveConstraints;
@property (nonatomic, strong) NSMutableSet                   * primitiveFirstItemConstraints;
@property (nonatomic, strong) NSMutableSet                   * primitiveSecondItemConstraints;
// @property (nonatomic, strong, readwrite) RemoteElementLayoutConfiguration *layoutConfiguration;
// @property (nonatomic, strong, readwrite) NSHashTable *dependentChildConstraints;
// @property (nonatomic, strong, readwrite) NSHashTable *dependentConstraints;
// @property (nonatomic, strong, readwrite) NSHashTable *subelementConstraints;
// @property (nonatomic, strong, readwrite) NSHashTable *dependentSiblingConstraints;

// - (void)constraintDidUpdate:(RemoteElementLayoutConstraint *)constraint;
//
// - (void)removeConstraintFromCache:(RemoteElementLayoutConstraint *)constraint;

@end

@interface RemoteElement (FlagsAndOptionsPrivate)
@property (nonatomic, assign) uint64_t                  primitiveFlags;
@property (nonatomic, assign) uint64_t                  primitiveAppearance;
@property (nonatomic, readwrite) RemoteElementType      type;
@property (nonatomic, readwrite) RemoteElementSubtype   subtype;
@property (nonatomic, readwrite) RemoteElementState     state;
@end
