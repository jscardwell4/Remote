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
        case 0: // Info
        {
            switch (indexPath.row)
            {
                case 0: // Category
                {
                    cell = [self dequeueReusableCellWithIdentifier:TextFieldCellIdentifier
                                                      forIndexPath:indexPath];
                    cell.nameLabel.text = @"Category";
                    cell.infoTextField.text = (self.preset.category ?: @"Uncategorized");
                    BankableDetailTextFieldChangeHandler changeHandler = ^{
                        _preset.category = cell.infoTextField.text;
                        if (![_categories containsObject:_preset.category]) _categories = nil;
                    };
                    [self registerTextField:cell.infoTextField
                               forIndexPath:indexPath
                                   handlers:@{BankableDetailTextFieldChangeHandlerKey:changeHandler}];
                    [self registerPickerView:cell.pickerView forIndexPath:indexPath];
                } break;

                case 1: // Type
                {
                    cell = [self dequeueReusableCellWithIdentifier:LabelCellIdentifier
                                                      forIndexPath:indexPath];
                    cell.nameLabel.text = @"Type";
                    cell.infoLabel.text = NSStringFromREType([[self.preset
                                                               valueForKeyPath:@"element.type"]
                                                              intValue]);
                } break;
            }
        } break;

        case 1: // Preview
        {
            cell = [self dequeueReusableCellWithIdentifier:ImageCellIdentifier
                                              forIndexPath:indexPath];
            cell.infoImageView.image = self.preset.preview;
            if (CGSizeContainsSize(cell.infoImageView.bounds.size, cell.infoImageView.image.size))
                cell.infoImageView.contentMode = UIViewContentModeCenter;
        } break;

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
        [request setPropertiesToFetch:@[@"info.category"]];

        NSError * error = nil;
        NSArray * objects = [self.preset.managedObjectContext executeFetchRequest:request
                                                                            error:&error];
        NSMutableArray * categories = [[objects valueForKey:@"info.category"] mutableCopy];
        if (![categories containsObject:self.preset.category])
            [categories addObject:self.preset.category];
        [categories sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];

        if (error) [CoreDataManager handleErrors:error];
        else
            self.categories = [@[@"Uncategorized"] arrayByAddingObjectsFromArray:categories];

        assert(!self.preset.category || [_categories containsObject:self.preset.category]);
    }

    return _categories;
}

- (id)dataForIndexPath:(NSIndexPath *)indexPath type:(BankableDetailDataType)type
{
    return (type == BankableDetailPickerViewData ? self.categories : self.preset.category);
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Managing text fields
////////////////////////////////////////////////////////////////////////////////


- (void)textFieldForIndexPath:(NSIndexPath *)indexPath didSetText:(NSString *)text
{
    if ([indexPath isEqual:kCategoryCellIndexPath])
    {
        self.preset.category = text;
        if (![self.categories containsObject:text])
        {
            _categories = nil;
//            [self.preset.managedObjectContext processPendingChanges];
        }
    }
    [super textFieldForIndexPath:indexPath didSetText:text];
}

@end
