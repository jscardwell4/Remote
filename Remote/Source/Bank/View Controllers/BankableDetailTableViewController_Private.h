//
//  BankableDetailTableViewController_Private.h
//  Remote
//
//  Created by Jason Cardwell on 9/24/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
#import "MSKit/MSKit.h"
#import "MSRemoteMacros.h"

#import "BankableDetailTableViewController.h"
#import "BankableDetailTableViewCell.h"


typedef NS_ENUM(uint8_t, BankableDetailDataType)
{
    BankableDetailUndefinedData       = 0,
    BankableDetailPickerViewData      = 1,
    BankableDetailPickerViewSelection = 2,
    BankableDetailPickerButtonData    = 3,
    BankableDetailTextFieldData       = 4
};

typedef void(^BankableChangeHandler)(void);
typedef BOOL(^BankableValidationHandler)(void);

@interface BankableDetailTableViewController () <UITextFieldDelegate, UITextViewDelegate,
                                                 UIPickerViewDataSource, UIPickerViewDelegate>

////////////////////////////////////////////////////////////////////////////////
#pragma mark Common interface items and actions
////////////////////////////////////////////////////////////////////////////////
@property (nonatomic, weak)     IBOutlet UITextField     * nameTextField;
@property (nonatomic, strong)   IBOutlet UIBarButtonItem * cancelBarButtonItem;

- (void)updateDisplay; // refresh user interface info

// may be overridden by subclasses to have interaction toggled along with editing property
@property (nonatomic, strong, readonly) NSHashTable * editableViews;
- (void)registerEditableView:(UIView *)view;

////////////////////////////////////////////////////////////////////////////////
#pragma mark Actions
////////////////////////////////////////////////////////////////////////////////

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

////////////////////////////////////////////////////////////////////////////////
#pragma mark Animations
////////////////////////////////////////////////////////////////////////////////

- (void)revealAnimationForView:(UIView *)hiddenView besideView:(UIView *)neighborView;
- (void)hideAnimationForView:(UIView *)hiddenView besideView:(UIView *)neighborView;

////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view management
////////////////////////////////////////////////////////////////////////////////

- (UINib *)nibForIdentifier:(NSString *)identifier;
- (BankableDetailTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
                                                      forIndexPath:(NSIndexPath *)indexPath;
- (BankableDetailTableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;

// data sources
- (id)dataForIndexPath:(NSIndexPath *)indexPath type:(BankableDetailDataType)type;


////////////////////////////////////////////////////////////////////////////////
#pragma mark Stepper management
////////////////////////////////////////////////////////////////////////////////

- (void)registerStepper:(UIStepper *)stepper
              withLabel:(UILabel *)label
           forIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForStepper:(UIStepper *)stepper;
- (UIStepper *)stepperForIndexPath:(NSIndexPath *)indexPath;

////////////////////////////////////////////////////////////////////////////////
#pragma mark Text field management
////////////////////////////////////////////////////////////////////////////////

- (UITextField *)textFieldForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForTextField:(UITextField *)textField;
- (void)registerTextField:(UITextField *)textField
             forIndexPath:(NSIndexPath *)indexPath
                  handlers:(NSDictionary *)handlers;
- (UIView *)integerKeyboardViewForTextField:(UITextField *)textField;

////////////////////////////////////////////////////////////////////////////////
#pragma mark Picker view management
////////////////////////////////////////////////////////////////////////////////

- (void)registerPickerView:(UIPickerView *)pickerView forIndexPath:(NSIndexPath *)indexPath;
- (UIPickerView *)pickerViewForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForPickerView:(UIPickerView *)pickerView;
- (void)pickerView:(UIPickerView *)pickerView
   didSelectObject:(id)selection
               row:(NSUInteger)row
         indexPath:(NSIndexPath *)indexPath;

// marks the current table cell, if any, that has expanded to reveal picker view
@property (nonatomic, weak) NSIndexPath * visiblePickerCellIndexPath;

@end


MSEXTERN_NAMETAG(BankableDetailHiddenNeighborConstraint);

MSEXTERN_IDENTIFIER(StepperCell);
MSEXTERN_IDENTIFIER(SwitchCell);
MSEXTERN_IDENTIFIER(LabelCell);
MSEXTERN_IDENTIFIER(LabelListCell);
MSEXTERN_IDENTIFIER(DetailDisclosureCell);
MSEXTERN_IDENTIFIER(ButtonCell);
MSEXTERN_IDENTIFIER(ImageCell);
MSEXTERN_IDENTIFIER(TextFieldCell);
MSEXTERN_IDENTIFIER(TextViewCell);
MSEXTERN_IDENTIFIER(TableCell);

MSEXTERN_KEY(BankableChangeHandler);
MSEXTERN_KEY(BankableValidationHandler);

MSEXTERN const CGFloat BankableDetailDefaultRowHeight;
MSEXTERN const CGFloat BankableDetailExpandedRowHeight;
MSEXTERN const CGFloat BankableDetailPreviewRowHeight;
MSEXTERN const CGFloat BankableDetailTextViewRowHeight;

NSString * textForSelection(id selection);
