#import "RemoteElementView_Private.h"
#import "RemoteView.h"
#import "PresetInfo.h"
#import "Remote.h"
#import "ButtonView.h"
#import "ButtonGroup.h"
#import "ButtonGroupView.h"
#import "RemoteViewController.h"
#import "GalleryImage.h"

#define NUM_PANELS 13

// Panel registration keys
static NSArray   * kValidPanelKeys;
MSKIT_STRING_CONST   kTopPanelOneKey      = @"kTopPanelOneKey";
MSKIT_STRING_CONST   kBottomPanelOneKey   = @"kBottomPanelOneKey";
MSKIT_STRING_CONST   kLeftPanelOneKey     = @"kLeftPanelOneKey";
MSKIT_STRING_CONST   kRightPanelOneKey    = @"kRightPanelOneKey";
MSKIT_STRING_CONST   kTopPanelTwoKey      = @"kTopPanelTwoKey";
MSKIT_STRING_CONST   kBottomPanelTwoKey   = @"kBottomPanelTwoKey";
MSKIT_STRING_CONST   kLeftPanelTwoKey     = @"kLeftPanelTwoKey";
MSKIT_STRING_CONST   kRightPanelTwoKey    = @"kRightPanelTwoKey";
MSKIT_STRING_CONST   kTopPanelThreeKey    = @"kTopPanelThreeKey";
MSKIT_STRING_CONST   kBottomPanelThreeKey = @"kBottomPanelThreeKey";
MSKIT_STRING_CONST   kLeftPanelThreeKey   = @"kLeftPanelThreeKey";
MSKIT_STRING_CONST   kRightPanelThreeKey  = @"kRightPanelThreeKey";

// Panel gesture keys
MSKIT_STATIC_STRING_CONST   kPinchGestureKey           = @"kPinchGestureKey";
MSKIT_STATIC_STRING_CONST   kTapGestureKey             = @"kTapGestureKey";
MSKIT_STATIC_STRING_CONST   kSwipeDownOneTouchKey      = @"kSwipeDownOneTouchKey";
MSKIT_STATIC_STRING_CONST   kSwipeDownTwoTouchesKey    = @"kSwipeDownTwoTouchesKey";
MSKIT_STATIC_STRING_CONST   kSwipeDownThreeTouchesKey  = @"kSwipeDownThreeTouchesKey";
MSKIT_STATIC_STRING_CONST   kSwipeUpOneTouchKey        = @"kSwipeUpOneTouchKey";
MSKIT_STATIC_STRING_CONST   kSwipeUpTwoTouchesKey      = @"kSwipeUpTwoTouchesKey";
MSKIT_STATIC_STRING_CONST   kSwipeUpThreeTouchesKey    = @"kSwipeUpThreeTouchesKey";
MSKIT_STATIC_STRING_CONST   kSwipeLeftOneTouchKey      = @"kSwipeLeftOneTouchKey";
MSKIT_STATIC_STRING_CONST   kSwipeLeftTwoTouchesKey    = @"kSwipeLeftTwoTouchesKey";
MSKIT_STATIC_STRING_CONST   kSwipeLeftThreeTouchesKey  = @"kSwipeLeftThreeTouchesKey";
MSKIT_STATIC_STRING_CONST   kSwipeRightOneTouchKey     = @"kSwipeRightOneTouchKey";
MSKIT_STATIC_STRING_CONST   kSwipeRightTwoTouchesKey   = @"kSwipeRightTwoTouchesKey";
MSKIT_STATIC_STRING_CONST   kSwipeRightThreeTouchesKey = @"kSwipeRightThreeTouchesKey";

// static int ddLogLevel = LOG_LEVEL_DEBUG;
static int          ddLogLevel = DefaultDDLogLevel;
static DebugFlags   debugFlags = {
    .logKVO                   = NO,
    .logGeometry              = NO,
    .logTouches               = NO,
    .logGestures              = NO,
    .overrideBackgroundColors = 0
};
#pragma unused(debugFlags)

#define isTopPanelKey(panelKey)                   \
    (  [panelKey isEqualToString:kTopPanelOneKey] \
    || [panelKey isEqualToString:kTopPanelTwoKey] \
    || [panelKey isEqualToString:kTopPanelThreeKey])

#define isBottomPanelKey(panelKey)                   \
    (  [panelKey isEqualToString:kBottomPanelOneKey] \
    || [panelKey isEqualToString:kBottomPanelTwoKey] \
    || [panelKey isEqualToString:kBottomPanelThreeKey])

#define isLeftPanelKey(panelKey)                   \
    (  [panelKey isEqualToString:kLeftPanelOneKey] \
    || [panelKey isEqualToString:kLeftPanelTwoKey] \
    || [panelKey isEqualToString:kLeftPanelThreeKey])

#define isRightPanelKey(panelKey)                   \
    (  [panelKey isEqualToString:kRightPanelOneKey] \
    || [panelKey isEqualToString:kRightPanelTwoKey] \
    || [panelKey isEqualToString:kRightPanelThreeKey])

@implementation RemoteView {
    NSMutableDictionary    * _panelGestures;
    NSMapTable             * _buttonGroupPanelAssignments;
    UIImageView            * _backgroundImageView;
    NSString               * _currentlyDisplayedPanel;
    __weak ButtonGroupView * _overlayGroupCurrentlyDisplayed;
}

+ (void)initialize {
    if (self == [RemoteView class]) {
        static dispatch_once_t   onceToken;

        dispatch_once(&onceToken, ^{
            kValidPanelKeys = @[kTopPanelOneKey,
                                kTopPanelTwoKey,
                                kTopPanelThreeKey,
                                kBottomPanelOneKey,
                                kBottomPanelTwoKey,
                                kBottomPanelThreeKey,
                                kLeftPanelOneKey,
                                kLeftPanelTwoKey,
                                kLeftPanelThreeKey,
                                kRightPanelOneKey,
                                kRightPanelTwoKey,
                                kRightPanelThreeKey
                              ];
        }

                      );
    }
}

- (void)setButtonGroupsLocked:(BOOL)buttonGroupsLocked {
    [self.subelementViews setValue:@(!buttonGroupsLocked) forKey:@"resizable"];
    [self.subelementViews setValue:@(!buttonGroupsLocked) forKey:@"moveable"];
    _buttonGroupsLocked = buttonGroupsLocked;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Panels
////////////////////////////////////////////////////////////////////////////////

- (ButtonGroupView *)panelForKey:(NSString *)panelKey {
    return [_buttonGroupPanelAssignments objectForKey:panelKey];
}

- (void)untuckPanelForKey:(NSString *)panelKey {
    ButtonGroupView * panel = [self panelForKey:panelKey];

    if (ValueIsNil(panel)) {
        DDLogWarn(@"%@\n\tno button group registered for panel:%@", ClassTagSelectorStringForInstance(self.displayName), panelKey);

        return;
    }

    panel.hidden = NO;

    NSLayoutConstraint * constraint = [self constraintWithNametag:panelKey];

    if (!constraint) {
        DDLogError(@"%@ constraint for panelKey %@ does not exist", ClassTagSelectorString, panelKey);

        return;
    }

    [UIView animateWithDuration:0.1
                     animations:^{
                         constraint.constant = 0.0f;
                         [self setNeedsLayout];
                         [self layoutIfNeeded];
                     }

                     completion:^(BOOL finished) {
                         if (finished) _currentlyDisplayedPanel = panelKey;
                     }

    ];
}

- (void)tuckPanelForKey:(NSString *)panelKey {
    ButtonGroupView * panel = [self panelForKey:panelKey];

    if (ValueIsNil(panel)) {
        DDLogWarn(@"%@\n\tno button group registered for panel:%@", ClassTagSelectorStringForInstance(self.displayName), panelKey);

        return;
    }

    CGSize    size        = panel.bounds.size;
    CGFloat   newConstant = 0;

    if (size.height == 0 || size.width == 0) return;

    NSLayoutConstraint * constraint      = [self constraintWithNametag:panelKey];
    BOOL                 isNewConstraint = (!constraint);

    if (isBottomPanelKey(panelKey)) {
        if (!constraint) {
            constraint = [NSLayoutConstraint constraintWithItem:panel
                                                      attribute:NSLayoutAttributeBottom
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:self
                                                      attribute:NSLayoutAttributeBottom
                                                     multiplier:1.0f
                                                       constant:0.0f];
            constraint.nametag = panelKey;
        }

        newConstant = size.height;
    } else if (isTopPanelKey(panelKey)) {
        if (!constraint) {
            constraint = [NSLayoutConstraint constraintWithItem:panel
                                                      attribute:NSLayoutAttributeTop
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:self
                                                      attribute:NSLayoutAttributeTop
                                                     multiplier:1.0f
                                                       constant:0.0f];
            constraint.nametag = panelKey;
        }

        newConstant = -size.height;
    } else if (isRightPanelKey(panelKey)) {
        if (!constraint) {
            constraint = [NSLayoutConstraint constraintWithItem:panel
                                                      attribute:NSLayoutAttributeRight
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:self
                                                      attribute:NSLayoutAttributeRight
                                                     multiplier:1.0f
                                                       constant:0.0f];
            constraint.nametag = panelKey;
        }

        newConstant = size.width;
    } else if (isLeftPanelKey(panelKey)) {
        if (!constraint) {
            constraint = [NSLayoutConstraint constraintWithItem:panel
                                                      attribute:NSLayoutAttributeLeft
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:self
                                                      attribute:NSLayoutAttributeLeft
                                                     multiplier:1.0f
                                                       constant:0.0f];
            constraint.nametag = panelKey;
        }

        newConstant = -size.width;
    } else {
        DDLogWarn(@"%@\n\tinvalid panel key:%@", ClassTagSelectorStringForInstance(self.displayName), panelKey);

        return;
    }

    [UIView animateWithDuration:0.1
                     animations:^{
                         constraint.constant = newConstant;
                         if (isNewConstraint) [self addConstraint:constraint];

                         [self setNeedsLayout];
                         [self layoutIfNeeded];
                     }

                     completion:^(BOOL finished) {
                         if (finished) _currentlyDisplayedPanel = nil;
                     }

    ];
}  /* tuckPanelForKey */

- (BOOL)buttonGroupViewIsPanel:(ButtonGroupView *)buttonGroupView {
    return ([_buttonGroupPanelAssignments objectForKey:buttonGroupView.key] != nil);
}

- (void)registerView:(ButtonGroupView *)buttonGroupView forPanel:(NSString *)panelKey {
    if ([kValidPanelKeys containsObject:panelKey]) {
        [_buttonGroupPanelAssignments setObject:buttonGroupView forKey:panelKey];
        buttonGroupView.hidden                                    = YES;
        ((UIGestureRecognizer *)_panelGestures[panelKey]).enabled = YES;
    }
}

- (void)unregisterView:(ButtonGroupView *)buttonGroupView forPanel:(NSString *)panelKey {
    if (  [kValidPanelKeys containsObject:panelKey]
       && buttonGroupView == [self panelForKey:panelKey])
    {
        if (_overlayGroupCurrentlyDisplayed == buttonGroupView) {
            _overlayGroupCurrentlyDisplayed = nil;
            _currentlyDisplayedPanel        = nil;
        }

        [_buttonGroupPanelAssignments removeObjectForKey:panelKey];
        ((UIGestureRecognizer *)_panelGestures[panelKey]).enabled = YES;
    }
}

- (void)tuckRequestFromButtonGroupView:(ButtonGroupView *)buttonGroupView {
    if (  [self buttonGroupViewIsPanel:buttonGroupView]
       && [_currentlyDisplayedPanel isEqualToString:buttonGroupView.key]) [self tuckPanelForKey:_currentlyDisplayedPanel];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Gestures
////////////////////////////////////////////////////////////////////////////////

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (!_currentlyDisplayedPanel) {
            NSString * panelKey = nil;

            switch (gestureRecognizer.numberOfTouchesRequired) {
                case 3 : {
                    switch (gestureRecognizer.direction) {
                        case UISwipeGestureRecognizerDirectionUp :
                            panelKey = kBottomPanelThreeKey;
                            break;

                        case UISwipeGestureRecognizerDirectionDown :
                            panelKey = kTopPanelThreeKey;
                            break;

                        case UISwipeGestureRecognizerDirectionLeft :
                            panelKey = kRightPanelThreeKey;
                            break;

                        case UISwipeGestureRecognizerDirectionRight :
                            panelKey = kLeftPanelThreeKey;
                            break;
                    }  /* switch */

                    break;
                }

                case 2 : {
                    switch (gestureRecognizer.direction) {
                        case UISwipeGestureRecognizerDirectionUp :
                            panelKey = kBottomPanelTwoKey;
                            break;

                        case UISwipeGestureRecognizerDirectionDown :
                            panelKey = kTopPanelTwoKey;
                            break;

                        case UISwipeGestureRecognizerDirectionLeft :
                            panelKey = kRightPanelTwoKey;
                            break;

                        case UISwipeGestureRecognizerDirectionRight :
                            panelKey = kLeftPanelTwoKey;
                            break;
                    }  /* switch */

                    break;
                }

                default : {
                    switch (gestureRecognizer.direction) {
                        case UISwipeGestureRecognizerDirectionUp :
                            panelKey = kBottomPanelOneKey;
                            break;

                        case UISwipeGestureRecognizerDirectionDown :
                            panelKey = kTopPanelOneKey;
                            break;

                        case UISwipeGestureRecognizerDirectionLeft :
                            panelKey = kRightPanelOneKey;
                            break;

                        case UISwipeGestureRecognizerDirectionRight :
                            panelKey = kLeftPanelOneKey;
                            break;
                    } /* switch */

                    break;
                }
            }         /* switch */

            [self untuckPanelForKey:panelKey];
        } else {
            BOOL   shouldTuck = NO;

            switch (gestureRecognizer.direction) {
                case UISwipeGestureRecognizerDirectionUp :
                    shouldTuck = isTopPanelKey(_currentlyDisplayedPanel);
                    break;

                case UISwipeGestureRecognizerDirectionDown :
                    shouldTuck = isBottomPanelKey(_currentlyDisplayedPanel);
                    break;

                case UISwipeGestureRecognizerDirectionLeft :
                    shouldTuck = isLeftPanelKey(_currentlyDisplayedPanel);
                    break;

                case UISwipeGestureRecognizerDirectionRight :
                    shouldTuck = isRightPanelKey(_currentlyDisplayedPanel);
                    break;
            } /* switch */

            if (shouldTuck) [self tuckPanelForKey:_currentlyDisplayedPanel];
        }
    }
}             /* handleSwipe */

- (void)updateActiveGestures:(BOOL)enabled {
    for (UIGestureRecognizer * gesture in[_panelGestures allValues]) {
        gesture.enabled = (enabled && [_buttonGroupPanelAssignments objectForKey:gesture.nametag] != nil);
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIView Overrides
////////////////////////////////////////////////////////////////////////////////

- (void)didMoveToSuperview {
    if (self.superview) {
        // Tuck panels to establish the constraints used in untucking.
        int64_t           delayInSeconds = 0.1;
        dispatch_time_t   popTime        = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);

        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            for (NSString * panelKey in kValidPanelKeys) {
                if ([_buttonGroupPanelAssignments objectForKey:panelKey] != nil) [self tuckPanelForKey:panelKey];
            }
        }

                       );
    }
}

- (CGSize)intrinsicContentSize {
    return [MainScreen bounds].size;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - RemoteElementView Overrides
////////////////////////////////////////////////////////////////////////////////

- (void)addSubelementView:(ButtonGroupView *)view {
    if ([kValidPanelKeys containsObject:view.key]) [self registerView:view forPanel:view.key];

    [super addSubelementView:view];
}

- (void)removeSubelementView:(ButtonGroupView *)view {
    if ([self buttonGroupViewIsPanel:view]) [self unregisterView:view forPanel:view.key];

    [super removeSubelementView:view];
}

- (void)setResizable:(BOOL)resizable
{}

- (void)setMoveable:(BOOL)moveable
{}

- (BOOL)isResizable {
    return NO;
}

- (BOOL)isMoveable {
    return NO;
}

- (void)setEditingMode:(EditingMode)mode {
    if (mode == EditingModeEditingRemote) [self updateActiveGestures:NO];
    else if (self.editingMode == EditingModeEditingRemote) [self updateActiveGestures:YES];

    [super setEditingMode:mode];

    [self.subelementViews setValue:@(mode) forKeyPath:@"editingMode"];
}

- (void)attachGestureRecognizers {
    UISwipeGestureRecognizer * swipeRecognizer =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(handleSwipe:)];

    swipeRecognizer.direction               = UISwipeGestureRecognizerDirectionUp;
    swipeRecognizer.numberOfTouchesRequired = 1;
    swipeRecognizer.delegate                = self;
    swipeRecognizer.enabled                 = NO;
    swipeRecognizer.nametag                 = kBottomPanelOneKey;
    [_panelGestures setObject:swipeRecognizer forKey:kBottomPanelOneKey];
    [self addGestureRecognizer:swipeRecognizer];

    swipeRecognizer =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRecognizer.direction               = UISwipeGestureRecognizerDirectionDown;
    swipeRecognizer.numberOfTouchesRequired = 1;
    swipeRecognizer.delegate                = self;
    swipeRecognizer.enabled                 = NO;
    swipeRecognizer.nametag                 = kTopPanelOneKey;
    [_panelGestures setObject:swipeRecognizer forKey:kTopPanelOneKey];
    [self addGestureRecognizer:swipeRecognizer];

    swipeRecognizer =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRecognizer.direction               = UISwipeGestureRecognizerDirectionLeft;
    swipeRecognizer.numberOfTouchesRequired = 1;
    swipeRecognizer.delegate                = self;
    swipeRecognizer.enabled                 = NO;
    swipeRecognizer.nametag                 = kRightPanelOneKey;
    [_panelGestures setObject:swipeRecognizer forKey:kRightPanelOneKey];
    [self addGestureRecognizer:swipeRecognizer];

    swipeRecognizer =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRecognizer.direction               = UISwipeGestureRecognizerDirectionRight;
    swipeRecognizer.numberOfTouchesRequired = 1;
    swipeRecognizer.delegate                = self;
    swipeRecognizer.enabled                 = NO;
    swipeRecognizer.nametag                 = kLeftPanelOneKey;
    [_panelGestures setObject:swipeRecognizer forKey:kLeftPanelOneKey];
    [self addGestureRecognizer:swipeRecognizer];

    swipeRecognizer =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRecognizer.direction               = UISwipeGestureRecognizerDirectionUp;
    swipeRecognizer.numberOfTouchesRequired = 2;
    swipeRecognizer.delegate                = self;
    swipeRecognizer.enabled                 = NO;
    swipeRecognizer.nametag                 = kBottomPanelTwoKey;
    [_panelGestures setObject:swipeRecognizer forKey:kBottomPanelTwoKey];
    [self addGestureRecognizer:swipeRecognizer];

    swipeRecognizer =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRecognizer.direction               = UISwipeGestureRecognizerDirectionDown;
    swipeRecognizer.numberOfTouchesRequired = 2;
    swipeRecognizer.delegate                = self;
    swipeRecognizer.enabled                 = NO;
    swipeRecognizer.nametag                 = kTopPanelTwoKey;
    [_panelGestures setObject:swipeRecognizer forKey:kTopPanelTwoKey];
    [self addGestureRecognizer:swipeRecognizer];

    swipeRecognizer =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRecognizer.direction               = UISwipeGestureRecognizerDirectionLeft;
    swipeRecognizer.numberOfTouchesRequired = 2;
    swipeRecognizer.delegate                = self;
    swipeRecognizer.enabled                 = NO;
    swipeRecognizer.nametag                 = kRightPanelTwoKey;
    [_panelGestures setObject:swipeRecognizer forKey:kRightPanelTwoKey];
    [self addGestureRecognizer:swipeRecognizer];

    swipeRecognizer =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRecognizer.direction               = UISwipeGestureRecognizerDirectionRight;
    swipeRecognizer.numberOfTouchesRequired = 2;
    swipeRecognizer.delegate                = self;
    swipeRecognizer.enabled                 = NO;
    swipeRecognizer.nametag                 = kLeftPanelOneKey;
    [_panelGestures setObject:swipeRecognizer forKey:kLeftPanelTwoKey];
    [self addGestureRecognizer:swipeRecognizer];

    swipeRecognizer =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRecognizer.direction               = UISwipeGestureRecognizerDirectionUp;
    swipeRecognizer.numberOfTouchesRequired = 3;
    swipeRecognizer.delegate                = self;
    swipeRecognizer.enabled                 = NO;
    swipeRecognizer.nametag                 = kBottomPanelThreeKey;
    [_panelGestures setObject:swipeRecognizer forKey:kBottomPanelThreeKey];
    [self addGestureRecognizer:swipeRecognizer];

    swipeRecognizer =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRecognizer.direction               = UISwipeGestureRecognizerDirectionDown;
    swipeRecognizer.numberOfTouchesRequired = 3;
    swipeRecognizer.delegate                = self;
    swipeRecognizer.enabled                 = NO;
    swipeRecognizer.nametag                 = kTopPanelThreeKey;
    [_panelGestures setObject:swipeRecognizer forKey:kTopPanelThreeKey];
    [self addGestureRecognizer:swipeRecognizer];

    swipeRecognizer =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRecognizer.direction               = UISwipeGestureRecognizerDirectionLeft;
    swipeRecognizer.numberOfTouchesRequired = 3;
    swipeRecognizer.delegate                = self;
    swipeRecognizer.enabled                 = NO;
    swipeRecognizer.nametag                 = kRightPanelThreeKey;
    [_panelGestures setObject:swipeRecognizer forKey:kRightPanelThreeKey];
    [self addGestureRecognizer:swipeRecognizer];

    swipeRecognizer =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRecognizer.direction               = UISwipeGestureRecognizerDirectionRight;
    swipeRecognizer.numberOfTouchesRequired = 3;
    swipeRecognizer.delegate                = self;
    swipeRecognizer.enabled                 = NO;
    swipeRecognizer.nametag                 = kLeftPanelThreeKey;
    [_panelGestures setObject:swipeRecognizer forKey:kLeftPanelThreeKey];
    [self addGestureRecognizer:swipeRecognizer];
}  /* attachGestureRecognizers */

- (void)initializeIVARs {
    _panelGestures               = [NSMutableDictionary dictionaryWithCapacity:NUM_PANELS];
    _buttonGroupPanelAssignments = [NSMapTable strongToWeakObjectsMapTable];
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired
                                          forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired
                                          forAxis:UILayoutConstraintAxisVertical];
    [self setContentHuggingPriority:UILayoutPriorityRequired
                            forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentHuggingPriority:UILayoutPriorityRequired
                            forAxis:UILayoutConstraintAxisVertical];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0f
                                                      constant:self.intrinsicContentSize.width]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0f
                                                      constant:self.intrinsicContentSize.height]];
    [super initializeIVARs];
}

@end
