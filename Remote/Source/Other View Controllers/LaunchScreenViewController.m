//
// LaunchScreenViewController.m
// Remote
//
// Created by Jason Cardwell on 12/27/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "LaunchScreenViewController.h"
#import "RERemoteViewController.h"
#import "CoreDataManager.h"
#import "RemoteElement.h"
#import "MSRemoteAppController.h"
#import "StoryboardProxy.h"

static int   ddLogLevel = LOG_LEVEL_DEBUG;

// static int ddLogLevel = DefaultDDLogLevel;

@interface LaunchScreenViewController ()

/**
 * Presents the shared remote view controller.
 * @param sender Object, typically a button, that invoked the action.
 */
- (IBAction)launchRemote:(id)sender;

- (IBAction)launchEditor:(id)sender;

- (IBAction)unwind:(UIStoryboardSegue *)sender;

@end

@implementation LaunchScreenViewController {
    IBOutlet UIProgressView          * progressView;
    IBOutlet UILabel                 * currentTaskLabel;
    IBOutlet UILabel                 * taskCountLabel;
    IBOutlet UIActivityIndicatorView * spinner;
    IBOutlet UIView                  * loadingView;
    IBOutlet UILabel                 * versionInfoLabel;
}

@synthesize progress, loadingComplete, taskCount, currentTaskIndex;

- (void)viewDidLoad {
    [super viewDidLoad];

    versionInfoLabel.text = [NSString stringWithFormat:@"version: %@", [MSRemoteAppController versionInfo]];
}

/// @name ￼Actions
- (IBAction)launchRemote:(id)sender {
    assert(NO);
// [self presentViewController:[RemoteViewController sharedRemoteViewController] animated:YES
// completion:nil];
}

- (IBAction)launchEditor:(id)sender {
    RERemoteEditingViewController * editorVC = [StoryboardProxy remoteEditingViewController];
    RERemote * remote   = [RERemote remoteElementInContext:[NSManagedObjectContext MR_defaultContext]];

    editorVC.remoteElement = remote;
    editorVC.delegate      = nil;

    [self presentViewController:editorVC animated:YES completion:nil];
}

/// @name Loading screen properties

- (void)toggleSpinner {
    if (spinner.isAnimating) {
        [spinner stopAnimating];
        progressView.hidden = NO;
    } else {
        [spinner startAnimating];
        progressView.hidden = YES;
    }

    [self.view setNeedsDisplay];
}

- (void)setTaskCount:(NSUInteger)newTaskCount {
    taskCount = newTaskCount;

    if (taskCount > 0) loadingView.alpha = 1.0;
}

- (NSString *)currentTask {
    return currentTaskLabel.text;
}

- (void)setCurrentTask:(NSString *)newTask incrementTaskCount:(BOOL)increment {
    [UIView animateWithDuration:0.25
                     animations:^{
                         currentTaskLabel.alpha = 0.0;
                         currentTaskLabel.text = newTask;
                         currentTaskLabel.alpha = 1.0;
                     }

    ];

    if (increment) {
        currentTaskIndex++;
        taskCountLabel.text = [NSString stringWithFormat:@"%u/%u", currentTaskIndex, taskCount];
    }

    [self.view setNeedsDisplay];
}

- (void)setLoadingComplete:(BOOL)loadingIsComplete {
    loadingComplete = loadingIsComplete;

    if (loadingComplete) {
        [UIView animateWithDuration:1.0
                         animations:^{
                             loadingView.alpha = 0.0;
                         }

        ];
    } else
        loadingView.alpha = 1.0;
}

- (CGFloat)progress {
    return progressView.progress;
}

- (void)setProgress:(CGFloat)newProgressValue {
    [progressView setProgress:newProgressValue animated:(newProgressValue != 0.0)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    versionInfoLabel = nil;
    progressView     = nil;
    currentTaskLabel = nil;
    taskCountLabel   = nil;
    spinner          = nil;
    loadingView      = nil;

    if ([self isViewLoaded] && self.view.window == nil) self.view = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DDLogDebug(@"%@", ClassTagSelectorString);
}

- (IBAction)unwind:(UIStoryboardSegue *)sender
{}

@end
