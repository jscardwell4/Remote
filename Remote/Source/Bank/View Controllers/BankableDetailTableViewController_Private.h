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
#import "BankableModelObject.h"
#import "BankableDetailTableViewController.h"
#import "BankableDetailTableViewCell.h"


@interface BankableDetailTableViewController (Subclass)

////////////////////////////////////////////////////////////////////////////////
#pragma mark Common interface items and actions
////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, weak, readonly) UITextField * nameTextField;

- (void)updateDisplay; // refresh user interface info

@property (nonatomic, strong, readonly ) NSSet        const * editableRows;
@property (nonatomic, strong, readwrite) NSMutableArray     * expandedRows;  // Rows showing picker view
@property (nonatomic, assign, readonly ) NSInteger            numberOfSections;
@property (nonatomic, strong, readonly ) NSArray            * sectionHeaderTitles;
@property (nonatomic, strong, readonly)  NSArray const * identifiers;

- (NSInteger)numberOfRowsInSection:(NSInteger)section;

- (BankableDetailTableViewCell *)cellForRowAtIndexPath:(NSIndexPath const *)indexPath;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;


// Cell dequeueing convenience
- (BankableDetailTableViewCell *)dequeueCellForIndexPath:(NSIndexPath *)indexPath;

@end

#define CellIndexPathDeclaration(CELL) \
  static NSIndexPath const * __CONCAT(CELL,CellIndexPath)

#define CellIndexPathDefinition(CELL,ROW,SEC) \
  __CONCAT(CELL,CellIndexPath) = [NSIndexPath indexPathForRow:ROW inSection:SEC]


MSEXTERN const CGFloat BankableDetailDefaultRowHeight;
MSEXTERN const CGFloat BankableDetailExpandedRowHeight; // Picker view displayed
MSEXTERN const CGFloat BankableDetailPreviewRowHeight;
MSEXTERN const CGFloat BankableDetailTextViewRowHeight;
MSEXTERN const CGFloat BankableDetailTableRowHeight;    // Cell containing another table view
