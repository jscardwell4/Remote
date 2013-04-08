//
//  RemoteElementEditingViewController+Toolbars.h
//  Remote
//
//  Created by Jason Cardwell on 2/15/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "REEditingViewController.h"

MSKIT_EXTERN NSUInteger const   kTopToolbarIndex;
MSKIT_EXTERN NSUInteger const   kEmptySelectionToolbarIndex;
MSKIT_EXTERN NSUInteger const   kNonEmptySelectionToolbarIndex;
MSKIT_EXTERN NSUInteger const   kFocusSelectionToolbarIndex;

@interface REEditingViewController (Toolbars) <MSPopupBarButtonDelegate>

@property (nonatomic, weak) UIToolbar * currentToolbar;

- (void)initializeToolbars;

/**
 * Enables/disables state dependent `UIBarButtonItem` objects based on the number of selected views.
 */
- (void)updateBarButtonItems;

- (void)updateToolbarDisplayed;
- (void)populateTopToolbar;
- (void)populateEmptySelectionToolbar;
- (void)populateNonEmptySelectionToolbar;
- (void)populateFocusSelectionToolbar;

@end