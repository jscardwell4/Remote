//
// ControlStateColorSet.h
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "ControlStateSet.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ControlStateColorSet
////////////////////////////////////////////////////////////////////////////////
@class Button, ControlStateImageSet;

@interface ControlStateColorSet : ControlStateSet

- (UIColor *)objectAtIndexedSubscript:(NSUInteger)state;
@property (nonatomic, strong) Button * button;
@property (nonatomic, strong) ControlStateImageSet * imageSet;

@end
