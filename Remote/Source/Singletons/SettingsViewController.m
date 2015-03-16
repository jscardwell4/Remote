//
// SettingsViewController.m
// Remote
//
// Created by Jason Cardwell on 3/2/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "SettingsViewController.h"
#import "MSRemoteAppController.h"
#import "SettingsManager.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

@interface SettingsViewController ()

- (IBAction)switchValueDidChange:(UISwitch *)sender;
- (IBAction)doneAction:(id)sender;

@property (strong, nonatomic) IBOutletCollection(UISwitch) NSArray *switches;

@end

@implementation SettingsViewController

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && self.view.window == nil) {
        self.view          = nil;
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateUI];
}

- (void)updateUI {
    // fill UI with values from settings manager
    for (UISwitch * s in self.switches) {
        s.on = [[SettingsManager valueForSetting:s.tag] boolValue];
    }
}

- (IBAction)switchValueDidChange:(UISwitch *)sender {
    [SettingsManager setValue:@(sender.on) forSetting:sender.tag];
}


- (IBAction)doneAction:(id)sender { [AppController dismissViewController:self completion:nil]; }

@end
