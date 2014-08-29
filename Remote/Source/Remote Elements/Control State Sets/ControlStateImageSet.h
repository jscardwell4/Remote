//
// ControlStateImageSet.h
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "ControlStateSet.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ControlStateImageSet
////////////////////////////////////////////////////////////////////////////////
@class ImageView;

@interface ControlStateImageSet : ControlStateSet

- (ImageView *)objectAtIndexedSubscript:(NSUInteger)state;
- (ImageView *)objectForKeyedSubscript:(NSString *)key;

@end

