//
// RemoteElementEditingViewController.m
//
//
// Created by Jason Cardwell on 4/20/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteElementEditingViewController_Private.h"
#import "Remote.h"
#import "MSRemoteAppController.h"
#import "REPresetCollectionViewController.h"
#import "ViewDecorator.h"
#import "RemoteElementView.h"
#import "StoryboardProxy.h"
#import "REBackgroundEditingViewController.h"

static int       ddLogLevel   = LOG_LEVEL_DEBUG;
static const int msLogContext = (LOG_CONTEXT_EDITOR | LOG_CONTEXT_FILE);

MSSTATIC_STRING_CONST kCenterXConstraintNametag = @"kCenterXConstraintNametag";
MSSTATIC_STRING_CONST kCenterYConstraintNametag = @"kCenterYConstraintNametag";
MSSTATIC_STRING_CONST kParentConstraintNametag  = @"kParentConstraintNametag";

@implementation RemoteElementEditingViewController {
  UIView              * _referenceView;
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

- (void)initializeIVARs {
  _flags.showSourceBoundary  = YES;
  self.selectedViews         = [NSMutableSet set];
  self.selectionInProgress   = [NSMutableSet set];
  self.deselectionInProgress = [NSMutableSet set];
  _maxSizeCache              = [NSMutableDictionary dictionaryWithCapacity:10];
  _minSizeCache              = [NSMutableDictionary dictionaryWithCapacity:10];
}

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

  if (CGRectIsEmpty(_flags.contentRect)) {
    _referenceView     = self.view;
    _flags.contentRect =
      CGRectMake(_referenceView.frame.origin.x,
                 _topToolbar.bounds.size.height,
                 _referenceView.frame.size.width,
                 _referenceView.frame.size.height - (_topToolbar.bounds.size.height
                                                     + _currentToolbar.bounds.size.height));
  }

  if (self.remoteElement) {
    self.sourceView = [[[self class] elementClass] viewWithModel:self.remoteElement];
  }
}

- (void)viewDidLayoutSubviews { [self updateBoundaryLayer]; }

- (BOOL)canBecomeFirstResponder { return YES; }

- (void)registerForNotifications {
  __weak RemoteElementEditingViewController * weakself = self;
  [NotificationCenter addObserverForName:UIMenuControllerDidHideMenuNotification
                                  object:MenuController
                                   queue:MainQueue
                              usingBlock:^(NSNotification * note) {
                                RemoteElementEditingViewController * strongself = weakself;
                                if (strongself)
                                  strongself->_flags.menuState = REEditingMenuStateDefault;
                              }];
}

- (void)dealloc { [NotificationCenter removeObserver:self]; }

- (id)forwardingTargetForSelector:(SEL)selector {
  if (MSSelectorInProtocol(selector, @protocol(UIGestureRecognizerDelegate), NO, YES))
    return self.gestureManager;
  else
    return [super forwardingTargetForSelector:selector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
  if ([SelectorString(selector) hasPrefix:@"menuAction_"])
    return [self methodSignatureForSelector:@selector(menuAction:)];
  else
    return [super methodSignatureForSelector:selector];
}

- (BOOL)respondsToSelector:(SEL)selector {
  if (  [SelectorString(selector) hasPrefix:@"menuAction_"]
     || MSSelectorInProtocol(selector, @protocol(UIGestureRecognizerDelegate), NO, YES))
    return YES;
  else
    return [super respondsToSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
  SEL        selector = [invocation selector];
  NSString * action   = SelectorString(selector);

  if ([action hasPrefix:@"menuAction_"]) {
    [invocation setSelector:@selector(menuAction:)];
    NSString * identifier = [action stringByReplacingRegEx:@"(?:menuAction)|(?::)"
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

- (void)viewDidAppear:(BOOL)animated {
  assert(_sourceView);
  [super viewDidAppear:animated];
  [self becomeFirstResponder];
  [self registerForNotifications];

  CGFloat sourceHeight   = _sourceView.bounds.size.height;
  CGFloat viewHeight     = self.view.bounds.size.height;
  CGFloat boundarySize   = MSBoundarySizeOfBoundary(_flags.allowableSourceViewYOffset);
  BOOL    gestureEnabled = (sourceHeight < viewHeight - boundarySize ? NO : YES);

  _twoTouchPanGesture.enabled = gestureEnabled;

  [self updateState];
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
  MSLogWarnTag(@"Is view loaded? %@", BOOLString([self isViewLoaded]));
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Updating UI State
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

- (void)clearCacheForViews:(NSSet *)views {
  NSArray * identifiers = [[views valueForKeyPath:@"uuid"] allObjects];
  [_maxSizeCache removeObjectsForKeys:identifiers];
  [_minSizeCache removeObjectsForKeys:identifiers];
}

#pragma mark - Moving the selected views
////////////////////////////////////////////////////////////////////////////////

- (BOOL)shouldTranslateSelectionFrom:(CGRect)fromUnion to:(CGRect)toUnion {
  return CGRectContainsRect(_flags.contentRect, toUnion);
}

- (void)translateSelectedViews:(CGPoint)translation {
  if (CGPointEqualToPoint(translation, CGPointZero)) return;

  CGRect translatedFrame =
    CGRectApplyAffineTransform(_flags.currentFrame,
                               CGAffineTransformMakeTranslation(translation.x, translation.y));

  if ([self shouldTranslateSelectionFrom:_flags.currentFrame to:translatedFrame]) {
    _flags.currentFrame = translatedFrame;

    for (RemoteElementView * view in _selectedViews)
      view.frame =
        CGRectApplyAffineTransform(view.frame,
                                   CGAffineTransformMakeTranslation(translation.x,
                                                                    translation.y));
  }
}

- (void)willTranslateSelectedViews {
  _flags.originalFrame = [self selectedViewsUnionFrameInView:self.view];
  _flags.currentFrame  = _flags.originalFrame;
}

- (void)didTranslateSelectedViews {
  [self clearCacheForViews:_selectedViews];

  // inform source view of translation
  CGPoint translation = CGPointGetDelta(_flags.currentFrame.origin, _flags.originalFrame.origin);

  [_sourceView translateSubelements:_selectedViews translation:translation];

  // update editing style for selected views
  [_selectedViews setValue:@(REEditingStateSelected) forKeyPath:@"editingState"];

  // udpate state
  _flags.movingSelectedViews = NO;
  [self updateState];
}

#pragma mark Scaling the selected views
////////////////////////////////////////////////////////////////////////////////

- (CGFloat)scaleSelectedViews:(CGFloat)scale
                   validation:(BOOL (^)(RemoteElementView *, CGSize, CGSize *, CGSize *))isValidSize {
  MSLogDebugTag(@"scale: %.2f", scale);

  if (!isValidSize) {
    // create default block for testing scale validity
    isValidSize = ^BOOL (RemoteElementView * view, CGSize size, CGSize * max, CGSize * min)
    {
      CGRect frame = [view convertRect:view.frame toView:nil];


      if (_maxSizeCache[view.uuid] && _minSizeCache[view.uuid]) {
        *max = CGSizeValue(_maxSizeCache[view.uuid]);
        *min = CGSizeValue(_minSizeCache[view.uuid]);
      } else {
        CGSize deltaMax = CGSizeGetDelta(frame.size, view.maximumSize);
        CGRect maxFrame = (CGRect) {
          .origin = (CGPoint) {
            .x = frame.origin.x + deltaMax.width / 2.0f,
            .y = frame.origin.y + deltaMax.height / 2.0f
          },
          .size = view.maximumSize
        };

        if (!CGRectContainsRect(_flags.contentRect, maxFrame)) {
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

          *max = (CGSize) {
            .width  = frame.size.width  + MIN(deltaMin.x, deltaMax.x) * 2.0f,
            .height = frame.size.height + MIN(deltaMin.y, deltaMax.y) * 2.0f
          };

          if (view.proportionLock) {
            if (max->width < max->height)
              max->height = frame.size.height / frame.size.width * max->width;
            else
              max->width = frame.size.width / frame.size.height * max->height;
          }
        } else
          *max = view.maximumSize;

        *min = view.minimumSize;

        _maxSizeCache[view.uuid] = NSValueWithCGSize(*max);
        _minSizeCache[view.uuid] = NSValueWithCGSize(*min);
      }

      BOOL valid = (  size.width  <= max->width
                   && size.height <= max->height
                   && size.width  >= min->width
                   && size.height >= min->height);

      if (!valid)
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

  for (RemoteElementView * view in _selectedViews) {
    CGSize scaledSize = CGSizeApplyAffineTransform(view.bounds.size,
                                                   CGAffineTransformMakeScale(scale, scale));

    CGSize maxSize, minSize;
    BOOL   valid = isValidSize(view, scaledSize, &maxSize, &minSize);

    if (!_maxSizeCache[view.uuid] || !_minSizeCache[view.uuid]) {
      _maxSizeCache[view.uuid] = NSValueWithCGSize(maxSize);
      _minSizeCache[view.uuid] = NSValueWithCGSize(minSize);
    }

    if (!valid) {
      CGSize boundedSize = (scale > 1.0f
                            ? CGSizeMakeSquare(CGSizeMinAxis(maxSize))
                            : CGSizeMakeSquare(CGSizeMaxAxis(minSize)));
      CGFloat validScale = boundedSize.width / view.bounds.size.width;

      if (view.proportionLock) assert(boundedSize.height / view.bounds.size.height == validScale);

      [scaleRejections addObject:@(validScale)];
    }
  }

  CGFloat appliedScale = (scaleRejections.count
                          ? (scale > 1.0f
                             ? FloatValue([scaleRejections valueForKeyPath:@"@min.self"])
                             : FloatValue([scaleRejections valueForKeyPath:@"@max.self"]))
                          : scale);

  MSLogDebugTagIf((scale != appliedScale),
                  @"scale adjusted to remain valid: %@ \u27F9 %@",
                  PrettyFloat(scale),
                  PrettyFloat(appliedScale));

  for (RemoteElementView * view in _selectedViews) [view scale:appliedScale];

  _flags.appliedScale = appliedScale;

  return appliedScale;
}

- (void)willScaleSelectedViews { _flags.appliedScale = 1.0; }
- (void)didScaleSelectedViews {}

#pragma mark Aligning the selected views
////////////////////////////////////////////////////////////////////////////////

- (void)alignSelectedViews:(NSLayoutAttribute)alignment {
  if (!_focusView) ThrowInvalidInternalInconsistency("there must be a view to align to");

  [self willAlignSelectedViews];
  [_sourceView alignSubelements:[_selectedViews setByRemovingObject:_focusView]
                      toSibling:_focusView
                      attribute:alignment];
  [self didAlignSelectedViews];
}

- (void)willAlignSelectedViews {}
- (void)didAlignSelectedViews { [self clearCacheForViews:_selectedViews]; }


#pragma mark Resizing the selected views to match focus view
////////////////////////////////////////////////////////////////////////////////

- (void)resizeSelectedViews:(NSLayoutAttribute)axis {
  if (!_focusView) ThrowInvalidInternalInconsistency("there must be a view to resize to");

  [_sourceView resizeSubelements:[_selectedViews setByRemovingObject:_focusView]
                       toSibling:_focusView attribute:axis];
}

- (void)willResizeSelectedViews {}
- (void)didResizeSelectedViews {}

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
  self.context     = [CoreDataManager childContextOfType:NSMainQueueConcurrencyType forContext:remoteElement.managedObjectContext];
  _context.nametag = ClassString([self class]);
  [_context performBlockAndWait:^{
    self.changedModelValues = [remoteElement changedValues];
    _remoteElement = (RemoteElement *)[_context existingObjectWithID:remoteElement.objectID error:nil];
  }];
}

/*
 * Removes any existing `sourceView` and `mockParentView` then manages adding the new `sourceView`
 * to root view, creating a new `mockParentView` for its `superview` if appropriate
 * @param sourceView `REView` for `remoteElement` to set as the `sourceView`
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

  _sourceView.editingMode = [[self class] editingModeForElement];

  CGFloat barHeight = self.topToolbar.intrinsicContentSize.height;

  _flags.allowableSourceViewYOffset = MSBoundaryMake(-barHeight, barHeight);

  self.mockParentView = [[UIView alloc]
                         initForAutoLayoutWithFrame:(CGRect) {.size = self.mockParentSize }];

  _mockParentView.nametag = @"mockParentView";
  __weak RemoteElementEditingViewController * weakSelf = self;
  _sourceViewBoundsObserver = [MSKVOReceptionist
                               receptionistWithObserver:self
                                              forObject:_sourceView.layer
                                                keyPath:@"bounds"
                                                options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                                  queue:MainQueue
                                                handler:^(MSKVOReceptionist * receptionist) {
                                                  [(RemoteElementEditingViewController *)receptionist.observer updateBoundaryLayer];
                                                }];

  [_mockParentView addSubview:_sourceView];

  if (_remoteElement.parentElement) {
    NSSet * parentConstraints = [_remoteElement.firstItemConstraints objectsPassingTest:
                                 ^BOOL (Constraint * obj, BOOL * stop)  {
                                   return (obj.secondItem == _remoteElement.parentElement);
                                 }];

    for (Constraint * constraint in parentConstraints) {
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
     [NSLayoutConstraint
      constraintsByParsingString:$(@"'%@' sourceView.centerX = mockParentView.centerX\n"
                                   "'%@' sourceView.centerY = mockParentView.centerY + %f",
                                   kCenterXConstraintNametag,
                                   kCenterYConstraintNametag,
                                   _flags.allowableSourceViewYOffset.upper)
                           views:(@{ @"mockParentView" : _mockParentView,
                                     @"sourceView" : _sourceView })]];

    self.sourceViewCenterYConstraint = [_mockParentView
                                        constraintWithNametag:kCenterYConstraintNametag];
  }

  [self.view insertSubview:_mockParentView belowSubview:_topToolbar];
  [self.view addConstraints:
   [NSLayoutConstraint constraintsByParsingString:$(@"mockParentView.centerX = view.centerX\n"
                                                    "mockParentView.centerY = view.centerY\n"
                                                    "mockParentView.width = %f\n"
                                                    "mockParentView.height = %f",
                                                    self.mockParentSize.width, self.mockParentSize.height)
                                            views:@{ @"mockParentView" : _mockParentView,
                                                     @"view"           : self.view }]];

  [self.view.layer addSublayer:_sourceViewBoundsLayer];

}

/*
 * Sets the view used for the basis of alignment/resizing operations involving the current selection
 * of views.
 * @param focusView `REView` to set as the focus
 */
- (void)setFocusView:(RemoteElementView *)focusView {
  if (focusView != _focusView) {
    if (_focusView) _focusView.editingState = REEditingStateSelected;

    _focusView = focusView;

    if (_focusView) _focusView.editingState = REEditingStateFocus;

    [self updateState];
  }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Dialogs
////////////////////////////////////////////////////////////////////////////////

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
  static NSSet const   * menuDefaults = nil;
  static dispatch_once_t onceToken;
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

- (void)remoteElementEditorDidSave:(RemoteElementEditingViewController *)remoteElementEditor {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)remoteElementEditorDidCancel:(RemoteElementEditingViewController *)remoteElementEditor {
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark Debugging
////////////////////////////////////////////////////////////////////////////////
@implementation RemoteElementEditingViewController (Debugging)

- (void)logSourceViewAfter:(dispatch_time_t)delay message:(NSString *)message {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
                 dispatch_get_main_queue(),
                 ^{
    MSLogDebugTag(@"%@\n%@\n\n%@\n\n%@\n\n%@\n\n%@\n",
                  ClassTagSelectorString,
                  message,
                  [_sourceView constraintsDescription],
                  [_sourceView framesDescription],
                  @"subelements",
                  [[_sourceView.subelementViews
                    valueForKeyPath:@"constraintsDescription"]
                   componentsJoinedByString:@"\n\n"]);
  });
}

- (NSString *)shortDescription { return (_sourceView ? _sourceView.name : [self description]); }

@end

#define UNDO_BUTTON_INDEX 2

#define MSLogDebugGesture                  \
  MSLogDebugTag(@"%@ state: %@",           \
                gestureRecognizer.nametag, \
                UIGestureRecognizerStateString(gestureRecognizer.state));

@implementation RemoteElementEditingViewController (Gestures)

- (void)attachGestureRecognizers {
  self.gestures = [NSPointerArray weakObjectsPointerArray];

  // long press to translate selected views
  ////////////////////////////////////////////////////////////////////////////////
  self.longPressGesture = [[UILongPressGestureRecognizer alloc]
                           initWithTarget:self
                                   action:@selector(handleLongPress:)];
  _longPressGesture.nametag  = @"longPressGesture";
  _longPressGesture.delegate = self;
  [self.view addGestureRecognizer:_longPressGesture];
  [_gestures addPointer:(__bridge void *)(_longPressGesture)];

  // pinch to scale selected views
  ////////////////////////////////////////////////////////////////////////////////
  self.pinchGesture = [[UIPinchGestureRecognizer alloc]
                       initWithTarget:self
                               action:@selector(handlePinch:)];
  _pinchGesture.nametag  = @"pinchGesture";
  _pinchGesture.delegate = self;
  [self.view addGestureRecognizer:_pinchGesture];
  [_gestures addPointer:(__bridge void *)(_pinchGesture)];

  // double tap to set a focus view
  ////////////////////////////////////////////////////////////////////////////////
  self.oneTouchDoubleTapGesture = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                           action:@selector(handleTap:)];
  _oneTouchDoubleTapGesture.nametag              = @"oneTouchDoubleTapGesture";
  _oneTouchDoubleTapGesture.numberOfTapsRequired = 2;
  _oneTouchDoubleTapGesture.delegate             = self;
  [self.view addGestureRecognizer:_oneTouchDoubleTapGesture];
  [_gestures addPointer:(__bridge void *)(_oneTouchDoubleTapGesture)];

  /// drag/touch to select views
  ////////////////////////////////////////////////////////////////////////////////
  self.multiselectGesture = [[MSMultiselectGestureRecognizer alloc]
                             initWithTarget:self
                                     action:@selector(handleSelection:)];
  _multiselectGesture.nametag                = @"multiselectGesture";
  _multiselectGesture.delegate               = self;
  _multiselectGesture.maximumNumberOfTouches = 1;
  _multiselectGesture.minimumNumberOfTouches = 1;
  [_multiselectGesture requireGestureRecognizerToFail:_oneTouchDoubleTapGesture];
  [self.view addGestureRecognizer:_multiselectGesture];
  [_gestures addPointer:(__bridge void *)(_multiselectGesture)];

  /// anchored drag/touch to deselect views
  ////////////////////////////////////////////////////////////////////////////////
  self.anchoredMultiselectGesture = [[MSMultiselectGestureRecognizer alloc]
                                     initWithTarget:self
                                             action:@selector(handleSelection:)];
  _anchoredMultiselectGesture.nametag                       = @"anchoredMultiselectGesture";
  _anchoredMultiselectGesture.delegate                      = self;
  _anchoredMultiselectGesture.maximumNumberOfTouches        = 1;
  _anchoredMultiselectGesture.minimumNumberOfTouches        = 1;
  _anchoredMultiselectGesture.numberOfAnchorTouchesRequired = 1;
  [_pinchGesture requireGestureRecognizerToFail:_anchoredMultiselectGesture];
  [_multiselectGesture requireGestureRecognizerToFail:_anchoredMultiselectGesture];
  [self.view addGestureRecognizer:_anchoredMultiselectGesture];
  [_gestures addPointer:(__bridge void *)(_anchoredMultiselectGesture)];

  /// two finger pan to scroll if source view extends out of sight
  ////////////////////////////////////////////////////////////////////////////////
  self.twoTouchPanGesture = [[UIPanGestureRecognizer alloc]
                             initWithTarget:self
                                     action:@selector(handlePan:)];
  _twoTouchPanGesture.nametag                = @"twoTouchPanGesture";
  _twoTouchPanGesture.minimumNumberOfTouches = 2;
  _twoTouchPanGesture.maximumNumberOfTouches = 2;
  _twoTouchPanGesture.delegate               = self;
  [self.view addGestureRecognizer:_twoTouchPanGesture];
  [_twoTouchPanGesture requireGestureRecognizerToFail:_pinchGesture];
  [_multiselectGesture requireGestureRecognizerToFail:_twoTouchPanGesture];
  _twoTouchPanGesture.enabled = NO;
  [_gestures addPointer:(__bridge void *)(_twoTouchPanGesture)];

  /// long press to translate selected views
  ////////////////////////////////////////////////////////////////////////////////
  self.toolbarLongPressGesture = [[UILongPressGestureRecognizer alloc]
                                  initWithTarget:self
                                          action:@selector(handleLongPress:)];
  _toolbarLongPressGesture.nametag  = @"toolbarLongPressGesture";
  _toolbarLongPressGesture.delegate = self;
  [_longPressGesture requireGestureRecognizerToFail:_toolbarLongPressGesture];
  [_undoButton addGestureRecognizer:_toolbarLongPressGesture];
  [_gestures addPointer:(__bridge void *)(_toolbarLongPressGesture)];

  [self createGestureManager];

}

- (void)createGestureManager {
  NSMutableArray * gestureBlocks = [NSMutableArray arrayWithNullCapacity:_gestures.count];
  NSArray        * gestures      = @[_pinchGesture,
                                     _longPressGesture,
                                     _toolbarLongPressGesture,
                                     _twoTouchPanGesture,
                                     _oneTouchDoubleTapGesture,
                                     _multiselectGesture,
                                     _anchoredMultiselectGesture];
  __weak RemoteElementEditingViewController * weakSelf = self;

  #define ShouldBegin                   @(MSGestureManagerResponseTypeBegin)
  #define ShouldReceiveTouch            @(MSGestureManagerResponseTypeReceiveTouch)
  #define ShouldRecognizeSimultaneously @(MSGestureManagerResponseTypeRecognizeSimultaneously)

  #define RecognizeSimultaneouslyBlock(name)                                                   \
    (MSGestureManagerBlock) ^ BOOL(UIGestureRecognizer * gesture, UIGestureRecognizer * other) \
    {                                                                                          \
      return [name isEqualToString:other.nametag];                                             \
    }

  #define ReceiveTouchBlock(condition)                                             \
    (MSGestureManagerBlock) ^ BOOL(UIGestureRecognizer * gesture, UITouch * touch) \
    {                                                                              \
      return condition;                                                            \
    }

  #define ShouldBeginBlock(condition)                                        \
    (MSGestureManagerBlock) ^ BOOL(UIGestureRecognizer * gesture, id unused) \
    {                                                                        \
      return condition;                                                      \
    }

  // general blocks

  MSGestureManagerBlock notMovingBlock = ShouldBeginBlock(!_flags.movingSelectedViews);

  MSGestureManagerBlock hasSelectionBlock = ShouldBeginBlock(weakSelf.selectionCount);

  MSGestureManagerBlock noPopovers =
    ShouldBeginBlock(  !_flags.popoverActive
                    && !_flags.presetsActive
                    && _flags.menuState == REEditingMenuStateDefault);

  MSGestureManagerBlock noToolbars =
    ReceiveTouchBlock(![weakSelf.toolbars objectPassingTest:
                        ^BOOL (UIToolbar * obj, NSUInteger idx)
  {
    return [touch.view isDescendantOfView:obj];
  }]);

  MSGestureManagerBlock selectableClassBlock =
    ReceiveTouchBlock([touch.view isKindOfClass:[[self class] subelementClass]]);

  // pinch
  [gestureBlocks addObject:@{ ShouldBegin        : hasSelectionBlock,
                              ShouldReceiveTouch : ReceiveTouchBlock(  noPopovers(gesture, touch)
                                                                    && noToolbars(gesture, touch)) }];

  // long press
  [gestureBlocks addObject:
   @{ ShouldReceiveTouch            : ReceiveTouchBlock(  noPopovers(gesture, touch)
                                                       && noToolbars(gesture, touch)
                                                       && selectableClassBlock(gesture, touch)),
      ShouldRecognizeSimultaneously : RecognizeSimultaneouslyBlock(@"toolbarLongPressGesture") }];

  // toolbar long press
  [gestureBlocks addObject:
   @{ ShouldReceiveTouch            : ReceiveTouchBlock(  noPopovers(gesture, touch)
                                                       && [touch.view
                                                             isDescendantOfView:_topToolbar]),
      ShouldRecognizeSimultaneously : RecognizeSimultaneouslyBlock(@"longPressGesture") }];

  // two touch pan
  [gestureBlocks addObject:
   @{ ShouldReceiveTouch : ReceiveTouchBlock(  noPopovers(gesture, touch)
                                            && noToolbars(gesture, touch)) }];

  // one touch double tap
  [gestureBlocks addObject:
   @{ ShouldBegin        : notMovingBlock,
      ShouldReceiveTouch : ReceiveTouchBlock(  noPopovers(gesture, touch)
                                            && noToolbars(gesture, touch)) }];

  // multiselect
  [gestureBlocks addObject:
   @{ ShouldBegin                : notMovingBlock,
      ShouldReceiveTouch         : ReceiveTouchBlock(  noPopovers(gesture, touch)
                                                    && noToolbars(gesture, touch)),
      ShouldRecognizeSimultaneously  : RecognizeSimultaneouslyBlock(@"anchoredMultiselectGesture") }];

  // anchored multiselect
  [gestureBlocks addObject:@{
     ShouldBegin                   : notMovingBlock,
     ShouldReceiveTouch            : ReceiveTouchBlock(  noPopovers(gesture, touch)
                                                      && noToolbars(gesture, touch)),
     ShouldRecognizeSimultaneously : RecognizeSimultaneouslyBlock(@"multiselectGesture")
   }];

  self.gestureManager = [MSGestureManager gestureManagerForGestures:gestures blocks:gestureBlocks];
}

- (void)updateGesturesEnabled {
  BOOL focused   = (_focusView ? YES : NO);
  BOOL moving    = _flags.movingSelectedViews;
  BOOL selection = (self.selectionCount ? YES : NO);

  _longPressGesture.enabled           = !focused;
  _pinchGesture.enabled               = selection;
  _oneTouchDoubleTapGesture.enabled   = !moving;
  _multiselectGesture.enabled         = !moving;
  _anchoredMultiselectGesture.enabled = !moving;

  MSLogDebugTag(@"%@", [[[_gestures allObjects] mapped:
                         ^NSString *(UIGestureRecognizer * obj, NSUInteger idx)
  {
    return $(@"%@: %@",
             obj.nametag,
             (obj.enabled ? @"enabled" : @"disabled"));
  }] componentsJoinedByString:@"\n\t"]);
}

- (IBAction)handleTap:(UITapGestureRecognizer *)gestureRecognizer {
  assert(gestureRecognizer == _oneTouchDoubleTapGesture);

  MSLogDebugGesture;

  if (gestureRecognizer.state == UIGestureRecognizerStateRecognized) {
    UIView * view = [self.view hitTest:[gestureRecognizer locationInView:self.view]
                             withEvent:nil];

    if ([view isKindOfClass:[[self class] subelementClass]]) {
      if (![_selectedViews containsObject:view])
        [self selectView:(RemoteElementView *)view];

      self.focusView = (_focusView == view ? nil : (RemoteElementView *)view);
    }
  }
}

- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
  MSLogDebugGesture;

  if (gestureRecognizer == _longPressGesture) {
    switch (gestureRecognizer.state) {
      case UIGestureRecognizerStateBegan: {
        UIView * view = [self.view hitTest:[gestureRecognizer locationInView:self.view]
                                 withEvent:nil];

        if ([view isKindOfClass:[[self class] subelementClass]]) {
          if (![_selectedViews containsObject:view])
            [self selectView:(RemoteElementView *)view];

          for (RemoteElementView * view in _selectedViews)
            view.editingState = REEditingStateMoving;

          _flags.movingSelectedViews = YES;
          [self updateState];
          _flags.longPressPreviousLocation = [gestureRecognizer locationInView:nil];
          [self willTranslateSelectedViews];
        }

        break;
      }

      case UIGestureRecognizerStateChanged: {
        CGPoint currentLocation = [gestureRecognizer locationInView:nil];
        CGPoint translation     = CGPointGetDelta(currentLocation,
                                                  _flags.longPressPreviousLocation);

        _flags.longPressPreviousLocation = currentLocation;
        [self translateSelectedViews:translation];
        break;
      }

      case UIGestureRecognizerStateCancelled:
      case UIGestureRecognizerStateFailed:
      case UIGestureRecognizerStateEnded:
        [self didTranslateSelectedViews];
        break;

      case UIGestureRecognizerStatePossible:
        break;
    }

  } else if (gestureRecognizer == _toolbarLongPressGesture)   {
    switch (gestureRecognizer.state) {
      case UIGestureRecognizerStateBegan:
        [_undoButton.button setTitle:[UIFont fontAwesomeIconForName:@"repeat"]
                            forState:UIControlStateNormal];
        _undoButton.button.selected = YES;
        break;

      case UIGestureRecognizerStateChanged:

        if (![_undoButton.button
              pointInside:[gestureRecognizer locationInView:_undoButton.button]
                withEvent:nil])
        {
          _undoButton.button.selected = NO;
          gestureRecognizer.enabled   = NO;
        }

        break;

      case UIGestureRecognizerStateRecognized:
        [self redo:nil];

      case UIGestureRecognizerStateCancelled:
      case UIGestureRecognizerStateFailed:
      case UIGestureRecognizerStatePossible:
        gestureRecognizer.enabled   = YES;
        _undoButton.button.selected = NO;
        [_undoButton.button setTitle:[UIFont fontAwesomeIconForName:@"undo"]
                            forState:UIControlStateNormal];
        break;
    }
  }
}

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer {
  MSLogDebugGesture;

  if (gestureRecognizer == _pinchGesture) {
    switch (gestureRecognizer.state) {
      case UIGestureRecognizerStateBegan:
        [self willScaleSelectedViews];
        break;

      case UIGestureRecognizerStateChanged:
        [self scaleSelectedViews:gestureRecognizer.scale validation:nil];
        break;

      case UIGestureRecognizerStateCancelled:
      case UIGestureRecognizerStateFailed:
      case UIGestureRecognizerStateEnded:
        [self didScaleSelectedViews];
        break;

      case UIGestureRecognizerStatePossible:
        break;
    }

  }
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)gestureRecognizer {
  MSLogDebugGesture;

  static CGFloat startingOffset = 0.0f;

  if (gestureRecognizer == _twoTouchPanGesture) {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
      startingOffset = self.sourceViewCenterYConstraint.constant;
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
      CGPoint translation    = [gestureRecognizer translationInView:self.view];
      CGFloat adjustedOffset = startingOffset + translation.y;
      BOOL    isInBounds     = MSValueInBounds(adjustedOffset,
                                               _flags.allowableSourceViewYOffset);
      CGFloat newOffset = (isInBounds
                           ? adjustedOffset
                           : (adjustedOffset < _flags.allowableSourceViewYOffset.lower
                              ? _flags.allowableSourceViewYOffset.lower
                              : _flags.allowableSourceViewYOffset.upper));

      if (self.sourceViewCenterYConstraint.constant != newOffset) {
        [UIView animateWithDuration:0.1f
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{ self.sourceViewCenterYConstraint.constant = newOffset;
                                       [self.view layoutIfNeeded]; }

                         completion:nil];
      }
    }
  }
}

- (IBAction)toggleSelected:(UIButton *)sender { sender.selected = !sender.selected; }

- (void)displayStackedViewDialogForViews:(NSSet *)stackedViews {
  MSLogDebug(@"%@ select stacked views to include: (%@)",
             ClassTagSelectorString,
             [[[stackedViews allObjects] valueForKey:@"name"]
                componentsJoinedByString:@", "]);

  _flags.menuState = REEditingMenuStateStackedViews;

  MenuController.menuItems = [[stackedViews allObjects]
                              mapped:
                              ^UIMenuItem *(RemoteElementView * obj, NSUInteger idx) {
    SEL action = NSSelectorFromString($(@"menuAction%@:",
                                        obj.uuid));
    return MenuItem(obj.name, action);
  }];

  [MenuController setTargetRect:[self.view.window
                                 convertRect:[UIView unionFrameForViews:[stackedViews allObjects]]
                                    fromView:_sourceView]
                         inView:self.view];
  MenuController.arrowDirection = UIMenuControllerArrowDefault;
  [MenuController update];
  MenuController.menuVisible = YES;

}

- (IBAction)handleSelection:(MSMultiselectGestureRecognizer *)gestureRecognizer {
  MSLogDebugGesture;

  if (gestureRecognizer.state == UIGestureRecognizerStateRecognized) {
    SEL action = (gestureRecognizer == _anchoredMultiselectGesture
                  ? @selector(deselectViews:)
                  : @selector(selectViews:));

    NSSet        * touchLocations         = [gestureRecognizer touchLocationsInView:_sourceView];
    NSMutableSet * touchedSubelementViews =
      [[gestureRecognizer touchedSubviewsInView:_sourceView
                                         ofKind:[[self class] subelementClass]] mutableCopy];

    if (touchedSubelementViews.count) {
      NSMutableDictionary * viewsPerTouch = [NSMutableDictionary
                                             dictionaryWithCapacity:touchLocations.count];

      [touchLocations enumerateObjectsUsingBlock:
       ^(NSValue * obj, BOOL * stop)
      {
        viewsPerTouch[obj] =
          [_sourceView.subelementViews filteredArrayUsingPredicateWithBlock:
           ^BOOL (RemoteElementView * rev, NSDictionary * bindings)
        {
          return [rev pointInside:[rev convertPoint:CGPointValue(obj)
                                           fromView:_sourceView]
                        withEvent:nil];
        }];
      }];

      NSSet * stackedLocations = [viewsPerTouch keysOfEntriesPassingTest:
                                  ^BOOL (id key, NSArray * obj, BOOL * stop)
      {
        return (ValueIsNotNil(obj) && obj.count > 1);
      }];

      if (stackedLocations.count) {
        NSSet * stackedViews = [NSSet setWithArrays:[viewsPerTouch allValues]];

        [touchedSubelementViews minusSet:stackedViews];
        [self displayStackedViewDialogForViews:stackedViews];
      }

      SuppressPerformSelectorLeakWarning([self performSelector:action
                                                    withObject:touchedSubelementViews]; )

    } else if (_selectedViews.count) [self deselectAll];
  }
}

@end

@implementation RemoteElementEditingViewController (Selection)

- (CGRect)selectedViewsUnionFrameInView:(UIView *)view {
  return [view convertRect:[self selectedViewsUnionFrameInSourceView] fromView:_sourceView];
}

- (CGRect)selectedViewsUnionFrameInSourceView {
  CGRect unionRect = CGRectZero;

  for (RemoteElementView * view in _selectedViews) {
    if (CGRectIsEmpty(unionRect)) unionRect = view.frame;
    else unionRect = CGRectUnion(unionRect, view.frame);
  }

  return unionRect;
}

/**
 * Convenience property that returns `[selectedViews count]`.
 * @return The number of selected views
 */
- (NSUInteger)selectionCount {
  return [_selectedViews count];
}

/**
 * Adds a subelement of the `sourceView` to the current selection.
 * @param view `REView` to add to the current selection
 */
- (void)selectView:(RemoteElementView *)view {
  [self selectViews:[@[view] set]];
}

/**
 * Adds multiple subelement views of the `sourceView` to the current selection.
 * @param views `NSSet` of `REView` objects to add to the current selection.
 */
- (void)selectViews:(NSSet *)views {
  for (RemoteElementView * view in [views setByRemovingObjectsFromSet: self.selectedViews]) {
    view.editingState = REEditingStateSelected;
    [_sourceView bringSubelementViewToFront:view];
  }

  [_selectedViews unionSet:views];
  [self updateState];
}

/**
 * Removes a subelement of the `sourceView` from the current selection.
 * @param view `REView` to remove to the current selection
 */
- (void)deselectView:(RemoteElementView *)view {
  [self deselectViews:[@[view] set]];
}

/**
 * Removes multiple subelement views of the `sourceView` to the current selection.
 * @param views `NSSet` of `REView` objects to remove to the current selection.
 */
- (void)deselectViews:(NSSet *)views {
  for (RemoteElementView * view in [views setByIntersectingSet: self.selectedViews]) {
    if (view == _focusView) self.focusView = nil;
    else view.editingState = REEditingStateNotEditing;
  }

  [self.selectedViews minusSet:views];
  [self updateState];
}

/**
 * Empties the current selction.
 */
- (void)deselectAll {
  self.focusView = nil;
  [self deselectViews:self.selectedViews];
}

/**
 * Removes a subelement view of the `sourceView` from the current selection when selected,
 * adds it the current selection otherwise.
 * @param views `REView` to add/remove from the current selection
 */
- (void)toggleSelectionForViews:(NSSet *)views {
  NSSet * selectedViews   = [views setByIntersectingSet:self.selectedViews];
  NSSet * unselectedViews = [views setByRemovingObjectsFromSet:self.selectedViews];

  [self selectViews:unselectedViews];
  [self deselectViews:selectedViews];
}

@end

@implementation RemoteElementEditingViewController (IBActions)

- (IBAction)addSubelement:(id)sender {
  MSLogDebugTag(@"");
  REPresetCollectionViewController * presetVC =
    [REPresetCollectionViewController presetControllerWithLayout:
     [UICollectionViewFlowLayout layoutWithScrollDirection:UICollectionViewScrollDirectionHorizontal]];
  presetVC.context = _context;
  [self addChildViewController:presetVC];
  [presetVC didMoveToParentViewController:self];
  UICollectionView   * presetView       = presetVC.collectionView;
  NSLayoutConstraint * heightConstraint = [NSLayoutConstraint
                                           constraintWithItem:presetView
                                                    attribute:NSLayoutAttributeHeight
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:nil
                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                   multiplier:1.0f
                                                     constant:0];
  [presetView addConstraint:heightConstraint];
  [self.view addSubview:presetView];
  [self.view addConstraints:
   [NSLayoutConstraint   constraintsByParsingString:@"H:|[presetView]|\nV:[presetView]|"
                                              views:@{ @"presetView" : presetView }]];
  [self.view layoutIfNeeded];

  [UIView transitionWithView:self.view
                    duration:0.25f
                     options:UIViewAnimationOptionCurveEaseInOut
                  animations:^{ heightConstraint.constant = 200.0f; [presetView layoutIfNeeded]; }
                  completion:^(BOOL finished) { _flags.presetsActive = YES; }];
}

- (IBAction)presets:(id)sender { // TODO: needs implementing
  MSLogDebugTag(@"");
}

- (IBAction)editBackground:(id)sender { // TODO: needs implementing
  MSLogDebugTag(@"");
  REBackgroundEditingViewController * bgEditor = [StoryboardProxy backgroundEditingViewController];
  bgEditor.subject = self.remoteElement;
  [self presentViewController:bgEditor animated:YES completion:nil];
}

- (IBAction)editSubelement:(id)sender { // TODO: needs to be overridden by REButtonGroupEditingViewController
  MSLogDebugTag(@"");
  assert(self.selectionCount == 1);
  [self openSubelementInEditor:((RemoteElementView *)[self.selectedViews anyObject]).model];
}

- (IBAction)duplicateSubelements:(id)sender { // TODO: needs implementing
  MSLogDebugTag(@"");
}

- (IBAction)copyStyle:(id)sender { // TODO: needs implementing
  MSLogDebugTag(@"");
}

- (IBAction)pasteStyle:(id)sender { // TODO: needs implementing
  MSLogDebugTag(@"");
}

- (IBAction)toggleBoundsVisibility:(id)sender {
  MSLogDebugTag(@"");
  _flags.showSourceBoundary     = !_flags.showSourceBoundary;
  _sourceViewBoundsLayer.hidden = !_flags.showSourceBoundary;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Resizing, alignment actions
///@name Resizing, alignment actions
////////////////////////////////////////////////////////////////////////////////

- (IBAction)alignVerticalCenters:(id)sender {
  MSLogDebugTag(@"");
  [self willAlignSelectedViews];
  [self alignSelectedViews:NSLayoutAttributeCenterY];
  [self didAlignSelectedViews];
}

- (IBAction)alignHorizontalCenters:(id)sender {
  MSLogDebugTag(@"");
  [self willAlignSelectedViews];
  [self alignSelectedViews:NSLayoutAttributeCenterX];
  [self didAlignSelectedViews];
}

- (IBAction)alignTopEdges:(id)sender {
  MSLogDebugTag(@"");
  [self willAlignSelectedViews];
  [self alignSelectedViews:NSLayoutAttributeTop];
  [self didAlignSelectedViews];
}

- (IBAction)alignBottomEdges:(id)sender {
  MSLogDebugTag(@"");
  [self willAlignSelectedViews];
  [self alignSelectedViews:NSLayoutAttributeBottom];
  [self didAlignSelectedViews];
}

- (IBAction)alignLeftEdges:(id)sender {
  MSLogDebugTag(@"");
  [self willAlignSelectedViews];
  [self alignSelectedViews:NSLayoutAttributeLeft];
  [self didAlignSelectedViews];
}

- (IBAction)alignRightEdges:(id)sender {
  MSLogDebugTag(@"");
  [self willAlignSelectedViews];
  [self alignSelectedViews:NSLayoutAttributeRight];
  [self didAlignSelectedViews];
}

- (IBAction)resizeFromFocusView:(id)sender {
  MSLogDebugTag(@"");
  [self willResizeSelectedViews];
  [self resizeSelectedViews:NSLayoutAttributeWidth];
  [self resizeSelectedViews:NSLayoutAttributeHeight];
  [self didResizeSelectedViews];
}

- (IBAction)resizeHorizontallyFromFocusView:(id)sender {
  MSLogDebugTag(@"");
  [self willResizeSelectedViews];
  [self resizeSelectedViews:NSLayoutAttributeWidth];
  [self didResizeSelectedViews];
}

- (IBAction)resizeVerticallyFromFocusView:(id)sender {
  MSLogDebugTag(@"");
  [self willResizeSelectedViews];
  [self resizeSelectedViews:NSLayoutAttributeHeight];
  [self didResizeSelectedViews];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Saving and reverting the managed object context
///@name Saving and reverting the managed object context
////////////////////////////////////////////////////////////////////////////////

- (IBAction)saveAction:(id)sender {
  __block BOOL savedOk = NO;
  [_context performBlockAndWait:
   ^{
    NSError * error = nil;
    savedOk = [_context save:&error];
    MSHandleErrors(error);
  }];

  if (savedOk) {
    if (_delegate) [_delegate remoteElementEditorDidSave:self];
    else [AppController dismissViewController:self completion:nil];
  }
}

- (IBAction)resetAction:(id)sender {
  MSLogDebugTag(@"");
  [_context performBlockAndWait:^{ [_context rollback]; }];
}

- (IBAction)cancelAction:(id)sender {
  [_context performBlockAndWait:^{ [_context rollback]; }];

  if (_delegate)
    [_delegate remoteElementEditorDidCancel:self];

  else
    [AppController dismissViewController:self completion:nil];

//    else if (self.presentingViewController)
//        [self dismissViewControllerAnimated:YES completion:nil];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark UIResponderStandardEditActions Protocol Methods
///@name UIResponderStandardEditActions Protocol Methods
////////////////////////////////////////////////////////////////////////////////

- (void)undo:(id)sender {
  MSLogDebugTag(@"");
  [_context performBlockAndWait:^{ [_context undo]; }];
}

- (void)redo:(id)sender {
  MSLogDebugTag(@"");
  [_context performBlockAndWait:^{ [_context redo]; }];
}

- (void)copy:(id)sender { // TODO: needs implementing
  MSLogDebugTag(@"");
}

- (void)cut:(id)sender { // TODO: needs implementing
  MSLogDebugTag(@"");
}

- (void)delete:(id)sender { // TODO: needs to handle sibling dependencies
  MSLogDebugTag(@"");
  NSSet * elementsToDelete = [_selectedViews valueForKeyPath:@"model"];
  [_selectedViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  [_selectedViews removeAllObjects];
  _focusView = nil;
  [_context performBlockAndWait:
   ^{
    [_context deleteObjects:elementsToDelete];
    [_context processPendingChanges];
  }];
  [_sourceView setNeedsUpdateConstraints];
  [_sourceView updateConstraintsIfNeeded];
}

- (void)paste:(id)sender { // TODO: needs implementing
  MSLogDebugTag(@"");
}

- (void)select:(id)sender { // TODO: needs implementing
  MSLogDebugTag(@"");
}

- (void)selectAll:(id)sender { // TODO: needs implementing
  MSLogDebugTag(@"");
}

- (void)toggleBoldface:(id)sender { // TODO: needs implementing
  MSLogDebugTag(@"");
}

- (void)toggleItalics:(id)sender { // TODO: needs implementing
  MSLogDebugTag(@"");
}

- (void)toggleUnderline:(id)sender { // TODO: needs implementing
  MSLogDebugTag(@"");
}

@end


NSUInteger const kTopToolbarIndex               = 0;
NSUInteger const kEmptySelectionToolbarIndex    = 1;
NSUInteger const kNonEmptySelectionToolbarIndex = 2;
NSUInteger const kFocusSelectionToolbarIndex    = 3;

@implementation RemoteElementEditingViewController (Toolbars)

- (UIBarButtonItem *)barButtonItemWithImage:(NSString *)imageName selector:(SEL)selector {
  UIBarButtonItem * barButtonItem = ImageBarButton(imageName, selector);
  barButtonItem.width = 44.0f;

  return barButtonItem;
}

- (void)initializeToolbars {

  self.topToolbar      = [[UIToolbar alloc] initForAutoLayoutWithFrame:(CGRect) {0, 0, 320, 44 }];
  _topToolbar.barStyle = UIBarStyleBlack;
  [self.view addSubview:_topToolbar];

  self.emptySelectionToolbar      = [[UIToolbar alloc] initForAutoLayoutWithFrame:TOOLBAR_FRAME];
  _emptySelectionToolbar.barStyle = UIBarStyleBlack;
  [self.view addSubview:_emptySelectionToolbar];

  self.nonEmptySelectionToolbar      = [[UIToolbar alloc] initForAutoLayoutWithFrame:TOOLBAR_FRAME];
  _nonEmptySelectionToolbar.barStyle = UIBarStyleBlack;
  _nonEmptySelectionToolbar.hidden   = YES;
  [self.view addSubview:_nonEmptySelectionToolbar];

  self.focusSelectionToolbar      = [[UIToolbar alloc] initForAutoLayoutWithFrame:TOOLBAR_FRAME];
  _focusSelectionToolbar.barStyle = UIBarStyleBlack;
  _focusSelectionToolbar.hidden   = YES;
  [self.view addSubview:_focusSelectionToolbar];

  NSDictionary * bindings = NSDictionaryOfVariableBindings(_topToolbar,
                                                           _emptySelectionToolbar,
                                                           _nonEmptySelectionToolbar,
                                                           _focusSelectionToolbar);
  NSString * constraints = @"H:|[_topToolbar]|\n"
                           "V:|[_topToolbar]\n"
                           "H:|[_emptySelectionToolbar]|\n"
                           "V:[_emptySelectionToolbar]|\n"
                           "H:|[_nonEmptySelectionToolbar]|\n"
                           "V:[_nonEmptySelectionToolbar]|\n"
                           "H:|[_focusSelectionToolbar]|\n"
                           "V:[_focusSelectionToolbar]|";

  [self.view addConstraints:[NSLayoutConstraint constraintsByParsingString:constraints
                                                                     views:bindings]];

  self.toolbars = @[_topToolbar,
                    _emptySelectionToolbar,
                    _nonEmptySelectionToolbar,
                    _focusSelectionToolbar];

  self.singleSelButtons = [@[] mutableCopy];
  self.anySelButtons    = [@[] mutableCopy];
  self.noSelButtons     = [@[] mutableCopy];
  self.multiSelButtons  = [@[] mutableCopy];

  [self populateTopToolbar];
  [self populateEmptySelectionToolbar];
  [self populateNonEmptySelectionToolbar];
  [self populateFocusSelectionToolbar];

  self.currentToolbar = _emptySelectionToolbar;
}

/*
 * topToolbar: Cancel ↔ Undo ↔ Save
 */
- (void)populateTopToolbar {
  self.undoButton = [ViewDecorator fontAwesomeBarButtonItemWithName:@"undo"
                                                             target:self
                                                           selector:@selector(undo:)];

  _topToolbar.items =
    @[[ViewDecorator fontAwesomeBarButtonItemWithName:@"remove"
                                               target:self
                                             selector:@selector(cancelAction:)],
      FlexibleSpaceBarButton,
      _undoButton,
      FlexibleSpaceBarButton,
      [ViewDecorator fontAwesomeBarButtonItemWithName:@"save"
                                               target:self
                                             selector:@selector(saveAction:)]];
  NSMutableIndexSet * indices = [NSMutableIndexSet indexSetWithIndex:0];
  [indices addIndex:2];
  [indices addIndex:4];
  [_anySelButtons addObjectsFromArray:[_topToolbar.items objectsAtIndexes:indices]];
}

/*
 * emptySelectionToolbar: Add ↔ Background ↔ Toggle Bounds ↔ Presets
 */
- (void)populateEmptySelectionToolbar {
  _emptySelectionToolbar.items =
    @[[ViewDecorator fontAwesomeBarButtonItemWithName:@"plus"
                                               target:self
                                             selector:@selector(addSubelement:)],
      FlexibleSpaceBarButton,
      [ViewDecorator fontAwesomeBarButtonItemWithName:@"picture"
                                               target:self
                                             selector:@selector(editBackground:)],
      FlexibleSpaceBarButton,
      [ViewDecorator fontAwesomeBarButtonItemWithName:@"bounds"
                                               target:self
                                             selector:@selector(toggleBoundsVisibility:)],
      FlexibleSpaceBarButton,
      [ViewDecorator fontAwesomeBarButtonItemWithName:@"hdd"
                                               target:self
                                             selector:@selector(presets:)]];

  NSMutableIndexSet * indices = [NSMutableIndexSet indexSetWithIndex:0];
  [indices addIndex:2];
  [indices addIndex:4];
  [indices addIndex:6];
  [_anySelButtons addObjectsFromArray:[_emptySelectionToolbar.items objectsAtIndexes:indices]];
}

/*
 * nonEmptySelectionToolbar: Edit ↔ Trash ↔ Duplicate ↔ Copy Style ↔ Paste Style
 */
- (void)populateNonEmptySelectionToolbar {
  _nonEmptySelectionToolbar.items =
    @[[ViewDecorator fontAwesomeBarButtonItemWithName:@"edit"
                                               target:self
                                             selector:@selector(editSubelement:)],
      FlexibleSpaceBarButton,
      [ViewDecorator fontAwesomeBarButtonItemWithName:@"trash"
                                               target:self
                                             selector:@selector(delete:)],
      FlexibleSpaceBarButton,
      [ViewDecorator fontAwesomeBarButtonItemWithName:@"th-large"
                                               target:self
                                             selector:@selector(duplicateSubelements:)],
      FlexibleSpaceBarButton,
      [ViewDecorator fontAwesomeBarButtonItemWithName:@"copy"
                                               target:self
                                             selector:@selector(copyStyle:)],
      FlexibleSpaceBarButton,
      [ViewDecorator fontAwesomeBarButtonItemWithName:@"paste"
                                               target:self
                                             selector:@selector(pasteStyle:)]];

  NSMutableIndexSet * indices = [NSMutableIndexSet indexSetWithIndex:2];
  [indices addIndex:4];
  [indices addIndex:8];
  [_anySelButtons addObjectsFromArray:[_nonEmptySelectionToolbar.items objectsAtIndexes:indices]];

  [indices removeAllIndexes];
  [indices addIndex:0];
  [indices addIndex:6];
  [_singleSelButtons addObjectsFromArray:[_nonEmptySelectionToolbar.items objectsAtIndexes:indices]];
}

/*
 * focusSelectionToolbar: Alignment ↔ Size
 */
- (void)populateFocusSelectionToolbar {

  NSArray * titles = @[[ViewDecorator fontAwesomeTitleWithName:@"align-bottom-edges" size:48.0f],
                       [ViewDecorator fontAwesomeTitleWithName:@"align-top-edges"    size:48.0f],
                       [ViewDecorator fontAwesomeTitleWithName:@"align-left-edges"   size:48.0f],
                       [ViewDecorator fontAwesomeTitleWithName:@"align-right-edges"  size:48.0f],
                       [ViewDecorator fontAwesomeTitleWithName:@"align-center-y"     size:48.0f],
                       [ViewDecorator fontAwesomeTitleWithName:@"align-center-x"     size:48.0f]];

  NSArray * selectorNames = @[SelectorString(@selector(alignBottomEdges:)),
                              SelectorString(@selector(alignTopEdges:)),
                              SelectorString(@selector(alignLeftEdges:)),
                              SelectorString(@selector(alignRightEdges:)),
                              SelectorString(@selector(alignVerticalCenters:)),
                              SelectorString(@selector(alignHorizontalCenters:))];

  MSPopupBarButton * align = [[MSPopupBarButton alloc]
                              initWithTitle:[UIFont fontAwesomeIconForName:@"align-edges"]
                                      style:UIBarButtonItemStylePlain
                                     target:nil
                                     action:NULL];

  [align setTitleTextAttributes:@{ NSFontAttributeName : [UIFont fontAwesomeFontWithSize:32.0f] }
                       forState:UIControlStateNormal];

  [align setTitleTextAttributes:@{ NSFontAttributeName : [UIFont fontAwesomeFontWithSize:32.0f] }
                       forState:UIControlStateHighlighted];

  align.delegate = self;

  for (int i = 0; i < titles.count; i++)
    [align addItemWithAttributedTitle:titles[i]
                               target:self
                               action:NSSelectorFromString(selectorNames[i])];

  titles = @[[ViewDecorator fontAwesomeTitleWithName:@"align-horizontal-size" size:48.0f],
             [ViewDecorator fontAwesomeTitleWithName:@"align-vertical-size" size:48.0f],
             [ViewDecorator fontAwesomeTitleWithName:@"align-size-exact" size:48.0f]];

  selectorNames = @[SelectorString(@selector(resizeHorizontallyFromFocusView:)),
                    SelectorString(@selector(resizeVerticallyFromFocusView:)),
                    SelectorString(@selector(resizeFromFocusView:))];

  MSPopupBarButton * resize = [[MSPopupBarButton alloc]
                               initWithTitle:[UIFont fontAwesomeIconForName:@"align-size"]
                                       style:UIBarButtonItemStylePlain
                                      target:nil
                                      action:NULL];

  [resize setTitleTextAttributes:@{ NSFontAttributeName : [UIFont fontAwesomeFontWithSize:32.0f] }
                        forState:UIControlStateNormal];

  [resize setTitleTextAttributes:@{ NSFontAttributeName : [UIFont fontAwesomeFontWithSize:32.0f] }
                        forState:UIControlStateHighlighted];

  resize.delegate = self;

  for (int i = 0; i < titles.count; i++)
    [resize addItemWithAttributedTitle:titles[i]
                                target:self
                                action:NSSelectorFromString(selectorNames[i])];

  _focusSelectionToolbar.items = @[FlexibleSpaceBarButton,
                                   align,
                                   FlexibleSpaceBarButton,
                                   resize,
                                   FlexibleSpaceBarButton];

  [_multiSelButtons addObjectsFromArray:@[align, resize]];
}

- (void)setCurrentToolbar:(UIToolbar *)currentToolbar {
  if (currentToolbar && _currentToolbar && _currentToolbar != currentToolbar) {
    currentToolbar.frame = _currentToolbar.frame;
    [UIView animateWithDuration:0.25
                     animations:^{
                       _currentToolbar.hidden = YES;
                       currentToolbar.hidden  = NO;
                     }

                     completion:^(BOOL finished) {
                       if (finished) _currentToolbar = currentToolbar;
                     }];
  } else
    _currentToolbar = currentToolbar;
}

- (UIToolbar *)currentToolbar { return _currentToolbar; }

/*
 * Updates the toolbar to display based on the current selection and whether `focusView` has been
 * set.
 */
- (void)updateToolbarDisplayed {
  if (self.selectionCount > 0) {
    BOOL        focusBarAvailable = ValueIsNotNil(_focusSelectionToolbar);
    UIToolbar * toolbar           = ((ValueIsNotNil(_focusView) && focusBarAvailable)
                                     ? _focusSelectionToolbar
                                     : _nonEmptySelectionToolbar);

    if (_currentToolbar != toolbar && ValueIsNotNil(toolbar)) self.currentToolbar = toolbar;
  } else self.currentToolbar = _emptySelectionToolbar;
}

- (void)updateBarButtonItems {
  if (_flags.movingSelectedViews) {
    [_singleSelButtons setValue:@NO forKeyPath:@"enabled"];
    [_anySelButtons setValue:@NO forKeyPath:@"enabled"];
    [_multiSelButtons setValue:@NO forKeyPath:@"enabled"];
  } else   {
    [_anySelButtons setValue:@YES forKeyPath:@"enabled"];

    BOOL multipleButtonsSelected = self.selectionCount > 1;
    [_singleSelButtons setValue:@(!multipleButtonsSelected) forKeyPath:@"enabled"];
    [_multiSelButtons setValue:@(multipleButtonsSelected) forKeyPath:@"enabled"];
  }
}

/*
 * Delegate method for being notified when an `MSPopupBarButton` has displayed its popover. Toggles
 * `flags.popoverActive`.
 * @param popupBarButton The newly active `MSPopupBarButton`
 */
- (void)popupBarButtonDidShowPopover:(MSPopupBarButton *)popupBarButton { _flags.popoverActive = YES; }

/*
 * Delegate method for being notified when an `MSPopupBarButton` has hidden its popover. Toggles
 * `flags.popoverActive`.
 * @param popupBarButton The newly inactive `MSPopupBarButton`
 */
- (void)popupBarButtonDidHidePopover:(MSPopupBarButton *)popupBarButton { _flags.popoverActive = NO; }

@end
