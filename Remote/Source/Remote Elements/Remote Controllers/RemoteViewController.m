//
// RemoteViewController.m
// Remote
//
// Created by Jason Cardwell on 5/3/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import "RemoteViewController.h"
//#import "RemoteElementView.h"
#import "RemoteController.h"
#import "SettingsManager.h"
//#import "ButtonGroup.h"
//#import "Remote.h"
//#import "CoreDataManager.h"
#import "StoryboardProxy.h"
#import "MSRemoteAppController.h"
#import "Remote-Swift.h"

static int       ddLogLevel   = LOG_LEVEL_DEBUG;
static const int msLogContext = (LOG_CONTEXT_CONSOLE);

@interface RemoteViewController ()
@property (nonatomic, weak,  readwrite) RemoteController   * remoteController;
@property (nonatomic, weak,  readwrite) RemoteView         * remoteView;
@property (nonatomic, weak,  readwrite) NSLayoutConstraint * topToolbarConstraint;
@property (nonatomic, weak,  readwrite) ButtonGroupView    * topToolbarView;

@property (nonatomic, strong) MSNotificationReceptionist * settingsReceptionist;
@property (nonatomic, strong) MSKVOReceptionist          * remoteReceptionist;
@end

@implementation RemoteViewController

+ (instancetype)viewControllerWithModel:(RemoteController *)model {
  RemoteViewController * controller = nil;

  if (model) {

    controller                  = [self new];
    controller.remoteController = model;

    controller.remoteReceptionist =
    [MSKVOReceptionist receptionistWithObserver:controller
                                      forObject:model
                                        keyPath:@"currentRemote"
                                        options:NSKeyValueObservingOptionNew
                                          queue:MainQueue
                                        handler:^(MSKVOReceptionist * receptionist) {
                                          Remote * remote = (Remote *)receptionist.change[NSKeyValueChangeNewKey];
                                          assert(remote && [remote isKindOfClass:[Remote class]]);
                                          RemoteView * remoteView = [[RemoteView alloc] initWithModel:remote];
                                          RemoteViewController * viewController =
                                            (RemoteViewController *)receptionist.observer;
                                          [viewController insertRemoteView:remoteView];
                                        }];

    NSString * name = SMSettingProximitySensorDidChangeNotification;

    controller.settingsReceptionist =
      [MSNotificationReceptionist receptionistWithObserver:controller
                                                 forObject:[SettingsManager class]
                                          notificationName:name
                                                     queue:MainQueue
                                                   handler:^(MSNotificationReceptionist * receptionist) {
                                                     CurrentDevice.proximityMonitoringEnabled =
                                                       [[SettingsManager valueForSetting:SMSettingProximitySensor] boolValue];
                                                   }];
  }

  return controller;
}

/////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController overrides
/////////////////////////////////////////////////////////////////////////////////

/// Releases the cached remote view and any other retained properties relating to the view.
- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  if (!self.remoteController) return;


  [self.view addGestureRecognizer:[UIPinchGestureRecognizer gestureWithTarget:self
                                                                       action:@selector(handlePinch:)]];

  [self initializeTopToolbar];

  [self insertRemoteView:[[RemoteView alloc] initWithModel:self.remoteController.currentRemote]];

}

- (void)updateViewConstraints {

  [super updateViewConstraints];

  NSString * nametag = ClassNametagWithSuffix(@"Remote");

  if (self.remoteView && ![[self.view constraintsWithNametagPrefix:nametag] count]) {
    NSString * rawConstraints = $(@"'%1$@' remote.centerX = view.centerX\n"
                                  "'%1$@' remote.bottom = view.bottom\n"
                                  "'%1$@' remote.top = view.top", nametag);
    NSDictionary * bindings = @{
      @"view" : self.view,
      @"remote" : self.remoteView,
      @"toolbar" : self.topToolbarView
    };
    NSArray * constraints = [NSLayoutConstraint constraintsByParsingString:rawConstraints views:bindings];
    [self.view addConstraints:constraints];

  }

  if (!self.topToolbarConstraint) {
    NSLayoutConstraint * topToolbarConstraint = [NSLayoutConstraint constraintWithItem:self.topToolbarView
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.view
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1.0
                                                                              constant:0.0];

    [self.view addConstraint:topToolbarConstraint];
    self.topToolbarConstraint = topToolbarConstraint;

    [self.view addConstraints:[NSLayoutConstraint constraintsByParsingString:@"toolbar.centerX = view.centerX"
                                                                       views:@{ @"toolbar" : self.topToolbarView,
                                                                                @"view" : self.view }]];
  }

  [self updateTopToolbarLocation];

}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinch {
  if (pinch.state == UIGestureRecognizerStateRecognized)
    [self toggleTopToolbar:YES];
}

- (void)insertRemoteView:(RemoteView *)remoteView {
  assert(OnMainThread && remoteView);

  if (self.remoteView) {
    [UIView animateWithDuration:0.25
                     animations:^{
                       assert(IsMainQueue);
                       [self.remoteView removeFromSuperview];
                       [self.view insertSubview:remoteView belowSubview:self.topToolbarView];
                       self.remoteView = remoteView;
                       [self.view setNeedsUpdateConstraints];
                     }];
  } else {
    [self.view insertSubview:remoteView belowSubview:self.topToolbarView];
    self.remoteView = remoteView;
    [self.view setNeedsUpdateConstraints];
  }

}

- (void)updateTopToolbarLocation {
  if (self.remoteController.currentRemote.topBarHidden == (self.topToolbarConstraint.constant == 0))
    [self toggleTopToolbar:YES];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  [self updateTopToolbarLocation];
}

/// Re-enables proximity monitoring and determines whether toolbar should be visible.
/// @param animated Whether the view is appearing via animation.
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  if ([[SettingsManager valueForSetting:SMSettingProximitySensor] boolValue])
    CurrentDevice.proximityMonitoringEnabled = YES;

}

/// Ceases proximity monitoring if it had been enabled.
/// @param animated Whether the view is disappearing via animation.
- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  if ([[SettingsManager valueForSetting:SMSettingProximitySensor] boolValue])
    CurrentDevice.proximityMonitoringEnabled = NO;
}

/////////////////////////////////////////////////////////////////////////////////
#pragma mark - Managing the top toolbar
/////////////////////////////////////////////////////////////////////////////////

- (void)animateToolbar:(CGFloat)constraintConstant {
  [UIView animateWithDuration:0.25
                        delay:0.0
                      options:UIViewAnimationOptionBeginFromCurrentState
                   animations:^{
                     self.topToolbarConstraint.constant = constraintConstant;
                     [self.view layoutIfNeeded];
                   } completion:nil];
}

- (void)showTopToolbar:(BOOL)animated {
  CGFloat constant = 0;

  if (animated) [self animateToolbar:constant];
  else self.topToolbarConstraint.constant = constant;
}

- (void)hideTopToolbar:(BOOL)animated {
  CGFloat constant = -self.topToolbarView.bounds.size.height;

  if (animated) [self animateToolbar:constant];
  else self.topToolbarConstraint.constant = constant;
}

- (void)toggleTopToolbar:(BOOL)animated {
  CGFloat constant = (self.topToolbarConstraint.constant ? 0 : -self.topToolbarView.bounds.size.height);

  if (animated) [self animateToolbar:constant];
  else self.topToolbarConstraint.constant = constant;
}

/// Creates and attaches the default toolbar items to the items created by the storyboard. Currently
/// this includes a connection status button and a battery status button.
- (void)initializeTopToolbar {
  assert(self.remoteController);

  ButtonGroup * topToolbar = self.remoteController.topToolbar;
  assert(topToolbar);

  ButtonGroupView * topToolbarView = [[ButtonGroupView alloc] initWithModel:topToolbar];
  assert(topToolbarView);

  [self.view addSubview:topToolbarView];
  self.topToolbarView = topToolbarView;
  [self.view setNeedsUpdateConstraints];
}

@end
