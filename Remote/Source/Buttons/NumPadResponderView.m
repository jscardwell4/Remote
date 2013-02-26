//
// NumPadResponderView.m
// iPhonto
//
// Created by Jason Cardwell on 6/8/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import "NumPadResponderView.h"
#import "NumberPad.h"
#import "Command.h"
#import "IRCode.h"

#import "MSRemoteAppController.h"
#import "ConnectionManager.h"

static int   ddLogLevel = DefaultDDLogLevel;

@interface NumPadResponderView ()

- (void)initializeIVARs;

@end

@implementation NumPadResponderView

@synthesize autocorrectionType;
@synthesize autocapitalizationType;
@synthesize enablesReturnKeyAutomatically;
@synthesize keyboardType;
@synthesize keyboardAppearance;
@synthesize returnKeyType;
@synthesize secureTextEntry;
@synthesize numberPad = _numberPad;
@synthesize delegate;

static NSString * numberPadKeys[] = {
    @"digit0",
    @"digit1",
    @"digit2",
    @"digit3",
    @"digit4",
    @"digit5",
    @"digit6",
    @"digit7",
    @"digit8",
    @"digit9",
    @"aux1",
    @"aux2"
};

/*
 * showNumberPad
 */
- (IBAction)showNumberPad {
    [self becomeFirstResponder];
}

/*
 * hideNumberPad
 */
- (IBAction)hideNumberPad {
    [self resignFirstResponder];
}

/*
 * initializeIVARs
 */
- (void)initializeIVARs {
    self.autocorrectionType            = UITextAutocorrectionTypeNo;
    self.autocapitalizationType        = UITextAutocapitalizationTypeNone;
    self.enablesReturnKeyAutomatically = NO;
    self.keyboardType                  = UIKeyboardTypeNumberPad;
    self.keyboardAppearance            = UIKeyboardAppearanceDefault;
    self.returnKeyType                 = UIReturnKeyDefault;
    self.secureTextEntry               = NO;
}

/*
 * initWithFrame:
 */
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)
        // Initialization code
        [self initializeIVARs];


    return self;
}

/*
 * setInputView:
 */
- (void)setInputView:(UIView *)inputView {
    _inputView = inputView;
}

/*
 * inputView
 */
- (UIView *)inputView {
    if (ValueIsNotNil(_inputView)) return _inputView;

    NSArray * loadedObjects = [[NSBundle mainBundle] loadNibNamed:@"NumPadInputView" owner:self options:nil];

    self.inputView = [loadedObjects lastObject];

    return _inputView;
}

/*
 * initWithCoder:
 */
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self)
        // Initilization code
        [self initializeIVARs];


    return self;
}

/*
 * deleteBackward
 */
- (void)deleteBackward
{}

/*
 * buttonAction:
 */
- (IBAction)buttonAction:(UIButton *)sender {
    if (ValueIsNil(_numberPad)) return;

    NSUInteger   tag         = sender.tag;
    NSURL      * selectedURL = [self.numberPad valueForKey:numberPadKeys[tag]];

    DDLogVerbose(@"selectedURL = %@", selectedURL);

    Command * buttonCommand = [_numberPad commandForTag:tag];

    DDLogVerbose(@"buttonCommand = %@", buttonCommand);
// IRCode * irCode = [buttonCommand valueForKey:@"code"];

// if (ValueIsNotNil(buttonCommand)) {
// if ([buttonCommand isMemberOfClass:[SendIRCommand class]]) {
// NSString *commandString = [NSString stringWithFormat:@"sendir,1:%i,%@",
// [[buttonCommand valueForKey:@"port"] integerValue],
// irCode.value];
//
// [[ConnectionManager sharedConnectionManager] sendIRCommand:commandString];
////            DDLogVerbose(@"fake send command %@", commandString);
// }
// }

    if (ValueIsNotNil(delegate)) [delegate numPad:self buttonActionForButtonWithTag:tag];
}

/*
 * insertText:
 */
- (void)insertText:(NSString *)text {
    DDLogVerbose(@"insertText:%@", text);
}

/*
 * hasText
 */
- (BOOL)hasText {
    return NO;
}

/*
 * // Only override drawRect: if you perform custom drawing.
 * // An empty implementation adversely affects performance during animation.
 * - (void)drawRect:(CGRect)rect
 * {
 *  // Drawing code
 * }
 */

- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
