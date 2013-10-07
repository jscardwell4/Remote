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


static NSIndexPath * kManufacturerIndexPath;
static NSIndexPath * kCodesetIndexPath;
static NSIndexPath * kFrequencyIndexPath;
static NSIndexPath * kRepeatIndexPath;
static NSIndexPath * kOffsetIndexPath;
static NSIndexPath * kOnOffPatternIndexPath;

@interface IRCodeDetailViewController ()

@property (nonatomic, weak) IBOutlet UITextView   * patternTextView;

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
        kManufacturerIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        kCodesetIndexPath      = [NSIndexPath indexPathForRow:1 inSection:0];
        kFrequencyIndexPath    = [NSIndexPath indexPathForRow:2 inSection:0];
        kRepeatIndexPath       = [NSIndexPath indexPathForRow:3 inSection:0];
        kOffsetIndexPath       = [NSIndexPath indexPathForRow:4 inSection:0];
        kOnOffPatternIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
    }
}

- (Class<Bankable>)itemClass { return [IRCode class]; }

- (void)updateDisplay
{
    [super updateDisplay];
    self.patternTextView.text = self.irCode.onOffPattern;
    UIButton * codesetButton = [self cellForRowAtIndexPath:kCodesetIndexPath].infoButton;
    if (codesetButton) codesetButton.enabled = (self.irCode.manufacturer != nil);
}

- (NSArray *)editableViews
{
    return [[super editableViews] arrayByAddingObjectsFromArray:@[_patternTextView]];
}

- (id)dataForIndexPath:(NSIndexPath *)indexPath type:(BankableDetailDataType)type
{
    switch (type)
    {
        case BankableDetailPickerViewData:
            return ([indexPath isEqual:kManufacturerIndexPath] ? self.manufacturers : self.codesets);

        case BankableDetailTextFieldData:
            return ([indexPath isEqual:kFrequencyIndexPath]
                    ? [@(self.irCode.frequency) description]
                    : [@(self.irCode.repeatCount) description]);

        case BankableDetailPickerButtonData:
            return ([indexPath isEqual:kManufacturerIndexPath]
                    ? (self.irCode.manufacturer ?: @"No Manufacturer")
                    : (self.irCode.codeset ?: @"No Codeset"));

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
                                [Manufacturer MR_findAllSortedBy:@"info.name"
                                                       ascending:YES
                                                       inContext:self.item.managedObjectContext],
                                @"➕ Create Manufacturer"] flattenedArray];
    }

    return _manufacturers;
}

- (NSArray *)codesets
{
    if (!_codesets)
    {
        NSArray * codesets = [[self.irCode.manufacturer.codesets allObjects]
                              sortedArrayUsingDescriptors:@[[NSSortDescriptor
                                                             sortDescriptorWithKey:@"name"
                                                             ascending:YES]]];
        self.codesets = [@[@"No Codeset", (codesets?:@[]), @"➕ Create Codeset"] flattenedArray];
    }
    return _codesets;
}

- (void)pickerView:(UIPickerView *)pickerView
   didSelectObject:(id)selection
               row:(NSUInteger)row
         indexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:kManufacturerIndexPath])
    {
        if (row == [_manufacturers lastIndex])
        {
            MSLogDebug(@"right now would be a good time to create a new manufacturer");
        }

        else if (selection != self.irCode.manufacturer)
        {
            self.irCode.manufacturer = ([selection isKindOfClass:[Manufacturer class]]
                                        ? selection
                                        : nil);
            UIButton * codesetButton = [self cellForRowAtIndexPath:kCodesetIndexPath].infoButton;
            [codesetButton setTitle:@"No Codeset" forState:UIControlStateNormal];
            _codesets = nil;
       }
    }

    else if ([indexPath isEqual:kCodesetIndexPath])
    {
        if (row == [_codesets lastIndex])
        {
            MSLogDebug(@"right now would be a good time to create a new codeset");
        }
        else
        {
            self.irCode.codeset = ([selection isKindOfClass:[IRCodeset class]]
                                   ? selection
                                   : nil);
        }
    }
    [super pickerView:pickerView didSelectObject:selection row:row indexPath:indexPath];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Aliased properties
////////////////////////////////////////////////////////////////////////////////

- (IRCode *)irCode { if (!_irCode) _irCode = (IRCode *)self.item; return _irCode; }

- (void)setPatternTextView:(UITextView *)patternTextView
{
    _patternTextView = patternTextView;
    _patternTextView.delegate = self;
    _patternTextView.text = self.irCode.onOffPattern;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view data source
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return 6; }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BankableDetailTableViewCell * cell = nil;
    __weak IRCodeDetailViewController * weakself = self;

    switch (indexPath.row)
    {
        case 0: // Manufacturer
        {
            cell = [self dequeueReusableCellWithIdentifier:ButtonCellIdentifier
                                              forIndexPath:indexPath];
            cell.nameLabel.text = @"Manufacturer";
            [cell.infoButton setTitle:([_irCode valueForKeyPath:@"manufacturer.name"]
                                       ?: @"No Manufacturer")
                             forState:UIControlStateNormal];
            void (^actionBlock)(void) = ^{
                id selection = (_irCode.manufacturer ?: @"No Manufacturer");
                [weakself showPickerViewForIndexPath:indexPath selectedObject:selection];
            };
            [cell.infoButton addActionBlock:actionBlock forControlEvents:UIControlEventTouchUpInside];
            [self registerEditableView:cell.infoButton];
        } break;

        case 1: // Codeset
        {
            cell = [self dequeueReusableCellWithIdentifier:ButtonCellIdentifier
                                              forIndexPath:indexPath];
            cell.nameLabel.text = @"Codeset";
            [cell.infoButton setTitle:([_irCode valueForKeyPath:@"codeset.name"]
                                       ?: @"No Codeset")
                             forState:UIControlStateNormal];
            void (^actionBlock)(void) = ^{
                id selection = (_irCode.codeset ?: @"No Codeset");
                [weakself showPickerViewForIndexPath:indexPath selectedObject:selection];
            };
            [cell.infoButton addActionBlock:actionBlock forControlEvents:UIControlEventTouchUpInside];
            [self registerEditableView:cell.infoButton];
        } break;

        case 2: // Frequency
        {
            cell = [self dequeueReusableCellWithIdentifier:TextFieldCellIdentifier
                                              forIndexPath:indexPath];
            cell.nameLabel.text = @"Frequency";
            cell.infoTextField.text = [@(_irCode.frequency) stringValue];
            cell.infoTextField.inputView = [self integerKeyboardViewForTextField:cell.infoTextField];
            BankableDetailTextFieldChangeHandler changeHandler = ^{
                _irCode.frequency = [cell.infoTextField.text longLongValue];
            };
            [self registerTextField:cell.infoTextField
                       forIndexPath:indexPath
                           handlers:@{BankableDetailTextFieldChangeHandlerKey: changeHandler}];
        } break;

        case 3: // Repeat
        {
            cell = [self dequeueReusableCellWithIdentifier:TextFieldCellIdentifier
                                              forIndexPath:indexPath];
            cell.nameLabel.text = @"Repeat";
            cell.infoTextField.text = [@(_irCode.repeatCount) stringValue];
            cell.infoTextField.inputView = [self integerKeyboardViewForTextField:cell.infoTextField];
            BankableDetailTextFieldChangeHandler changeHandler = ^{
                _irCode.repeatCount = [cell.infoTextField.text intValue];
            };
            [self registerTextField:cell.infoTextField
                       forIndexPath:indexPath
                           handlers:@{BankableDetailTextFieldChangeHandlerKey: changeHandler}];
        } break;

        case 4: // Offset
        {
            cell = [self dequeueReusableCellWithIdentifier:StepperCellIdentifier
                                              forIndexPath:indexPath];
            cell.nameLabel.text = @"Offset";
            cell.infoStepper.minimumValue = 0;
            cell.infoStepper.maximumValue = 127;
            cell.infoStepper.wraps = NO;
            cell.infoStepper.value = self.irCode.offset;
            cell.infoLabel.text = [@(self.irCode.offset) description];
            [cell.infoStepper addActionBlock:
             ^{
                 weakself.irCode.offset = (int16_t)cell.infoStepper.value;
                 cell.infoLabel.text = [@(cell.infoStepper.value) description];
             } forControlEvents:UIControlEventValueChanged];
            
            [self registerStepper:cell.infoStepper
                        withLabel:cell.infoLabel
                     forIndexPath:indexPath];
        } break;

        case 5: // On-Off Pattern
        {
            cell = [self dequeueReusableCellWithIdentifier:TextViewCellIdentifier
                                              forIndexPath:indexPath];
            cell.nameLabel.text = @"On-Off Pattern";
            self.patternTextView = cell.infoTextView;
        } break;
    }

    return cell;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view delegate
////////////////////////////////////////////////////////////////////////////////


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([indexPath isEqual:kOnOffPatternIndexPath]
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
    if (textView == _patternTextView)
        self.irCode.onOffPattern = _patternTextView.text;

    else [super textViewDidEndEditing:textView];
}

- (BOOL)           textView:(UITextView *)textView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text
{
    if (textView == _patternTextView)
    {
        if (text.length && [text[0] isEqual:@('\n')])
        {
            [_patternTextView resignFirstResponder];
            return NO;
        }

        else return YES;
    }

    else return [super textView:textView shouldChangeTextInRange:range replacementText:text];
}

@end
