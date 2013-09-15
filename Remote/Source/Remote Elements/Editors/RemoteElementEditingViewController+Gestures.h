//
//  RemoteElementEditingViewController+Gestures.h
//  Remote
//
//  Created by Jason Cardwell on 2/15/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "RemoteElementEditingViewController.h"

/*
typedef NS_ENUM (NSInteger, GestureIndex) {
    LongPressGestureIndex              = 0,
    PinchGestureIndex                  = 1,
    OneTouchDoubleTapGestureIndex      = 2,
    MultiselectGestureIndex            = 3,
    PanGestureIndex                    = 4,
    TwoTouchPanGestureIndex            = 5,
    ToolbarLongPressGestureIndex       = 6,
    AnchoredMultiselectionGestureIndex = 7
};
*/

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
