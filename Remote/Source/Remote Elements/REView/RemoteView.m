//
// RemoteView.m
// Remote
//
// Created by Jason Cardwell on 3/17/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "RemoteElementView_Private.h"

#define NUM_PANELS 13

static int ddLogLevel   = DefaultDDLogLevel;
static int   msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel, msLogContext)

@implementation RemoteView

- (void)setLocked:(BOOL)locked
{
    _locked = locked;
    [self.subelementViews setValuesForKeysWithDictionary:@{@"resizable": @(!_locked),
                                                           @"moveable" : @(!_locked)}];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIView Overrides
////////////////////////////////////////////////////////////////////////////////

- (CGSize)intrinsicContentSize
{
    return [MainScreen bounds].size;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - REView Overrides
////////////////////////////////////////////////////////////////////////////////

- (void)setResizable:(BOOL)resizable {}

- (void)setMoveable:(BOOL)moveable {}

- (BOOL)isResizable { return NO; }

- (BOOL)isMoveable { return NO; }

- (void)setEditingMode:(REEditingMode)mode
{
    [super setEditingMode:mode];

    [self.subelementViews setValue:@(mode) forKeyPath:@"editingMode"];
}

- (void)initializeIVARs
{
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired
                                          forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired
                                          forAxis:UILayoutConstraintAxisVertical];
    [self setContentHuggingPriority:UILayoutPriorityRequired
                            forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentHuggingPriority:UILayoutPriorityRequired
                            forAxis:UILayoutConstraintAxisVertical];
    [super initializeIVARs];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Configurations
////////////////////////////////////////////////////////////////////////////////

- (NSString *)currentMode { return self.model.configurationDelegate.currentMode; }

- (ButtonGroupView *)objectAtIndexedSubscript:(NSUInteger)idx {
    return (ButtonGroupView *)[super objectAtIndexedSubscript:idx];
}

- (ButtonGroupView *)objectForKeyedSubscript:(NSString *)key {
    return (ButtonGroupView *)[super objectForKeyedSubscript:key];
}
@end
