//
// ControlStateTitleSet.h
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "ControlStateSet.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ControlStateTitleSet
////////////////////////////////////////////////////////////////////////////////

@class TitleAttributes;

@interface ControlStateTitleSet : ControlStateSet

@property (nonatomic) BOOL suppressNormalStateAttributes;

- (NSAttributedString *)objectAtIndex:(NSUInteger)state;
- (id)objectForKey:(NSString *)key;

- (id)objectForKeyedSubscript:(NSString *)key;
- (NSAttributedString *)objectAtIndexedSubscript:(NSUInteger)state;

@end
