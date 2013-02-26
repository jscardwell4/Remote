//
// NumberPadResponder.h
// iPhonto
//
// Created by Jason Cardwell on 6/17/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//
#import "ButtonView.h"

@class   NumberPad, Command, IRCode, NumberPadButtonView;

@protocol NumberPadButtonDelegate <NSObject>

@optional
- (void)numberPadButtonDidShowNumberPad:(NumberPadButtonView *)numberPadButton;
- (void)numberPadButtonDidHideNumberPad:(NumberPadButtonView *)numberPadButton;

@end

@interface NumberPadButtonView : ButtonView <UITextInputTraits, UIKeyInput> {
    UIView    * _inputView;
    NSString  * _inputViewNibName;
    NumberPad * _numberPad;
    CALayer   * _backdropLayer;

    struct {
        BOOL   toggles;
        BOOL   showsBackdropWhenSelected;
    }
    numberPadFlags;
}

- (IBAction)showNumberPad;
- (IBAction)hideNumberPad;
- (IBAction)toggleNumberPad;
- (IBAction)buttonAction:(UIButton *)sender;
- (void)setButtonCommand:(Command *)command forNumberPadButtonWithTag:(NSUInteger)tag;
- (void)setButtonCommandFromIRCode:(IRCode *)irCode forNumberPadButtonWithTag:(NSUInteger)tag;

@property (readwrite, strong) UIView                                  * inputView;
@property (nonatomic) UITextAutocapitalizationType                      autocapitalizationType;
@property (nonatomic) UITextAutocorrectionType                          autocorrectionType;
@property (nonatomic) BOOL                                              enablesReturnKeyAutomatically;
@property (nonatomic) UIKeyboardAppearance                              keyboardAppearance;
@property (nonatomic) UIKeyboardType                                    keyboardType;
@property (nonatomic) UIReturnKeyType                                   returnKeyType;
@property (nonatomic, getter = isSecureTextEntry) BOOL                  secureTextEntry;
@property (nonatomic, strong) NumberPad                               * numberPad;
@property (nonatomic, assign) BOOL                                      dismissOnEnterExit;
@property (nonatomic, unsafe_unretained) id <NumberPadButtonDelegate>   delegate;
@property (nonatomic, copy) NSString                                  * inputViewNibName;

@end
