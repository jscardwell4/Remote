//
// ViewDecorator.m
// Remote
//
// Created by Jason Cardwell on 4/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "ViewDecorator.h"

#define DefaultShadowOffset (CGSize) {.width = 1, .height = 1}

// Colors and Fonts
static UIColor * babyBlue;
static UIFont  * defaultBoldFont;
static UIFont  * fontAwesomeFont;

// Button Specific
static CGFloat   defaultButtonFontSize = 14.0;
static UIColor * buttonTitleColorNormal;
static UIColor * buttonTitleColorHighlighted;
static UIColor * buttonTitleColorDisabled;
static UIColor * buttonTitleColorSelected;
static UIColor * buttonTitleShadowColorNormal;
static UIColor * buttonTitleShadowColorHighlighted;
static UIColor * buttonTitleShadowColorDisabled;
static UIColor * buttonTitleShadowColorSelected;
static CGSize    buttonLabelShadowOffset   = DefaultShadowOffset;
static CGRect    defaultBarButtonItemFrame = (CGRect) {{0, 0}, {55, 18}};

// Label Specific
static UIColor * labelTextColor;
static UIColor * labelShadowColor;
static CGSize    labelShadowOffset = DefaultShadowOffset;

@implementation ViewDecorator

+ (void)initialize {
    if (self == [ViewDecorator class] && [UIApplication sharedApplication]) {
        babyBlue        = [UIColor colorWithRed:0 green:175 / 255.0 blue:1 alpha:1];
        defaultBoldFont = [UIFont boldSystemFontOfSize:defaultButtonFontSize];
        fontAwesomeFont = [UIFont fontAwesomeFontWithSize:32.0f];
//        assert(fontAwesomeFont);

        buttonTitleColorNormal      = babyBlue;
        buttonTitleColorHighlighted = WhiteColor;
        buttonTitleColorDisabled    = [buttonTitleColorNormal colorWithAlphaComponent:0.5];
        buttonTitleColorSelected    = buttonTitleColorHighlighted;

        buttonTitleShadowColorNormal      = ClearColor;
        buttonTitleShadowColorHighlighted = buttonTitleColorNormal;
        buttonTitleShadowColorDisabled    = ClearColor;
        buttonTitleShadowColorSelected    = buttonTitleShadowColorHighlighted;

        labelTextColor   = [WhiteColor colorWithAlphaComponent:0.5];
        labelShadowColor = [DarkTextColor colorWithAlphaComponent:0.5];
    }
}

+ (void)decorateButton:(id)button {
    [self decorateButton:button excludedStates:0];
}

+ (void)decorateButton:(id)button excludedStates:(UIControlState)states {
    if ([button respondsToSelector:@selector(setTitleColor:forState:)]) {
        [button setTitleColor:buttonTitleColorNormal forState:UIControlStateNormal];

        if (!(states & UIControlStateHighlighted)) [button setTitleColor:buttonTitleColorHighlighted forState:UIControlStateHighlighted];

        if (!(states & UIControlStateSelected)) [button setTitleColor:buttonTitleColorSelected forState:UIControlStateSelected];

        if (!(states & UIControlStateDisabled)) [button setTitleColor:buttonTitleColorDisabled forState:UIControlStateDisabled];
    }

    if ([button respondsToSelector:@selector(setTitleShadowColor:forState:)]) {
        [button setTitleShadowColor:buttonTitleShadowColorNormal forState:UIControlStateNormal];

        if (!(states & UIControlStateHighlighted))
            [button setTitleShadowColor:buttonTitleShadowColorHighlighted
                               forState:UIControlStateHighlighted];

        if (!(states & UIControlStateSelected)) [button setTitleShadowColor:buttonTitleShadowColorSelected forState:UIControlStateSelected];

        if (!(states & UIControlStateDisabled)) [button setTitleShadowColor:buttonTitleShadowColorDisabled forState:UIControlStateDisabled];
    }

    if ([button respondsToSelector:@selector(titleLabel)]) {
        [button titleLabel].font         = defaultBoldFont;
        [button titleLabel].shadowOffset = buttonLabelShadowOffset;
    }
}

+ (void)decorateLabel:(UILabel *)label {
    if (!label) return;

    label.textColor    = labelTextColor;
    label.shadowColor  = labelShadowColor;
    label.shadowOffset = labelShadowOffset;
    label.font         = defaultBoldFont;
}

+ (NSAttributedString *)fontAwesomeTitleWithName:(NSString *)name size:(CGFloat)size {
    return [[NSAttributedString alloc] initWithString:[UIFont fontAwesomeIconForName:name]
                                           attributes:@{
                NSFontAttributeName             : [UIFont fontAwesomeFontWithSize:size],
                NSForegroundColorAttributeName  : WhiteColor,
                NSStrokeColorAttributeName      : [WhiteColor colorWithAlphaComponent:0.5f]
            }
    ];

}

+ (MSBarButtonItem *)fontAwesomeBarButtonItemWithName:(NSString *)name
                                               target:(id)target
                                             selector:(SEL)selector
{

    MSBarButtonItem * item = [[MSBarButtonItem alloc]
                              initWithTitle:[UIFont fontAwesomeIconForName:name]
                                      style:UIBarButtonItemStylePlain
                                     target:target
                                     action:selector];
    [item setTitleTextAttributes:@{UITextAttributeFont      : [UIFont fontAwesomeFontWithSize:32.0f],
                                   UITextAttributeTextColor : WhiteColor}
                        forState:UIControlStateNormal];
    [item setTitleTextAttributes:@{UITextAttributeFont      : [UIFont fontAwesomeFontWithSize:32.0f],
                                   UITextAttributeTextColor : LightTextColor}
                        forState:UIControlStateHighlighted];

    return item;
}

+ (UIBarButtonItem *)pickerInputCancelBarButtonItem {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];

    button.frame = defaultBarButtonItemFrame;
    [button setTitleColor:buttonTitleColorNormal forState:UIControlStateNormal];
    [button setTitleColor:buttonTitleColorHighlighted forState:UIControlStateHighlighted];
    [button setTitle:@"Cancel" forState:UIControlStateNormal];
    [button setTitleShadowColor:buttonTitleShadowColorNormal forState:UIControlStateNormal];
    [button setTitleShadowColor:buttonTitleShadowColorHighlighted
                       forState:UIControlStateHighlighted];
    button.titleLabel.font         = defaultBoldFont;
    button.titleLabel.shadowOffset = buttonLabelShadowOffset;

    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

+ (UIBarButtonItem *)pickerInputSelectBarButtonItem {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];

    button.frame = defaultBarButtonItemFrame;
    [button setTitleColor:buttonTitleColorNormal forState:UIControlStateNormal];
    [button setTitleColor:buttonTitleColorHighlighted forState:UIControlStateHighlighted];
    [button setTitle:@"Select" forState:UIControlStateNormal];
    [button setTitleShadowColor:buttonTitleShadowColorNormal forState:UIControlStateNormal];
    [button setTitleShadowColor:buttonTitleShadowColorHighlighted
                       forState:UIControlStateHighlighted];
    button.titleLabel.font         = defaultBoldFont;
    button.titleLabel.shadowOffset = buttonLabelShadowOffset;

    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

@end
