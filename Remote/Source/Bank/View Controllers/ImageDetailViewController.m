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

static NSIndexPath * kCategoryCellIndexPath;
static NSIndexPath * kPreviewCellIndexPath;

@interface ImageDetailViewController ()

@property (nonatomic, weak, readonly) Image   * image;
@property (nonatomic, strong)         NSArray * categories;

@end

@implementation ImageDetailViewController
{
  __weak Image * _image;
}

+ (void)initialize {
  if (self == [ImageDetailViewController class]) {
    kCategoryCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    kPreviewCellIndexPath  = [NSIndexPath indexPathForRow:0 inSection:1];
  }
}

- (Class<Bankable>)itemClass { return [Image class]; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Aliased properties
////////////////////////////////////////////////////////////////////////////////

- (void)setItem:(NSManagedObject<Bankable> *)item {
  [super setItem:item];
  _image = (Image *)item;
}

- (Image *)image {
  if (!_image) _image = (Image *)self.item;

  return _image;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view data source
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 2; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return (section ? 1 : 3);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  BankableDetailTableViewCell * cell;

  switch (indexPath.section) {
    case 0:     // Info
    {
      switch (indexPath.row) {
        case 0:         // Category
        {
          cell = [self dequeueReusableCellWithIdentifier:TextFieldCellIdentifier
                                            forIndexPath:indexPath];
          cell.name = @"Category";
          cell.text = (self.image.category ?: @"Uncategorized");

          BankableChangeHandler changeHandler =
          ^{
            _image.category = cell.infoTextField.text;

            if (![_categories containsObject:_image.category]) _categories = nil;
          };

          [self registerTextField:cell.infoTextField
                     forIndexPath:indexPath
                         handlers:@{ BankableChangeHandlerKey : changeHandler }];

          [self registerPickerView:cell.pickerView forIndexPath:indexPath];

          break;
        }

        case 1:         // File name
        {
          cell = [self dequeueReusableCellWithIdentifier:LabelCellIdentifier
                                            forIndexPath:indexPath];
          cell.name = @"File";
          cell.text = self.image.fileName;

          break;
        }

        case 2:         // Size
        {
          cell = [self dequeueReusableCellWithIdentifier:LabelCellIdentifier
                                            forIndexPath:indexPath];
          cell.name = @"Size";
          cell.text = PrettySize(self.image.size);

          break;
        }
      }

      break;
    }

    case 1:     // Preview
    {
      cell = [self dequeueReusableCellWithIdentifier:ImageCellIdentifier
                                        forIndexPath:indexPath];
      UIImage * image = _image.preview;
      cell.image = image;

      CGSize imageSize  = image.size;
      CGSize boundsSize = cell.infoImageView.bounds.size;

      if (CGSizeContainsSize(boundsSize, imageSize))
        cell.infoImageView.contentMode = UIViewContentModeCenter;

      break;
    }

  }

  return cell;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view delegate
////////////////////////////////////////////////////////////////////////////////


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return ([indexPath isEqual:kPreviewCellIndexPath]
          ? BankableDetailPreviewRowHeight
          : ([indexPath isEqual:self.visiblePickerCellIndexPath]
             ? BankableDetailExpandedRowHeight
             : BankableDetailDefaultRowHeight));
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Managing picker views
////////////////////////////////////////////////////////////////////////////////


- (NSArray *)categories {
  if (!_categories) {
    NSManagedObjectContext * context = self.item.managedObjectContext;

    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"BankInfo"];
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

- (id)dataForIndexPath:(NSIndexPath *)indexPath type:(BankableDetailDataType)type {
  return (type == BankableDetailPickerViewData ? self.categories : self.image.category);
}

@end
