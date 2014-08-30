//
// RemoteElement_Private.h
// Remote
//
// Created by Jason Cardwell on 10/20/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "RemoteElement.h"

@interface RemoteElement ()

@property (nonatomic, strong, readwrite) ConstraintManager     * constraintManager;
@property (nonatomic, strong, readwrite) NSDictionary          * configurations;
- (void)updateForMode:(NSString *)mode;

@end

@interface RemoteElement (CoreDataGeneratedAccessors)

@property (nonatomic) NSNumber                * primitiveRole;
@property (nonatomic) NSNumber                * primitiveShape;
@property (nonatomic) NSNumber                * primitiveStyle;
@property (nonatomic) NSMutableSet            * primitiveConstraints;
@property (nonatomic) NSMutableSet            * primitiveFirstItemConstraints;
@property (nonatomic) NSMutableSet            * primitiveSecondItemConstraints;
@property (nonatomic) NSMutableOrderedSet     * primitiveSubelements;
@property (nonatomic) NSMutableDictionary     * primitiveConfigurations;
@property (nonatomic) RemoteElement           * primitiveParentElement;
@property (nonatomic) NSString                * primitiveName;
@property (nonatomic) NSString                * primitiveKey;
@property (nonatomic) UIColor                 * primitiveBackgroundColor;
@property (nonatomic) Image                   * primitiveBackgroundImage;
@property (nonatomic) NSNumber                * primitiveBackgroundImageAlpha;

@end

