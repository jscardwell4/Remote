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

static int   ddLogLevel = DefaultDDLogLevel;

@interface SettingsViewController ()

- (IBAction)switchValueDidChange:(UISwitch *)sender;
- (IBAction)sliderValueDidChange:(UISlider *)sender;
- (IBAction)doneAction:(id)sender;

@property (strong, nonatomic)IBOutletCollection(UISwitch) NSArray * keyedSwitches;
@property (strong, nonatomic)IBOutletCollection(UISlider) NSArray * keyedSliders;
@property (strong, nonatomic)IBOutletCollection(UILabel) NSArray * keyedLabels;

@end

@implementation SettingsViewController

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && self.view.window == nil) {
        self.view          = nil;
        self.keyedSwitches = nil;
        self.keyedSliders  = nil;
        self.keyedLabels   = nil;
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateUI];
}

- (void)updateUI {
    // fill UI with values from settings manager
    for (UISwitch * s in _keyedSwitches) {
        s.on = [SettingsManager boolForSetting:s.nametag];
    }

    for (UISlider * s in _keyedSliders) {
        s.value = [SettingsManager floatForSetting:s.nametag];
        [self updateLabelTextForKey:s.nametag];
        [self updateLabelConstraintForSlider:s];
    }
}

- (IBAction)switchValueDidChange:(UISwitch *)sender {
    [SettingsManager setBool:sender.on forSetting:sender.nametag];
}

- (void)updateLabelTextForKey:(NSString *)key {
    NSUInteger   idx = [_keyedLabels indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL * stop) {
        if ([key isEqualToString:((UILabel *)obj).nametag]) {
            *stop = YES;

            return YES;
        } else
            return NO;
    }

                       ];

        assert(idx != NSNotFound);

    UILabel  * label = _keyedLabels[idx];
    NSString * text  = nil;

    if ([MSSettingsInactivityTimeoutKey isEqualToString:key]) {
        NSUInteger   idx = [_keyedSliders indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL * stop) {
            if ([key isEqualToString:((UISlider *)obj).nametag]) {
                *stop = YES;

                return YES;
            } else
                return NO;
        }

                           ];

        assert(idx != NSNotFound);

        CGFloat   sliderValue = ((UISlider *)_keyedSliders[idx]).value; // 0-5 minutes
        int       minutes     = (int)sliderValue;
        int       seconds     = (int)(fmodf(sliderValue, 1) * 60.0);

        if (minutes || seconds)
            text = [NSString stringWithFormat:@"%@%@",
                    (minutes ?[NSString stringWithFormat:@"%i min ", minutes] : @""),
                    (seconds ?[NSString stringWithFormat:@"%i sec", seconds] : @"")];
        else
            text = @"never";
    } else {
        DDLogError(@"%@ unrecognized key:'%@'", ClassTagSelectorString, key);

        return;
    }

    assert(text && label);
    label.attributedText = [[NSAttributedString alloc] initWithString:text
                                                           attributes:[label.attributedText
                                        attributesAtIndex:0
                                           effectiveRange:NULL]];
}  /* updateLabelTextForKey */

- (void)updateLabelConstraintForSlider:(UISlider *)slider {
    static const CGFloat   kHalfThumbWidth = 10.0;
    NSLayoutConstraint   * c               = [self.view constraintWithNametag:slider.nametag];

    assert(c);

    CGFloat   valueMagnitude   = slider.maximumValue - slider.minimumValue;
    CGFloat   widthByValue     = slider.bounds.size.width / valueMagnitude;
    CGFloat   zeroOffset       = widthByValue * (valueMagnitude / 2.0f);
    CGFloat   distanceToMiddle = zeroOffset - slider.value * widthByValue;
    CGFloat   percentToMiddle  = distanceToMiddle / zeroOffset;

    c.constant = kHalfThumbWidth * percentToMiddle - distanceToMiddle;
    [self.view layoutIfNeeded];
}

- (IBAction)sliderValueDidChange:(UISlider *)sender {
    [SettingsManager setFloat:sender.value forSetting:sender.nametag];
    [self updateLabelTextForKey:sender.nametag];
    [self updateLabelConstraintForSlider:sender];
}

- (IBAction)doneAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
