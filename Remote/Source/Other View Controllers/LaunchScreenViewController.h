/*
 * LaunchScreenViewController.h
 * iPhonto
 *
 * Created by Jason Cardwell on 12/27/11.
 * Copyright (c) 2011 Moondeer Studios. All rights reserved.
 */

#import "RemoteEditingViewController.h"

/**
 * `LaunchScreenViewController` is created in the main storyboard as the initial view controller
 * for the application. It contains buttons for navigating to the remote, the IR learner, and the
 * root view controller for all the banks (i.e. codes, images, presets).
 */
@interface LaunchScreenViewController : UIViewController

@property (nonatomic, getter = isLoadingComplete) BOOL   loadingComplete;

@property (nonatomic, readonly, weak) NSString * currentTask;

- (void)toggleSpinner;

- (void)setCurrentTask:(NSString *)newTask incrementTaskCount:(BOOL)increment;

@property (nonatomic) CGFloat   progress;

@property (nonatomic) NSUInteger   taskCount;

@property (nonatomic) NSUInteger   currentTaskIndex;
@end
