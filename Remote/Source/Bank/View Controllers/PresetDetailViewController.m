//
//  PresetDetailViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/22/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankableDetailTableViewController_Private.h"
#import "PresetDetailViewController.h"
#import "Preset.h"
#import "RETypedefs.h"
#import "CoreDataManager.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

static NSIndexPath * kCategoryCellIndexPath;
static NSIndexPath * kPreviewCellIndexPath;


@interface PresetDetailViewController ()

@property (nonatomic, weak, readonly) Preset  * preset;
@property (nonatomic, strong)         NSArray * categories;

@end

@implementation PresetDetailViewController
{
    __weak Preset * _preset;
}

+ (void)initialize
{
    if (self == [PresetDetailViewController class])
    {
        kCategoryCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        kPreviewCellIndexPath  = [NSIndexPath indexPathForRow:0 inSection:1];
    }
}

- (Class<Bankable>)itemClass { return [Preset class]; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Aliased properties
////////////////////////////////////////////////////////////////////////////////

- (void)setItem:(NSManagedObject<Bankable> *)item
{
    [super setItem:item];
    _preset = (Preset *)item;
}

- (Preset *)preset { if (!_preset) _preset = (Preset *)self.item; return _preset; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view data source
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 2; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section ? 1 : 2);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BankableDetailTableViewCell * cell;

    switch (indexPath.section)
    {
        case 0:  // Info
        {
            switch (indexPath.row)
            {
                case 0:  // Category
                {
                    cell = [self dequeueReusableCellWithIdentifier:TextFieldCellIdentifier
                                                      forIndexPath:indexPath];
                    cell.name = @"Category";
                    cell.text = (_preset.category ?: @"Uncategorized");
                    BankableChangeHandler change =
                    ^{
                        NSString * text = cell.text;

                        _preset.category = (text.length ? text : nil);

                        if (![_categories containsObject:_preset.category]) _categories = nil;
                    };

                    [self registerTextField:cell.infoTextField
                               forIndexPath:indexPath
                                   handlers:@{ BankableChangeHandlerKey : change }];

                    [self registerPickerView:cell.pickerView forIndexPath:indexPath];

                    break;
                }

                case 1:  // Type
                {
                    cell = [self dequeueReusableCellWithIdentifier:LabelCellIdentifier
                                                      forIndexPath:indexPath];
                    cell.name = @"Type";
                    REType type = [[_preset valueForKeyPath:@"element.type"] intValue];
                    cell.text = NSStringFromREType(type);

                    break;
                }
            }

            break;
        }

        case 1:  // Preview
        {
            cell = [self dequeueReusableCellWithIdentifier:ImageCellIdentifier
                                              forIndexPath:indexPath];
            UIImage * image = _preset.preview;
            cell.image = image;

            CGSize imageSize = image.size;
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([indexPath isEqual:kPreviewCellIndexPath]
            ? BankableDetailPreviewRowHeight
            : ([indexPath isEqual:self.visiblePickerCellIndexPath]
               ? BankableDetailExpandedRowHeight
               : BankableDetailDefaultRowHeight));
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Managing picker views
////////////////////////////////////////////////////////////////////////////////


- (NSArray *)categories
{
    if (!_categories)
    {
        NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Preset"];
        [request setIncludesPendingChanges:YES];
        [request setResultType:NSDictionaryResultType];
        [request setReturnsDistinctResults:YES];
        [request setPropertiesToFetch:@[@"category"]];

        NSError * error = nil;
        NSArray * objects = [self.preset.managedObjectContext executeFetchRequest:request
                                                                            error:&error];
        NSMutableArray * categories = [[objects valueForKey:@"category"] mutableCopy];
        if (![categories containsObject:self.preset.category])
            [categories addObject:self.preset.category];
        [categories sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self"
                                                                         ascending:YES]]];

        if (!MSHandleErrors(error))
            self.categories = [@[@"Uncategorized"] arrayByAddingObjectsFromArray:categories];

        assert(!self.preset.category || [_categories containsObject:self.preset.category]);
    }

    return _categories;
}

- (id)dataForIndexPath:(NSIndexPath *)indexPath type:(BankableDetailDataType)type
{
    return (type == BankableDetailPickerViewData ? self.categories : self.preset.category);
}


@end
