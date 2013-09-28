//
//  RemoteElementEditingViewController+Toolbars.h
//  Remote
//
//  Created by Jason Cardwell on 2/15/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "RemoteElementEditingViewController.h"

MSEXTERN NSUInteger const   kTopToolbarIndex;
MSEXTERN NSUInteger const   kEmptySelectionToolbarIndex;
MSEXTERN NSUInteger const   kNonEmptySelectionToolbarIndex;
MSEXTERN NSUInteger const   kFocusSelectionToolbarIndex;

@interface RemoteElementEditingViewController (Toolbars) <MSPopupBarButtonDelegate>

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
