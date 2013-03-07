//
// IRCodeDetailViewController.m
// iPhonto
//
// Created by Jason Cardwell on 5/23/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import "IRCodeDetailViewController.h"
#import "ComponentDevice.h"
#import "IRCode.h"
#import "ConnectionManager.h"
#import "CoreDataManager.h"

static int                ddLogLevel   = LOG_LEVEL_DEBUG;
MSKIT_STATIC_STRING_CONST   kTestSuccess = @"=";
MSKIT_STATIC_STRING_CONST   kTestFailure = @"X";

@interface IRCodeDetailViewController ()

@property (nonatomic, assign) NSUInteger               deviceIndex;
@property (nonatomic, assign) NSUInteger               commandIndex;
@property (nonatomic, assign) NSUInteger               testPort;
@property (nonatomic, strong) NSManagedObjectContext * testContext;
@property (nonatomic, strong) SendIRCommand          * testCommand;

- (IBAction)stepperValueChanged:(UIStepper *)sender;
- (IBAction)executeTestCommand:(id)sender;
- (IBAction)selectCurrentCommand:(id)sender;

@end

@implementation IRCodeDetailViewController
@synthesize deviceIndex, commandIndex, testPort, testCommand, testContext;

- (void)awakeFromNib {
    [super awakeFromNib];
    self.testContext = [DataManager childContext];
    self.testCommand = [NSEntityDescription insertNewObjectForEntityForName:@"SendIRCommand"
                                                     inManagedObjectContext:testContext];
    if (ValueIsNil(testCommand)) DDLogWarn(@"failed to create test command object");
    else DDLogDebug(@"test command created");
}

- (IBAction)selectCurrentCommand:(id)sender
{}

- (IBAction)stepperValueChanged:(UIStepper *)sender {
    if (sender == portStepper)
        self.testPort = sender.value;
    else if (sender == repeatStepper) {
        repeatLabel.text      = [NSString stringWithFormat:@"%.f", sender.value];
        self.code.repeatCount = sender.value;
    }
}

- (void)checkboxValueDidChange:(MSCheckboxView *)checkbox checked:(BOOL)checked {
    if (checkbox == setsDeviceInputCheckbox) self.code.setsDeviceInput = checked;
}

- (void)viewWillAppear:(BOOL)animated {
    if (ValueIsNil(self.code)) return;

    codeNameLabel.text      = self.code.name;
    frequencyTextField.text = [NSString stringWithFormat:@"%lli", self.code.frequency];
    repeatLabel.text        = [NSString stringWithFormat:@"%i", self.code.repeatCount];
    offsetTextField.text    = [NSString stringWithFormat:@"%i", self.code.offset];

    NSString * onOffText = self.code.onOffPattern;

    if (ValueIsNil(onOffText)) onOffText = [self.code globalCacheFromProntoHex];

    onOffPatternTextView.text       = onOffText;
    setsDeviceInputCheckbox.checked = self.code.setsDeviceInput;

    NSInteger   port = self.testCommand.port;

    if (port <= 0) {
        port                          = 1;
        self.testCommand.portOverride = port;
    }

    self.testPort = port;
}

- (IRCode *)code {
    return self.testCommand.code;
}

- (void)setCode:(IRCode *)code {
    if (ValueIsNil(code)) return;

    IRCode * testCode = (IRCode *)[testContext objectWithID:code.objectID];

    self.testCommand.code = testCode;

    DDLogDebug(@"testCommand value changed:%@", [testCommand debugDescription]);
}

- (IBAction)executeTestCommand:(id)sender {
    [self.testCommand execute:self];
}

- (void)commandDidComplete:(Command *)command success:(BOOL)success {
    testCommandResultView.checkmarkText  = success ? kTestSuccess : kTestFailure;
    testCommandResultView.checkmarkColor = success ?[UIColor greenColor] :[UIColor redColor];
}

- (void)setTestPort:(NSUInteger)newPort {
    testPort                      = newPort;
    portLabel.text                = [NSString stringWithFormat:@"%u", testPort];
    portStepper.value             = testPort;
    self.testCommand.portOverride = testPort;
}

@end
