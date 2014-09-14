//
//  ImageDetailViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/22/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankableDetailTableViewController_Private.h"
#import "ImageDetailViewController.h"
#import "Image.h"
#import "CoreDataManager.h"
#import "MSKit/MSKit.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

CellIndexPathDeclaration(Category);
CellIndexPathDeclaration(File);
CellIndexPathDeclaration(Size);
CellIndexPathDeclaration(Preview);

@interface ImageDetailViewController ()
@property (nonatomic, strong) NSArray * categories;
@end

@implementation ImageDetailViewController

/// initialize
+ (void)initialize {
  if (self == [ImageDetailViewController class]) {
    CellIndexPathDefinition(Category, 0, 0);
    CellIndexPathDefinition(File,     1, 0);
    CellIndexPathDefinition(Size,     2, 0);
    CellIndexPathDefinition(Preview,  0, 1);
  }
}

/// itemClass
/// @return Class<BankableModel>
- (Class<BankableModel>)itemClass { return [Image class]; }

/// image
/// @return Image *
- (Image *)image { return (Image *)self.item; }

/// categories
/// @return NSArray *
- (NSArray *)categories {
  if (!_categories) self.categories = [Image allValuesForAttribute:@"category" context:self.item.managedObjectContext];
  return _categories;
}

/// numberOfSections
/// @return NSInteger
- (NSInteger)numberOfSections { return 2; }

/// numberOfRowsInSection:
/// @param section description
/// @return NSInteger
- (NSInteger)numberOfRowsInSection:(NSInteger)section { return (section ? 1 : 3); }

/// editableRows
/// @return NSSet const *
- (NSSet const *)editableRows {

  static NSSet const * rows = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{ rows = [@[CategoryCellIndexPath] set]; });

  return rows;

}

/// identifiers
/// @return NSArray const *
- (NSArray const *)identifiers {

  static NSArray const * identifiers = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    identifiers = @[ @[BankableDetailCellTextFieldStyleIdentifier,
                       BankableDetailCellLabelStyleIdentifier,
                       BankableDetailCellLabelStyleIdentifier],
                     @[BankableDetailCellImageStyleIdentifier] ];
  });

  return identifiers;

}

/// decorateCell:forIndexPath:
/// @param cell description
/// @param indexPath description
- (void)decorateCell:(BankableDetailTableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {

  if (indexPath == CategoryCellIndexPath) {

    cell.name = @"Category";
    cell.info = (self.image.category ?: @"Uncategorized");

    __weak ImageDetailViewController * weakself = self;

    cell.changeHandler = ^(BankableDetailTableViewCell * cell) {
      weakself.image.category = cell.info;
      if (![weakself.categories containsObject:weakself.image.category]) weakself.categories = nil;
    };

    cell.pickerData = self.categories;
    cell.pickerSelection = self.image.category;

  }

  else if (indexPath == FileCellIndexPath)    { cell.name = @"File"; cell.info = self.image.fileName;         }
  else if (indexPath == SizeCellIndexPath)    { cell.name = @"Size"; cell.info = PrettySize(self.image.size); }
  else if (indexPath == PreviewCellIndexPath) { cell.info = self.image.preview;                               }

}

@end
