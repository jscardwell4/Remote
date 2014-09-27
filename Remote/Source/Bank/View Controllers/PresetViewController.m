//
//  PresetViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/22/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankItemViewController_Private.h"
#import "PresetViewController.h"
#import "Preset.h"
#import "RETypedefs.h"
#import "CoreDataManager.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

CellIndexPathDeclaration(Category);
CellIndexPathDeclaration(Type);
CellIndexPathDeclaration(Preview);


@interface PresetViewController ()

@property (nonatomic, weak, readonly) Preset  * preset;
@property (nonatomic, strong)         NSArray * categories;

@end

@implementation PresetViewController

/// initialize
+ (void)initialize {
  if (self == [PresetViewController class]) {
    CellIndexPathDefinition(Category, 0, 0);
    CellIndexPathDefinition(Type,     1, 0);
    CellIndexPathDefinition(Preview,  0, 1);
  }
}

/// itemClass
/// @return Class<BankableModel>
- (Class<BankableModel>)itemClass { return [Preset class]; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Aliased properties
////////////////////////////////////////////////////////////////////////////////


/// preset
/// @return Preset *
- (Preset *)preset { return (Preset *)self.item; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view data source
////////////////////////////////////////////////////////////////////////////////


/// numberOfSections
/// @return NSInteger
- (NSInteger)numberOfSections { return 2; }

/// numberOfRowsInSection:
/// @param section
/// @return NSInteger
- (NSInteger)numberOfRowsInSection:(NSInteger)section { return (section ? 1 : 2); }

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
    identifiers = @[ @[BankItemCellTextFieldStyleIdentifier,
                       BankItemCellLabelStyleIdentifier],
                     @[BankItemCellImageStyleIdentifier] ];
  });

  return identifiers;

}

/// decorateCell:forIndexPath:
/// @param cell
/// @param indexPath
- (void)decorateCell:(BankItemTableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {


  if (indexPath == CategoryCellIndexPath) {

    cell.name = @"Category";
    cell.info = (self.preset.category ?: @"Uncategorized");

    __weak PresetViewController * weakself = self;

    cell.changeHandler = ^(BankItemTableViewCell * cell) {
      NSString * text = cell.info;
      weakself.preset.category = (text.length ? text : nil);
      if (![weakself.categories containsObject:weakself.preset.category]) weakself.categories = nil;
    };

    cell.pickerData = self.categories;
    cell.pickerSelection = self.preset.category;

  }

  else if (indexPath == TypeCellIndexPath) {

    cell.name = @"Type";
    cell.info = NSStringFromREType([[self.preset valueForKeyPath:@"element.type"] intValue]);

  }

  else if (indexPath == PreviewCellIndexPath)
    cell.info = self.preset.preview;

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Managing picker views
////////////////////////////////////////////////////////////////////////////////


/// categories
/// @return NSArray *
- (NSArray *)categories {

  if (!_categories) {
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Preset"];
    [request setIncludesPendingChanges:YES];
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:@[@"category"]];

    NSError * error   = nil;
    NSArray * objects = [self.preset.managedObjectContext executeFetchRequest:request
                                                                        error:&error];
    NSMutableArray * categories = [[objects valueForKey:@"category"] mutableCopy];

    if (![categories containsObject:self.preset.category])
      [categories addObject:self.preset.category];

    [categories sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];

    if (!MSHandleErrors(error))
      self.categories = [@[@"Uncategorized"] arrayByAddingObjectsFromArray : categories];

    assert(!self.preset.category || [_categories containsObject:self.preset.category]);
  }

  return _categories;

}


@end
