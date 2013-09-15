//
// LabelEditingViewController.m
// Remote
//
// Created by Jason Cardwell on 3/29/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "LabelEditingViewController.h"
#import "AttributeEditingViewController_Private.h"
#import "RemoteElementEditingViewController.h"
#import "ControlStateSet.h"
#import "RemoteElementView.h"

#import "StoryboardProxy.h"

MSKIT_STATIC_STRING_CONST   kEmptyLabelText = @"Add Label";
static int                ddLogLevel      = LOG_LEVEL_DEBUG;
static NSArray const    * fontNames;

@interface LabelEditingViewController ()
@property (strong, nonatomic) IBOutlet UITextView   * titleTextView;
@property (strong, nonatomic) IBOutlet UIButton     * fontNameButton;
@property (strong, nonatomic) IBOutlet UILabel      * fontSizeLabel;
@property (strong, nonatomic) IBOutlet UISlider     * fontSizeSlider;
@property (strong, nonatomic) IBOutlet UITextField  * topInsetTextField;
@property (strong, nonatomic) IBOutlet UITextField  * leftInsetTextField;
@property (strong, nonatomic) IBOutlet UITextField  * rightInsetTextField;
@property (strong, nonatomic) IBOutlet UITextField  * bottomInsetTextField;
@property (strong, nonatomic) IBOutlet UIPickerView * fontNamePicker;
@property (strong, nonatomic) IBOutlet UIButton     * titleColorButton;
@property (strong, nonatomic) IBOutlet MSView       * insetContainer;
@property (strong, nonatomic) IBOutlet UIButton     * doneEditingTitleButton;
@property (strong, nonatomic) IBOutlet UIView       * contentContainer;

@property (copy, nonatomic) NSString   * initialFontName;
@property (strong, nonatomic) NSValue  * initialEdgeInsets;
@property (strong, nonatomic) NSNumber * initialFontSize;
@property (copy, nonatomic) NSString   * initialTitleText;
@property (strong, nonatomic) UIColor  * initialColor;

@property (copy, nonatomic) NSString         * currentFontName;
@property (strong, nonatomic) NSValue        * currentEdgeInsets;
@property (strong, nonatomic) NSNumber       * currentFontSize;
@property (copy, nonatomic) NSString         * currentTitleText;
@property (strong, nonatomic) UIColor        * currentColor;
@property (weak, nonatomic) ButtonView       * buttonView;
@property (nonatomic, assign) UIControlState   controlState;

- (IBAction)sliderValueChanged:(UISlider *)sender;
- (IBAction)togglePicker:(id)sender;
- (IBAction)launchColorSelection:(id)sender;
- (IBAction)doneEditingTitleAction:(UIButton *)sender;
- (IBAction)beginEditingTitleAction:(id)sender;

@end

@implementation LabelEditingViewController
@synthesize doneEditingTitleButton = _doneEditingTitleButton;
@synthesize contentContainer       = _contentContainer;
@synthesize
detailedButtonEditor = _detailedButtonEditor,
button               = _button,
buttonView           = _buttonView,
insetContainer       = _insetContainer,
titleColorButton     = _titleColorButton,
titleTextView        = _titleTextView,
fontNameButton       = _fontNameButton,
fontSizeLabel        = _fontSizeLabel,
fontSizeSlider       = _fontSizeSlider,
topInsetTextField    = _topInsetTextField,
leftInsetTextField   = _leftInsetTextField,
rightInsetTextField  = _rightInsetTextField,
bottomInsetTextField = _bottomInsetTextField,
fontNamePicker       = _fontNamePicker,
initialFontSize      = _initialFontSize,
initialTitleText     = _initialTitleText,
initialFontName      = _initialFontName,
initialEdgeInsets    = _initialEdgeInsets,
initialColor         = _initialColor,
currentFontSize      = _currentFontSize,
currentTitleText     = _currentTitleText,
currentFontName      = _currentFontName,
currentEdgeInsets    = _currentEdgeInsets,
currentColor         = _currentColor,
controlState         = _controlState,
delegate             = _delegate;

+ (void)initialize {
    if (self == [LabelEditingViewController class]) {
        NSMutableArray * tempFontNames = [NSMutableArray array];

        for (NSString * familyName in[UIFont familyNames]) {
            for (NSString * font in[UIFont fontNamesForFamilyName : familyName]) {
                [tempFontNames addObject:font];
            }
        }

        fontNames = [NSArray arrayWithArray:tempFontNames];
        DDLogVerbose(@"%@\n\tavailable fonts:\n%@", ClassTagString, fontNames);
    }
}

#pragma mark - Actions

- (void)setInitialValuesFromDictionary:(NSDictionary *)initialValues {
    [super setInitialValuesFromDictionary:initialValues];
    self.initialTitleText  = NilSafeValue(initialValues[kAttributeEditingTitleTextKey]);
    self.initialFontSize   = NilSafeValue(initialValues[kAttributeEditingFontSizeKey]);
    self.initialFontName   = NilSafeValue(initialValues[kAttributeEditingFontNameKey]);
    self.initialEdgeInsets = NilSafeValue(initialValues[kAttributeEditingEdgeInsetsKey]);
    self.initialColor      = NilSafeValue(initialValues[kAttributeEditingTitleColorKey]);
    self.button            = initialValues[kAttributeEditingButtonKey];
    self.controlState      = [initialValues[kAttributeEditingControlStateKey] unsignedIntegerValue];
    [self syncCurrentValuesWithIntialValues];
}

- (void)syncCurrentValuesWithIntialValues {
    self.currentTitleText  = _initialTitleText;
    self.currentFontSize   = _initialFontSize;
    self.currentFontName   = _initialFontName;
    self.currentEdgeInsets = _initialEdgeInsets;
    self.currentColor      = _initialColor;

// if ([self isViewLoaded])
// [self restoreCurrentValues];
}

- (void)resetToInitialState {
    [self syncCurrentValuesWithIntialValues];
    [self restoreCurrentValues:YES];
}

- (void)storeCurrentValues {
    self.currentFontName   = _fontNameButton.titleLabel.text;
    self.currentTitleText  = _titleTextView.text;
    self.currentFontSize   = @(_fontSizeSlider.value);
    self.currentEdgeInsets = [NSValue valueWithUIEdgeInsets:
                              UIEdgeInsetsMake([_topInsetTextField.text floatValue],
                                               [_leftInsetTextField.text floatValue],
                                               [_bottomInsetTextField.text floatValue],
                                               [_rightInsetTextField.text floatValue])];
    self.currentColor = _titleColorButton.backgroundColor;
}

- (void)restoreCurrentValues:(BOOL)animated {
    if (StringIsNotEmpty(_currentTitleText)) {
        if (animated) {
            [UIView animateWithDuration:0.5
                             animations:^{_titleTextView.text = _currentTitleText; }

            ];
        } else
            _titleTextView.text = _currentTitleText;

// [_button setTitle:_currentTitleText forState:_controlState];
    } else {
        _titleTextView.text = kEmptyLabelText;
        _button.titles[_controlState] = nil;
    }

    if (_currentFontSize) {
        if (animated) {
            [UIView animateWithDuration:0.5
                             animations:^{
                                 _fontSizeLabel.text = [NSString stringWithFormat:@"%.1f",
                                       [_currentFontSize floatValue]];
                                 _fontSizeSlider.value = [_currentFontSize floatValue];
                             }

            ];
        } else {
            _fontSizeLabel.text   = [NSString stringWithFormat:@"%.1f", [_currentFontSize floatValue]];
            _fontSizeSlider.value = [_currentFontSize floatValue];
        }

// _button.fontSize = [_currentFontSize floatValue];
    }

    if (_currentFontName) {
        if (animated) {
            [UIView animateWithDuration:0.5
                             animations:^{
                                 [_fontNameButton  setTitle:_currentFontName
                                  forState:UIControlStateNormal];
                             }

            ];
        } else
            [_fontNameButton setTitle:_currentFontName forState:UIControlStateNormal];

// _button.fontName = _currentFontName;
    }

    if (_currentEdgeInsets) {
        UIEdgeInsets   insets = [_currentEdgeInsets UIEdgeInsetsValue];

        if (animated) {
            [UIView animateWithDuration:0.5
                             animations:^{
                                 _topInsetTextField.text =
                                 [NSString stringWithFormat:@"%.1f", insets.top];
                                 _leftInsetTextField.text =
                                 [NSString stringWithFormat:@"%.1f", insets.left];
                                 _bottomInsetTextField.text =
                                 [NSString stringWithFormat:@"%.1f", insets.bottom];
                                 _rightInsetTextField.text =
                                 [NSString stringWithFormat:@"%.1f", insets.right];
                             }

            ];
        } else {
            _topInsetTextField.text    = [NSString stringWithFormat:@"%.1f", insets.top];
            _leftInsetTextField.text   = [NSString stringWithFormat:@"%.1f", insets.left];
            _bottomInsetTextField.text = [NSString stringWithFormat:@"%.1f", insets.bottom];
            _rightInsetTextField.text  = [NSString stringWithFormat:@"%.1f", insets.right];
        }

        _button.titleEdgeInsets = insets;
    }

    if (_currentColor) {
        if (animated) {
            [UIView animateWithDuration:0.5
                             animations:^{
                                 _titleColorButton.backgroundColor = _currentColor;
                             }

            ];
        } else
            _titleColorButton.backgroundColor = _currentColor;

// [_button setTitleColor:_currentColor forState:_controlState];
    }
}  /* restoreCurrentValues */

- (IBAction)launchColorSelection:(id)sender {
    if (ValueIsNil(_detailedButtonEditor)) return;

    ColorSelectionViewController * colorSelector =
        [StoryboardProxy colorSelectionViewController];

    colorSelector.delegate     = self;
    colorSelector.initialColor = _titleColorButton.backgroundColor;

    [self storeCurrentValues];

    [_detailedButtonEditor addAuxController:colorSelector animated:YES];
}

- (IBAction)doneEditingTitleAction:(UIButton *)sender {
    _doneEditingTitleButton.hidden = YES;
    [_titleTextView resignFirstResponder];
    _titleTextView.editable = NO;

    CGRect   frame = _titleTextView.frame;

    frame.size.width += _doneEditingTitleButton.frame.size.width;
    [UIView animateWithDuration:0.5
                     animations:^{_titleTextView.frame = frame; }

    ];
}

- (IBAction)beginEditingTitleAction:(id)sender {
    _titleTextView.editable = YES;
    if ([kEmptyLabelText isEqualToString:_titleTextView.text]) _titleTextView.text = @"";
    else _titleTextView.selectedRange = NSMakeRange(0, [_titleTextView.text length]);

    [_titleTextView becomeFirstResponder];
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    _currentFontSize = @(sender.value);
    [self restoreCurrentValues:YES];
}

- (IBAction)togglePicker:(id)sender {
    if (ValueIsNotNil([UIView firstResponderInView:self.view])) return;

    if (_fontNamePicker.alpha == 0.0) {
        [UIView animateWithDuration:0.5
                         animations:^{
                             _fontNamePicker.alpha = 1.0;
                             _fontNameButton.selected = YES;
                             NSInteger currentPickerRow =
                             [fontNames indexOfObject:_currentFontName];
                             if (currentPickerRow != NSNotFound)
                             [_fontNamePicker selectRow:currentPickerRow
                                           inComponent:0
                                  animated:YES];
        }

        ];
    } else {
        [UIView animateWithDuration:0.5
                         animations:^{
                             _fontNamePicker.alpha = 0.0;
                             _fontNameButton.selected = NO;
                         }

        ];
    }
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
    [self restoreCurrentValues:YES];
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

#pragma mark - ColorSelectionViewControllerDelegate

- (void)colorSelector:(ColorSelectionViewController *)controller
       didSelectColor:(UIColor *)color {
    self.currentColor = color;
    [self restoreCurrentValues:YES];

    if (ValueIsNotNil(_detailedButtonEditor)) [_detailedButtonEditor removeAuxController:controller animated:YES];
}

- (void)colorSelectorDidCancel:(ColorSelectionViewController *)controller {
    if (ValueIsNotNil(_detailedButtonEditor)) [_detailedButtonEditor removeAuxController:controller animated:YES];
}

#pragma mark - UITextViewDelegate methods

- (BOOL)           textView:(UITextView *)textView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text {
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    _doneEditingTitleButton.hidden = NO;

    CGRect   frame = _titleTextView.frame;

    frame.size.width -= _doneEditingTitleButton.frame.size.width;
    [UIView animateWithDuration:0.5
                     animations:^{_titleTextView.frame = frame; }

    ];
}

- (void)textViewDidChange:(UITextView *)textView
{}

- (void)textViewDidChangeSelection:(UITextView *)textView
{}

- (void)textViewDidEndEditing:(UITextView *)textView {
    _currentTitleText = textView.text;

    [self restoreCurrentValues:YES];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return _doneEditingTitleButton.hidden;
}

#pragma mark - UIPickerViewDataSource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [fontNames count];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (BOOL)                             gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

#pragma mark - UIPickerViewDelegate methods

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    NSString * fontName = fontNames[row];

    DDLogVerbose(@"%@\n\tselected font '%@'", ClassTagString, fontName);

    [_fontNameButton setTitle:fontName forState:UIControlStateNormal];
    _currentFontName = fontName;

    [self restoreCurrentValues:YES];
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    return fontNames[row];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Resize view to fit appropriately
    self.view.frame = self.contentContainer.bounds;

    // Style text view
    CALayer * textViewLayer = self.titleTextView.layer;

    textViewLayer.borderWidth = 1.0;
    textViewLayer.borderColor =
        [[UIColor colorWithRed:0.0 green:175.0 / 275.0 blue:1.0 alpha:1.0] CGColor];

    CGRect   frame = _titleTextView.frame;

    frame.size.width    += _doneEditingTitleButton.frame.size.width;
    _titleTextView.frame = frame;

    // Add font picker
    if (!_fontNamePicker.superview) {
        [self.view addSubview:_fontNamePicker];

        CGFloat   pickerTop =
            _fontNameButton.frame.origin.y + _fontNameButton.frame.size.height + 4.0;
        CGRect   pickerFrame = _fontNamePicker.frame;

        pickerFrame.origin.y  = pickerTop;
        _fontNamePicker.frame = pickerFrame;
    }

    // Add border to the color button
    _titleColorButton.layer.borderWidth = 1.0;
    _titleColorButton.layer.borderColor = [[UIColor blackColor] CGColor];

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

    // Fill presentation from ivar values
    [self restoreCurrentValues:NO];
}  /* viewDidLoad */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self setTitleTextView:nil];
    [self setFontNameButton:nil];
    [self setFontSizeLabel:nil];
    [self setFontSizeSlider:nil];
    [self setTopInsetTextField:nil];
    [self setLeftInsetTextField:nil];
    [self setRightInsetTextField:nil];
    [self setBottomInsetTextField:nil];
    [self setFontNamePicker:nil];
    [self setTitleColorButton:nil];
    [self setInsetContainer:nil];
    [self setDoneEditingTitleButton:nil];
    [self setContentContainer:nil];
    if ([self isViewLoaded] && self.view.window == nil) self.view = nil;
}

@end
