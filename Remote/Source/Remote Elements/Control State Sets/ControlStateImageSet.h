//
// ControlStateImageSet.h
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
@import Lumberjack;
@import MoonKit;
#import "MSRemoteMacros.h"
#import "ControlStateSet.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ControlStateImageSet
////////////////////////////////////////////////////////////////////////////////
@class ImageView;

@interface ControlStateImageSet : ControlStateSet

- (ImageView *)objectAtIndexedSubscript:(NSUInteger)state;
- (ImageView *)objectForKeyedSubscript:(NSString *)key;

@end

