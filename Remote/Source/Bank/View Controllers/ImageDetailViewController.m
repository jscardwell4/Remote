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

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

#define kCategoryCell      2
#define kExpandedRowHeight 200
#define kDefaultRowHeight  38
#define kImageCellHeight   291

@interface ImageDetailViewController () <UIPickerViewDataSource, UIPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField  * categoryTextField;
@property (weak, nonatomic) IBOutlet UIPickerView * pickerView;

@property (nonatomic, weak, readonly) Image   * image;
@property (nonatomic, strong)         NSArray * categories;

@end

@implementation ImageDetailViewController
{
    NSInteger _expandedCell;
    BOOL      _categorySelected;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    _expandedCell = -1;
}

- (Image *)image { return (Image *)self.item; }

+ (Class)itemClass { return [Image class]; }

- (NSArray *)editableViews
{
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
        [request setPredicate:[NSPredicate predicateWithFormat:@"image != nil"]];

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
            cell.imageView.image = self.image.preview;
            if (CGSizeContainsSize(cell.imageView.bounds.size, cell.imageView.image.size))
                cell.imageView.contentMode = UIViewContentModeCenter;
        } break;

        case 0:
        {
            switch (indexPath.row)
            {
                case 2:
                {
                    cell = [self.tableView dequeueReusableCellWithIdentifier:LabelCellIdentifier
                                                                forIndexPath:indexPath];
                    cell.nameLabel.text = @"Size";
                    cell.infoLabel.text = PrettySize(self.image.size);
                } break;

                case 1:
                {
                    cell = [self.tableView dequeueReusableCellWithIdentifier:LabelCellIdentifier
                                                                forIndexPath:indexPath];
                    cell.nameLabel.text = @"File";
                    cell.infoLabel.text = self.image.fileName;
                } break;

                case 0:
                {
                    cell = [self.tableView dequeueReusableCellWithIdentifier:TextFieldCellIdentifier
                                                                forIndexPath:indexPath];
                    cell.nameLabel.text = @"Category";
                    cell.infoTextField.text = self.image.category;
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
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [super textFieldDidBeginEditing:textField];

    if (textField == _categoryTextField)
    {
        _expandedCell = kCategoryCell;
        [self.tableView reloadData];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _categoryTextField)
    {
        if (_categorySelected)
            _categorySelected = NO;

        else
        {
            NSString * category = textField.text;
            self.image.category = category;
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
    }

    else
        [super textFieldDidEndEditing:textField];

}
*/



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
    self.image.category = category;
    _expandedCell = -1;
    [self.tableView reloadData];
}

@end
