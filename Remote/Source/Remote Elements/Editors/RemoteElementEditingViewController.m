//
// RemoteElementEditingViewController.m
//
//
// Created by Jason Cardwell on 4/20/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteElementEditingViewController_Private.h"

#define SOURCEVIEW_DEBUG_COLOR RedColor
// #define COLOR_SOURCEVIEW_BACKGROUND

#define CONTAINER_DEBUG_COLOR OrangeColor
// #define COLOR_CONTAINER_BACKGROUND

static int         ddLogLevel   = LOG_LEVEL_DEBUG;
static const int    msLogContext = (LOG_CONTEXT_EDITOR|LOG_CONTEXT_FILE);
// static const int ddLogLevel = DefaultDDLogLevel;

MSSTATIC_STRING_CONST   kCenterXConstraintNametag = @"kCenterXConstraintNametag";
MSSTATIC_STRING_CONST   kCenterYConstraintNametag = @"kCenterYConstraintNametag";
MSSTATIC_STRING_CONST   kParentConstraintNametag  = @"kParentConstraintNametag";

@implementation RemoteElementEditingViewController {
    UIView              * _referenceView;
    MSKVOReceptionist   * _parentConstraintsObserver;
    MSKVOReceptionist   * _sourceViewBoundsObserver;
    NSMutableDictionary * _maxSizeCache;
    NSMutableDictionary * _minSizeCache;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialization and loading
///@name Initialization and loading
////////////////////////////////////////////////////////////////////////////////

+ (Class)subelementClass { return [RemoteElementView class]; }

+ (Class)elementClass { return [RemoteElementView class]; }

+ (REEditingMode)editingModeForElement { return REEditingModeNotEditing; }

- (void)awakeFromNib { [self initializeIVARs]; }

- (void)initializeIVARs
{
    _flags.showSourceBoundary  = YES;
    self.selectedViews         = [NSMutableSet set];
    self.selectionInProgress   = [NSMutableSet set];
    self.deselectionInProgress = [NSMutableSet set];
    _maxSizeCache              = [NSMutableDictionary dictionaryWithCapacity:10];
    _minSizeCache              = [NSMutableDictionary dictionaryWithCapacity:10];
}

- (void)viewDidLoad
{

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

    if (CGRectIsEmpty(_flags.contentRect))
    {
        _referenceView     = self.view;
        _flags.contentRect =
        CGRectMake(_referenceView.frame.origin.x,
                   _topToolbar.bounds.size.height,
                   _referenceView.frame.size.width,
                   _referenceView.frame.size.height - (  _topToolbar.bounds.size.height
                                                       + _currentToolbar.bounds.size.height));
    }

    if (self.remoteElement)
    {
        self.sourceView = [[[self class] elementClass] viewWithModel:self.remoteElement];
    }
}

- (void)viewDidLayoutSubviews { [self updateBoundaryLayer]; }

- (BOOL)canBecomeFirstResponder { return YES; }

- (void)registerForNotifications
{
    [NotificationCenter addObserverForName:UIMenuControllerDidHideMenuNotification
                                    object:MenuController
                                     queue:MainQueue
                                usingBlock:^(NSNotification *note) {
                                    _flags.menuState = REEditingMenuStateDefault;
                                }];
}

- (void)dealloc { [NotificationCenter removeObserver:self]; }

- (id)forwardingTargetForSelector:(SEL)selector
{
    if (MSSelectorInProtocol(selector, @protocol(UIGestureRecognizerDelegate), NO, YES))
        return self.gestureManager;
    else
        return [super forwardingTargetForSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    if ([SelectorString(selector) hasPrefix:@"menuAction_"])
        return [self methodSignatureForSelector:@selector(menuAction:)];
    else
        return [super methodSignatureForSelector:selector];
}

- (BOOL)respondsToSelector:(SEL)selector
{
    if (   [SelectorString(selector) hasPrefix:@"menuAction_"]
        || MSSelectorInProtocol(selector, @protocol(UIGestureRecognizerDelegate), NO, YES))
        return YES;
    else
        return [super respondsToSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    SEL selector = [invocation selector];
    NSString * action = SelectorString(selector);
    if ([action hasPrefix:@"menuAction_"]) {
        [invocation setSelector:@selector(menuAction:)];
        NSString * identifier = [action stringByReplacingOccurrencesOfRegEx:@"(?:menuAction)|(?::)"
                                                                withString:@""];
        RemoteElementView * view = _sourceView[identifier];
        assert(view);
        [invocation setSelector:@selector(menuAction:)];
        [invocation setTarget:self];
        [invocation setArgument:&view atIndex:2];
        [invocation invoke];
    } else
        [super forwardInvocation:invocation];
}

- (void)viewDidAppear:(BOOL)animated
{
    assert(_sourceView);
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
    [self registerForNotifications];

    CGFloat   sourceHeight   = _sourceView.bounds.size.height;
    CGFloat   viewHeight     = self.view.bounds.size.height;
    CGFloat   boundarySize   = MSBoundarySizeOfBoundary(_flags.allowableSourceViewYOffset);
    BOOL      gestureEnabled = (sourceHeight < viewHeight - boundarySize ? NO : YES);

    _twoTouchPanGesture.enabled = gestureEnabled;

    [self updateState];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self resignFirstResponder];
    [NotificationCenter removeObserver:self
                                  name:UIMenuControllerDidHideMenuNotification
                                object:MenuController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    MSLogWarnTag(@"Is view loaded? %@", BOOLString([self isViewLoaded]));
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Updating UI State
///@name Updating UI State
////////////////////////////////////////////////////////////////////////////////

- (void)updateBoundaryLayer
{
//    CGRect frame = (CGRectIsEmpty(_sourceView.frame) ? self.view.frame : _sourceView.frame);
    _sourceViewBoundsLayer.path   = [UIBezierPath bezierPathWithRect:_sourceView.frame].CGPath;
    _sourceViewBoundsLayer.hidden = !_flags.showSourceBoundary;
}

- (void)updateState
{
    [self updateBarButtonItems];
    [self updateToolbarDisplayed];
    [self updateBoundaryLayer];
    [self updateGesturesEnabled];
}

- (void)clearCacheForViews:(NSSet *)views
{
    NSArray * identifiers = [[views valueForKeyPath:@"uuid"] allObjects];
    [_maxSizeCache removeObjectsForKeys:identifiers];
    [_minSizeCache removeObjectsForKeys:identifiers];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Moving the selected views
///@name Moving the selected views
////////////////////////////////////////////////////////////////////////////////

- (BOOL)shouldTranslateSelectionFrom:(CGRect)fromUnion to:(CGRect)toUnion
{
    return CGRectContainsRect(_flags.contentRect, toUnion);
}

- (void)translateSelectedViews:(CGPoint)translation
{
    if (CGPointEqualToPoint(translation, CGPointZero)) return;

    CGRect translatedFrame =
        CGRectApplyAffineTransform(_flags.currentFrame,
                                   CGAffineTransformMakeTranslation(translation.x, translation.y));

    if ([self shouldTranslateSelectionFrom:_flags.currentFrame to:translatedFrame])
    {
        _flags.currentFrame = translatedFrame;

        for (RemoteElementView * view in _selectedViews)
            view.frame =
                CGRectApplyAffineTransform(view.frame,
                                           CGAffineTransformMakeTranslation(translation.x,
                                                                            translation.y));
    }
}

- (void)willTranslateSelectedViews
{
    [_sourceView willTranslateViews:_selectedViews];
    _flags.originalFrame = [self selectedViewsUnionFrameInView:self.view];
    _flags.currentFrame  = _flags.originalFrame;
}

- (void)didTranslateSelectedViews
{
    [self clearCacheForViews:_selectedViews];
    [_sourceView didTranslateViews:_selectedViews];

    // inform source view of translation
    CGPoint   translation = CGPointGetDelta(_flags.currentFrame.origin, _flags.originalFrame.origin);

    [_sourceView translateSubelements:_selectedViews translation:translation];

    // update editing style for selected views
    [_selectedViews setValue:@(REEditingStateSelected) forKeyPath:@"editingState"];

    // udpate state
    _flags.movingSelectedViews = NO;
    [self updateState];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Scaling the selected views
///@name Scaling the selected views
////////////////////////////////////////////////////////////////////////////////

- (CGFloat)scaleSelectedViews:(CGFloat)scale
                   validation:(BOOL (^)(RemoteElementView *, CGSize, CGSize *, CGSize *))isValidSize
{
     MSLogDebugTag(@"scale: %.2f", scale);

    if (!isValidSize) {
        // create default block for testing scale validity
        isValidSize = ^BOOL (RemoteElementView * view, CGSize size, CGSize * max, CGSize * min)
                     {
                         CGRect frame = [view convertRect:view.frame toView:nil];


                         if (_maxSizeCache[view.uuid] && _minSizeCache[view.uuid])
                         {
                             *max = CGSizeValue(_maxSizeCache[view.uuid]);
                             *min = CGSizeValue(_minSizeCache[view.uuid]);
                         }

                         else
                         {
                             CGSize deltaMax = CGSizeGetDelta(frame.size, view.maximumSize);
                             CGRect maxFrame = (CGRect){
                                 .origin = (CGPoint){
                                     .x = frame.origin.x + deltaMax.width/2.0f,
                                     .y = frame.origin.y + deltaMax.height/2.0f
                                 },
                                 .size = view.maximumSize
                             };

                             if (!CGRectContainsRect(_flags.contentRect, maxFrame))
                             {
                                 CGRect intersection = CGRectIntersection(_flags.contentRect,
                                                                          maxFrame);
                                 CGPoint deltaMin =
                                     CGPointDeltaPointABS(CGPointMake(CGRectGetMinX(frame),
                                                                      CGRectGetMinY(frame)),
                                                          CGPointMake(CGRectGetMinX(intersection),
                                                                      CGRectGetMinY(intersection)));

                                 CGPoint deltaMax =
                                     CGPointDeltaPointABS(CGPointMake(CGRectGetMaxX(frame),
                                                                      CGRectGetMaxY(frame)),
                                                          CGPointMake(CGRectGetMaxX(intersection),
                                                                      CGRectGetMaxY(intersection)));

                                 *max = (CGSize){
                                     .width  = frame.size.width  + MIN(deltaMin.x, deltaMax.x) * 2.0f,
                                     .height = frame.size.height + MIN(deltaMin.y, deltaMax.y) * 2.0f
                                 };

                                 if (view.proportionLock)
                                 {
                                     if (max->width < max->height)
                                         max->height = frame.size.height/frame.size.width*max->width;
                                     else
                                         max->width  = frame.size.width/frame.size.height*max->height;
                                 }
                             }

                             else
                                 *max = view.maximumSize;

                             *min = view.minimumSize;

                             _maxSizeCache[view.uuid] = NSValueWithCGSize(*max);
                             _minSizeCache[view.uuid] = NSValueWithCGSize(*min);
                         }

                         BOOL     valid   = (   size.width  <= max->width
                                             && size.height <= max->height
                                             && size.width  >= min->width
                                             && size.height >= min->height);
                         if(!valid)
                              MSLogDebugTag(@"invalid size, %.2f x %.2f, for subelement view '%@'; "
                                            "min:%.2f x %.2f; max:%.2f x %.2f current:%.2f x %.2f",
                                            size.width,
                                            size.height,
                                            view.name,
                                            min->width,
                                            min->height,
                                            max->width,
                                            max->height,
                                            view.bounds.size.width,
                                            view.bounds.size.height);

                         return valid;
                     };
    }

    NSMutableArray * scaleRejections = [@[] mutableCopy];

    for (RemoteElementView * view in _selectedViews)
    {
        CGSize   scaledSize = CGSizeApplyAffineTransform(view.bounds.size,
                                                         CGAffineTransformMakeScale(scale, scale));

        CGSize maxSize, minSize;
        BOOL valid = isValidSize(view, scaledSize, &maxSize, &minSize);

        if (!_maxSizeCache[view.uuid] || !_minSizeCache[view.uuid])
        {
            _maxSizeCache[view.uuid] = NSValueWithCGSize(maxSize);
            _minSizeCache[view.uuid] = NSValueWithCGSize(minSize);
        }

        if (!valid)
        {
            CGSize boundedSize = (scale > 1.0f
                        ? CGSizeMakeSquare(CGSizeMinAxis(maxSize))
                        : CGSizeMakeSquare(CGSizeMaxAxis(minSize)));
            CGFloat validScale = boundedSize.width / view.bounds.size.width;
            if (view.proportionLock) assert(boundedSize.height/view.bounds.size.height == validScale);

            [scaleRejections addObject:@(validScale)];
        }
    }

    CGFloat appliedScale = (scaleRejections.count
                            ? (scale > 1.0f
                               ? CGFloatValue([scaleRejections valueForKeyPath:@"@min.self"])
                               : CGFloatValue([scaleRejections valueForKeyPath:@"@max.self"]))
                            : scale);

     MSLogDebugTagIf((scale != appliedScale),
                     @"scale adjusted to remain valid: %@ \u27F9 %@",
                     PrettyFloat(scale),
                     PrettyFloat(appliedScale));

    for (RemoteElementView * view in _selectedViews) [view scale:appliedScale];

    _flags.appliedScale = appliedScale;

    return appliedScale;
}

- (void)willScaleSelectedViews
{
    [_sourceView willScaleViews:_selectedViews];
    _flags.appliedScale = 1.0;
}

- (void)didScaleSelectedViews { [_sourceView didScaleViews:_selectedViews]; }

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Aligning the selected views
///@name Aligning the selected views
////////////////////////////////////////////////////////////////////////////////

- (void)alignSelectedViews:(NSLayoutAttribute)alignment
{
    assert(_focusView);
    [self willAlignSelectedViews];
    [_sourceView alignSubelements:[_selectedViews setByRemovingObject:_focusView]
                        toSibling:_focusView attribute:alignment];
    [self didAlignSelectedViews];
}

- (void)willAlignSelectedViews
{
    [_sourceView willAlignViews:_selectedViews];
#ifdef DEBUG_ALIGNMENT
    [self logSourceViewAfter:0 message:@"before alignment"];
#endif
}

- (void)didAlignSelectedViews
{
    [self clearCacheForViews:_selectedViews];
    [_sourceView didAlignViews:_selectedViews];
#ifdef DEBUG_ALIGNMENT
    [self logSourceViewAfter:5.0 message:@"after alignment"];
#endif
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Resizing the selected views to match focus view
////////////////////////////////////////////////////////////////////////////////

- (void)resizeSelectedViews:(NSLayoutAttribute)axis
{
    assert(_focusView);
    [_sourceView resizeSubelements:[_selectedViews setByRemovingObject:_focusView]
                         toSibling:_focusView attribute:axis];
}

- (void)willResizeSelectedViews { [_sourceView willResizeViews:_selectedViews]; }

- (void)didResizeSelectedViews { [_sourceView didResizeViews:_selectedViews]; }

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Custom accessors
////////////////////////////////////////////////////////////////////////////////

/*
 * Creates a new child context for `remoteElement.managedObjectContext`, gets existing object from
 * the context and observes `constraints` property of the element's parent element
 * @param remoteElement `RemoteElement` to edit
 */
- (void)setRemoteElement:(RemoteElement *)remoteElement
{
    assert(remoteElement);
    self.context = [NSManagedObjectContext MR_contextWithParent:remoteElement.managedObjectContext];
    [_context MR_setWorkingName:ClassString([self class])];
    [_context performBlockAndWait:
     ^{
         self.changedModelValues = [remoteElement changedValues];
         _remoteElement = (RemoteElement *)[remoteElement faultedObject];

         if (_remoteElement.parentElement)
         {
             _parentConstraintsObserver =
             [MSKVOReceptionist
              receptionistForObject:_remoteElement.parentElement
              keyPath:@"constraints"
              options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
              context:NULL
              queue:MainQueue
              handler:MSMakeKVOHandler({MSLogVerboseTag(@"parent element '%@' constraints changed",
                                                        _remoteElement.parentElement.name);})];
         }

    }];
}

/*
 * Removes any existing `sourceView` and `mockParentView` then manages adding the new `sourceView`
 * to root view, creating a new `mockParentView` for its `superview` if appropriate
 * @param sourceView `REView` for `remoteElement` to set as the `sourceView`
 */
- (void)setSourceView:(RemoteElementView *)sourceView
{
    if (_sourceView == sourceView) return;

    if (_sourceView)
    {
        [_sourceView removeFromSuperview];
        [_mockParentView removeFromSuperview];
        self.mockParentView = nil;
    }

    _sourceView = sourceView;
    assert(_sourceView);

    _sourceView.editingMode = [[self class] editingModeForElement];

#ifdef COLOR_SOURCEVIEW_BACKGROUND
    _sourceView.backgroundColor = SOURCEVIEW_DEBUG_COLOR;
#endif

    CGFloat   barHeight = self.topToolbar.intrinsicContentSize.height;

    _flags.allowableSourceViewYOffset = MSBoundaryMake(-barHeight, barHeight);

    self.mockParentView = [[UIView alloc]
                           initForAutoLayoutWithFrame:(CGRect) {.size = self.mockParentSize}];
#ifdef COLOR_CONTAINER_BACKGROUND
    _mockParentView.backgroundColor = CONTAINER_DEBUG_COLOR;
#endif
    _mockParentView.nametag = @"mockParentView";
    __weak RemoteElementEditingViewController * weakSelf = self;
    _sourceViewBoundsObserver = [MSKVOReceptionist
                                 receptionistForObject:_sourceView.layer
                                               keyPath:@"bounds"
                                               options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                                               context:NULL
                                                 queue:MainQueue
                                               handler:MSMakeKVOHandler({
                                                   [weakSelf updateBoundaryLayer];
                                               })];

    [_mockParentView addSubview:_sourceView];

    if (_remoteElement.parentElement)
    {
        NSSet * parentConstraints = [_remoteElement.firstItemConstraints objectsPassingTest:
                                     ^BOOL (Constraint * obj, BOOL * stop)
                                     {
                                         return (obj.secondItem == _remoteElement.parentElement);
                                     }];

        for (Constraint * constraint in parentConstraints)
        {
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
    }

    else
    {
        [_mockParentView addConstraints:
         [NSLayoutConstraint
          constraintsByParsingString:$(@"'%@' sourceView.centerX = mockParentView.centerX\n"
                                       "'%@' sourceView.centerY = mockParentView.centerY + %f",
                                       kCenterXConstraintNametag,
                                       kCenterYConstraintNametag,
                                       _flags.allowableSourceViewYOffset.upper)
                               views:(@{@"mockParentView" : _mockParentView,
                                      @"sourceView" : _sourceView})]];
        
        self.sourceViewCenterYConstraint = [_mockParentView
                                            constraintWithNametag:kCenterYConstraintNametag];
    }

//    [_sourceView setNeedsUpdateConstraints];
//    [_sourceView updateConstraintsIfNeeded];
    [self.view insertSubview:_mockParentView belowSubview:_topToolbar];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsByParsingString:$(@"mockParentView.centerX = view.centerX\n"
                                                      "mockParentView.centerY = view.centerY\n"
                                                      "mockParentView.width = %f\n"
                                                      "mockParentView.height = %f",
                                                      self.mockParentSize.width, self.mockParentSize.height)
                                              views:@{@"mockParentView" : _mockParentView,
      @"view"           : self.view}]];
//    [self.view setNeedsLayout];

    [self.view.layer addSublayer:_sourceViewBoundsLayer];

//    [self.view layoutSubviews];
}

/*
 * Sets the view used for the basis of alignment/resizing operations involving the current selection
 * of views.
 * @param focusView `REView` to set as the focus
 */
- (void)setFocusView:(RemoteElementView *)focusView
{
    if (focusView != _focusView)
    {
        if (_focusView) _focusView.editingState = REEditingStateSelected;
        _focusView = focusView;
        if (_focusView) _focusView.editingState = REEditingStateFocus;
        [self updateState];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Dialogs
////////////////////////////////////////////////////////////////////////////////

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    static NSSet const * menuDefaults = nil;
    static dispatch_once_t   onceToken;
    dispatch_once(&onceToken,
                  ^{
                      menuDefaults = [NSSet setWithObjects:SelectorString(@selector(cut:)),
                                                           SelectorString(@selector(copy:)),
                                                           SelectorString(@selector(select:)),
                                                           SelectorString(@selector(selectAll:)),
                                                           SelectorString(@selector(paste:)),
                                                           SelectorString(@selector(delete:)), nil];
                  });

    if (_flags.menuState == REEditingMenuStateStackedViews)
        return ([SelectorString(action) hasPrefix:@"menuAction_"]);
    else
        return [super canPerformAction:action withSender:sender];
}

- (void)openSubelementInEditor:(RemoteElement *)subelement {}

////////////////////////////////////////////////////////////////////////////////
#pragma mark REEditingDelegate
////////////////////////////////////////////////////////////////////////////////

- (void)remoteElementEditorDidSave:(RemoteElementEditingViewController *)remoteElementEditor
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)remoteElementEditorDidCancel:(RemoteElementEditingViewController *)remoteElementEditor
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark Debugging
////////////////////////////////////////////////////////////////////////////////
@implementation RemoteElementEditingViewController (Debugging)

- (void)logSourceViewAfter:(dispatch_time_t)delay message:(NSString *)message
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   ^{
                       MSLogDebugTag(@"%@\n%@\n\n%@\n\n%@\n\n%@\n\n%@\n",
                                     ClassTagSelectorString,
                                     [message dividerWithCharacterString:@"#"],
                                     [_sourceView constraintsDescription],
                                     [_sourceView framesDescription],
                                     [@"subelements" dividerWithCharacterString: @"#"],
                                     [[_sourceView.subelementViews
                                       valueForKeyPath:@"constraintsDescription"]
                                      componentsJoinedByString:@"\n\n"]);
                   });
}

- (NSString *)shortDescription { return (_sourceView?_sourceView.name:[self description]); }

@end
