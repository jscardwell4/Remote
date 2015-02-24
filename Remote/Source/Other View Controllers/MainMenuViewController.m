//
// MainMenuViewController.m
// Remote
//
// Created by Jason Cardwell on 12/27/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "MainMenuViewController.h"
#import "RemoteViewController.h"
//#import "CoreDataManager.h"
//#import "RemoteElement.h"
#import "MSRemoteAppController.h"
#import "StoryboardProxy.h"
@import MoonKit;

static int ddLogLevel = LOG_LEVEL_WARN;
static const int msLogContext = 0;
#pragma unused(ddLogLevel, msLogContext)

@interface MainMenuViewController ()

- (IBAction)showRemote;
- (IBAction)showEditor;
- (IBAction)showBank;
- (IBAction)showSettings;
- (IBAction)showHelp;

@end

@implementation MainMenuViewController {
    IBOutlet UIProgressView          * progressView;
    IBOutlet UILabel                 * currentTaskLabel;
    IBOutlet UILabel                 * taskCountLabel;
    IBOutlet UIActivityIndicatorView * spinner;
    IBOutlet UIView                  * loadingView;
    IBOutlet UILabel                 * versionInfoLabel;
}

@synthesize progress, loadingComplete, taskCount, currentTaskIndex;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    versionInfoLabel.text = [NSString stringWithFormat:@"version: %@", [MSRemoteAppController versionInfo]];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  UIApp.statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  UIApp.statusBarStyle = UIStatusBarStyleDefault;
}

/// @name ￼Actions
- (IBAction)showRemote { [AppController showRemote]; }

- (IBAction)showEditor { [AppController showEditor]; }

- (IBAction)showBank { [AppController showBank]; }

- (IBAction)showSettings { [AppController showSettings]; }

- (IBAction)showHelp { [AppController showHelp]; }

/// @name Loading screen properties

- (void)toggleSpinner
{
    if (spinner.isAnimating) {
        [spinner stopAnimating];
        progressView.hidden = NO;
    } else {
        [spinner startAnimating];
        progressView.hidden = YES;
    }

    [self.view setNeedsDisplay];
}

- (void)setTaskCount:(NSUInteger)newTaskCount
{
    taskCount = newTaskCount;

    if (taskCount > 0) loadingView.alpha = 1.0;
}

- (NSString *)currentTask { return currentTaskLabel.text; }

- (void)setCurrentTask:(NSString *)newTask incrementTaskCount:(BOOL)increment
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         currentTaskLabel.alpha = 0.0;
                         currentTaskLabel.text = newTask;
                         currentTaskLabel.alpha = 1.0;
                     }

    ];

    if (increment) {
        currentTaskIndex++;
        taskCountLabel.text = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)currentTaskIndex, (unsigned long)taskCount];
    }

    [self.view setNeedsDisplay];
}

- (void)setLoadingComplete:(BOOL)loadingIsComplete
{
    loadingComplete = loadingIsComplete;

    if (loadingComplete)
        [UIView animateWithDuration:1.0
                         animations:^{
                             loadingView.alpha = 0.0;
                         }

        ];

    else
        loadingView.alpha = 1.0;
}

- (CGFloat)progress { return progressView.progress; }

- (void)setProgress:(CGFloat)newProgressValue { [progressView setProgress:newProgressValue animated:(newProgressValue != 0.0)]; }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    versionInfoLabel = nil;
    progressView     = nil;
    currentTaskLabel = nil;
    taskCountLabel   = nil;
    spinner          = nil;
    loadingView      = nil;

    if ([self isViewLoaded] && self.view.window == nil) self.view = nil;
}

@end
