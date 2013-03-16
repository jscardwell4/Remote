#import "RemoteViewController.h"
#import "RemoteView.h"
#import "Remote.h"
#import "RemoteController.h"
#import "ButtonView.h"
#import "ButtonGroup.h"
#import "RemoteEditingViewController.h"
#import "SettingsManager.h"
#import "ButtonEditingViewController.h"
#import "RemoteBuilder.h"
#import "ControlStateSet.h"
#import "GalleryImage.h"
#import "CoreDataManager.h"
#import "ButtonGroupView.h"
#import "StoryboardProxy.h"
#import "MSRemoteAppController.h"
#import "Command.h"

// #define DUMP_ELEMENT_HIERARCHY
// #define DUMP_LAYOUT_DATA

// #define INACTIVITY_TIMER

// static int ddLogLevel = DefaultDDLogLevel;
static const int          ddLogLevel                             = LOG_LEVEL_DEBUG;
static const int          msLogContext                           = REMOTE_F;
MSKIT_STATIC_STRING_CONST   kRemoteViewNameTag                     = @"kRemoteViewNameTag";
MSKIT_STATIC_STRING_CONST   kTopToolbarConstraintNameTag           = @"kTopToolbarConstraintNameTag";
MSKIT_STATIC_STRING_CONST   kTopToolbarRemoteViewConstraintNameTag = @"kTopToolbarRemoteViewConstraintNameTag";

// static DebugFlags debugFlags = {
// .logKVO = NO,
// .logGeometry = YES,
// .logTouches = NO,
// .logGestures = NO
// };

@implementation RemoteViewController {
    struct {
        BOOL             monitorProximitySensor;
        NSTimeInterval   inactivityTimeout;
        BOOL             autohideTopBar;
        BOOL             remoteInactive;
        BOOL             loadHomeScreen;
        BOOL             monitoringInactivity;
    }
    _flags;

    ButtonGroupView    * _topToolbar;
    NSLayoutConstraint * _topToolbarConstraint;
    RemoteController   * _remoteController;
    dispatch_source_t    _inactivityTimer;
}

#pragma mark - Managing notificaitons

/**
 * Determines which property of the model has changed and updates the view accordingly.
 * @param keyPath The keypath for the value being observed.
 * @param object The object being observed.
 * @param change `NSDictionary` containing the change information.
 * @param context Not currently being used for anything.
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    assert(object == _remoteController);
    assert([@"currentRemote" isEqualToString: keyPath]);
    assert([change[NSKeyValueChangeNewKey] isMemberOfClass:[Remote class]]);
    MSRunSyncOnMain (^{[self insertRemoteView:(RemoteView *)[RemoteElementView remoteElementViewWithElement:(Remote *)change[NSKeyValueChangeNewKey]]]; }

                     );
}

/**
 * Register for changes to various values of the model as well as any changes to its
 * `NSManagedObjectContext`.
 */
- (void)registerForKVONotifications {
    [_remoteController addObserver:self
                        forKeyPath:@"currentRemote"
                           options:NSKeyValueObservingOptionNew
                           context:NULL];
}

/**
 * Removes the `RemoteViewController` as an observer for the notifications registered for in
 * `registerForChangeNotification`.
 */
- (void)unregisterForKVONotifications {
    [_remoteController removeObserver:self forKeyPath:@"currentRemote"];
}

- (void)registerForNotificationCenterNotifications {
    [NotificationCenter addObserverForName:MSSettingsManagerProximitySensorSettingDidChangeNotification
                                    object:[SettingsManager sharedSettingsManager]
                                     queue:nil
                                usingBlock:^(NSNotification * note) {
                                    _flags.monitorProximitySensor = [SettingsManager boolForSetting:kProximitySensorKey];
                                    CurrentDevice.proximityMonitoringEnabled = _flags.monitorProximitySensor;
                                }

    ];
#ifdef INACTIVITY_TIMER
    [NotificationCenter addObserverForName:MSSettingsManagerInactivityTimeoutSettingDidChangeNotification
                                    object:[SettingsManager sharedSettingsManager]
                                     queue:nil
                                usingBlock:^(NSNotification * note) {
                                    _flags.inactivityTimeout = [SettingsManager floatForSetting:kInactivityTimeoutKey];
                                    if (_flags.monitoringInactivity && !_flags.inactivityTimeout) [self stopInactivityTimer:NO];
                                }

    ];
#endif /* ifdef INACTIVITY_TIMER */
}

- (void)unregisterForNotificationCenterNotifications {
    [NotificationCenter removeObserver:self name:nil object:[SettingsManager sharedSettingsManager]];
}

#pragma mark - NSObject overrides

- (void)awakeFromNib {
    _remoteController = [RemoteController remoteController];
    assert(_remoteController);

    _flags.monitorProximitySensor = [SettingsManager boolForSetting:kProximitySensorKey];
    _flags.inactivityTimeout      = [SettingsManager floatForSetting:kInactivityTimeoutKey];
    _flags.loadHomeScreen         = YES;
    [self registerForKVONotifications];
    [self registerForNotificationCenterNotifications];
    assert([SystemCommand registerRemoteViewController:self]);
}

- (void)dealloc {
    [self unregisterForKVONotifications];
    [self unregisterForNotificationCenterNotifications];
    [SystemCommand registerRemoteViewController:nil];
}

#pragma mark - UIViewController overrides

/**
 * Releases the cached remote view and any other retained properties relating to the view.
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DDLogWarn(@"%@ is view loaded? %@  is toolbar allocated? %@",
              ClassTagSelectorString,
              BOOLString([self isViewLoaded]),
              BOOLString(_topToolbar == nil));
}

#ifdef INACTIVITY_TIMER
- (void)resumeInactivityTimer {
    assert(_inactivityTimer && !dispatch_source_testcancel(_inactivityTimer) && _flags.remoteInactive);
    dispatch_resume(_inactivityTimer);
    DDLogDebug(@"%@ inactivity timer resumed", ClassTagSelectorString);
    _flags.remoteInactive       = NO;
    _flags.monitoringInactivity = YES;
}

- (void)startInactivityTimer {
    if (_inactivityTimer) {
        [self resumeInactivityTimer];

        return;
    }

    NSTimeInterval   maxInactivity = _flags.inactivityTimeout;

    _flags.monitoringInactivity = YES;

    static const uint64_t   leeway = 5.0 * NSEC_PER_SEC;
    __block uint64_t        (^ timeToNext)(void) = ^(void) {
        uint64_t         now          = dispatch_walltime(DISPATCH_TIME_NOW, 0);
        uint64_t         lastEvent    = [AppController lastEvent];
        NSTimeInterval   timeInactive = (now - lastEvent) / NSEC_PER_SEC;
        BOOL             timeout      = (timeInactive >= maxInactivity);
        uint64_t         next         = (timeout ? 0ull : (maxInactivity - timeInactive) * NSEC_PER_SEC);

        return next;
    };

    assert(_flags.inactivityTimeout && !_inactivityTimer);
    _inactivityTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                              0,
                                              0,
                                              dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)
                                              );
    assert(_inactivityTimer);
    dispatch_source_set_timer(_inactivityTimer,
                              dispatch_walltime(DISPATCH_TIME_NOW, maxInactivity * NSEC_PER_SEC),
                              maxInactivity,
                              leeway);
    dispatch_source_set_event_handler(_inactivityTimer, ^{
        uint64_t next = timeToNext();
        DDLogDebug(@"%@ next: %lld (%fs)", ClassTagSelectorString, next, (NSTimeInterval)next / NSEC_PER_SEC);
        if (next) {
            MSLogDebug(@"%@ max inactivity:%fs  last event:%fs timeout in:%llds",
                       ClassTagSelectorString,
                       (maxInactivity / NSEC_PER_SEC),
                       ((maxInactivity - next) / NSEC_PER_SEC),
                       (next / NSEC_PER_SEC));
            dispatch_source_set_timer(_inactivityTimer,
                                      dispatch_walltime(DISPATCH_TIME_NOW, next),
                                      maxInactivity,
                                      leeway);
        } else {
            MSLogDebug(@"%@ max inactivity reached, turning off screen...", ClassTagSelectorString);
            [self stopInactivityTimer:YES];
        }
    }

                                      );
    dispatch_source_set_cancel_handler(_inactivityTimer, ^{
        _inactivityTimer = nil;
    }

                                       );
    dispatch_resume(_inactivityTimer);
}  /* startInactivityTimer */

- (void)stopInactivityTimer:(BOOL)timeout {
    if (_inactivityTimer) {
        dispatch_suspend(_inactivityTimer);
        if (timeout) {
            [NotificationCenter addObserverForName:UIScreenBrightnessDidChangeNotification
                                            object:MainScreen
                                             queue:nil
                                        usingBlock:^(NSNotification * note) {
                                            if (MainScreen.brightness > 0) {
                                            DDLogDebug(@"%@ restarting inactivity timer",
                                            ClassTagSelectorString);
                                            [NotificationCenter
                                             removeObserver:self
                                                       name:UIScreenBrightnessDidChangeNotification
                                                     object:MainScreen];
                                            [self resumeInactivityTimer];
                                            }
                                        }

            ];
            [AppController dimScreen];
            _flags.remoteInactive = YES;
        } else
            _flags.monitoringInactivity = NO;
    }
}
#endif /* ifdef INACTIVITY_TIMER */

- (void)viewDidLoad {
    assert(!_topToolbar);
    [self initializeTopToolbar];
    assert(![self.view viewWithNametag:kRemoteViewNameTag]);
    [self insertRemoteView:(RemoteView *)[RemoteElementView
                                          remoteElementViewWithElement:_remoteController.currentRemote]];
// remoteElementViewWithElement:[_remoteController remoteWithKey:@"activity1"]]];

    [self.view.gestureRecognizers
     enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
         if ([obj isMemberOfClass:[MSPinchGestureRecognizer class]]) {
            ((MSPinchGestureRecognizer *)obj).threshold = (MSBoundary) {.lower = -44.0f, .upper = 44.0f};
            *stop = YES;
         }
     }

    ];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];

    RemoteView * remoteView = (RemoteView *)[self.view viewWithNametag:kRemoteViewNameTag];

    if (remoteView && ![self.view constraintsWithNametag:kRemoteViewNameTag]) {
        UIView  * parentView  = self.view;
        NSArray * constraints = [NSLayoutConstraint constraintsByParsingString:@"remoteView.centerX = parentView.centerX\n"
                                                                               "remoteView.bottom = parentView.bottom\n"
// "nremoteView.top = _topToolbar.bottom"
                                                                               "remoteView.top = parentView.top"
                                 views:NSDictionaryOfVariableBindings(remoteView, parentView, _topToolbar)];

        for (NSLayoutConstraint * lc in constraints) {
            lc.nametag = kRemoteViewNameTag;
        }

        [parentView addConstraints:constraints];
    }
}

- (void)insertRemoteView:(RemoteView *)remoteView {
    assert(OnMainThread && remoteView);

    RemoteView * currentRV = (RemoteView *)[self.view viewWithNametag:kRemoteViewNameTag];

    assert([currentRV isKindOfClass:[RemoteView class]] || currentRV == nil);

// if (currentRV && currentRV.identifier == remoteView.identifier)
// return;

    BOOL   shouldToggleToolbar = ([self isTopToolbarVisible] == remoteView.topBarHiddenOnLoad);

    remoteView.nametag = kRemoteViewNameTag;
    if (currentRV) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             [currentRV removeFromSuperview];
                             [self.view
                              insertSubview:remoteView
                               belowSubview:_topToolbar];
                             [self.view setNeedsUpdateConstraints];
                             if (shouldToggleToolbar) [self toggleTopToolbar:NO];
                         }

        ];
    } else {
        [self.view insertSubview:remoteView belowSubview:_topToolbar];
        if (shouldToggleToolbar) [self toggleTopToolbar:NO];

        [self.view setNeedsUpdateConstraints];
    }

#ifdef DUMP_LAYOUT_DATA
    NSOperationQueue * queue = [NSOperationQueue new];

    [queue addOperationWithBlock:^{
               int64_t delayInSeconds = 2.0;
               dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
               dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                [self dumpLayoutData];
#  ifdef DUMP_ELEMENT_HIERARCHY
                [self dumpElements];
#  endif
               }

                       );
           }

    ];
#else /* ifdef DUMP_LAYOUT_DATA */
#  ifdef DUMP_ELEMENT_HIERARCHY
    NSOperationQueue * queue = [NSOperationQueue new];

    [queue addOperationWithBlock:^{
               int64_t delayInSeconds = 2.0;
               dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
               dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                [self dumpElements];
               }

                       );
           }

    ];
#  endif /* ifdef DUMP_ELEMENT_HIERARCHY */
#endif   /* ifdef DUMP_LAYOUT_DATA */
}  /* insertRemoteView */

/**
 * Re-enables proximity monitoring and determines whether toolbar should be visible.
 * @param animated Whether the view is appearing via animation.
 */
- (void)viewWillAppear:(BOOL)animated {
    if (_flags.monitorProximitySensor) CurrentDevice.proximityMonitoringEnabled = YES;

#ifdef INACTIVITY_TIMER
    if (_flags.inactivityTimeout) [self startInactivityTimer];
#endif
}

/**
 * Ceases proximity monitoring if it had been enabled.
 * @param animated Whether the view is disappearing via animation.
 */
- (void)viewWillDisappear:(BOOL)animated {
    if (_flags.monitorProximitySensor) CurrentDevice.proximityMonitoringEnabled = NO;

#ifdef INACTIVITY_TIMER
    if (_flags.monitoringInactivity) [self stopInactivityTimer:NO];
#endif
}

#pragma mark - Managing the top toolbar

- (void)showTopToolbar:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             _topToolbarConstraint.constant = 0;
                             [self.view layoutIfNeeded];
                         }

                         completion:nil];
    } else
        _topToolbarConstraint.constant = 0;
}

- (void)hideTopToolbar:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             _topToolbarConstraint.constant = -_topToolbar.bounds.size.height;
                             [self.view layoutIfNeeded];
                         }

                         completion:nil];
    } else
        _topToolbarConstraint.constant = -_topToolbar.bounds.size.height;
}

- (void)toggleTopToolbar:(BOOL)animated {
    CGFloat   newValue = (_topToolbarConstraint.constant ? 0 : -_topToolbar.bounds.size.height);

    if (animated) {
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             _topToolbarConstraint.constant = newValue;
                             [self.view layoutIfNeeded];
                         }

                         completion:nil];
    } else
        _topToolbarConstraint.constant = newValue;
}

- (IBAction)toggleTopToolbarAction:(id)sender {
    static const MSBoundary   threshold = {.lower = -44.0f, .upper = 44.0f};

                assert(_topToolbar.bounds.size.height == threshold.upper);
    if ([sender isKindOfClass:[MSPinchGestureRecognizer class]]) {
        MSPinchGestureRecognizer * pinch = (MSPinchGestureRecognizer *)sender;

        switch (pinch.state) {
            case UIGestureRecognizerStateBegan : {
                assert(pinch.threshold.lower == -44.0f && pinch.threshold.upper == 44.0f);
            }
            break;

            case UIGestureRecognizerStateChanged : {
                CGFloat   delta       = llroundl(pinch.distance);               // * multiplier;
                CGFloat   newConstant = _topToolbarConstraint.constant - delta; /*(delta > 0
                                                                                 * ? 0 - delta
                                                                                 * : threshold.lower
                                                                                 * - delta
                                                                                 * );*/

                if (newConstant < threshold.lower) newConstant = threshold.lower;
                else if (newConstant > 0) newConstant = 0;

                if (newConstant != _topToolbarConstraint.constant) {
                    [UIView animateWithDuration:0.25
                                          delay:0.0
                                        options:UIViewAnimationOptionBeginFromCurrentState
                                     animations:^{
                                         _topToolbarConstraint.constant = newConstant;
                                         [self.view layoutIfNeeded];
                                     }

                                     completion:nil];
                }
            }
            break;

            case UIGestureRecognizerStateEnded : {
                if (_topToolbarConstraint.constant < threshold.lower / 2.0f) [self hideTopToolbar:YES];
                else [self showTopToolbar:YES];
            }
            break;

            default :
                break;
        } /* switch */
    } else
        [self toggleTopToolbar:YES];
}         /* toggleTopToolbarAction */

- (IBAction)openSettings:(id)sender {
    [self presentViewController:(UIViewController *)[StoryboardProxy settingsViewController]
                       animated:YES
                     completion:nil];
}

- (BOOL)isTopToolbarVisible {
    return (_topToolbarConstraint.constant == 0);
}

/**
 * Creates and attaches the default toolbar items to the items created by the storyboard. Currently
 * this includes a connection status button and a battery status button.
 */
- (void)initializeTopToolbar {
    _topToolbar = (ButtonGroupView *)[RemoteElementView remoteElementViewWithElement:(ButtonGroup *)
                                      [_remoteController.managedObjectContext
                                       existingObjectWithID:_remoteController.topToolbar.objectID
                                                      error:nil]];
                assert(_topToolbar);
    _topToolbar.nametag = @"remote controller top toolbar";
    [self.view addSubview:_topToolbar];
    _topToolbarConstraint = [NSLayoutConstraint constraintWithItem:_topToolbar
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.view
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1
                                                          constant:0];
    _topToolbarConstraint.nametag = kTopToolbarConstraintNameTag;
    [self.view addConstraint:_topToolbarConstraint];
    [self.view
     addConstraints:[NSLayoutConstraint constraintsByParsingString:@"H:|[_topToolbar]|"  //
                                                                                         // nV:|[_topToolbar]"
                                                             views:NSDictionaryOfVariableBindings(_topToolbar)]];
}

#pragma mark - Editing remotes

/**
 * `IBAction` for launching an editor for `Remote` object of the current `RemoteView` being
 * displayed by the view controller.
 * @param sender Object responsible for invoking the method.
 */
- (IBAction)editCurrentRemote:(id)sender {
    RemoteEditingViewController * editorVC = [StoryboardProxy remoteEditingViewController];

    editorVC.remoteElement = _remoteController.currentRemote;
    editorVC.delegate      = self;

    [self presentViewController:editorVC animated:YES completion:nil];
}

- (void)remoteElementEditorDidSave:(RemoteElementEditingViewController *)remoteElementEditor {
    [self dismissViewControllerAnimated:YES completion:nil];

// assert([DataManager saveMainContext]);

// RemoteView * rv = (RemoteView *)[self.view  viewWithNametag:kRemoteViewNameTag];
// [rv updateViewFromModel];
}

- (void)remoteElementEditorDidCancel:(RemoteElementEditingViewController *)remoteElementEditor {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Debugging

- (void)dumpLayoutData {
    MSLogDebug(@"%@ dumping constraints...\n\n%@\n\n",
               ClassTagSelectorString,
               [[UIWindow keyWindow] viewTreeDescriptionWithProperties:@[@"frame", @"hasAmbiguousLayout?", @"key", @"nametag", @"displayName", @"constraints"]]);
}

- (void)dumpElements {
    MSLogDebug(@"%@ dumping elements...\n\n%@\n\n",
               ClassTagSelectorString,
               [[(RemoteView *)[self.view
                                viewWithNametag:kRemoteViewNameTag]
                 remoteElement]
                dumpElementHierarchy]);
}

- (IBAction)debugAmbiguity:(id)sender {
    [self.view exerciseAmbiguityInLayout];
}

@end
