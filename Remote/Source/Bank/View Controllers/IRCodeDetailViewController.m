//
//  IRCodeDetailViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/22/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankableDetailTableViewController_Private.h"
#import "IRCodeDetailViewController.h"
#import "IRCode.h"


static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel, msLogContext)

@interface IRCodeDetailViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField * frequencyTextField;
@property (weak, nonatomic) IBOutlet UITextField * repeatTextField;
@property (weak, nonatomic) IBOutlet UILabel     * offsetLabel;
@property (weak, nonatomic) IBOutlet UIStepper   * offsetStepper;
@property (weak, nonatomic) IBOutlet UITextView  * patternTextView;
@property (weak, nonatomic) IBOutlet UIButton    * codesetButton;
@property (weak, nonatomic) IBOutlet UIButton    * manufacturerButton;

@property (nonatomic, readonly) IRCode * irCode;

@end

@implementation IRCodeDetailViewController

- (IRCode *)irCode { return (IRCode *)self.item; }

+ (Class)itemClass { return [IRCode class]; }

- (void)updateDisplay
{
    [super updateDisplay];

    NSString * text = ([self.irCode valueForKeyPath:@"codeset.name"]
                       ? : @"No Codeset");
    [self.codesetButton setTitle:text forState:UIControlStateNormal];

    text = ([self.irCode valueForKeyPath:@"codeset.manufacturer.name"]
            ? : @"No Manufacturer");
    [self.manufacturerButton setTitle:text forState:UIControlStateNormal];

    self.frequencyTextField.text = [@(self.irCode.frequency) description];
    self.repeatTextField.text    = [@(self.irCode.repeatCount) description];
    self.offsetStepper.value     = self.irCode.offset;
    self.offsetLabel.text        = [@(_offsetStepper.value) description];
    self.patternTextView.text    = self.irCode.onOffPattern;
}

- (NSArray *)editableViews
{
    return [[super editableViews] arrayByAddingObjectsFromArray:@[_frequencyTextField,
                                                                  _repeatTextField,
                                                                  _offsetStepper,
                                                                  _patternTextView,
                                                                  _codesetButton,
                                                                  _manufacturerButton]];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    if (editing)
        [self revealAnimationForView:_offsetStepper besideView:_offsetLabel];

    else
        [self hideAnimationForView:_offsetStepper besideView:_offsetLabel];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Picker view data source
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 0;
}



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Actions
////////////////////////////////////////////////////////////////////////////////

- (IBAction)selectIRCodeset:(id)sender { MSLogDebug(@""); }

- (IBAction)selectManufacturer:(id)sender { MSLogDebug(@""); }

- (IBAction)offsetValueDidChange:(UIStepper *)sender
{
    MSLogDebug(@"");
    self.irCode.offset = (int16_t)sender.value;
    _offsetLabel.text = [@(sender.value) description];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Text field delegate
////////////////////////////////////////////////////////////////////////////////

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _repeatTextField)
        self.irCode.repeatCount = [textField.text intValue];

    else if (textField == _frequencyTextField)
        self.irCode.frequency = [textField.text longLongValue];

    else
        [super textFieldDidEndEditing:textField];
    
}

@end
