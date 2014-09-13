//
//  BankableDetailTableViewCell.h
//  Remote
//
//  Created by Jason Cardwell on 10/1/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
#import "MSKit/MSKit.h"
#import "MSRemoteMacros.h"

MSEXTERN_IDENTIFIER(BankableDetailCellLabelStyle);
MSEXTERN_IDENTIFIER(BankableDetailCellListStyle);
MSEXTERN_IDENTIFIER(BankableDetailCellButtonStyle);
MSEXTERN_IDENTIFIER(BankableDetailCellImageStyle);
MSEXTERN_IDENTIFIER(BankableDetailCellSwitchStyle);
MSEXTERN_IDENTIFIER(BankableDetailCellStepperStyle);
MSEXTERN_IDENTIFIER(BankableDetailCellDetailStyle);
MSEXTERN_IDENTIFIER(BankableDetailCellTextViewStyle);
MSEXTERN_IDENTIFIER(BankableDetailCellTextFieldStyle);
MSEXTERN_IDENTIFIER(BankableDetailCellTableStyle);

@interface BankableDetailTableViewCell : UITableViewCell

/// validIdentifiers
/// @return NSSet const *
+ (NSSet const *)validIdentifiers;

/// isValidIentifier:
/// @param identifier description
/// @return BOOL
+ (BOOL)isValidIentifier:(NSString *)identifier;

/// registerIdentifiersWithTableView:
/// @param tableView description
+ (void)registerIdentifiersWithTableView:(UITableView *)tableView;

@property (nonatomic, copy) void(^changeHandler    )     (BankableDetailTableViewCell * cell);
@property (nonatomic, copy) BOOL(^validationHandler)     (BankableDetailTableViewCell * cell);
@property (nonatomic, copy) void(^pickerSelectionHandler)(BankableDetailTableViewCell * cell, NSInteger row);
@property (nonatomic, copy) void(^buttonActionHandler)   (BankableDetailTableViewCell * cell);
@property (nonatomic, copy) void(^pickerDisplayCallback) (BankableDetailTableViewCell * cell, BOOL hidden);
@property (nonatomic, copy) void(^rowSelectionHandler)   (BankableDetailTableViewCell * cell, NSUInteger row);

@property (nonatomic, assign, getter=shouldUseIntegerKeyboard)     BOOL useIntegerKeyboard;
@property (nonatomic, assign, getter=shouldAllowReturnsInTextView) BOOL allowReturnsInTextView;
@property (nonatomic, assign, getter=isExpanded)                   BOOL expanded;
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

/// showPickerView
- (void)showPickerView;

/// hidePickerView
- (void)hidePickerView;

@end
