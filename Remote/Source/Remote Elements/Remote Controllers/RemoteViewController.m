#import "RemoteViewController.h"
#import "RemoteElementView.h"
#import "StoryboardProxy.h"
#import "RemoteController.h"
#import "SettingsViewController.h"
#import "SettingsManager.h"
#import "RemoteElementConstructionManager.h"
#import "ControlStateSet.h"
#import "ButtonGroup.h"
#import "Remote.h"
#import "CoreDataManager.h"
#import "StoryboardProxy.h"
#import "MSRemoteAppController.h"
#import "Command.h"

// #define DUMP_ELEMENT_HIERARCHY
// #define DUMP_LAYOUT_DATA

// #define INACTIVITY_TIMER

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static const int   msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE);

MSSTATIC_STRING_CONST   kRemoteViewNameTag                     = @"kRemoteViewNameTag";
MSSTATIC_STRING_CONST   kTopToolbarConstraintNameTag           = @"kTopToolbarConstraintNameTag";
MSSTATIC_STRING_CONST   kTopToolbarRemoteViewConstraintNameTag = @"kTopToolbarRemoteViewConstraintNameTag";

@implementation RemoteViewController {
    struct {
        BOOL             monitorProximitySensor;
        NSTimeInterval   inactivityTimeout;
        BOOL             autohideTopBar;
        BOOL             remoteInactive;
        BOOL             loadHomeScreen;
        BOOL             monitoringInactivity;
        BOOL             shouldHideTopToolbar;
    } _flags;

    ButtonGroupView  * _topToolbar;
    NSLayoutConstraint * _topToolbarConstraint;
    RemoteController * _remoteController;
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
                       context:(void *)context
{
    assert(object == _remoteController);
    assert([@"currentRemote" isEqualToString: keyPath]);
    if([change[NSKeyValueChangeNewKey] isMemberOfClass:[Remote class]])
        MSRunSyncOnMain (^{
            Remote * r = (Remote*)change[NSKeyValueChangeNewKey];
            assert(r && [r isKindOfClass:[Remote class]]);
            RemoteView * rv = (RemoteView*)[RemoteElementView viewWithModel:r];
            assert(rv && [rv isKindOfClass:[RemoteView class]]);
            [self insertRemoteView:rv];
        });
}

/**
 * Register for changes to various values of the model as well as any changes to its
 * `NSManagedObjectContext`.
 */
- (void)registerForKVONotifications
{
    [_remoteController addObserver:self
                        forKeyPath:@"currentRemote"
                           options:NSKeyValueObservingOptionNew
                           context:NULL];
}

/**
 * Removes the `RemoteViewController` as an observer for the notifications registered for in
 * `registerForChangeNotification`.
 */
- (void)unregisterForKVONotifications
{
    [_remoteController removeObserver:self forKeyPath:@"currentRemote"];
}

- (void)registerForNotificationCenterNotifications
{
    [NotificationCenter addObserverForName:MSSettingsManagerProximitySensorSettingDidChangeNotification
                                    object:[SettingsManager class]
                                     queue:nil
                                usingBlock:^(NSNotification * note){
         _flags.monitorProximitySensor = [SettingsManager boolForSetting:MSSettingsProximitySensorKey];
         CurrentDevice.proximityMonitoringEnabled = _flags.monitorProximitySensor;
     }

    ];
#ifdef INACTIVITY_TIMER
    [NotificationCenter addObserverForName:MSSettingsManagerInactivityTimeoutSettingDidChangeNotification
                                    object:[SettingsManager sharedSettingsManager]
                                     queue:nil
                                usingBlock:^(NSNotification * note){
         _flags.inactivityTimeout = [SettingsManager floatForSetting:MSSettingsInactivityTimeoutKey];
         if (_flags.monitoringInactivity && !_flags.inactivityTimeout) [self stopInactivityTimer:NO];
     }

    ];
#endif  /* ifdef INACTIVITY_TIMER */
}

- (void)unregisterForNotificationCenterNotifications
{
    [NotificationCenter removeObserver:self name:nil object:[SettingsManager class]];
}

#pragma mark - NSObject overrides
/*
- (void)awakeFromNib
{
    _remoteController = [RERemoteController remoteController];
    assert(_remoteController);
    _remoteController.managedObjectContext.nametag = @"remote";

    _flags.monitorProximitySensor = [SettingsManager boolForSetting:MSSettingsProximitySensorKey];
    _flags.inactivityTimeout      = [SettingsManager floatForSetting:MSSettingsInactivityTimeoutKey];
    _flags.loadHomeScreen         = YES;
    [self registerForKVONotifications];
    [self registerForNotificationCenterNotifications];
                         assert([SystemCommand registerRemoteViewController:self]);
}
*/

- (void)dealloc
{
    [self unregisterForKVONotifications];
    [self unregisterForNotificationCenterNotifications];
    [SystemCommand registerRemoteViewController:nil];
}

#pragma mark - UIViewController overrides

/**
 * Releases the cached remote view and any other retained properties relating to the view.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    DDLogWarn(@"%@ is view loaded? %@  is toolbar allocated? %@",
              ClassTagSelectorString,
              BOOLString([self isViewLoaded]),
              BOOLString(_topToolbar == nil));
}

#ifdef INACTIVITY_TIMER
- (void)resumeInactivityTimer
{
    assert(_inactivityTimer && !dispatch_source_testcancel(_inactivityTimer) && _flags.remoteInactive);
    dispatch_resume(_inactivityTimer);
    MSLogDebug(@"%@ inactivity timer resumed", ClassTagSelectorString);
    _flags.remoteInactive       = NO;
    _flags.monitoringInactivity = YES;
}

- (void)startInactivityTimer
{
    if (_inactivityTimer)
    {
        [self resumeInactivityTimer];

        return;
    }

    NSTimeInterval   maxInactivity = _flags.inactivityTimeout;

    _flags.monitoringInactivity = YES;

    static const uint64_t   leeway = 5.0 * NSEC_PER_SEC;
    __block uint64_t        (^ timeToNext)(void) = ^(void){
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
      MSLogDebug(@"%@ next: %lld (%fs)",
                 ClassTagSelectorString,
                 next,
                 (NSTimeInterval)next / NSEC_PER_SEC);
      if (next)
      {
          MSLogDebug(@"%@ max inactivity:%fs  last event:%fs timeout in:%llds",
                     ClassTagSelectorString,
                     (maxInactivity / NSEC_PER_SEC),
                     ((maxInactivity - next) / NSEC_PER_SEC),
                     (next / NSEC_PER_SEC));
          dispatch_source_set_timer(_inactivityTimer,
                                    dispatch_walltime(DISPATCH_TIME_NOW, next),
                                    maxInactivity,
                                    leeway);
      }
      else
      {
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
}

- (void)stopInactivityTimer:(BOOL)timeout
{
    if (_inactivityTimer)
    {
        dispatch_suspend(_inactivityTimer);
        if (timeout)
        {
            [NotificationCenter addObserverForName:UIScreenBrightnessDidChangeNotification
                                            object:MainScreen
                                             queue:nil
                                        usingBlock:^(NSNotification * note){
                 if (MainScreen.brightness > 0)
                 {
                     MSLogDebug(@"%@ restarting inactivity timer",
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
        }
        else
            _flags.monitoringInactivity = NO;
    }
}
#endif  /* ifdef INACTIVITY_TIMER */

- (void)viewDidLoad
{
    [self.view addGestureRecognizer:[UIPinchGestureRecognizer gestureWithTarget:self
                                                                         action:@selector(toggleTopToolbarAction:)]];
    _remoteController = [RemoteController remoteController];
    assert(_remoteController);
    _remoteController.managedObjectContext.nametag = @"remote";

    _flags.monitorProximitySensor = [SettingsManager boolForSetting:MSSettingsProximitySensorKey];
    _flags.inactivityTimeout      = [SettingsManager floatForSetting:MSSettingsInactivityTimeoutKey];
    _flags.loadHomeScreen         = YES;
    [self registerForKVONotifications];
    [self registerForNotificationCenterNotifications];
    assert([SystemCommand registerRemoteViewController:self]);

    assert(!_topToolbar);
    [self initializeTopToolbar];
    
    assert(![self.view viewWithNametag:kRemoteViewNameTag]);

    Remote * remote = _remoteController.currentRemote;
    if (!remote && [_remoteController switchToRemote:_remoteController.homeRemote])
        remote = _remoteController.currentRemote;
    assert(remote);

    [self insertRemoteView:[RemoteView viewWithModel:remote]];

    _flags.shouldHideTopToolbar = remote.topBarHidden;

    [self.view.gestureRecognizers enumerateObjectsUsingBlock:
     ^(id obj, NSUInteger idx, BOOL * stop)
     {
         if ([obj isMemberOfClass:[MSPinchGestureRecognizer class]])
         {
             ((MSPinchGestureRecognizer*)obj).threshold = (MSBoundary) {.lower = -44.0f, .upper = 44.0f};
             *stop = YES;
         }
     }];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];

    RemoteView * remoteView = (RemoteView*)[self.view viewWithNametag:kRemoteViewNameTag];

    if (remoteView && ![self.view constraintsWithNametag:kRemoteViewNameTag])
    {
        UIView  * parentView  = self.view;
        NSArray * constraints = [NSLayoutConstraint
                                 constraintsByParsingString:@"remoteView.centerX = parentView.centerX\n"
                                                             "remoteView.bottom = parentView.bottom\n"
                                                             "remoteView.top = parentView.top"
                                                      views:NSDictionaryOfVariableBindings(remoteView,
                                                                                           parentView,
                                                                                           _topToolbar)];

        for (NSLayoutConstraint * lc in constraints)
            lc.nametag = kRemoteViewNameTag;

        [parentView addConstraints:constraints];
    }
}

- (void)insertRemoteView:(RemoteView *)remoteView
{
    assert(OnMainThread && remoteView);

    RemoteView * currentRV = (RemoteView*)[self.view viewWithNametag:kRemoteViewNameTag];

    assert([currentRV isKindOfClass:[RemoteView class]] || currentRV == nil);

    BOOL shouldToggleToolbar = ([self isTopToolbarVisible] == remoteView.topBarHidden);

    remoteView.nametag = kRemoteViewNameTag;

    if (currentRV)
    {
        [UIView animateWithDuration:0.25
                         animations:^{
                                         assert(IsMainQueue);
                                         [currentRV removeFromSuperview];
                                         [self.view insertSubview:remoteView belowSubview:_topToolbar];
                                         if (shouldToggleToolbar) [self toggleTopToolbar:YES];
                                         [self.view setNeedsUpdateConstraints];
                                     }];
    }
    
    else
    {
        [self.view insertSubview:remoteView belowSubview:_topToolbar];

        if (shouldToggleToolbar) [self toggleTopToolbar:YES];

        [self.view setNeedsUpdateConstraints];
    }

#ifdef DUMP_LAYOUT_DATA
    NSOperationQueue * queue = [NSOperationQueue new];

    [queue addOperationWithBlock:^{
         int64_t delayInSeconds = 2.0;
         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            [self dumpLayoutData];
#  ifdef DUMP_ELEMENT_HIERARCHY
                            [self dumpElements];
#  endif
                        }

         );
     }

    ];
#else  /* ifdef DUMP_LAYOUT_DATA */
#  ifdef DUMP_ELEMENT_HIERARCHY
    NSOperationQueue * queue = [NSOperationQueue new];

    [queue addOperationWithBlock:^{
         int64_t delayInSeconds = 2.0;
         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            [self dumpElements];
                        }

         );
     }

    ];
#  endif  /* ifdef DUMP_ELEMENT_HIERARCHY */
#endif   /* ifdef DUMP_LAYOUT_DATA */

#define LOG_ELEMENTS
#ifdef LOG_ELEMENTS

    NSOperationQueue * queue = [NSOperationQueue new];

    [queue addOperationWithBlock:^{
        int64_t delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

            MSLogDebugInContext(LOG_CONTEXT_CONSOLE,
                                @"%@\n%@\n%@\n",
                                [@"Displayed Remote Elements" singleBarMessageBox],
                                [_topToolbar.model recursiveDeepDescription],
                                [remoteView.model recursiveDeepDescription]);
            
        });
    }];

#endif
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    if (_flags.shouldHideTopToolbar == [self isTopToolbarVisible])
        [self toggleTopToolbar:YES];

}

/**
 * Re-enables proximity monitoring and determines whether toolbar should be visible.
 * @param animated Whether the view is appearing via animation.
 */
- (void)viewWillAppear:(BOOL)animated
{
    if (_flags.monitorProximitySensor) CurrentDevice.proximityMonitoringEnabled = YES;

#ifdef INACTIVITY_TIMER
    if (_flags.inactivityTimeout) [self startInactivityTimer];
#endif

}

/**
 * Ceases proximity monitoring if it had been enabled.
 * @param animated Whether the view is disappearing via animation.
 */
- (void)viewWillDisappear:(BOOL)animated
{
    if (_flags.monitorProximitySensor) CurrentDevice.proximityMonitoringEnabled = NO;

#ifdef INACTIVITY_TIMER
    if (_flags.monitoringInactivity) [self stopInactivityTimer:NO];
#endif
}

#pragma mark - Managing the top toolbar

- (void)showTopToolbar:(BOOL)animated
{
    if (animated)
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                                       _topToolbarConstraint.constant = 0;
                                       [self.view layoutIfNeeded];
                                     }
                         completion:nil];

    else
        _topToolbarConstraint.constant = 0;
}

- (void)hideTopToolbar:(BOOL)animated
{
    if (animated)
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                                         _topToolbarConstraint.constant = -_topToolbar.bounds.size.height;
                                         [self.view layoutIfNeeded];
                                     }
                         completion:nil];

    else
        _topToolbarConstraint.constant = -_topToolbar.bounds.size.height;
}

- (void)toggleTopToolbar:(BOOL)animated
{
    CGFloat   newValue = (_topToolbarConstraint.constant ? 0 : -_topToolbar.bounds.size.height);

    if (animated)
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                                        _topToolbarConstraint.constant = newValue;
                                        [self.view layoutIfNeeded];
                                     }
                         completion:nil];

    else
        _topToolbarConstraint.constant = newValue;
}

- (IBAction)toggleTopToolbarAction:(id)sender
{
    static const MSBoundary   threshold = { .lower = -44.0f, .upper = 44.0f };
//    assert(_topToolbar.bounds.size.height == threshold.upper);

    if ([sender isKindOfClass:[MSPinchGestureRecognizer class]])
    {
        MSPinchGestureRecognizer * pinch = (MSPinchGestureRecognizer*)sender;

        switch (pinch.state)
        {
            case UIGestureRecognizerStateBegan:
            {
                assert(pinch.threshold.lower == -44.0f && pinch.threshold.upper == 44.0f);
            }
            break;

            case UIGestureRecognizerStateChanged:
            {
                CGFloat   delta       = llroundl(pinch.distance);
                CGFloat   newConstant = _topToolbarConstraint.constant - delta;

                if (newConstant < threshold.lower) newConstant = threshold.lower;
                else if (newConstant > 0)
                    newConstant = 0;

                if (newConstant != _topToolbarConstraint.constant)
                {
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

            case UIGestureRecognizerStateEnded:
            {
                if (_topToolbarConstraint.constant < threshold.lower / 2.0f) [self hideTopToolbar:YES];
                else [self showTopToolbar:YES];
            }
            break;

            default:
                break;
        }
    }
    
    else
        [self toggleTopToolbar:YES];
}

- (IBAction)openSettings:(id)sender
{
    [self presentViewController:[StoryboardProxy settingsViewController]
                       animated:YES
                     completion:nil];
}

- (BOOL)isTopToolbarVisible { return (_topToolbarConstraint.constant == 0); }

/**
 * Creates and attaches the default toolbar items to the items created by the storyboard. Currently
 * this includes a connection status button and a battery status button.
 */
- (void)initializeTopToolbar
{
    _topToolbar = [ButtonGroupView viewWithModel:
                   (ButtonGroup *)[_remoteController.topToolbar faultedObject]];
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
    [self.view addConstraints:
     [NSLayoutConstraint constraintsByParsingString:@"H:|[_topToolbar]|"
                                              views:@{ @"_topToolbar": _topToolbar }]];
}

#pragma mark - Editing remotes

/**
 * `IBAction` for launching an editor for `Remote` object of the current `RemoteView` being
 * displayed by the view controller.
 * @param sender Object responsible for invoking the method.
 */
- (IBAction)editCurrentRemote:(id)sender
{
    RemoteEditingViewController * editorVC = [StoryboardProxy remoteEditingViewController];

    editorVC.remoteElement = _remoteController.currentRemote;
    editorVC.delegate      = self;

    [self presentViewController:editorVC animated:YES completion:nil];
}

- (void)remoteElementEditorDidSave:(RemoteElementEditingViewController *)remoteElementEditor
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)remoteElementEditorDidCancel:(RemoteElementEditingViewController *)remoteElementEditor
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Debugging

- (void)dumpLayoutData
{
    MSLogDebug(@"%@ dumping constraints...\n\n%@\n\n",
               ClassTagSelectorString,
               [[UIWindow keyWindow] viewTreeDescriptionWithProperties:@[@"frame",
                                                                         @"hasAmbiguousLayout?",
                                                                         @"key",
                                                                         @"nametag",
                                                                         @"name",
                                                                         @"constraints"]]);
}


- (void)dumpElements
{
    MSLogDebug(@"%@ dumping elements...\n\n%@\n\n",
               ClassTagSelectorString,
               [[(RemoteView*)[self.view
                                 viewWithNametag:kRemoteViewNameTag]
                 model]
                dumpElementHierarchy]);
}

- (IBAction)debugAmbiguity:(id)sender
{
    [self.view exerciseAmbiguityInLayout];
}

@end
