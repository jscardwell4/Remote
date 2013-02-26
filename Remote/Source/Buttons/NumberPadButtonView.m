//
// NumberPadResponder.m
// iPhonto
//
// Created by Jason Cardwell on 6/17/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import "NumberPadButtonView.h"
#import "NumberPad.h"
#import "Command.h"
#import "IRCode.h"

#import "GalleryImage.h"
#import "ConnectionManager.h"

static int   ddLogLevel = DefaultDDLogLevel;

#define kDefaultInputViewNibName @"NumberPadInput"

@interface NumberPadButtonView ()

- (void)initializeNumberPadButtonIVARs;
- (void)loadInputView;
- (void)createAndAttachBackdropLayer;
- (void)toggleSelected;

@end

@implementation NumberPadButtonView
@synthesize       autocorrectionType;
@synthesize       autocapitalizationType;
@synthesize       enablesReturnKeyAutomatically;
@synthesize       keyboardType;
@synthesize       keyboardAppearance;
@synthesize       returnKeyType;
@synthesize       secureTextEntry;
@synthesize       numberPad = _numberPad;
@synthesize       dismissOnEnterExit;
@synthesize       delegate;
@synthesize       inputViewNibName = _inputViewNibName;

extern NSString * numberPadButtonKeys[];

/*
 * showNumberPad
 */
- (IBAction)showNumberPad {
    [self becomeFirstResponder];
    if (ValueIsNil(self.delegate)) return;

    if ([self.delegate respondsToSelector:@selector(numberPadButtonDidShowNumberPad:)]) [self.delegate numberPadButtonDidShowNumberPad:self];
}

/*
 * hideNumberPad
 */
- (IBAction)hideNumberPad {
    [self resignFirstResponder];
    if (ValueIsNil(self.delegate)) return;

    if ([self.delegate respondsToSelector:@selector(numberPadButtonDidHideNumberPad:)]) [self.delegate numberPadButtonDidHideNumberPad:self];
}

/*
 * toggleNumberPad
 */
- (IBAction)toggleNumberPad {
    if ([self isFirstResponder]) [self hideNumberPad];
    else [self showNumberPad];

    if (numberPadFlags.toggles) [self toggleSelected];
}

/*
 * toggleSelected
 */
- (void)toggleSelected {
// BOOL   selected;// = !_wrappedUIButton.selected;

// _wrappedUIButton.selected = selected;

// if (numberPadFlags.showsBackdropWhenSelected) _backdropLayer.hidden = !selected;
}

/*
 * inputViewNibName
 */
- (NSString *)inputViewNibName {
    if (ValueIsNotNil(_inputViewNibName)) return _inputViewNibName;

    self.inputViewNibName = kDefaultInputViewNibName;

    return _inputViewNibName;
}

/*
 * initializeNumberPadButtonIVARs
 */
- (void)initializeNumberPadButtonIVARs {
    self.autocorrectionType            = UITextAutocorrectionTypeNo;
    self.autocapitalizationType        = UITextAutocapitalizationTypeNone;
    self.enablesReturnKeyAutomatically = NO;
    self.keyboardType                  = UIKeyboardTypeNumberPad;
    self.keyboardAppearance            = UIKeyboardAppearanceDefault;
    self.returnKeyType                 = UIReturnKeyDefault;
    self.secureTextEntry               = NO;
    self.dismissOnEnterExit            = YES;

// self.styleHighlightedIcon = YES;
    numberPadFlags.toggles                   = YES;
    numberPadFlags.showsBackdropWhenSelected = YES;
    if (numberPadFlags.showsBackdropWhenSelected) [self createAndAttachBackdropLayer];

// [self resetActions];
}

/*
 * createAndAttachBackdropLayer
 */
- (void)createAndAttachBackdropLayer {
    if (ValueIsNotNil(_backdropLayer)) return;

    CGRect   frame = self.layer.bounds;

    frame.size.height             -= 4.0;
    frame.origin.y                += 2.0;
    _backdropLayer                 = [CALayer layer];
    _backdropLayer.frame           = frame;
    _backdropLayer.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.15].CGColor;
    _backdropLayer.cornerRadius    = 2.0;
    [self.layer insertSublayer:_backdropLayer atIndex:0];
    _backdropLayer.hidden = YES;
}

/*
 * addTarget:action:forControlEvents:
 */
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
// [_wrappedUIButton addTarget:self action:@selector(toggleNumberPad)
// forControlEvents:UIControlEventTouchUpInside];
}

/*
 * resetActions
 */
- (void)resetActions {
// [super resetActions];
// [_wrappedUIButton addTarget:self action:@selector(toggleNumberPad)
// forControlEvents:UIControlEventTouchUpInside];
}

/*
 * loadInputView
 */
- (void)loadInputView {
    NSArray * loadedObjects = [[NSBundle mainBundle] loadNibNamed:self.inputViewNibName owner:self options:nil];

    self.inputView = [loadedObjects lastObject];
}

/*
 * initWithButtonInstance:
 */
// - (id)initWithButtonInstance:(NumberPadButtonInstance *)instance {
// self = [super initWithButtonInstance:instance];
// if (self) {
// self.numberPad = instance.numberPad;
// self.inputViewNibName = instance.inputViewNibName;
// }
// return self;
// }

/*
 * initWithFrame:
 */
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)
        //
        [self initializeNumberPadButtonIVARs];


    return self;
}

/*
 * initWithCoder:
 */
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self)
        //
        [self initializeNumberPadButtonIVARs];


    return self;
}

/*
 * awakeFromNib
 */
- (void)awakeFromNib {
    DDLogSelector(@"");
// [super awakeFromNib];
}

/*
 * setInputView:
 */
- (void)setInputView:(UIView *)inputView {
    _inputView = inputView;
}

// - (void)setIconImage:(IconImage *)iconImage {
// [super setIconImage:iconImage];
// }
- (UIView *)inputView {
    if (ValueIsNotNil(_inputView)) return _inputView;

    NSArray * loadedObjects = [[NSBundle mainBundle] loadNibNamed:@"NumberPadInput" owner:self options:nil];

    self.inputView = [loadedObjects lastObject];

    return _inputView;
}

/*
 * deleteBackward
 */
- (void)deleteBackward
{}

/*
 * setButtonCommand:forNumberPadButtonWithTag:
 */
- (void)setButtonCommand:(Command *)command forNumberPadButtonWithTag:(NSUInteger)tag {
    [self.numberPad setCommand:command forTag:tag];
}

/*
 * setButtonCommandFromIRCode:forNumberPadButtonWithTag:
 */
- (void)setButtonCommandFromIRCode:(IRCode *)irCode forNumberPadButtonWithTag:(NSUInteger)tag {
    [self.numberPad setCommandFromIRCode:irCode forTag:tag];
}

/*
 * numberPad
 */
- (NumberPad *)numberPad {
    if (ValueIsNotNil(_numberPad)) return _numberPad;

// if ([(NumberPadButtonInstance *)self.buttonInstance numberPad] != nil)
// self.numberPad = [(NumberPadButtonInstance *)self.buttonInstance numberPad];
// else
// self.numberPad = [NumberPad newNumberPadInContext:AppController.managedObjectContext];

    return _numberPad;
}

/*
 * buttonType
 */
- (ButtonType)buttonType {
    return ButtonTypeNumberPad;
}

/*
 * buttonAction:
 */
- (IBAction)buttonAction:(UIButton *)sender {
    if (ValueIsNil(_numberPad)) return;

    Command * buttonCommand = [_numberPad commandForTag:sender.tag];

    if (ValueIsNil(buttonCommand)) return;

    if ([buttonCommand isMemberOfClass:[SendIRCommand class]]) {
        NSString * commandString = [(SendIRCommand *)buttonCommand commandString];

// [[ConnectionManager sharedConnectionManager] sendIRCommand:commandString];
        [[ConnectionManager sharedConnectionManager] sendCommand:commandString ofType:IRConnectionCommandType toDeviceAtIndex:0];
    }

    if (sender.tag >= 10 && self.dismissOnEnterExit) [self toggleNumberPad];
}

/*
 * willMoveToSuperview:
 */
- (void)willMoveToSuperview:(UIView *)newSuperview {
// if ([newSuperview isMemberOfClass:[ToolbarButtonGroupView class]]) [(ToolbarButtonGroupView *)
// newSuperview setNumberPadButton:self];
}

/*
 * insertText:
 */
- (void)insertText:(NSString *)text
{}

/*
 * hasText
 */
- (BOOL)hasText {
    return NO;
}

/*
 * canBecomeFirstResponder
 */
- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
