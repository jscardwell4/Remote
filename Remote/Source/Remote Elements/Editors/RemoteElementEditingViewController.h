//
// RemoteElementEditingViewController.h
//
//
// Created by Jason Cardwell on 4/20/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
@import Moonkit;
@class RemoteElement, RemoteView, ButtonGroup, Button, RemoteElementEditingViewController;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Controller Delegate Protocol
////////////////////////////////////////////////////////////////////////////////

@protocol RemoteElementEditingDelegate <NSObject>

- (void)remoteElementEditorDidCancel:(RemoteElementEditingViewController *)editor;
- (void)remoteElementEditorDidSave:(RemoteElementEditingViewController *)editor;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Editor
////////////////////////////////////////////////////////////////////////////////
@interface RemoteElementEditingViewController : UIViewController

@property (nonatomic, strong) RemoteElement            * remoteElement;
@property (nonatomic, weak)   id <RemoteElementEditingDelegate>     delegate;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Editing
////////////////////////////////////////////////////////////////////////////////
@interface RemoteEditingViewController : RemoteElementEditingViewController @end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Group Editing
////////////////////////////////////////////////////////////////////////////////
@interface ButtonGroupEditingViewController : RemoteElementEditingViewController

//@property (nonatomic, assign) CGSize   presentedElementSize;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Editing
////////////////////////////////////////////////////////////////////////////////
@interface ButtonEditingViewController : RemoteElementEditingViewController

- (id)initWithButton:(Button *)button delegate:(UIViewController <RemoteElementEditingDelegate> *)delegate;
- (void)removeAuxController:(UIViewController *)controller animated:(BOOL)animated;
- (void)addAuxController:(UIViewController *)controller animated:(BOOL)animated;

@property (nonatomic, assign) UIControlState   presentedControlState;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Detailed Button Editing
////////////////////////////////////////////////////////////////////////////////

MSEXTERN_STRING   REDetailedButtonEditingButtonKey;
MSEXTERN_STRING   REDetailedButtonEditingControlStateKey;

@interface DetailedButtonEditingViewController : RemoteElementEditingViewController

- (void)initializeEditorWithValues:(NSDictionary *)values;

- (void)removeAuxController:(UIViewController *)controller animated:(BOOL)animated;
- (void)addAuxController:(UIViewController *)controller animated:(BOOL)animated;

@end

/**
 RemoteElementEditingViewController (Gestures)

 States:

 - Default
 - Single View Selected
 - Multiple Views Selected
 - Single View Selected & Focused
 - Multiple Views Selected & One Focused
 - Popup Overlay Displayed


 Gestures | Default | Single View Selected | Multiple Views Selected | Single View Selected & Focused | Multiple Views Selected<br>& One Focused | Popup
 :--------:|:-------:|:--------------------:|:-----------------------:|:------------------------------:|:-------------------------------------:|:----:
 tap | x | x | x | x | x | x
 double-tap | set focus | set focus | set focus | unset focus | unset focus | x
 two-touch tap | x | x | x | x | x | x
 pan | x | x | x | x | x | x
 two-touch pan | scroll | scroll | scroll | scroll | scroll | x
 pinch | x | scale | scale | scale | scale | x
 long press | translate | translate | translate | translate | translate | x
 long press (toolbar) | secondary action | secondary action | secondary action | secondary action | secondary action | x
 multi-select | select | select | select | select | select | x

 */
@interface RemoteElementEditingViewController (Gestures) <UIGestureRecognizerDelegate>

///@name Gestures

/**
 * Creates and attaches `UIGestureRecognizer` objects for user interaction.
 *
 * Long press and drag to move `selectedViews`.
 * Touch/drag to add views to selection.
 * Pinch scales selected views.
 * Two finger pan to scroll.
 * Double tapping a selected view sets it as the `focusView`.
 */
- (void)attachGestureRecognizers;

/**
 * Toggles gesture `enabled` values based on factors such as whether `focusView` is set,
 * whether there are any views selected and whether they are being moved
 */
- (void)updateGesturesEnabled;

/**
 * Handler for taps received. When `gestureRecognizer` is `oneTouchDoubleTapGesture`
 * the touched view is added to selection and set as `focusView`.
 * @param gestureRecognizer `UITapGestureRecognizer` handling the tap
 */
- (IBAction)handleTap:(UITapGestureRecognizer *)gestureRecognizer;

/**
 * Handler for long press events. Moves `selectedViews` when `gestureRecognizer` is
 * `longPressGesture`.
 * @param gestureRecognizer `UILongPressGestureRecognizer` handling the long press
 */
- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer;

/**
 * Handler for pinch events. Scales `selectedViews` when `gestureRecognizer` is `pinchGesture`.
 * @param gestureRecognizer `UIPinchGestureRecognizer` handling the pinch
 */
- (IBAction)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer;

/**
 * Handler for touch or drag events. Adds contacted views to `selectedViews`, or removes selection
 * if no elligble views are touched, when `gestureRecognizer` is `multiSelectionGesture`.
 * @param gestureRecognizer `MultiSelectionGestureRecognizer` handling the touch or drag
 */
- (IBAction)handleSelection:(MSMultiselectGestureRecognizer *)gestureRecognizer;

/**
 * Handler for pan events. Scrolls visible portion of `sourceView` when `gestureRecognizer` is
 * `twoTouchPanGesture`.
 * @param gestureRecognizer `UIPanGestureRecognizer` handling the pan
 */
- (IBAction)handlePan:(UIPanGestureRecognizer *)gestureRecognizer;

/**
 * Displays menu for selecting an element when a gesture has targeted overlapping views.
 * param stackedViews The views with which to populate the menu
 */
- (void)displayStackedViewDialogForViews:(NSSet *)stackedViews;

@end

@interface RemoteElementEditingViewController (IBActions)

///@name Top Toolbar
- (IBAction)saveAction:(id)sender;
- (IBAction)resetAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)undo:(id)sender;
- (IBAction)redo:(id)sender;

///@name Empty Selection Toolbar
- (IBAction)addSubelement:(id)sender;
- (IBAction)editBackground:(id)sender;
- (IBAction)toggleBoundsVisibility:(id)sender;
- (IBAction)presets:(id)sender;

///@name Non-empty Selection Toolbar
- (IBAction)editSubelement:(id)sender;
- (IBAction)duplicateSubelements:(id)sender;
- (IBAction)copyStyle:(id)sender;
- (IBAction)pasteStyle:(id)sender;

///@name Focus Selected Toolbar
- (IBAction)alignVerticalCenters:(id)sender;
- (IBAction)alignHorizontalCenters:(id)sender;
- (IBAction)alignTopEdges:(id)sender;
- (IBAction)alignBottomEdges:(id)sender;
- (IBAction)alignLeftEdges:(id)sender;
- (IBAction)alignRightEdges:(id)sender;
- (IBAction)resizeHorizontallyFromFocusView:(id)sender;
- (IBAction)resizeVerticallyFromFocusView:(id)sender;
- (IBAction)resizeFromFocusView:(id)sender;

@end

typedef NS_ENUM (NSInteger, HighlightStyle) {
  HighlightStyleNone     = 0,
  HighlightStyleSelected = 1,
  HighlightStyleFocus    = 2,
  HighlightStyleMoving   = 3
};

@class   RemoteElementView;

@interface RemoteElementEditingViewController (Selection)

///@name Selection

@property (nonatomic, readonly) NSUInteger   selectionCount;

- (void)toggleSelectionForViews:(NSSet *)views;
- (void)selectView:(RemoteElementView *)view;
- (void)selectViews:(NSSet *)views;
- (void)deselectView:(RemoteElementView *)view;
- (void)deselectViews:(NSSet *)views;
- (void)deselectAll;
- (CGRect)selectedViewsUnionFrameInView:(UIView *)view;
- (CGRect) selectedViewsUnionFrameInSourceView;

@end

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


