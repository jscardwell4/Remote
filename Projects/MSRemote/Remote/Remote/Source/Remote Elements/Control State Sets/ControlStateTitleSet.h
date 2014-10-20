//
// ControlStateTitleSet.h
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
@import CocoaLumberjack;
@import MoonKit;
#import "MSRemoteMacros.h"
#import "ControlStateSet.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ControlStateTitleSet
////////////////////////////////////////////////////////////////////////////////

@class TitleAttributes;

@interface ControlStateTitleSet : ControlStateSet

//@property (nonatomic) BOOL suppressNormalStateAttributes;

- (void)setObject:(TitleAttributes *)obj atIndexedSubscript:(NSUInteger)state;
- (void)setObject:(TitleAttributes *)obj forKeyedSubscript:(NSString *)key;

- (TitleAttributes *)objectForKeyedSubscript:(NSString *)key;
- (NSAttributedString *)objectAtIndexedSubscript:(NSUInteger)state;

@end
