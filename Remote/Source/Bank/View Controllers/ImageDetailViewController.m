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

@property (nonatomic, weak, readonly) Image   * image;
@property (nonatomic, strong)         NSArray * categories;

@end

@implementation ImageDetailViewController

/// initialize
+ (void)initialize {
  if (self == [ImageDetailViewController class]) {
    CellIndexPathDefinition(Category, 0, 0);
    CellIndexPathDefinition(File,     0, 1);
    CellIndexPathDefinition(Size,     0, 2);
    CellIndexPathDefinition(Preview,  0, 3);
  }
}

/// itemClass
/// @return Class<BankableModel>
- (Class<BankableModel>)itemClass { return [Image class]; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Aliased properties
////////////////////////////////////////////////////////////////////////////////


/// image
/// @return Image *
- (Image *)image { return (Image *)self.item; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view data source
////////////////////////////////////////////////////////////////////////////////


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
  dispatch_once(&onceToken, ^{
    rows = [@[CategoryCellIndexPath] set];
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
                       BankableDetailCellLabelStyleIdentifier,
                       BankableDetailCellLabelStyleIdentifier],
                     @[BankableDetailCellImageStyleIdentifier] ];
  });

  return identifiers;

}

/// tableView:cellForRowAtIndexPath:
/// @param tableView description
/// @param indexPath description
/// @return UITableViewCell *
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  BankableDetailTableViewCell * cell;

  switch (indexPath.section) {
    case 0:     // Info
    {
      switch (indexPath.row) {
        case 0:         // Category
        {
          cell = [self dequeueCellForIndexPath:indexPath];
          cell.name = @"Category";
          cell.info = (self.image.category ?: @"Uncategorized");


          __weak ImageDetailViewController * weakself = self;
          cell.changeHandler = ^(BankableDetailTableViewCell * cell) {

            weakself.image.category = cell.info;
            if (![weakself.categories containsObject:weakself.image.category]) weakself.categories = nil;

          };

          cell.pickerData = self.categories;
          cell.pickerSelection = self.image.category;

          break;
        }

        case 1:         // File name
        {
          cell = [self dequeueCellForIndexPath:indexPath];
          cell.name = @"File";
          cell.info = self.image.fileName;

          break;
        }

        case 2:         // Size
        {
          cell = [self dequeueCellForIndexPath:indexPath];
          cell.name = @"Size";
          cell.info = PrettySize(self.image.size);

          break;
        }
      }

      break;
    }

    case 1:     // Preview
    {
      cell = [self dequeueCellForIndexPath:indexPath];
      cell.info = self.image.preview;

      break;
    }

  }

  return cell;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Managing picker views
////////////////////////////////////////////////////////////////////////////////


/// categories
/// @return NSArray *
- (NSArray *)categories {
  if (!_categories) {
    NSManagedObjectContext * context = self.item.managedObjectContext;

    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Image"];
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:@[@"category"]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"preset != nil"]];

    NSError * error   = nil;
    NSArray * objects = [context executeFetchRequest:request error:&error];

    if (!MSHandleErrors(error))
      self.categories = [@[@"Uncategorized"]
                         arrayByAddingObjectsFromArray:[objects valueForKeyPath:@"category"]];
  }

  return _categories;
}

@end
