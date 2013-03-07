//
// RemoteElementEditingViewController.m
//
//
// Created by Jason Cardwell on 4/20/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "CoreDataManager.h"
#import "RemoteElementEditingViewController_Private.h"
#import "RemoteElementView_Private.h"
#import "RemoteElementViewConstraintManager.h"
#import "RemoteElementLayoutConstraint.h"
#import <MSKit/MSKit.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#define SOURCEVIEW_DEBUG_COLOR RedColor
// #define COLOR_SOURCEVIEW_BACKGROUND

#define CONTAINER_DEBUG_COLOR OrangeColor
// #define COLOR_CONTAINER_BACKGROUND

static int         ddLogLevel   = LOG_LEVEL_DEBUG;
static const int   msLogContext = EDITOR_F;
// static const int ddLogLevel = DefaultDDLogLevel;

MSKIT_STATIC_STRING_CONST   kCenterXConstraintNametag = @"kCenterXConstraintNametag";
MSKIT_STATIC_STRING_CONST   kCenterYConstraintNametag = @"kCenterYConstraintNametag";
MSKIT_STATIC_STRING_CONST   kParentConstraintNametag  = @"kParentConstraintNametag";

@implementation RemoteElementEditingViewController {
    UIView            * _referenceView;
    MSKVOReceptionist * _parentConstraintsObserver;
    MSKVOReceptionist * _sourceViewBoundsObserver;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialization and loading
///@name Initialization and loading
////////////////////////////////////////////////////////////////////////////////

/*
 * Calls `initializeIVARS`
 */
- (void)awakeFromNib {
    [self initializeIVARs];
}

/*
 * Sets initial state for various flags and instance variables
 */
- (void)initializeIVARs {
    _flags.showSourceBoundary  = YES;
    self.selectableClass       = [UIView class];
    self.selectedViews         = [NSMutableSet set];
    self.selectionInProgress   = [NSMutableSet set];
    self.deselectionInProgress = [NSMutableSet set];
}

/*
 * Manage various `UIBarButtonItem` objects and the `sourceViewBoundsLayer`
 */
- (void)viewDidLoad {

    [self initializeToolbars];
    [self attachGestureRecognizers];

    self.sourceViewBoundsLayer             = [CAShapeLayer layer];
    _sourceViewBoundsLayer.fillColor       = ClearColor.CGColor;
    _sourceViewBoundsLayer.lineCap         = kCALineCapRound;
    _sourceViewBoundsLayer.lineDashPattern = @[@1, @1];
    _sourceViewBoundsLayer.lineJoin        = kCALineJoinRound;
    _sourceViewBoundsLayer.lineWidth       = 1.0;
    _sourceViewBoundsLayer.strokeColor     = WhiteColor.CGColor;
    _sourceViewBoundsLayer.hidden          = YES;
}  /* viewDidLoad */

/*
 * Calls `updateBoundaryLayer`
 */
- (void)viewDidLayoutSubviews {
    [self updateBoundaryLayer];
}

- (BOOL)canBecomeFirstResponder { return YES; }

- (void)registerForNotifications {
    [NotificationCenter addObserverForName:UIMenuControllerDidHideMenuNotification
                                    object:MenuController
                                     queue:MainQueue
                                usingBlock:^(NSNotification *note) {
                                    _flags.menuState = REEditingMenuStateDefault;
                                }];
}

- (void)dealloc {
    [NotificationCenter removeObserver:self];
}

- (id)forwardingTargetForSelector:(SEL)selector {
    if (MSSelectorInProtocol(selector, @protocol(UIGestureRecognizerDelegate), NO, YES))
        return self.gestureManager;
    else
        return [super forwardingTargetForSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector {
    if ([NSStringFromSelector(selector) hasPrefix:@"menuAction_"])
        return [self methodSignatureForSelector:@selector(menuAction:)];
    else
        return [super methodSignatureForSelector:selector];
}

- (BOOL)respondsToSelector:(SEL)selector {
    if (   [NSStringFromSelector(selector) hasPrefix:@"menuAction_"]
        || MSSelectorInProtocol(selector, @protocol(UIGestureRecognizerDelegate), NO, YES))
        return YES;
    else
        return [super respondsToSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    SEL selector = [invocation selector];
    NSString * action = NSStringFromSelector(selector);
    if ([action hasPrefix:@"menuAction_"]) {
        [invocation setSelector:@selector(menuAction:)];
        NSString * identifier = [action stringByReplacingOccurrencesOfRegEx:@"(?:menuAction)|(?::)" withString:@""];
        RemoteElementView * view = _sourceView[identifier];
        assert(view);
        [invocation setSelector:@selector(menuAction:)];
        [invocation setTarget:self];
        [invocation setArgument:&view atIndex:2];
        [invocation invoke];
    } else
        [super forwardInvocation:invocation];
}

/*
 * Updates height and size flags, enables `twoTouchPanGesture` and calls `updateBoundaryLayer`
 * @param animated Whether view was animated
 */
- (void)viewDidAppear:(BOOL)animated {
    assert(_sourceView);
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
    [self registerForNotifications];

    CGFloat   sourceHeight   = _sourceView.bounds.size.height;
    CGFloat   viewHeight     = self.view.bounds.size.height;
    CGFloat   boundarySize   = MSBoundarySizeOfBoundary(_flags.allowableSourceViewYOffset);
    BOOL      gestureEnabled = (sourceHeight < viewHeight - boundarySize ? NO : YES);

    _twoTouchPanGesture.enabled = gestureEnabled;

    [self updateBoundaryLayer];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self resignFirstResponder];
    [NotificationCenter removeObserver:self
                                  name:UIMenuControllerDidHideMenuNotification
                                object:MenuController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DDLogWarn(@"%@ is view loaded? %@", ClassTagSelectorString, NSStringFromBOOL([self isViewLoaded]));
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Updating UI State
///@name Updating UI State
////////////////////////////////////////////////////////////////////////////////

- (void)updateBoundaryLayer {
    _sourceViewBoundsLayer.path   = [UIBezierPath bezierPathWithRect:_sourceView.frame].CGPath;
    _sourceViewBoundsLayer.hidden = !_flags.showSourceBoundary;
}

- (void)updateState {
    [self updateBarButtonItems];
    [self updateToolbarDisplayed];
    [self updateBoundaryLayer];
    [self updateGesturesEnabled];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Moving the selected views
///@name Moving the selected views
////////////////////////////////////////////////////////////////////////////////

- (BOOL)shouldMoveSelectionFrom:(CGRect)fromUnion to:(CGRect)toUnion {
    if (CGRectIsEmpty(_flags.contentRect)) {
        _referenceView     = self.view;
        _flags.contentRect = CGRectMake(_referenceView.frame.origin.x,
                                        _topToolbar.bounds.size.height,
                                        _referenceView.frame.size.width,
                                        _referenceView.frame.size.height - (  _topToolbar.bounds.size.height
                                                                              + _currentToolbar.bounds.size.height));
    }

    BOOL   move = CGRectContainsRect(_flags.contentRect, toUnion);

    return move;
}

- (void)moveSelectedViewsWithTranslation:(CGPoint)translation {
    if (CGPointEqualToPoint(translation, CGPointZero)) return;

    CGRect   translatedFrame = CGRectApplyAffineTransform(_flags.currentFrame,
                                                          CGAffineTransformMakeTranslation(translation.x, translation.y));

    if ([self shouldMoveSelectionFrom:_flags.currentFrame to:translatedFrame]) {
        _flags.currentFrame = translatedFrame;

        for (RemoteElementView * view in _selectedViews) {
            view.frame = CGRectApplyAffineTransform(view.frame, CGAffineTransformMakeTranslation(translation.x, translation.y));
        }
    }
}

- (void)willMoveSelectedViews {
    [self.context performBlock:^{[self.context processPendingChanges];}];
    _flags.originalFrame = [self selectedViewsUnionFrameInView:self.view];
    _flags.currentFrame  = _flags.originalFrame;
#ifdef DEBUG_TRANSLATION
    [self logSourceViewAfter:0 message:@"before translation"];
#endif
}

- (void)didMoveSelectedViews {
    // inform source view of translation
    CGPoint   translation = CGPointGetDelta(_flags.currentFrame.origin, _flags.originalFrame.origin);

    [_sourceView translateSubelements:_selectedViews translation:translation];

    [self.context performBlock:^{[self.context processPendingChanges];}];

#ifdef DEBUG_TRANSLATION
    [self logSourceViewAfter:5.0 message:$(@"after translation - %@", NSStringFromCGPoint(translation))];
#endif

    // update editing style for selected views
    [_selectedViews setValue:@(EditingStyleSelected) forKeyPath:@"editingStyle"];

    // udpate state
    _flags.movingSelectedViews = NO;
    [self updateState];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Scaling the selected views
///@name Scaling the selected views
////////////////////////////////////////////////////////////////////////////////

- (CGFloat)scaleSelectedViews:(CGFloat)scale
                   validation:(BOOL (^)(RemoteElementView *, CGSize))isValidSize {
    if (!isValidSize) {
        isValidSize = ^BOOL (RemoteElementView * view, CGSize size) {
            CGSize   minSize = view.minimumSize;
            CGSize   maxSize = view.maximumSize;
            BOOL     valid   = (  size.width <= maxSize.width
                               && size.height <= maxSize.height
                               && size.width >= minSize.width
                               && size.height >= minSize.height);

            MSLogDebug(
                       @"%@\n\tsize:%@\n\tminSize:%@\n\tmaxSize:%@\n\tvalid? %@",
                       ClassTagSelectorStringForInstance(view.displayName),
                       NSStringFromCGSize(size),
                       NSStringFromCGSize(minSize),
                       NSStringFromCGSize(maxSize),
                       NSStringFromBOOL(valid));

            return valid;
        };
    }

    NSMutableArray * scaleRejections = [@[] mutableCopy];

    for (RemoteElementView * view in _selectedViews) {
        CGSize   scaledSize = CGSizeApplyAffineTransform(view.bounds.size,
                                                         CGAffineTransformMakeScale(scale, scale));

        if (!isValidSize(view, scaledSize)) {
            CGSize    m          = (scale > 1.0f ? view.maximumSize : view.minimumSize);
            CGFloat   validScale = m.width / view.bounds.size.width;

            [scaleRejections addObject:@(validScale)];
        }
    }

    if (scaleRejections.count) {
        scale = (scale > 1.0f
                 ? Float([scaleRejections valueForKeyPath:@"@min.self"])
                 : Float([scaleRejections valueForKeyPath:@"@max.self"])
                 );
        MSLogDebug(
                   @"%@ scale adjusted to remain valid - new scale: %.2f",
                   ClassTagSelectorString, scale);
    }

    for (RemoteElementView * view in _selectedViews)
        view.transform = CGAffineTransformScale(view.transform,
                                                scale/CGAffineTransformGetScaleX(view.transform),
                                                scale/CGAffineTransformGetScaleY(view.transform));

    return scale;
}  /* scaleSelectedViews */

- (void)willScaleSelectedViews {
    [self.context performBlock:^{[self.context processPendingChanges];}];
}

- (void)didScaleSelectedViews {
    for (RemoteElementView * view in _selectedViews)
        view.transform = CGAffineTransformIdentity;

    [_sourceView scaleSubelements:_selectedViews scale:_flags.appliedScale];
    [self.context performBlock:^{[self.context processPendingChanges];}];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Aligning the selected views
///@name Aligning the selected views
////////////////////////////////////////////////////////////////////////////////

- (void)alignSelectedViews:(NSLayoutAttribute)alignment {
    assert(_focusView);
    [self willAlignSelectedViews];
    [_sourceView alignSubelements:[_selectedViews setByRemovingObject:_focusView] toSibling:_focusView attribute:alignment];
    [self didAlignSelectedViews];
}

- (void)willAlignSelectedViews {
    [self.context performBlock:^{[self.context processPendingChanges];}];
#ifdef DEBUG_ALIGNMENT
    [self logSourceViewAfter:0 message:@"before alignment"];
#endif
}

- (void)didAlignSelectedViews {
    [self.context performBlock:^{[self.context processPendingChanges];}];

#ifdef DEBUG_ALIGNMENT
    [self logSourceViewAfter:5.0 message:@"after alignment"];
#endif
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Resizing the selected views to match focus view
////////////////////////////////////////////////////////////////////////////////

- (void)resizeSelectedViews:(NSLayoutAttribute)axis {
    assert(_focusView);
    [_sourceView resizeSubelements:[_selectedViews setByRemovingObject:_focusView] toSibling:_focusView attribute:axis];
}

- (void)willResizeSelectedViews {
    [self.context performBlock:^{[self.context processPendingChanges];}];
}

- (void)didResizeSelectedViews {
    [self.context performBlock:^{[self.context processPendingChanges];}];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Custom accessors
////////////////////////////////////////////////////////////////////////////////

/*
 * Creates a new child context for `remoteElement.managedObjectContext`, gets existing object from
 * the context and observes `constraints` property of the element's parent element
 * @param remoteElement `RemoteElement` to edit
 */
- (void)setRemoteElement:(RemoteElement *)remoteElement {
    assert(remoteElement);
    self.context = [DataManager childContextWithNametag:NSStringFromClass([self class])
                                             forContext:remoteElement.managedObjectContext
                                        concurrencyType:NSMainQueueConcurrencyType
                                            undoManager:YES];
    assert(self.context.undoManager);

    [_context performBlockAndWait:^{
                  NSError * error = nil;
                  self.changedModelValues = [remoteElement changedValues];
                  _remoteElement = (RemoteElement *)[self.context
                                           existingObjectWithID:remoteElement.objectID
                                                          error:&error];

                  if (error)
                  MSLogError(@"%@ error unfaulting model object: %@ - %@",
                       ClassTagSelectorString, error, [error localizedFailureReason]);
        else if (_remoteElement.parentElement) {
                  _parentConstraintsObserver = [MSKVOReceptionist
                                          receptionistForObject:_remoteElement.parentElement
                                                        keyPath:@"constraints"
                                                        options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                                                        context:NULL
                                                        handler:^(MSKVOReceptionist * r, NSString * k, id o, NSDictionary * c, void * ctx) {
                                                            MSLogDebug(
                                                            @"%@ parent element '%@' constraints changed",
                                                            ClassTagSelectorString,
                                                            _remoteElement.parentElement.displayName);
                  }

                                                          queue:MainQueue];
                  }
              }];
}

/*
 * Removes any existing `sourceView` and `mockParentView` then manages adding the new `sourceView`
 * to root view, creating a new `mockParentView` for its `superview` if appropriate
 * @param sourceView `RemoteElementView` for `remoteElement` to set as the `sourceView`
 */
- (void)setSourceView:(RemoteElementView *)sourceView {
    if (_sourceView == sourceView) return;

    if (_sourceView) {
        [_sourceView removeFromSuperview];
        [_mockParentView removeFromSuperview];
        self.mockParentView = nil;
    }

    _sourceView = sourceView;
    assert(_sourceView);

#ifdef COLOR_SOURCEVIEW_BACKGROUND
    _sourceView.backgroundColor = SOURCEVIEW_DEBUG_COLOR;
#endif

    CGFloat   barHeight = self.topToolbar.intrinsicContentSize.height;

    _flags.allowableSourceViewYOffset = MSBoundaryMake(-barHeight, barHeight);

    self.mockParentView = [[UIView alloc] initWithFrame:(CGRect) {.size = _mockParentSize}
                          ];
#ifdef COLOR_CONTAINER_BACKGROUND
    _mockParentView.backgroundColor = CONTAINER_DEBUG_COLOR;
#endif
    _mockParentView.nametag                                   = @"mockParentView";
    _mockParentView.translatesAutoresizingMaskIntoConstraints = NO;
    __weak RemoteElementEditingViewController * weakSelf = self;
    _sourceViewBoundsObserver = [MSKVOReceptionist
                                 receptionistForObject:_sourceView.layer
                                               keyPath:@"bounds"
                                               options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                                               context:NULL
                                               handler:^(MSKVOReceptionist * r, NSString * k, id o, NSDictionary * c, void * ctx) {
                                                   [weakSelf updateBoundaryLayer];
                                               }

                                                 queue:MainQueue];
    [self.view insertSubview:_mockParentView atIndex:0];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsByParsingString:$(@"mockParentView.centerX = view.centerX\n"
                                                      "mockParentView.centerY = view.centerY\n"
                                                      "mockParentView.width = %f\n"
                                                      "mockParentView.height = %f",
                                                      _mockParentSize.width, _mockParentSize.height)
                                              views:@{@"mockParentView" : _mockParentView, @"view" : self.view}]];
    [self.view setNeedsLayout];
    [_mockParentView addSubview:_sourceView];

    if (_remoteElement.parentElement) {
        NSSet * parentConstraints = [_remoteElement.firstItemConstraints
                                     objectsPassingTest:^BOOL (RemoteElementLayoutConstraint * obj, BOOL * stop) {
            return (obj.secondItem == _remoteElement.parentElement);
        }];

        for (RemoteElementLayoutConstraint * constraint in parentConstraints) {
            NSLayoutConstraint * c = [NSLayoutConstraint constraintWithItem:_sourceView
                                                                  attribute:constraint.firstAttribute
                                                                  relatedBy:constraint.relation
                                                                     toItem:_mockParentView
                                                                  attribute:constraint.secondAttribute
                                                                 multiplier:constraint.multiplier
                                                                   constant:constraint.constant];

            c.priority = constraint.priority;
            c.nametag  = kParentConstraintNametag;
            [_mockParentView addConstraint:c];
        }
    } else {
        [_mockParentView addConstraints:
         [NSLayoutConstraint constraintsByParsingString:
          $(@"'%@' sourceView.centerX = mockParentView.centerX\n'%@' sourceView.centerY = mockParentView.centerY + %f",
            kCenterXConstraintNametag,
            kCenterYConstraintNametag,
            _flags.allowableSourceViewYOffset.upper)
                                                  views:(@{@"mockParentView" : _mockParentView,
                                                           @"sourceView" : _sourceView})]];
        self.sourceViewCenterYConstraint = [_mockParentView constraintWithNametag:kCenterYConstraintNametag];
        self.sourceViewCenterXConstraint = [_mockParentView constraintWithNametag:kCenterXConstraintNametag];
    }

    [self.view.layer addSublayer:_sourceViewBoundsLayer];
}  /* setSourceView */

/*
 * Sets the view used for the basis of alignment/resizing operations involving the current selection
 * of views.
 * @param focusView `RemoteElementView` to set as the focus
 */
- (void)setFocusView:(RemoteElementView *)focusView {
    if (focusView != _focusView) {
        if (_focusView) _focusView.editingStyle = EditingStyleSelected;

        _focusView = focusView;

        if (_focusView) _focusView.editingStyle = EditingStyleFocus;

        [self updateState];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Dialogs
////////////////////////////////////////////////////////////////////////////////

- (UIView *)multiselectView {
    if (!_multiselectView) {
        self.multiselectView = [[UIView alloc] initWithFrame:(CGRect){0,0,280,320}];
        assert(_multiselectView);
        _multiselectView.backgroundColor = [LightGrayColor colorWithAlphaComponent:0.75];
        _multiselectView.hidden          = YES;
        [self.view addSubview:_multiselectView];
        PrepConstraints(_multiselectView);
        ConstrainSize(_multiselectView, 320, 280);
        [self.view addConstraints:
         [NSLayoutConstraint constraintsByParsingString:
          @"'multiselect-centerX' view.centerX = self.centerX\n"
          "'multiselect-centerY' view.centerY = self.centerY"
                                                  views:@{@"self": self.view,
                                                          @"view": _multiselectView}]];
    }

    return _multiselectView;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    static NSSet const     * menuDefaults = nil;
    static dispatch_once_t   onceToken;
    dispatch_once(&onceToken, ^{
        menuDefaults = [NSSet setWithObjects:
                        NSStringFromSelector(@selector(cut:)),
                        NSStringFromSelector(@selector(copy:)),
                        NSStringFromSelector(@selector(select:)),
                        NSStringFromSelector(@selector(selectAll:)),
                        NSStringFromSelector(@selector(paste:)),
                        NSStringFromSelector(@selector(delete:)),
                        nil];
    });

    if (_flags.menuState == REEditingMenuStateStackedViews)
        return ([NSStringFromSelector(action) hasPrefix:@"menuAction_"]);
    else
        return [super canPerformAction:action withSender:sender];
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark Debugging
////////////////////////////////////////////////////////////////////////////////
@implementation RemoteElementEditingViewController (Debugging)

- (void)logSourceViewAfter:(dispatch_time_t)delay message:(NSString *)message {
    dispatch_time_t   popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));

    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        MSLogDebug(@"%@\n%@\n\n%@\n\n%@\n\n%@\n\n%@\n",
                   ClassTagSelectorString,
                   [message dividerWithCharacterString:@"#"],
                   [_sourceView constraintsDescription],
                   [_sourceView framesDescription],
                   [@"subelements" dividerWithCharacterString: @"#"],
                   [[_sourceView.subelementViews valueForKeyPath:@"constraintsDescription"] componentsJoinedByString:@"\n\n"]);
    });
}

@end
