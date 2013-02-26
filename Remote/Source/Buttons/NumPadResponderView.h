//
// NumPadResponderView.h
// iPhonto
//
// Created by Jason Cardwell on 6/8/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class   NumberPad, NumPadResponderView;

@protocol NumberPadDelegate <NSObject>

@required
- (void)numPad:(NumPadResponderView *)numPad buttonActionForButtonWithTag:(NSInteger)tag;

@end

@interface NumPadResponderView : UIView <UITextInputTraits, UIKeyInput> {
    UIView    * _inputView;
    NumberPad * _numberPad;
}

- (IBAction)showNumberPad;
- (IBAction)hideNumberPad;
- (IBAction)buttonAction:(UIButton *)sender;

@property (readwrite, strong) UIView                            * inputView;
@property (nonatomic) UITextAutocapitalizationType                autocapitalizationType;
@property (nonatomic) UITextAutocorrectionType                    autocorrectionType;
@property (nonatomic) BOOL                                        enablesReturnKeyAutomatically;
@property (nonatomic) UIKeyboardAppearance                        keyboardAppearance;
@property (nonatomic) UIKeyboardType                              keyboardType;
@property (nonatomic) UIReturnKeyType                             returnKeyType;
@property (nonatomic, getter = isSecureTextEntry) BOOL            secureTextEntry;
@property (nonatomic, strong) NumberPad                         * numberPad;
@property (nonatomic, unsafe_unretained) id <NumberPadDelegate>   delegate;

@end
