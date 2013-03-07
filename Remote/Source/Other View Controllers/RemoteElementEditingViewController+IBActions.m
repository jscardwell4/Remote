//
//  RemoteElementEditingViewController+IBActions.m
//  iPhonto
//
//  Created by Jason Cardwell on 2/15/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "RemoteElementEditingViewController_Private.h"
#import "RemoteElementView_Private.h"

//static const int   ddLogLevel = LOG_LEVEL_DEBUG;
static const int   ddLogLevel   = LOG_LEVEL_DEBUG;
static const int   msLogContext = EDITOR_F;
#pragma unused(ddLogLevel)

@implementation RemoteElementEditingViewController (IBActions)

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Trash, copy, paste actions
///@name Trash, copy, paste actions
////////////////////////////////////////////////////////////////////////////////

- (IBAction)addSubelement:(id)sender {}

- (IBAction)presets:(id)sender {}

- (IBAction)editBackground:(id)sender {}

- (IBAction)editSubelement:(id)sender {}

/**
 * Duplicate the selected subelement views for the `sourceView`.
 */
- (IBAction)duplicateSubelements:(id)sender {
    MSLogDebug(@"%@", ClassTagSelectorString);
}

/**
 * Copy the style of the selected subelement views for the `sourceView`.
 */
- (IBAction)copyStyle:(id)sender {
    MSLogDebug(@"%@", ClassTagSelectorString);
}

/**
 * Paste a copied style onto the selected subelement views for the `sourceView`.
 */
- (IBAction)pasteStyle:(id)sender {
    MSLogDebug(@"%@", ClassTagSelectorString);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Showing/hiding guides/bounds
///@name Showing/hiding guides/bounds
////////////////////////////////////////////////////////////////////////////////

/**
 * Show or hide an outline of the `sourceView`.
 */
- (IBAction)toggleBoundsVisibility:(id)sender {
    _flags.showSourceBoundary = !_flags.showSourceBoundary;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Resizing, alignment actions
///@name Resizing, alignment actions
////////////////////////////////////////////////////////////////////////////////

/**
 * Align the vertical centers of the `selectedViews` to the vertical center of the `focusView`.
 */
- (IBAction)alignVerticalCenters:(id)sender {
    MSLogDebug(@"%@", ClassTagSelectorString);
    [self willAlignSelectedViews];
    [self alignSelectedViews:NSLayoutAttributeCenterY];
    [self didAlignSelectedViews];
}

/**
 * Align the horizontal centers of the `selectedViews` to the horizontal center of the `focusView`.
 */
- (IBAction)alignHorizontalCenters:(id)sender {
    MSLogDebug(@"%@", ClassTagSelectorString);
    [self willAlignSelectedViews];
    [self alignSelectedViews:NSLayoutAttributeCenterX];
    [self didAlignSelectedViews];
}

/**
 * Align the top edges of the `selectedViews` to the top edge of the `focusView`.
 */
- (IBAction)alignTopEdges:(id)sender {
    MSLogDebug(@"%@", ClassTagSelectorString);
    [self willAlignSelectedViews];
    [self alignSelectedViews:NSLayoutAttributeTop];
    [self didAlignSelectedViews];
}

/**
 * Align the bottom edges of the `selectedViews` to the bottom edge of the `focusView`.
 */
- (IBAction)alignBottomEdges:(id)sender {
    MSLogDebug(@"%@", ClassTagSelectorString);
    [self willAlignSelectedViews];
    [self alignSelectedViews:NSLayoutAttributeBottom];
    [self didAlignSelectedViews];
}

/**
 * Align the left edges of the `selectedViews` to the left edge of the `focusView`.
 */
- (IBAction)alignLeftEdges:(id)sender {
    MSLogDebug(@"%@", ClassTagSelectorString);
    [self willAlignSelectedViews];
    [self alignSelectedViews:NSLayoutAttributeLeft];
    [self didAlignSelectedViews];
}

/**
 * Align the right edges of the `selectedViews` to the right edge of the `focusView`.
 */
- (IBAction)alignRightEdges:(id)sender {
    MSLogDebug(@"%@", ClassTagSelectorString);
    [self willAlignSelectedViews];
    [self alignSelectedViews:NSLayoutAttributeRight];
    [self didAlignSelectedViews];
}

/**
 * Resize the `selectedViews` to match the height and width of the `focusView`.
 */
- (IBAction)resizeFromFocusView:(id)sender {
    MSLogDebug(@"%@", ClassTagSelectorString);
    [self willResizeSelectedViews];
    [self resizeSelectedViews:NSLayoutAttributeWidth];
    [self resizeSelectedViews:NSLayoutAttributeHeight];
    [self didResizeSelectedViews];
}

/**
 * Resize the `selectedViews` to match the width of the `focusView`.
 */
- (IBAction)resizeHorizontallyFromFocusView:(id)sender {
    MSLogDebug(@"%@", ClassTagSelectorString);
    [self willResizeSelectedViews];
    [self resizeSelectedViews:NSLayoutAttributeWidth];
    [self didResizeSelectedViews];
}

/**
 * Resize the `selectedViews` to match the height of the `focusView`.
 */
- (IBAction)resizeVerticallyFromFocusView:(id)sender {
    MSLogDebug(@"%@", ClassTagSelectorString);
    [self willResizeSelectedViews];
    [self resizeSelectedViews:NSLayoutAttributeHeight];
    [self didResizeSelectedViews];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Saving and reverting the managed object context
///@name Saving and reverting the managed object context
////////////////////////////////////////////////////////////////////////////////

/**
 * Save the `sourceView` in its edited state and dismiss.
 */
- (IBAction)saveAction:(id)sender {
    assert(_context);

    __block NSError * error   = nil;
    __block BOOL      savedOK = NO;

    [_context performBlockAndWait:^{savedOK = [_context save:&error]; }

    ];

    if (!savedOK)
        MSLogError(@"<%@> Saving child context failed: %@, %@",
                   NSStringFromClass([self class]), error, [error localizedFailureReason]);
    else if (_delegate)
        [_delegate remoteElementEditorDidSave:self];
    else if (self.presentingViewController)
        [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 * Reset the `sourceView` to its pre-editing state.
 */
- (IBAction)resetAction:(id)sender {
    MSLogDebug(@"%@", ClassTagSelectorString);
    [_context performBlockAndWait:^{[_context rollback];}];
}

/**
 * Cancel editing of the `sourceView` and dismiss.
 */
- (IBAction)cancelAction:(id)sender {
    [_context performBlockAndWait:^{[_context rollback];}];

    if (_delegate) [_delegate remoteElementEditorDidCancel:self];
    else if (self.presentingViewController) [self dismissViewControllerAnimated:YES completion:nil];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Dialogs
///@name Dialogs
////////////////////////////////////////////////////////////////////////////////

- (IBAction)showMultiselect:(id)sender {
    self.multiselectView.hidden = NO;
    _flags.popoverActive        = YES;
}

- (IBAction)hideMultiselect:(id)sender {
    self.multiselectView.hidden = YES;
    _flags.popoverActive        = NO;
}

- (IBAction)menuAction:(id)sender {
    MSLogDebug(
               @"%@ sender class = %@, sender: %@", ClassTagSelectorString, NSStringFromClass([sender class]), sender);
    if ([sender isKindOfClass:[RemoteElementView class]]) {
        [self toggleSelectionForViews:[@[sender] set]];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark UIResponderStandardEditActions Protocol Methods
///@name UIResponderStandardEditActions Protocol Methods
////////////////////////////////////////////////////////////////////////////////

- (void)undo:(id)sender {
    MSLogDebug(@"%@", ClassTagSelectorString);
    [_context performBlockAndWait:^{[_context undo];}];
}

- (void)redo:(id)sender {
    MSLogDebug(@"%@", ClassTagSelectorString);
    [_context performBlockAndWait:^{[_context redo];}];
}

- (void)copy:(id)sender {
    MSLogDebug(@"%@", ClassTagSelectorString);
}

- (void)cut:(id)sender {
    MSLogDebug(@"%@", ClassTagSelectorString);
}

- (void)delete:(id)sender {
    MSLogDebug(@"%@", ClassTagSelectorString);
}

- (void)paste:(id)sender {
    MSLogDebug(@"%@", ClassTagSelectorString);
}

- (void)select:(id)sender {
    MSLogDebug(@"%@", ClassTagSelectorString);
}

- (void)selectAll:(id)sender {
    MSLogDebug(@"%@", ClassTagSelectorString);
}

- (void)toggleBoldface:(id)sender {
    MSLogDebug(@"%@", ClassTagSelectorString);
}

- (void)toggleItalics:(id)sender {
    MSLogDebug(@"%@", ClassTagSelectorString);
}

- (void)toggleUnderline:(id)sender {
    MSLogDebug(@"%@", ClassTagSelectorString);
}

@end
