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

#define kCategoryCell      0
#define kExpandedRowHeight 200
#define kDefaultRowHeight  38
#define kImageCellHeight   291

//NS_ENUM(NSInteger, CellRow)
//{
//    CategoryCellRow = 0,
//    TypeCellRow     = 1,
//    ImageCellRow    = 0
//};

@interface PresetDetailViewController ()

@property (weak, nonatomic) UITextField     * categoryTextField;
@property (strong, nonatomic) UIPickerView    * pickerView;

@property (nonatomic, weak, readonly) Preset  * preset;
@property (nonatomic, strong)         NSArray * categories;

@end

@implementation PresetDetailViewController
{
    NSInteger _expandedCell;
    BOOL      _categorySelected;
    BOOL      _expansionInProgress;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    _expandedCell = -1;  
}

- (Preset *)preset { return (Preset *)self.item; }

+ (Class)itemClass { return [Preset class]; }

- (NSArray *)editableViews
{
    assert(_categoryTextField);
    return [[super editableViews] arrayByAddingObjectsFromArray:@[_categoryTextField]];
}

- (NSArray *)categories
{
    if (!_categories)
    {
        NSManagedObjectContext *context = self.item.managedObjectContext;

        NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"BankInfo"];
        [request setResultType:NSDictionaryResultType];
        [request setReturnsDistinctResults:YES];
        [request setPropertiesToFetch:@[@"category"]];
        [request setPredicate:[NSPredicate predicateWithFormat:@"preset != nil"]];

        NSError *error = nil;
        NSArray *objects = [context executeFetchRequest:request error:&error];
        if (error) [CoreDataManager handleErrors:error];
        else
            self.categories = [objects valueForKeyPath:@"category"];
    }

    return _categories;
}


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
        case 1:
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:ImageCellIdentifier
                                                        forIndexPath:indexPath];
            cell.imageView.image = self.preset.preview;
            if (CGSizeContainsSize(cell.imageView.bounds.size, cell.imageView.image.size))
                cell.imageView.contentMode = UIViewContentModeCenter;
        } break;

        case 0:
        {
            switch (indexPath.row)
            {
                case 1:
                {
                    cell = [self.tableView dequeueReusableCellWithIdentifier:LabelCellIdentifier
                                                                forIndexPath:indexPath];
                    cell.nameLabel.text = @"Type";
                    REType type = [[self.preset valueForKeyPath:@"element.type"] intValue];
                    cell.infoLabel.text = NSStringFromREType(type);

                } break;
                    
                case 0:
                {
                    cell = [self.tableView dequeueReusableCellWithIdentifier:TextFieldCellIdentifier
                                                                forIndexPath:indexPath];
                    cell.nameLabel.text = @"Category";
                    cell.infoTextField.text = self.preset.category;
                    cell.infoTextField.delegate = self;
                    self.categoryTextField = cell.infoTextField;
                } break;
            }
        } break;
    }

    return cell;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view delegate
////////////////////////////////////////////////////////////////////////////////



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 1:
            return kImageCellHeight;

        default:
            return (indexPath.row == _expandedCell
                    ? kExpandedRowHeight
                    : kDefaultRowHeight);
    }
}



////////////////////////////////////////////////////////////////////////////////
#pragma mark Text field delegate
////////////////////////////////////////////////////////////////////////////////

/*
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL shouldBeginEditing = [super textFieldShouldBeginEditing:textField];
    if (shouldBeginEditing && textField == _categoryTextField)
    {
        _expandedCell = kCategoryCell;
        [self.tableView reloadData];
    }

    return shouldBeginEditing;
}
*/

/*
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return NO;
}
*/

/*
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [super textFieldDidBeginEditing:textField];

    if (textField == _categoryTextField && !_expansionInProgress)
    {
        _expandedCell = kCategoryCell;
        _expansionInProgress = YES;
        [self.tableView reloadData];
    }
}
*/


//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
    //    if (textField == _categoryTextField)
    //    {
/*

        if (_categorySelected)
            _categorySelected = NO;

        else
        {
            NSString * category = textField.text;
            self.preset.category = category;
            if (![self.categories containsObject:category])
            {
                self.categories = [_categories arrayByAddingObject:category];
                [self.pickerView reloadAllComponents];
            }

            [self.pickerView selectRow:[self.categories indexOfObject:category]
                           inComponent:0
                              animated:YES];
            _expandedCell = -1;
            [self.tableView reloadData];
        }
*/
    //  }

    // else
//        [super textFieldDidEndEditing:textField];
//}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Picker view data source
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView { return 1; }

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.categories count];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Picker view delegate
////////////////////////////////////////////////////////////////////////////////

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return self.categories[row];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    NSString * category = self.categories[row];
    _categorySelected = YES;
    [self.categoryTextField resignFirstResponder];
    self.categoryTextField.text = category;
    self.preset.category = category;
    _expandedCell = -1;
    [self.tableView reloadData];
}


@end
