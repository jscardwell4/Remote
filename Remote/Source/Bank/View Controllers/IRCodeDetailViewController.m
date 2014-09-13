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
#import "BankGroup.h"
#import "Manufacturer.h"


static int       ddLogLevel   = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel, msLogContext)


CellIndexPathDeclaration(Manufacturer);
CellIndexPathDeclaration(Codeset);
CellIndexPathDeclaration(Frequency);
CellIndexPathDeclaration(Repeat);
CellIndexPathDeclaration(Offset);
CellIndexPathDeclaration(OnOffPattern);

@interface IRCodeDetailViewController ()

@property (nonatomic, readonly) IRCode  * irCode;
@property (nonatomic, strong)   NSArray * manufacturers;
@property (nonatomic, strong)   NSArray * codesets;

@end

@implementation IRCodeDetailViewController

/// initialize
+ (void)initialize {
  if (self == [IRCodeDetailViewController class]) {
    CellIndexPathDefinition(Manufacturer, 0, 0);
    CellIndexPathDefinition(Codeset,      1, 0);
    CellIndexPathDefinition(Frequency,    2, 0);
    CellIndexPathDefinition(Repeat,       3, 0);
    CellIndexPathDefinition(Offset,       4, 0);
    CellIndexPathDefinition(OnOffPattern, 5, 0);
  }
}

/// itemClass
/// @return Class<BankableModel>
- (Class<BankableModel>)itemClass { return [IRCode class]; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Managing picker views
////////////////////////////////////////////////////////////////////////////////


/// manufacturers
/// @return NSArray *
- (NSArray *)manufacturers {
  if (!_manufacturers)
    self.manufacturers = [@[@"No Manufacturer",
                            [Manufacturer findAllSortedBy:@"name"
                                                ascending:YES
                                                  context:self.item.managedObjectContext]] flattened];
  return _manufacturers;
}

/// codesets
/// @return NSArray *
- (NSArray *)codesets {
  if (!_codesets) {
    NSArray * sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:nil ascending:YES]];
    NSArray * codesets        = [self.irCode.manufacturer.codesets
                                 sortedArrayUsingDescriptors:sortDescriptors];
    self.codesets = [@[@"No Codeset", (codesets ?: @[])] flattened];
  }

  return _codesets;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Aliased properties
////////////////////////////////////////////////////////////////////////////////


/// irCode
/// @return IRCode *
- (IRCode *)irCode { return (IRCode *)self.item; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view data source
////////////////////////////////////////////////////////////////////////////////


/// numberOfRowsInSection:
/// @param section description
/// @return NSInteger
- (NSInteger)numberOfRowsInSection:(NSInteger)section { return 6; }

/// editableRows
/// @return NSSet const *
- (NSSet const *)editableRows {

  static NSSet const * rows = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    rows = [@[ManufacturerCellIndexPath,
              CodesetCellIndexPath,
              FrequencyCellIndexPath,
              RepeatCellIndexPath,
              OffsetCellIndexPath,
              OnOffPatternCellIndexPath] set];
  });

  return rows;

}

/// identifiers
/// @return NSArray const *
- (NSArray const *)identifiers {

  static NSArray const * identifiers = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    identifiers = @[ @[BankableDetailCellTextFieldStyleIdentifier,
                       BankableDetailCellTextFieldStyleIdentifier,
                       BankableDetailCellTextFieldStyleIdentifier,
                       BankableDetailCellTextFieldStyleIdentifier,
                       BankableDetailCellStepperStyleIdentifier,
                       BankableDetailCellTextViewStyleIdentifier] ];
  });

  return identifiers;

}

/// decorateCell:forIndexPath:
/// @param cell description
/// @param indexPath description
- (void)decorateCell:(BankableDetailTableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {

  __weak IRCodeDetailViewController * weakself = self;

  if (indexPath == ManufacturerCellIndexPath) {

    cell.name = @"Manufacturer";
    cell.info = ([self.irCode valueForKeyPath:@"manufacturer.name"] ?: @"No Manufacturer");

    cell.validationHandler = ^BOOL(BankableDetailTableViewCell * cell) {
      return (((NSString *)cell.info).length > 0);
    };

    __weak IRCodeDetailViewController * weakself = self;
    cell.changeHandler = ^(BankableDetailTableViewCell * cell) {

      NSString * text = cell.info;

      if ([@"No Manufacturer" isEqualToString:text]) weakself.irCode.manufacturer = nil;

      else {

        Manufacturer * manufacturer =
        [weakself.manufacturers findFirstUsingPredicate:NSPredicateMake(@"name == %@", text)];

        if (!manufacturer) {

          manufacturer = [Manufacturer manufacturerWithName:text
                                                    context:weakself.irCode.managedObjectContext];
          weakself.manufacturers = nil;
        }

        assert(manufacturer);

        weakself.irCode.manufacturer = manufacturer;
      }

    };

    cell.pickerSelectionHandler = ^(BankableDetailTableViewCell * cell) {

      id selection = cell.pickerSelection;

      Manufacturer * manufacturer = nil;

      if ([selection isKindOfClass:[Manufacturer class]]) manufacturer = selection;

      if (!manufacturer) {

        weakself.irCode.manufacturer = nil;
        weakself.codesets            = nil;
        [weakself cellForRowAtIndexPath:CodesetCellIndexPath].info = @"No Codeset";

      } else if (manufacturer != weakself.irCode.manufacturer) {

        [weakself cellForRowAtIndexPath:CodesetCellIndexPath].info = @"No Codeset";
        weakself.codesets = nil;
        weakself.irCode.manufacturer = selection;

      }

    };

    cell.pickerData = self.manufacturers;
    cell.pickerSelection = self.irCode.manufacturer;

  }

  else if (indexPath == CodesetCellIndexPath) {

    cell.name = @"Codeset";
    cell.info = (self.irCode.codeset ?: @"No Codeset");

    cell.validationHandler =  ^BOOL(BankableDetailTableViewCell * cell) {
      return (((NSString *)cell.info).length > 0);
    };

    cell.changeHandler = ^(BankableDetailTableViewCell * cell) {

      NSString * text = cell.info;

      if ([@"No Codeset" isEqualToString:text]) weakself.irCode.codeset = nil;

      else {

        weakself.irCode.codeset = text;

        if (![weakself.codesets containsObject:text]) weakself.codesets = nil;

      }

    };


    cell.pickerSelectionHandler = ^(BankableDetailTableViewCell * cell) {
      id selection = cell.pickerSelection;
      weakself.irCode.codeset = ([selection isEqualToString:@"No Codeset"] ? nil : selection);
    };

    cell.pickerData = self.codesets;
    cell.pickerSelection = self.irCode.codeset;

  }

  else if (indexPath == FrequencyCellIndexPath) {

    cell.name = @"Frequency";
    cell.info = [self.irCode.frequency stringValue];

    cell.useIntegerKeyboard = YES;

    cell.changeHandler = ^(BankableDetailTableViewCell * cell) { weakself.irCode.frequency = cell.info; };

  }

  else if (indexPath == RepeatCellIndexPath) {

    cell.name               = @"Repeat";
    cell.info               = [self.irCode.repeatCount stringValue];
    cell.useIntegerKeyboard = YES;

    cell.changeHandler = ^(BankableDetailTableViewCell * cell) { weakself.irCode.repeatCount = cell.info; };

  }

  else if (indexPath == OffsetCellIndexPath) {

    cell.name            = @"Offset";
    cell.stepperMinValue = 0;
    cell.stepperMaxValue = 127;
    cell.stepperWraps    = NO;
    cell.info            = self.irCode.offset;

    cell.changeHandler = ^(BankableDetailTableViewCell * cell) {
      weakself.irCode.offset = cell.info;
    };

  }

  else if (indexPath == OnOffPatternCellIndexPath) {

    cell.name = @"On-Off Pattern";
    cell.info = self.irCode.onOffPattern;

    cell.validationHandler = ^BOOL(BankableDetailTableViewCell * cell) {

      NSString * text = [(NSString *)cell.info stringByTrimmingWhitespace];
      return (text.length == 0 || [IRCode isValidOnOffPattern:text]);

    };

    cell.changeHandler = ^(BankableDetailTableViewCell * cell) {
      NSString * text = [(NSString *)cell.info stringByTrimmingWhitespace];
      NSString * compressedText = [IRCode compressedOnOffPatternFromPattern:text];
      weakself.irCode.onOffPattern = compressedText;
    };

  }

}


@end
