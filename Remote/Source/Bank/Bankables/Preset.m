//
// Preset.m
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "Preset.h"
#import "RemoteElement.h"
#import "CoreDataManager.h"
#import "RemoteElementView_Private.h"
#import "Remote-Swift.h"

static int       ddLogLevel   = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel, msLogContext)

@implementation Preset

@dynamic element, category;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankableModel
////////////////////////////////////////////////////////////////////////////////


/// detailViewController
/// @return PresetViewController *
- (PresetDetailController *)detailViewController {
  return [[PresetDetailController alloc] initWithItem:self editing:NO];
}

/// editingViewController
/// @return PresetViewController *
- (PresetDetailController *)editingViewController {
  return [[PresetDetailController alloc] initWithItem:self editing:YES];
}

/// isPreviewable
/// @return BOOL
+ (BOOL)isPreviewable { return YES;  }

/// isThumbnailable
/// @return BOOL
+ (BOOL)isThumbnailable { return YES;  }

/// isCategorized
/// @return BOOL
+ (BOOL)isCategorized { return YES; }

/// directoryLabel
/// @return NSString *
+ (NSString *)directoryLabel { return @"Presets"; }

/// directoryIcon
/// @return UIImage *
//+ (UIImage *)directoryIcon { return [UIImage imageNamed:@"949-gray-paint-brush"]; }
+ (UIImage *)directoryIcon { return [UIImage imageNamed:@"1059-gray-sliders"]; }

/// isEditable
/// @return BOOL
- (BOOL)isEditable { return ([super isEditable] && self.user); }

@end
