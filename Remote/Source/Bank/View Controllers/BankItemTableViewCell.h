//
//  BankItemTableViewCell.h
//  Remote
//
//  Created by Jason Cardwell on 10/1/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
@import Moonkit;
#import "MSRemoteMacros.h"

MSEXTERN_IDENTIFIER(BankItemCellLabelStyle);
MSEXTERN_IDENTIFIER(BankItemCellListStyle);
MSEXTERN_IDENTIFIER(BankItemCellButtonStyle);
MSEXTERN_IDENTIFIER(BankItemCellImageStyle);
MSEXTERN_IDENTIFIER(BankItemCellSwitchStyle);
MSEXTERN_IDENTIFIER(BankItemCellStepperStyle);
MSEXTERN_IDENTIFIER(BankItemCellDetailStyle);
MSEXTERN_IDENTIFIER(BankItemCellTextViewStyle);
MSEXTERN_IDENTIFIER(BankItemCellTextFieldStyle);
MSEXTERN_IDENTIFIER(BankItemCellTableStyle);

MSEXTERN const CGFloat BankItemCellPickerHeight;

@interface BankItemTableViewCell : UITableViewCell

/// validIdentifiers
/// @return NSSet const *
+ (NSSet const *)validIdentifiers;

/// isValidIentifier:
/// @param identifier
/// @return BOOL
+ (BOOL)isValidIentifier:(NSString *)identifier;

/// registerIdentifiersWithTableView:
/// @param tableView
+ (void)registerIdentifiersWithTableView:(UITableView *)tableView;

@property (nonatomic, copy) void(^changeHandler    )     (BankItemTableViewCell * cell);
@property (nonatomic, copy) BOOL(^validationHandler)     (BankItemTableViewCell * cell);
@property (nonatomic, copy) void(^pickerSelectionHandler)(BankItemTableViewCell * cell);
@property (nonatomic, copy) void(^buttonActionHandler)   (BankItemTableViewCell * cell);
@property (nonatomic, copy) void(^rowSelectionHandler)   (BankItemTableViewCell * cell);
@property (nonatomic, copy) BOOL(^shouldShowPicker)      (BankItemTableViewCell * cell);
@property (nonatomic, copy) BOOL(^shouldHidePicker)      (BankItemTableViewCell * cell);
@property (nonatomic, copy) void(^didShowPicker)         (BankItemTableViewCell * cell);
@property (nonatomic, copy) void(^didHidePicker)         (BankItemTableViewCell * cell);

@property (nonatomic, assign, getter=shouldUseIntegerKeyboard)     BOOL useIntegerKeyboard;
@property (nonatomic, assign, getter=shouldAllowReturnsInTextView) BOOL allowReturnsInTextView;
@property (nonatomic, assign, getter=shouldAllowRowSelection)      BOOL allowRowSelection;

@property (nonatomic, weak) NSString * name;
@property (nonatomic, copy) id         info;

@property (nonatomic, assign) double stepperMinValue;
@property (nonatomic, assign) double stepperMaxValue;
@property (nonatomic, assign) BOOL   stepperWraps;

@property (nonatomic, weak, readonly) UITableView * table;

@property (nonatomic, strong) NSString * tableIdentifier;
@property (nonatomic, weak)   NSArray  * tableData;
@property (nonatomic, weak)   NSArray  * pickerData;
@property (nonatomic, strong) id         pickerSelection;
@property (nonatomic, strong) id         tableSelection;

/// showPickerView
- (void)showPickerView;

/// hidePickerView
- (void)hidePickerView;

@end
