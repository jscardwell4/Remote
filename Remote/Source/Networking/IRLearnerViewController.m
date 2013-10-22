//
// IRLearnerViewController.m
// iPhonto
//
// Created by Jason Cardwell on 5/6/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import "IRLearnerViewController.h"

static int ddLogLevel = DefaultDDLogLevel;

@interface IRLearnerViewController (Private)

- (void)validateTextFields;

@end

@implementation IRLearnerViewController
@synthesize saveCommandDialog        = _saveCommandDialog;
@synthesize saveCommandButton        = _saveCommandButton;
@synthesize confirmSaveCommandButton = _confirmSaveCommandButton;
@synthesize learnerSwitch            = _learnerSwitch;
@synthesize capturedCommandTextView  = _capturedCommandTextView;
@synthesize appDelegate              = _appDelegate;
@synthesize deviceNameTextField      = _deviceNameTextField;
@synthesize commandNameTextField     = _commandNameTextField;

/*
 * initWithNibName:bundle:
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }

    return self;
}

/*
 * appDelegate
 */
- (IPhontoAppController *)appDelegate {
    if (ValueIsNil(_appDelegate)) _appDelegate = (IPhontoAppController *)[UIApplication sharedApplication].delegate;

    return _appDelegate;
}

/*
 * saveCapturedCommand:
 */
- (IBAction)saveCapturedCommand:(id)sender {
    self.saveCommandDialog.hidden = NO;
}

/*
 * cancelSaveCapturedCommand:
 */
- (IBAction)cancelSaveCapturedCommand:(id)sender {
    self.saveCommandDialog.hidden  = YES;
    self.deviceNameTextField.text  = @"";
    self.commandNameTextField.text = @"";
}

/*
 * confirmSaveCapturedCommand:
 */
- (IBAction)confirmSaveCapturedCommand:(id)sender {
    self.saveCommandDialog.hidden = YES;

    NSString * deviceKey = _deviceNameTextField.text;

    if ([@"" isEqualToString : deviceKey]) return;

    NSString * commandKey = _commandNameTextField.text;

    if ([@"" isEqualToString : commandKey]) return;

    NSString * commandValue = _capturedCommandTextView.text;

    if ([@"" isEqualToString : commandValue]) return;

// #warning Need to re-implement learned IR code persistence
}

/*
 * validateTextFields
 */
- (void)validateTextFields {
    _confirmSaveCommandButton.enabled = ![@"" isEqualToString : _deviceNameTextField.text] && ![@"" isEqualToString : _commandNameTextField.text];
}

#pragma mark -
#pragma mark Text field and text view delegate methods

/*
 * textFieldDidBeginEditing:
 */
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self validateTextFields];
}

/*
 * textFieldDidEndEditing:
 */
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self validateTextFields];
}

/*
 * textFieldShouldReturn:
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];

    return YES;
}

#pragma mark - View lifecycle

/*
 * viewDidLoad
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self setLearnerSwitch:nil];
    [self setCapturedCommandTextView:nil];
    [self setSaveCommandDialog:nil];
    [self setDeviceNameTextField:nil];
    [self setCommandNameTextField:nil];
    [self setSaveCommandButton:nil];
    [self setConfirmSaveCommandButton:nil];
    if ([self isViewLoaded] && self.view.window == nil) self.view = nil;
}

/*
 * viewWillAppear:
 */
- (void)viewWillAppear:(BOOL)animated {
// _learnerSwitch.on = self.appDelegate.learnerEnabled;
}

/*
 * commandWithTag:didCompleteWithStatus:
 */
- (void)commandWithTag:(NSUInteger)tag didCompleteWithStatus:(BOOL)success
{}

/*
 * toggleLearner:
 */
- (IBAction)toggleLearner:(id)sender {
//    NSString * command = _learnerSwitch.on ? @"get_IRL\r" : @"stop_IRL\r";

// [[ConnectionManager sharedConnectionManager] sendIRCommand:command];
//    [[ConnectionManager sharedConnectionManager] sendCommand:command ofType:IRCMConnectionCommandType toDevice:0 sender:self];
}

/*
 * learnerStateDidChange:
 */
- (void)learnerStateDidChange:(BOOL)enabled {
    DDLogVerbose(@"learnerStateDidChange:%@", enabled ? @"YES" : @"NO");
    _learnerSwitch.on = enabled;
}

/*
 * receivedCapturedCommand:
 */
- (void)receivedCapturedCommand:(NSString *)command {
    DDLogVerbose(@"receivedCapturedCommand:%@", command);
    _capturedCommandTextView.text = command;
    _saveCommandButton.enabled    = ![@"" isEqualToString : _capturedCommandTextView.text];
}

@end
