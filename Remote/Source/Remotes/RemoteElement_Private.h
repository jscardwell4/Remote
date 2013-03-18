//
// RemoteElement_Private.h
// Remote
//
// Created by Jason Cardwell on 10/20/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "RemoteElement.h"
#import "RELayoutConfiguration.h"
#import "REConstraint.h"

@interface RemoteElement () {
@protected
    uint64_t   _flags;
    uint64_t   _appearance;
    uint64_t   _index;
}

@property (nonatomic, strong, readwrite) REConstraintManager   * constraintManager;
@property (nonatomic, strong)            NSMutableSet          * primitiveConstraints;
@property (nonatomic, strong)            NSMutableSet          * primitiveFirstItemConstraints;
@property (nonatomic, strong)            NSMutableSet          * primitiveSecondItemConstraints;
@property (nonatomic, strong, readwrite) RELayoutConfiguration * layoutConfiguration;

@end

@interface RemoteElement (FlagsAndOptionsPrivate)
@property (nonatomic, assign)    uint64_t               primitiveFlags;
@property (nonatomic, assign)    uint64_t               primitiveAppearance;
@property (nonatomic, readwrite) REType      type;
@property (nonatomic, readwrite) RESubtype   subtype;
@property (nonatomic, readwrite) REState     state;
@end
