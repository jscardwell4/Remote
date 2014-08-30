//
// RemoteView.m
// Remote
//
// Created by Jason Cardwell on 3/17/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "RemoteElementView_Private.h"

static int ddLogLevel   = DefaultDDLogLevel;
static int msLogContext = (LOG_CONTEXT_REMOTE | LOG_CONTEXT_FILE | LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel, msLogContext)

@implementation RemoteView

- (CGSize)intrinsicContentSize { return [MainScreen bounds].size; }

/// Override sizing and moving of the remote view
////////////////////////////////////////////////////////////////////////////////

- (void)setResizable:(BOOL)resizable {}
- (void)setMoveable:(BOOL)moveable   {}
- (BOOL)isResizable { return NO; }
- (BOOL)isMoveable  { return NO; }


- (void)initializeIVARs {
  [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
  [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
  [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
  [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
  [super initializeIVARs];
}

@end
