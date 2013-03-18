//
// DelayCommandEditingViewController.m
// Remote
//
// Created by Jason Cardwell on 4/5/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "DelayCommandEditingViewController.h"

@interface DelayCommandEditingViewController ()
@property (strong, nonatomic) IBOutlet UITextField * durationTextField;

@end

@implementation DelayCommandEditingViewController
@synthesize durationTextField, command = _command;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.durationTextField.text = [NSString stringWithFormat:@"%.2f", self.command.duration];

    CGRect     rightOverlayFrame = CGRectMake(0, 0, 24, 24);
    NSString * overlayText       = @"=";
    UIFont   * overlayFont       = [UIFont fontWithName:@"iconSweets" size:14.0];
    UIColor  * overlayColor      = [UIColor greenColor];
    UIButton * rightOverlayView  = [[UIButton alloc] initWithFrame:rightOverlayFrame];

    [rightOverlayView setTitle:overlayText forState:UIControlStateNormal];
    rightOverlayView.titleLabel.font = overlayFont;
    [rightOverlayView setTitleColor:overlayColor forState:UIControlStateNormal];
    [rightOverlayView addTarget:self.durationTextField
                         action:@selector(resignFirstResponder)
               forControlEvents:UIControlEventTouchUpInside];
    self.durationTextField.rightView    = rightOverlayView;
    self.durationTextField.keyboardType = UIKeyboardTypeDecimalPad;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self setDurationTextField:nil];
    if ([self isViewLoaded] && self.view.window == nil) self.view = nil;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.rightViewMode = UITextFieldViewModeAlways;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.rightViewMode = UITextFieldViewModeNever;
    self.command.duration   = [textField.text floatValue];
    textField.text          = [NSString stringWithFormat:@"%.2f", self.command.duration];
}

@end
