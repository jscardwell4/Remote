//
// RERemoteView.m
// Remote
//
// Created by Jason Cardwell on 3/17/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "REView_Private.h"

#define NUM_PANELS 13

// Panel registration keys
static NSArray     * kValidPanelKeys;

MSKIT_STRING_CONST   RERemoteTopPanel1Key    = @"RERemoteTopPanel1Key";
MSKIT_STRING_CONST   RERemoteBottomPanel1Key = @"RERemoteBottomPanel1Key";
MSKIT_STRING_CONST   RERemoteLeftPanel1Key   = @"RERemoteLeftPanel1Key";
MSKIT_STRING_CONST   RERemoteRightPanel1Key  = @"RERemoteRightPanel1Key";
MSKIT_STRING_CONST   RERemoteTopPanel2Key    = @"RERemoteTopPanel2Key";
MSKIT_STRING_CONST   RERemoteBottomPanel2Key = @"RERemoteBottomPanel2Key";
MSKIT_STRING_CONST   RERemoteLeftPanel2Key   = @"RERemoteLeftPanel2Key";
MSKIT_STRING_CONST   RERemoteRightPanel2Key  = @"RERemoteRightPanel2Key";
MSKIT_STRING_CONST   RERemoteTopPanel3Key    = @"RERemoteTopPanel3Key";
MSKIT_STRING_CONST   RERemoteBottomPanel3Key = @"RERemoteBottomPanel3Key";
MSKIT_STRING_CONST   RERemoteLeftPanel3Key   = @"RERemoteLeftPanel3Key";
MSKIT_STRING_CONST   RERemoteRightPanel3Key  = @"RERemoteRightPanel3Key";

static int   ddLogLevel   = DefaultDDLogLevel;
static int   msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel, msLogContext)

@implementation RERemoteView

+ (void)initialize
{
    if (self == [RERemoteView class])
    {
        static dispatch_once_t   onceToken;

        dispatch_once(&onceToken, ^{
            kValidPanelKeys = @[RERemoteTopPanel1Key,
                                RERemoteTopPanel2Key,
                                RERemoteTopPanel3Key,
                                RERemoteBottomPanel1Key,
                                RERemoteBottomPanel2Key,
                                RERemoteBottomPanel3Key,
                                RERemoteLeftPanel1Key,
                                RERemoteLeftPanel2Key,
                                RERemoteLeftPanel3Key,
                                RERemoteRightPanel1Key,
                                RERemoteRightPanel2Key,
                                RERemoteRightPanel3Key];
        });
    }
}

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

- (NSString *)currentConfiguration { return _currentConfiguration; }

- (REButtonGroupView *)objectAtIndexedSubscript:(NSUInteger)idx {
    return (REButtonGroupView *)[super objectAtIndexedSubscript:idx];
}

- (REButtonGroupView *)objectForKeyedSubscript:(NSString *)key {
    return (REButtonGroupView *)[super objectForKeyedSubscript:key];
}
@end
