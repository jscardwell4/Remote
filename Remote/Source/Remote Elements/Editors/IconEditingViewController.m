//
// IconEditingViewController.m
// Remote
//
// Created by Jason Cardwell on 3/30/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "AttributeEditingViewController_Private.h"
#import "IconEditingViewController.h"
#import "RemoteElementEditingViewController.h"
#import "ControlStateSet.h"
#import "ControlStateImageSet.h"
#import "ControlStateTitleSet.h"
#import "ControlStateColorSet.h"
#import "Image.h"
#import <QuartzCore/QuartzCore.h>
#import "RemoteElementView.h"
#import "Button.h"
#import "StoryboardProxy.h"
#import "ImageView.h"

static int ddLogLevel = LOG_LEVEL_WARN;
static const int msLogContext = 0;
#pragma unused(ddLogLevel, msLogContext)

@interface IconEditingViewController ()
@property (strong, nonatomic) IBOutlet UIButton    * iconColorButton;
@property (strong, nonatomic) IBOutlet UITextField * topInsetTextField;
@property (strong, nonatomic) IBOutlet UITextField * leftInsetTextField;
@property (strong, nonatomic) IBOutlet UITextField * rightInsetTextField;
@property (strong, nonatomic) IBOutlet UITextField * bottomInsetTextField;
@property (strong, nonatomic) IBOutlet UIButton    * iconNameButton;
@property (strong, nonatomic) IBOutlet MSView      * insetContainer;
@property (strong, nonatomic) IBOutlet UIView      * contentContainer;
@property (strong, nonatomic) NSValue              * initialEdgeInsets;
@property (strong, nonatomic) UIColor              * initialColor;
@property (strong, nonatomic) Image     * initialIconImage;
@property (strong, nonatomic) NSValue              * currentEdgeInsets;
@property (strong, nonatomic) UIColor              * currentColor;
@property (strong, nonatomic) Image     * currentIconImage;
@property (weak, nonatomic) ButtonView             * buttonView;
@property (nonatomic, assign) UIControlState         controlState;
@property (strong, nonatomic) IBOutlet UIButton    * removeIconButton;

- (IBAction)launchColorSection:(id)sender;
- (IBAction)launchIconSelection:(id)sender;
- (IBAction)removeIconAction:(UIButton *)sender;

@end

@implementation IconEditingViewController
@synthesize contentContainer = _contentContainer;
@synthesize removeIconButton = _removeIconButton;
@synthesize
insetContainer       = _insetContainer,
iconNameButton       = _iconNameButton,
detailedButtonEditor = _detailedButtonEditor,
button               = _button,
buttonView           = _buttonView,
iconColorButton      = _iconColorButton,
topInsetTextField    = _topInsetTextField,
leftInsetTextField   = _leftInsetTextField,
rightInsetTextField  = _rightInsetTextField,
bottomInsetTextField = _bottomInsetTextField,
initialEdgeInsets    = _initialEdgeInsets,
currentEdgeInsets    = _currentEdgeInsets,
initialColor         = _initialColor,
currentColor         = _currentColor,
initialIconImage     = _initialIconImage,
currentIconImage     = _currentIconImage,
controlState         = _controlState,
delegate             = _delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // Resize view to fit appropriately
    self.view.frame = self.contentContainer.bounds;

    // Add border to the color button
    _iconColorButton.layer.borderWidth = 1.0;
    _iconColorButton.layer.borderColor = [[UIColor blackColor] CGColor];

    // Add right overlay views to text fields
    CGRect     rightOverlayFrame = CGRectMake(0, 0, 24, 24);
    NSString * overlayText       = @"=";
    UIFont   * overlayFont       = [UIFont fontWithName:@"iconSweets" size:14.0];
    UIColor  * overlayColor      = [UIColor greenColor];
    UIButton * rightOverlayView  = [[UIButton alloc] initWithFrame:rightOverlayFrame];

    [rightOverlayView setTitle:overlayText forState:UIControlStateNormal];
    rightOverlayView.titleLabel.font = overlayFont;
    [rightOverlayView setTitleColor:overlayColor forState:UIControlStateNormal];
    [rightOverlayView addTarget:_leftInsetTextField
                         action:@selector(resignFirstResponder)
               forControlEvents:UIControlEventTouchUpInside];
    _leftInsetTextField.rightView    = rightOverlayView;
    _leftInsetTextField.keyboardType = UIKeyboardTypeDecimalPad;

    rightOverlayView = [[UIButton alloc] initWithFrame:rightOverlayFrame];
    [rightOverlayView setTitle:overlayText forState:UIControlStateNormal];
    rightOverlayView.titleLabel.font = overlayFont;
    [rightOverlayView setTitleColor:overlayColor forState:UIControlStateNormal];
    [rightOverlayView addTarget:_topInsetTextField
                         action:@selector(resignFirstResponder)
               forControlEvents:UIControlEventTouchUpInside];
    _topInsetTextField.rightView    = rightOverlayView;
    _topInsetTextField.keyboardType = UIKeyboardTypeDecimalPad;

    rightOverlayView = [[UIButton alloc] initWithFrame:rightOverlayFrame];
    [rightOverlayView setTitle:overlayText forState:UIControlStateNormal];
    rightOverlayView.titleLabel.font = overlayFont;
    [rightOverlayView setTitleColor:overlayColor forState:UIControlStateNormal];
    [rightOverlayView addTarget:_bottomInsetTextField
                         action:@selector(resignFirstResponder)
               forControlEvents:UIControlEventTouchUpInside];
    _bottomInsetTextField.rightView    = rightOverlayView;
    _bottomInsetTextField.keyboardType = UIKeyboardTypeDecimalPad;

    rightOverlayView = [[UIButton alloc] initWithFrame:rightOverlayFrame];
    [rightOverlayView setTitle:overlayText forState:UIControlStateNormal];
    rightOverlayView.titleLabel.font = overlayFont;
    [rightOverlayView setTitleColor:overlayColor forState:UIControlStateNormal];
    [rightOverlayView addTarget:_rightInsetTextField
                         action:@selector(resignFirstResponder)
               forControlEvents:UIControlEventTouchUpInside];
    _rightInsetTextField.rightView    = rightOverlayView;
    _rightInsetTextField.keyboardType = UIKeyboardTypeDecimalPad;

    [self restoreCurrentValues];
}  /* viewDidLoad */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self setIconColorButton:nil];
    [self setTopInsetTextField:nil];
    [self setLeftInsetTextField:nil];
    [self setRightInsetTextField:nil];
    [self setBottomInsetTextField:nil];
    [self setIconNameButton:nil];
    [self setInsetContainer:nil];
    [self setRemoveIconButton:nil];
    [self setContentContainer:nil];
    if ([self isViewLoaded] && self.view.window == nil) self.view = nil;
}

#pragma mark - Methods for managing initial/selected values
- (void)setInitialValuesFromDictionary:(NSDictionary *)initialValues {
    [super setInitialValuesFromDictionary:initialValues];
    self.initialIconImage  = NilSafe(initialValues[kAttributeEditingImageKey]);
    self.initialEdgeInsets = NilSafe(initialValues[kAttributeEditingEdgeInsetsKey]);
    self.initialColor      = NilSafe(initialValues[kAttributeEditingColorKey]);
    self.button            = initialValues[kAttributeEditingButtonKey];
    self.controlState      = [initialValues[kAttributeEditingControlStateKey] unsignedIntegerValue];
    [self syncCurrentValuesWithIntialValues];
}

- (void)syncCurrentValuesWithIntialValues {
    self.currentIconImage  = _initialIconImage;
    self.currentEdgeInsets = _initialEdgeInsets;
    self.currentColor      = _initialColor;
}

- (void)storeCurrentValues {
    // icon image?
    self.currentEdgeInsets = [NSValue valueWithUIEdgeInsets:
                              UIEdgeInsetsMake([_topInsetTextField.text floatValue],
                                               [_leftInsetTextField.text floatValue],
                                               [_bottomInsetTextField.text floatValue],
                                               [_rightInsetTextField.text floatValue])];
    self.currentColor = _iconColorButton.backgroundColor;
}

- (void)restoreCurrentValues {
    if (_currentIconImage) {
        [_iconNameButton setTitle:_currentIconImage.name forState:UIControlStateNormal];
        _button.icons[_controlState] = _currentIconImage;
        _removeIconButton.hidden = NO;
    } else {
        [_iconNameButton setTitle:@"Select Icon"  forState:UIControlStateNormal];
        _button.icons[_controlState] = nil;
        _removeIconButton.hidden = YES;
    }

    if (_currentEdgeInsets) {
        UIEdgeInsets   insets = [_currentEdgeInsets UIEdgeInsetsValue];

        _topInsetTextField.text    = [NSString stringWithFormat:@"%.1f", insets.top];
        _leftInsetTextField.text   = [NSString stringWithFormat:@"%.1f", insets.left];
        _bottomInsetTextField.text = [NSString stringWithFormat:@"%.1f", insets.bottom];
        _rightInsetTextField.text  = [NSString stringWithFormat:@"%.1f", insets.right];
        _button.imageEdgeInsets    = insets;
    }

    if (_currentColor) {
        _iconColorButton.backgroundColor = _currentColor;
        _button.icons[_controlState].color = _currentColor;
    }
}

#pragma mark - Actions

- (IBAction)launchColorSection:(id)sender {
    if (ValueIsNil(_detailedButtonEditor)) return;

    ColorSelectionViewController * colorSelector = [StoryboardProxy colorSelectionViewController];

    colorSelector.delegate     = self;
    colorSelector.initialColor = _iconColorButton.backgroundColor;

    [self storeCurrentValues];

    [_detailedButtonEditor addAuxController:colorSelector animated:YES];
}

- (IBAction)launchIconSelection:(id)sender {
    if (ValueIsNil(_detailedButtonEditor)) return;

    IconSelectionViewController * iconSelector = [StoryboardProxy iconSelectionViewController];

    iconSelector.delegate = self;
    iconSelector.context  = _button.managedObjectContext;

    [self storeCurrentValues];

    [_detailedButtonEditor addAuxController:iconSelector animated:YES];
}

- (IBAction)removeIconAction:(UIButton *)sender {
    self.currentIconImage = nil;
    [self restoreCurrentValues];
}

- (void)resetToInitialState {
    [self syncCurrentValuesWithIntialValues];
    [self restoreCurrentValues];
}

#pragma mark - UITextFieldDelegate methods

/*
 * - (BOOL)              textField:(UITextField *)textField
 * shouldChangeCharactersInRange:(NSRange)range
 *                        replacementString:(NSString *)string
 * {
 *      return YES;
 * }
 *
 */
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.rightViewMode = UITextFieldViewModeAlways;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.rightViewMode = UITextFieldViewModeNever;

    UIEdgeInsets   insets = [_currentEdgeInsets UIEdgeInsetsValue];

    if (textField == _leftInsetTextField) insets.left = [textField.text floatValue];
    else if (textField == _topInsetTextField) insets.top = [textField.text floatValue];
    else if (textField == _rightInsetTextField) insets.right = [textField.text floatValue];
    else if (textField == _bottomInsetTextField) insets.bottom = [textField.text floatValue];

    _currentEdgeInsets = [NSValue valueWithUIEdgeInsets:insets];
    [self restoreCurrentValues];
}

/*
 * - (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
 *      return YES;
 * }
 *
 * - (BOOL)textFieldShouldClear:(UITextField *)textField {
 *      return YES;
 * }
 *
 * - (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
 *      return YES;
 * }
 *
 * - (BOOL)textFieldShouldReturn:(UITextField *)textField {
 *      return YES;
 * }
 *
 */

#pragma mark - IconSelectionDelegate

- (void)iconSelectorDidCancel:(IconSelectionViewController *)controller {
    if (ValueIsNotNil(_detailedButtonEditor)) [_detailedButtonEditor removeAuxController:controller animated:YES];
}

- (void)iconSelector:(IconSelectionViewController *)controller didSelectIcon:(Image *)icon {
    MSLogDebug(@"%@\n\ticon selected:%@", ClassTagString, icon);
    self.currentIconImage = icon;
    [self restoreCurrentValues];

    if (ValueIsNotNil(_detailedButtonEditor)) [_detailedButtonEditor removeAuxController:controller animated:YES];
}

#pragma mark - ColorSelectionViewControllerDelegate

- (void)colorSelector:(ColorSelectionViewController *)controller
       didSelectColor:(UIColor *)color {
    self.currentColor = color;
    [self restoreCurrentValues];

    if (ValueIsNotNil(_detailedButtonEditor)) [_detailedButtonEditor removeAuxController:controller animated:YES];
}

- (void)colorSelectorDidCancel:(ColorSelectionViewController *)controller {
    if (ValueIsNotNil(_detailedButtonEditor)) [_detailedButtonEditor removeAuxController:controller animated:YES];
}

@end
