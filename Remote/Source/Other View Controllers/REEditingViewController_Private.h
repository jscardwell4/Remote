//
// EditingViewController_Private.h
// Remote
//
// Created by Jason Cardwell on 4/20/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "REEditingViewController.h"
#import "REEditingViewController+IBActions.h"
#import "REEditingViewController+Gestures.h"
#import "REEditingViewController+Selection.h"
#import "REEditingViewController+Toolbars.h"
#import <QuartzCore/QuartzCore.h>

#define TOOLBAR_FRAME CGRectMake(0, 436, 320, 44)

typedef NS_ENUM (NSUInteger, RemoteElementEditingMenuState) {
    REEditingMenuStateDefault      = 0,
    REEditingMenuStateStackedViews = 1
};

@class REView;

extern NSString const   * kLeftJiggleAnimationKey;
extern NSString const   * kRightJiggleAnimationKey;
extern NSString const   * kTranslationAnimationKey;

@interface REEditingViewController () {
    struct {
        BOOL                            testInProgress;
        BOOL                            movingSelectedViews;
        BOOL                            snapToEnabled;
        BOOL                            showSourceBoundary;
        BOOL                            popoverActive;
        RemoteElementEditingMenuState   menuState;
        CGFloat                         appliedScale;
        CGRect                          originalFrame;
        CGRect                          currentFrame;
        CGPoint                         longPressPreviousLocation;
        CGRect                          contentRect;
        MSBoundary                      allowableSourceViewYOffset;
    } _flags;

    NSManagedObjectContext                                 * _context;
    __weak id <REEditingViewControllerDelegate>              _delegate;
    Class                                                    _selectableClass;

    REView                                      * _focusView;
    REView                                      * _sourceView;
    UIView                                                 * _multiselectView;
    NSMutableSet                                           * _selectedViews;
    CAShapeLayer                                           * _sourceViewBoundsLayer;

    UITapGestureRecognizer                                 * _oneTouchTapGesture;
    UITapGestureRecognizer                                 * _oneTouchDoubleTapGesture;
    UITapGestureRecognizer                                 * _twoTouchTapGesture;
    UIPanGestureRecognizer                                 * _panGesture;
    UIPinchGestureRecognizer                               * _pinchGesture;
    UILongPressGestureRecognizer                           * _longPressGesture;
    UILongPressGestureRecognizer                           * _toolbarLongPressGesture;
    MSMultiselectGestureRecognizer                         * _multiselectGesture;
    MSMultiselectGestureRecognizer                         * _anchoredMultiselectGesture;
    UIPanGestureRecognizer                                 * _twoTouchPanGesture;
    NSPointerArray                                         * _gestures;
    MSGestureManager                                       * _gestureManager;

    UIToolbar                                              * _topToolbar;
    __weak UIToolbar                                       * _currentToolbar;
    UIToolbar                                              * _emptySelectionToolbar;
    UIToolbar                                              * _nonEmptySelectionToolbar;
    UIToolbar                                              * _focusSelectionToolbar;
    NSArray                                  			           * _toolbars;

    NSMutableArray                                         * _singleSelButtons;
    NSMutableArray                                         * _anySelButtons;
    NSMutableArray                                         * _noSelButtons;
    NSMutableArray                                         * _multiSelButtons;
    MSBarButtonItem                                        * _undoButton;
}

@property (nonatomic, strong) NSManagedObjectContext   * context;
@property (nonatomic, strong) NSDictionary             * changedModelValues;

@property (strong, nonatomic) NSArray         * toolbars;
@property (strong, nonatomic) NSMutableArray  * singleSelButtons;
@property (strong, nonatomic) NSMutableArray  * anySelButtons;
@property (strong, nonatomic) NSMutableArray  * noSelButtons;
@property (strong, nonatomic) NSMutableArray  * multiSelButtons;
@property (strong, nonatomic) MSBarButtonItem * undoButton;

@property (strong, nonatomic) UITapGestureRecognizer          * oneTouchTapGesture;
@property (strong, nonatomic) UITapGestureRecognizer          * oneTouchDoubleTapGesture;
@property (strong, nonatomic) UITapGestureRecognizer          * twoTouchTapGesture;
@property (strong, nonatomic) UIPanGestureRecognizer          * panGesture;
@property (strong, nonatomic) UIPinchGestureRecognizer        * pinchGesture;
@property (strong, nonatomic) UILongPressGestureRecognizer    * longPressGesture;
@property (strong, nonatomic) UILongPressGestureRecognizer    * toolbarLongPressGesture;
@property (strong, nonatomic) MSMultiselectGestureRecognizer  * multiselectGesture;
@property (strong, nonatomic) MSMultiselectGestureRecognizer  * anchoredMultiselectGesture;
@property (strong, nonatomic) UIPanGestureRecognizer          * twoTouchPanGesture;
@property (strong, nonatomic) NSPointerArray                  * gestures;
@property (strong, nonatomic) MSGestureManager                * gestureManager;

@property (strong, nonatomic) UIView * multiselectView;

@property (nonatomic, strong)           NSMutableSet        * selectedViews;
@property (nonatomic, strong)           NSMutableDictionary * startingOffsets;
@property (nonatomic, assign)           CGSize                mockParentSize;
@property (nonatomic, strong)           NSMutableSet        * selectionInProgress;
@property (nonatomic, strong)           NSMutableSet        * deselectionInProgress;
@property (nonatomic, strong) IBOutlet UIToolbar            * topToolbar;
@property (nonatomic, strong) IBOutlet UIToolbar            * emptySelectionToolbar;
@property (nonatomic, strong) IBOutlet UIToolbar            * nonEmptySelectionToolbar;
@property (nonatomic, strong) IBOutlet UIToolbar            * focusSelectionToolbar;
@property (nonatomic, strong)           UIView              * mockParentView;
@property (nonatomic, strong)           REView   * sourceView;
@property (nonatomic, strong)           NSLayoutConstraint  * sourceViewCenterXConstraint;
@property (nonatomic, strong)           NSLayoutConstraint  * sourceViewCenterYConstraint;
@property (nonatomic, strong)           REView   * focusView;
@property (nonatomic, strong)           CAShapeLayer        * sourceViewBoundsLayer;
@property (nonatomic, strong)           Class                 selectableClass;

- (void)initializeIVARs;

- (void)registerForNotifications;

/**
 * Convenience method that calls the following additional methods:
 * - `updateBarButtonItems`
 * - `updateToolbarDisplayed`
 * - `updateBoundaryLayer`
 * - `updateGesturesEnabled`
 */
- (void)updateState;

/**
 * Updates whether `sourceViewBoundsLayer` is hidden and sets its `path` from `sourceView.frame`.
 */
- (void)updateBoundaryLayer;

/**
 * Override point for subclasses to perform additional work pre-alignment.
 */
- (void)willAlignSelectedViews;

/**
 * Sends `alignSubelements:toSibling:attribute:` to the `sourceView` to perform actual alignment
 * @param alignment `NSLayoutAttribute` to use when aligning the `selectedViews` to the `focusView`
 */
- (void)alignSelectedViews:(NSLayoutAttribute)alignment;

/**
 * Override point for subclasses to perform additional work post-alignment.
 */
- (void)didAlignSelectedViews;

/**
 * Override point for subclasses to perform additional work pre-sizing.
 */
- (void)willResizeSelectedViews;

/**
 * Sends `resizeSubelements:toSibling:attribute:` to the `sourceView` to perform actual resizing.
 * @param axis `NSLayoutAttribute` specifying whether resizing should involve width or height
 */
- (void)resizeSelectedViews:(NSLayoutAttribute)axis;

/**
 * Override point for subclasses to perform additional work pre-sizing.
 */
- (void)didResizeSelectedViews;

/**
 * Override point for subclasses to perform additional work pre-scaling.
 */
- (void)willScaleSelectedViews;

/**
 * Performs a sanity check on the scale to be applied and then sends `scaleSubelements:scale:` to
 * the
 * `sourceView` to perform actual scaling.
 * @param scale The scale to apply to the current selection
 * @return The actual scale value applied to the current selection
 */
- (CGFloat)scaleSelectedViews:(CGFloat)scale
                   validation:(BOOL (^)(REView * view,
                                        CGSize size,
                                        CGSize * max,
                                        CGSize * min))isValidSize;

/**
 * Override point for subclasses to perform additional work post-scaling.
 */
- (void)didScaleSelectedViews;

/**
 * Sanity check for ensuring selected views can only be moved to reasonable locations.
 * @param fromUnion `CGRect` representing the current union of the `frame` properties of the current
 * selection
 * @param toUnion `CGRect` representing the resulting union of the `frame` properties of the current
 * selection when moved
 * @return Whether the views should be moved
 */
- (BOOL)shouldTranslateSelectionFrom:(CGRect)fromUnion to:(CGRect)toUnion;

/**
 * Captures the original union frame for the selected views before any translation and acts
 * as an override point for subclasses to perform additional work pre-movement.
 */
- (void)willTranslateSelectedViews;

/**
 * Updates the `frame` property of the selected views to affect the specified translation.
 * @param translation `CGPoint` value representing the x and y axis translations to be performed on
 * the selected views
 */
- (void)translateSelectedViews:(CGPoint)translation;

/**
 * Sends `translateSublements:translation:` to the `sourceView` to perform model-level translation
 * and acts
 * as an override point for subclasses to perform additional work post-movement.
 */
- (void)didTranslateSelectedViews;

@end

@interface REEditingViewController (Debugging)
- (void)logSourceViewAfter:(dispatch_time_t)delay message:(NSString *)message;
@end
