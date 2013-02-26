//
// ButtonEditingViewController.h
// iPhonto
//
// Created by Jason Cardwell on 3/24/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "RemoteElementEditingViewController.h"
#import "LabelEditingViewController.h"
#import "IconEditingViewController.h"

@class   Button;

@interface ButtonEditingViewController : RemoteElementEditingViewController

- (id)initWithButton:(Button *)button
            delegate:(UIViewController <RemoteElementEditingViewControllerDelegate> *)delegate;

- (void)removeAuxController:(UIViewController *)controller animated:(BOOL)animated;
- (void)addAuxController:(UIViewController *)controller animated:(BOOL)animated;

@property (nonatomic, assign) UIControlState   presentedControlState;

@end
