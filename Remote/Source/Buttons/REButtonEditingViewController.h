//
// ButtonEditingViewController.h
// Remote
//
// Created by Jason Cardwell on 3/24/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "REEditingViewController.h"
#import "LabelEditingViewController.h"
#import "IconEditingViewController.h"

@class   REButton;

@interface REButtonEditingViewController : REEditingViewController

- (id)initWithButton:(REButton *)button
            delegate:(UIViewController <REEditingViewControllerDelegate> *)delegate;

- (void)removeAuxController:(UIViewController *)controller animated:(BOOL)animated;
- (void)addAuxController:(UIViewController *)controller animated:(BOOL)animated;

@property (nonatomic, assign) UIControlState   presentedControlState;

@end
