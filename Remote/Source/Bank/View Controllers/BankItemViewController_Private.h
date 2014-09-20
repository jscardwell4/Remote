//
//  BankItemViewController_Private.h
//  Remote
//
//  Created by Jason Cardwell on 9/24/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
@import MoonKit;
#import "MSRemoteMacros.h"
#import "BankableModelObject.h"
#import "BankItemViewController.h"
#import "BankItemTableViewCell.h"


@interface BankItemViewController (Subclass)

////////////////////////////////////////////////////////////////////////////////
#pragma mark Common interface items and actions
////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, weak, readonly) UITextField * nameTextField;

- (void)updateDisplay; // refresh user interface info

@property (nonatomic, strong, readonly ) NSSet        const * editableRows;
@property (nonatomic, strong, readwrite) NSMutableArray     * expandedRows;  // Rows showing picker view
@property (nonatomic, assign, readonly ) NSInteger    const   numberOfSections;
@property (nonatomic, strong, readonly ) NSArray      const * sectionHeaderTitles;
@property (nonatomic, strong, readonly)  NSArray      const * identifiers;

- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (CGFloat)heightForSubTableAtIndexPath:(NSIndexPath *)indexPath;

- (BankItemTableViewCell *)cellForRowAtIndexPath:(NSIndexPath const *)indexPath;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;


- (void)decorateCell:(BankItemTableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath;

@end

#define CellIndexPathDeclaration(CELL) \
  static NSIndexPath const * __CONCAT(CELL,CellIndexPath)

#define CellIndexPathDefinition(CELL,ROW,SEC) \
  __CONCAT(CELL,CellIndexPath) = [NSIndexPath indexPathForRow:ROW inSection:SEC]

#define SectionHeadersDeclaration static NSArray const * TableSectionHeaders;
#define SectionHeadersDefinition(...) TableSectionHeaders = @[__VA_ARGS__];

MSEXTERN const CGFloat BankItemDefaultRowHeight;
MSEXTERN const CGFloat BankItemPreviewRowHeight;
MSEXTERN const CGFloat BankItemTextViewRowHeight;
MSEXTERN const CGFloat BankItemTableRowHeight;    // Cell containing another table view
