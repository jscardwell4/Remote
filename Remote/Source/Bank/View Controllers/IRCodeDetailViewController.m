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


static int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel, msLogContext)


CellIndexPathDeclaration(Manufacturer);
CellIndexPathDeclaration(Codeset);
CellIndexPathDeclaration(Frequency);
CellIndexPathDeclaration(Repeat);
CellIndexPathDeclaration(Offset);
CellIndexPathDeclaration(OnOffPattern);

@interface IRCodeDetailViewController ()

@property (nonatomic, readonly) IRCode       * irCode;
@property (nonatomic, strong)   NSArray      * manufacturers;
@property (nonatomic, strong)   NSArray      * codesets;

@end

@implementation IRCodeDetailViewController
{
    __weak IRCode * _irCode;
}

+ (void)initialize
{
    if (self == [IRCodeDetailViewController class])
    {
        CellIndexPathDefinition(Manufacturer, 0, 0);
        CellIndexPathDefinition(Codeset,      1, 0);
        CellIndexPathDefinition(Frequency,    2, 0);
        CellIndexPathDefinition(Repeat,       3, 0);
        CellIndexPathDefinition(Offset,       4, 0);
        CellIndexPathDefinition(OnOffPattern, 5, 0);
    }
}

- (Class<BankableModel>)itemClass { return [IRCode class]; }

- (id)dataForIndexPath:(NSIndexPath *)indexPath type:(BankableDetailDataType)type
{
    switch (type)
    {
        case BankableDetailPickerViewData:
            return ([indexPath isEqual:ManufacturerCellIndexPath]
                    ? self.manufacturers
                    : self.codesets);

        case BankableDetailPickerViewSelection:
            return ([indexPath isEqual:ManufacturerCellIndexPath]
                    ? self.irCode.manufacturer
                    : self.irCode.codeset);

        case BankableDetailTextFieldData:
            return ([indexPath isEqual:FrequencyCellIndexPath]
                    ? [self.irCode.frequency stringValue]
                    : ([indexPath isEqual:RepeatCellIndexPath]
                       ? [self.irCode.repeatCount stringValue]
                       : ([indexPath isEqual:ManufacturerCellIndexPath]
                          ? ([self.irCode valueForKeyPath:@"manufacturer.name"]
                             ?: @"No Manufacturer")
                          : ([self.irCode valueForKeyPath:@"codeset"]
                             ?: @"No Codeset"))));

        default:
            return nil;
    }
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Managing picker views
////////////////////////////////////////////////////////////////////////////////


- (NSArray *)manufacturers
{
    if (!_manufacturers)
    {
        self.manufacturers = [@[@"No Manufacturer",
                                [Manufacturer findAllSortedBy:@"name"
                                                    ascending:YES
                                                    context:self.item.managedObjectContext]]
                              flattened];
    }

    return _manufacturers;
}

- (NSArray *)codesets
{
    if (!_codesets)
    {
        NSArray * sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:nil ascending:YES]];
        NSArray * codesets = [self.irCode.manufacturer.codesets
                              sortedArrayUsingDescriptors:sortDescriptors];
        self.codesets = [@[@"No Codeset", (codesets?:@[])] flattened];
    }
    return _codesets;
}

- (void)pickerView:(UIPickerView *)pickerView
   didSelectObject:(id)selection
               row:(NSUInteger)row
         indexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:ManufacturerCellIndexPath])
    {
        if (!row)
        {
            _irCode.manufacturer = nil;
            _codesets = nil;
            [self cellForRowAtIndexPath:ManufacturerCellIndexPath].text = @"No Manufacturer";
            [self cellForRowAtIndexPath:CodesetCellIndexPath].text = @"No Codeset";
        }

        else
        {
            assert([selection isKindOfClass:[Manufacturer class]]);

             if (selection != _irCode.manufacturer)
             {
                 [self cellForRowAtIndexPath:CodesetCellIndexPath].text = @"No Codeset";
                 _codesets = nil;
             }

            _irCode.manufacturer = selection;
            [self cellForRowAtIndexPath:ManufacturerCellIndexPath].text = _irCode.manufacturer.name;
       }
    }

    else if ([indexPath isEqual:CodesetCellIndexPath])
    {
        _irCode.codeset = (row ? selection : nil);
        [self cellForRowAtIndexPath:CodesetCellIndexPath].text = (row ? selection : @"No Codeset");
    }

    [super pickerView:pickerView didSelectObject:selection row:row indexPath:indexPath];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Aliased properties
////////////////////////////////////////////////////////////////////////////////

- (void)setItem:(BankableModelObject *)item
{
    [super setItem:item];
    _irCode = (IRCode *)item;
}

- (IRCode *)irCode { if (!_irCode) _irCode = (IRCode *)self.item; return _irCode; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view data source
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return 6; }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BankableDetailTableViewCell       * cell     = nil;
    __weak IRCodeDetailViewController * weakself = self;

    switch (indexPath.row)
    {
        case 0:  // Manufacturer
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:BankableDetailCellTextFieldStyleIdentifier
                                              forIndexPath:indexPath];
            cell.name = @"Manufacturer";
            cell.text = ([_irCode valueForKeyPath:@"manufacturer.name"] ? : @"No Manufacturer");

            BankableValidationHandler validationHandler =
            ^{
                return (BOOL)(cell.text && cell.text.length > 0);
            };

            BankableChangeHandler changeHandler =
            ^{
                NSString * text = cell.text;

                if ([@"No Manufacturer" isEqualToString:text])
                    _irCode.manufacturer = nil;

                else
                {
                    Manufacturer * manufacturer =
                    [_manufacturers objectPassingTest:
                     ^BOOL(id obj, NSUInteger idx)
                     {
                         return (   [obj isKindOfClass:[Manufacturer class]]
                                 && [[obj valueForKey:@"name"] isEqualToString:text]);
                     }];

                    if (!manufacturer)
                    {
                        manufacturer = [Manufacturer
                                        manufacturerWithName:text
                                                     context:_irCode.managedObjectContext];
                        _manufacturers = nil;
                    }
                    assert(manufacturer);

                    _irCode.manufacturer = manufacturer;
                }
            };

            [self registerTextField:cell.infoTextField
                       forIndexPath:indexPath
                           handlers:@{ BankableValidationHandlerKey : validationHandler,
                                       BankableChangeHandlerKey     : changeHandler }];

            [self registerPickerView:cell.pickerView forIndexPath:indexPath];


            break;
        }

        case 1:  // Codeset
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:BankableDetailCellTextFieldStyleIdentifier
                                              forIndexPath:indexPath];
            cell.name = @"Codeset";
            cell.text = (_irCode.codeset ? : @"No Codeset");

            BankableValidationHandler validationHandler =
            ^{
                return (BOOL)(cell.text && cell.text.length > 0);
            };

            BankableChangeHandler changeHandler =
            ^{
                NSString * text = cell.text;

                if ([@"No Codeset" isEqualToString:text])
                    _irCode.codeset = nil;

                else
                {
                    _irCode.codeset = text;
                    if (![_codesets containsObject:text])
                        _codesets = nil;
                }
            };

            [self registerTextField:cell.infoTextField
                       forIndexPath:indexPath
                           handlers:@{ BankableValidationHandlerKey : validationHandler,
                                       BankableChangeHandlerKey     : changeHandler }];

            [self registerPickerView:cell.pickerView forIndexPath:indexPath];


            break;
        }

        case 2:  // Frequency
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:BankableDetailCellTextFieldStyleIdentifier
                                              forIndexPath:indexPath];
            cell.name = @"Frequency";
            cell.text = [_irCode.frequency stringValue];

            cell.infoTextField.inputView = [self integerKeyboardViewForTextField:cell.infoTextField];
            BankableChangeHandler   changeHandler =
            ^{
                _irCode.frequency = @([cell.infoTextField.text longLongValue]);
            };

            [self registerTextField:cell.infoTextField
                       forIndexPath:indexPath
                           handlers:@{ BankableChangeHandlerKey : changeHandler }];
            break;
        }

        case 3:  // Repeat
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:BankableDetailCellTextFieldStyleIdentifier
                                              forIndexPath:indexPath];
            cell.name = @"Repeat";
            cell.text = [_irCode.repeatCount stringValue];
            cell.infoTextField.inputView = [self integerKeyboardViewForTextField:cell.infoTextField];
            BankableChangeHandler   changeHandler =
            ^{
                _irCode.repeatCount = @([cell.infoTextField.text intValue]);
            };
            [self registerTextField:cell.infoTextField
                       forIndexPath:indexPath
                           handlers:@{ BankableChangeHandlerKey : changeHandler }];
            break;
        }

        case 4:  // Offset
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:BankableDetailCellStepperStyleIdentifier
                                              forIndexPath:indexPath];
            cell.nameLabel.text           = @"Offset";
            cell.infoStepper.minimumValue = 0;
            cell.infoStepper.maximumValue = 127;
            cell.infoStepper.wraps        = NO;
            cell.infoStepper.value        = self.irCode.offset.intValue;
            cell.infoLabel.text           = [self.irCode.offset stringValue];
            [cell.infoStepper addActionBlock:
             ^{
                 weakself.irCode.offset = @(cell.infoStepper.value);
                 cell.infoLabel.text = [@(cell.infoStepper.value) stringValue];
             }              forControlEvents:UIControlEventValueChanged];

            [self registerStepper:cell.infoStepper
                        withLabel:cell.infoLabel
                     forIndexPath:indexPath];
            break;
        }

        case 5:  // On-Off Pattern
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:BankableDetailCellTextViewStyleIdentifier
                                              forIndexPath:indexPath];
            cell.name = @"On-Off Pattern";
            cell.text = _irCode.onOffPattern;
            cell.infoTextView.delegate = self;
            [self registerEditableView:cell.infoTextView];

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
    return ([indexPath isEqual:OnOffPatternCellIndexPath]
            ? BankableDetailTextViewRowHeight
            : ([self.visiblePickerCellIndexPath isEqual:indexPath]
               ? BankableDetailExpandedRowHeight
               : BankableDetailDefaultRowHeight));
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Text view delegate
////////////////////////////////////////////////////////////////////////////////

- (void)textViewDidEndEditing:(UITextView *)textView
{
    _irCode.onOffPattern = textView.text;
}

- (BOOL)           textView:(UITextView *)textView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text
{
    if (text.length && [text[0] isEqual:@('\n')])
    {
        [textView resignFirstResponder];
        return NO;
    }

    else return YES;
}

@end
