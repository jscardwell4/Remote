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


static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel, msLogContext)

#define kManufacturerCell       0
#define kCodesetCell            1
#define kOnOffPatternCell       5
#define kExpandedRowHeight      200
#define kDefaultRowHeight       38
#define kOnOffPatternCellHeight 140

@interface IRCodeDetailViewController () <UIPickerViewDataSource, UIPickerViewDelegate>


@property (nonatomic, strong) IBOutlet UITableViewCell * manufacturerCell;
@property (nonatomic, strong) IBOutlet UITableViewCell * codesetCell;
@property (nonatomic, strong) IBOutlet UITableViewCell * frequencyCell;
@property (nonatomic, strong) IBOutlet UITableViewCell * repeatCell;
@property (nonatomic, strong) IBOutlet UITableViewCell * offsetCell;
@property (nonatomic, strong) IBOutlet UITableViewCell * onOffPatternCell;
@property (nonatomic, strong)          NSArray         * cells;

@property (nonatomic, weak) IBOutlet UITextField  * frequencyTextField;
@property (nonatomic, weak) IBOutlet UITextField  * repeatTextField;
@property (nonatomic, weak) IBOutlet UILabel      * offsetLabel;
@property (nonatomic, weak) IBOutlet UIStepper    * offsetStepper;
@property (nonatomic, weak) IBOutlet UITextView   * patternTextView;
@property (nonatomic, weak) IBOutlet UIButton     * codesetButton;
@property (nonatomic, weak) IBOutlet UILabel      * codesetLabel;
@property (nonatomic, weak) IBOutlet UIButton     * manufacturerButton;
@property (nonatomic, weak) IBOutlet UIPickerView * codesetPickerView;
@property (nonatomic, weak) IBOutlet UIPickerView * manufacturerPickerView;

@property (nonatomic, readonly) IRCode       * irCode;
@property (nonatomic, strong)   NSArray      * manufacturers;
@property (nonatomic, strong)   NSArray      * codesets;
@property (nonatomic, strong)   Manufacturer * manufacturer;

@end

@implementation IRCodeDetailViewController
{
    NSInteger _expandedCell;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    _expandedCell = -1;
}

/*
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.cells = @[_manufacturerCell,
                   _codesetCell,
                   _frequencyCell,
                   _repeatCell,
                   _offsetCell,
                   _onOffPatternCell];
}
*/

- (IRCode *)irCode { return (IRCode *)self.item; }

- (void)setItem:(NSManagedObject<Bankable> *)item
{
    [super setItem:item];
    self.manufacturer = self.irCode.codeset.manufacturer;
}

+ (Class)itemClass { return [IRCode class]; }

- (void)setManufacturer:(Manufacturer *)manufacturer
{
    _manufacturer = manufacturer;
    if ([self isEditing]) _codesetButton.enabled = (_manufacturer ? YES : NO);
}

- (void)updateDisplay
{
    [super updateDisplay];

    NSString * text = (self.irCode.codeset ? self.irCode.codeset.name : @"No Codeset");
    [self.codesetButton setTitle:text forState:UIControlStateNormal];

    text = (self.manufacturer ? self.manufacturer.name : @"No Manufacturer");
    [self.manufacturerButton setTitle:text forState:UIControlStateNormal];

    self.frequencyTextField.text = [@(self.irCode.frequency) description];
    self.repeatTextField.text    = [@(self.irCode.repeatCount) description];
    self.offsetStepper.value     = self.irCode.offset;
    self.offsetLabel.text        = [@(_offsetStepper.value) description];
    self.patternTextView.text    = self.irCode.onOffPattern;
}

- (NSArray *)editableViews
{
    return [[super editableViews] arrayByAddingObjectsFromArray:@[_frequencyTextField,
                                                                  _repeatTextField,
                                                                  _offsetStepper,
                                                                  _patternTextView,
                                                                  _codesetButton,
                                                                  _manufacturerButton]];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    if (editing)
    {
        _codesetButton.enabled = (self.codesets ? YES : NO);
        [self revealAnimationForView:_offsetStepper besideView:_offsetLabel];
    }

    else
    {
        [self hideAnimationForView:_offsetStepper besideView:_offsetLabel];
        if (_expandedCell)
        {
            _expandedCell = -1;
            [self.tableView reloadData];
        }
    }
}

- (NSArray *)manufacturers
{
    if (!_manufacturers)
    {
        NSMutableArray * a = [[Manufacturer MR_findAllInContext:self.item.managedObjectContext] mutableCopy];
        [a insertObject:@"No Manufacturer" atIndex:0];
        [a addObject:@"➕ Create Manufacturer"];
        self.manufacturers = a;
    }

    return _manufacturers;
}

- (NSArray *)codesets
{
    if (!_codesets)
    {
        NSMutableArray * a = [[self.manufacturer.codesets allObjects] mutableCopy];
        [a insertObject:@"No Codeset" atIndex:0];
        [a addObject:@"➕ Create Codeset"];
        self.codesets = a;
    }
    return _codesets;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view data source
////////////////////////////////////////////////////////////////////////////////

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return _cells[indexPath.row];
//}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view delegate
////////////////////////////////////////////////////////////////////////////////


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row == _expandedCell
            ? kExpandedRowHeight
            : (indexPath.row == kOnOffPatternCell
               ? kOnOffPatternCellHeight
               : kDefaultRowHeight));
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Picker view data source
////////////////////////////////////////////////////////////////////////////////


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView { return 1; }

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return (pickerView == _codesetPickerView ? [self.codesets count] : [self.manufacturers count]);
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Picker view delegate
////////////////////////////////////////////////////////////////////////////////


- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    id item = (pickerView == _codesetPickerView ? self.codesets[row] : self.manufacturers[row]);
    if ([item isKindOfClass:[NSString class]]) return item;
    else return [item valueForKey:@"name"];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    if (pickerView == _manufacturerPickerView)
    {
        if (row == [_manufacturers lastIndex])
        {
            MSLogDebug(@"right now would be a good time to create a new manufacturer");
        }
        else
        {
            self.manufacturer = (row ? _manufacturers[row] : nil);
            NSString * title  = (_manufacturer ? _manufacturer.name : @"No Manufacturer");
            _codesets = nil;
            [_codesetPickerView reloadAllComponents];

            [_manufacturerButton setTitle:title forState:UIControlStateNormal];

            _expandedCell = -1;
            [self.tableView reloadData];
        }
    }

    else if (pickerView == _codesetPickerView)
    {
        if (row == [_codesets lastIndex])
        {
            MSLogDebug(@"right now would be a good time to create a new codeset");
        }
        else
        {
            IRCodeset * codeset = (row ? _codesets[row] : nil);
            NSString  * title   = (codeset ? codeset.name : @"No Codeset");

            self.irCode.codeset = codeset;
            [_codesetButton setTitle:title forState:UIControlStateNormal];

            _expandedCell = -1;
            [self.tableView reloadData];
        }
    }
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Actions
////////////////////////////////////////////////////////////////////////////////


- (IBAction)selectIRCodeset:(id)sender
{
    MSLogDebug(@"");
    _expandedCell = kCodesetCell;
    if (self.irCode.codeset)
    {
        NSUInteger idx = [self.codesets indexOfObject:self.irCode.codeset];
        [_codesetPickerView selectRow:idx inComponent:0 animated:NO];
    }
    [self.tableView reloadData];
}

- (IBAction)selectManufacturer:(id)sender
{
    MSLogDebug(@"");
    _expandedCell = kManufacturerCell;
    if (self.manufacturer)
    {
        NSUInteger idx = [self.manufacturers indexOfObject:self.manufacturer];
        [_manufacturerPickerView selectRow:idx inComponent:0 animated:NO];
    }
    [self.tableView reloadData];
}

- (IBAction)offsetValueDidChange:(UIStepper *)sender
{
    MSLogDebug(@"");
    self.irCode.offset = (int16_t)sender.value;
    _offsetLabel.text = [@(sender.value) description];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Text field delegate
////////////////////////////////////////////////////////////////////////////////


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _repeatTextField)
        self.irCode.repeatCount = [textField.text intValue];

    else if (textField == _frequencyTextField)
        self.irCode.frequency = [textField.text longLongValue];

    else
        [super textFieldDidEndEditing:textField];
    
}

@end
