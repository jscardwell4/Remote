//
//  BankableDetailTableViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/24/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankableDetailTableViewController_Private.h"
#import "CoreDataManager.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

MSNAMETAG_DEFINITION(BankableDetailHiddenNeighborConstraint);

#define TextFieldNibName        @"BankableDetailTableViewCell-TextField"
#define LabelNibName            @"BankableDetailTableViewCell-Label"
#define ListNibName             @"BankableDetailTableViewCell-List"
#define DetailDisclosureNibName @"BankableDetailTableViewCell-DetailDisclosure"
#define ImageNibName            @"BankableDetailTableViewCell-Image"
#define TextViewNibName         @"BankableDetailTableViewCell-TextView"
#define StepperNibName          @"BankableDetailTableViewCell-Stepper"
#define SwitchNibName           @"BankableDetailTableViewCell-Switch"
#define ButtonNibName           @"BankableDetailTableViewCell-Button"
#define TableNibName            @"BankableDetailTableViewCell-Table"

MSIDENTIFIER_DEFINITION(StepperCell);
MSIDENTIFIER_DEFINITION(SwitchCell);
MSIDENTIFIER_DEFINITION(LabelCell);
MSIDENTIFIER_DEFINITION(LabelListCell);
MSIDENTIFIER_DEFINITION(ButtonCell);
MSIDENTIFIER_DEFINITION(ImageCell);
MSIDENTIFIER_DEFINITION(TextFieldCell);
MSIDENTIFIER_DEFINITION(TextViewCell);
MSIDENTIFIER_DEFINITION(TableCell);
MSIDENTIFIER_DEFINITION(DetailDisclosureCell);

MSKEY_DEFINITION(BankableChangeHandler);
MSKEY_DEFINITION(BankableValidationHandler);

const CGFloat BankableDetailDefaultRowHeight = 38;
const CGFloat BankableDetailExpandedRowHeight = 200;
const CGFloat BankableDetailPreviewRowHeight = 291;
const CGFloat BankableDetailTextViewRowHeight = 140;


NSString * textForSelection(id selection)
{
    if ([selection isKindOfClass:[NSString class]])
         return selection;

    else if ([selection respondsToSelector:@selector(name)])
        return [selection name];

    else
        return nil;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankableDetailTableViewController
////////////////////////////////////////////////////////////////////////////////


@implementation BankableDetailTableViewController
{
    NSMutableDictionary * _registeredNibs;
    NSHashTable         * _editableViews;

    MSDictionary * _steppersByIndexPath;
    MSDictionaryIndex   * _indexPathsByStepper;
    NSMutableDictionary * _stepperLabelsByIndexPath;

    MSDictionary * _pickersByIndexPath;
    MSDictionaryIndex   * _indexPathsByPicker;

    MSDictionary * _textFieldsByIndexPath;
    MSDictionaryIndex   * _indexPathsByTextField;
    NSMutableDictionary * _textFieldHandlersByIndexPath;
}

- (BOOL)hidesBottomBarWhenPushed { return YES; }

- (void)viewDidLoad
{
    [super viewDidLoad];

    // prepare navigation bar
    self.cancelBarButtonItem = SystemBarButton(UIBarButtonSystemItemCancel, @selector(cancel:));
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    if (self.item) [self updateDisplay];
}

- (void)updateDisplay
{
    self.nameTextField.text = self.item.name;
    self.editButtonItem.enabled = [self.item isEditable];
    [_textFieldsByIndexPath enumerateKeysAndObjectsUsingBlock:
     ^(NSIndexPath * indexPath, UITextField * textField, BOOL *stop)
     {
         textField.text = [self dataForIndexPath:indexPath type:BankableDetailTextFieldData];
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (![self isViewLoaded])
    {
        self.cancelBarButtonItem = nil;
        _registeredNibs = nil;
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    self.navigationItem.leftBarButtonItem = (editing
                                             ? SystemBarButton(UIBarButtonSystemItemCancel,
                                                               @selector(cancel:))
                                             : nil);

    [self.editableViews setValue:@(editing) forKeyPath:@"userInteractionEnabled"];


    [_steppersByIndexPath enumerateKeysAndObjectsUsingBlock:
     ^(NSIndexPath * indexPath, UIStepper * stepper, BOOL * stop)
     {
         UILabel * label = _stepperLabelsByIndexPath[indexPath];
         if (!editing)
             [self hideAnimationForView:stepper besideView:label];
         else
             [self revealAnimationForView:stepper besideView:label];
     }];

    if (!editing)
    {
        [self save:nil];
        self.visiblePickerCellIndexPath = nil;
    }

}

- (NSArray *)editableViews
{
    NSMutableArray * array = [@[_nameTextField] mutableCopy];

    if (_editableViews)
        [array addObjectsFromArray:[_editableViews allObjects]];

    if ([_textFieldsByIndexPath count])
        [array addObjectsFromArray:[_textFieldsByIndexPath allValues]];

    if ([_steppersByIndexPath count])
        [array addObjectsFromArray:[_steppersByIndexPath allValues]];

    return array;
}

- (void)registerEditableView:(UIView *)view
{
    if (!_editableViews)
        _editableViews = [NSHashTable weakObjectsHashTable];
    [_editableViews addObject:view];
}

- (BankableDetailTableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (BankableDetailTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
}

- (id)dataForIndexPath:(NSIndexPath *)indexPath type:(BankableDetailDataType)type { return nil; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Bankable detail delegate
////////////////////////////////////////////////////////////////////////////////


- (void)setItemClass:(Class<Bankable>)itemClass {}

- (Class<Bankable>)itemClass { return [NSManagedObject class]; }

- (void)editItem { assert(_item && [_item isEditable]); [self setEditing:YES animated:YES]; }

- (void)setItem:(NSManagedObject<Bankable> *)item
{
    assert([item conformsToProtocol:@protocol(Bankable)]);

    if ([item isKindOfClass:self.itemClass])
    {
       _item = item;
        if ([self isViewLoaded]) [self updateDisplay];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Animations
////////////////////////////////////////////////////////////////////////////////


- (void)revealAnimationForView:(UIView *)hiddenView besideView:(UIView *)neighborView
{
    assert(   hiddenView
           && neighborView
           && hiddenView.hidden);

    UIView * parentView = neighborView.superview;
    assert(parentView && [hiddenView isDescendantOfView:parentView]);

    NSLayoutConstraint * currentConstraint =
    [[parentView constraintsWithNametag:BankableDetailHiddenNeighborConstraintNametag]
     objectPassingTest:^BOOL(NSLayoutConstraint * obj, NSUInteger idx)
     {
         return [[@[neighborView,hiddenView] set]
                 isEqualToSet:[@[obj.firstItem,obj.secondItem] set]];
     }];

    assert(   currentConstraint
           && currentConstraint.relation == NSLayoutRelationEqual
           && (   currentConstraint.firstAttribute == NSLayoutAttributeTrailing
               && currentConstraint.secondAttribute == NSLayoutAttributeTrailing));

    NSLayoutConstraint * newConstraint = [NSLayoutConstraint
                                          constraintWithItem:neighborView
                                          attribute:NSLayoutAttributeTrailing
                                          relatedBy:NSLayoutRelationEqual
                                          toItem:hiddenView
                                          attribute:NSLayoutAttributeLeading
                                          multiplier:1.0
                                          constant:-16.0];

    newConstraint.nametag = BankableDetailHiddenNeighborConstraintNametag;

    hiddenView.hidden = NO;
    [parentView removeConstraint:currentConstraint];
    [parentView addConstraint:newConstraint];
    [parentView layoutIfNeeded];
}

- (void)hideAnimationForView:(UIView *)hiddenView besideView:(UIView *)neighborView
{
    assert(   hiddenView
           && neighborView
           && !hiddenView.hidden);

    UIView * parentView = neighborView.superview;
    assert(parentView && [hiddenView isDescendantOfView:parentView]);

    NSLayoutConstraint * currentConstraint =
    [[parentView constraintsWithNametag:BankableDetailHiddenNeighborConstraintNametag]
     objectPassingTest:^BOOL(NSLayoutConstraint * obj, NSUInteger idx)
     {
         return [[@[neighborView,hiddenView] set]
                 isEqualToSet:[@[obj.firstItem,obj.secondItem] set]];
     }];

    assert(   currentConstraint
           && currentConstraint.relation == NSLayoutRelationEqual
           && (   (  currentConstraint.firstAttribute == NSLayoutAttributeTrailing
                   && currentConstraint.secondAttribute == NSLayoutAttributeLeading)
               || (  currentConstraint.firstAttribute == NSLayoutAttributeLeading
                   && currentConstraint.secondAttribute == NSLayoutAttributeTrailing)));

    NSLayoutConstraint * newConstraint = [NSLayoutConstraint
                                          constraintWithItem:neighborView
                                          attribute:NSLayoutAttributeTrailing
                                          relatedBy:NSLayoutRelationEqual
                                          toItem:hiddenView
                                          attribute:NSLayoutAttributeTrailing
                                          multiplier:1.0
                                          constant:0.0];

    newConstraint.nametag = BankableDetailHiddenNeighborConstraintNametag;

    hiddenView.hidden = YES;
    [parentView removeConstraint:currentConstraint];
    [parentView addConstraint:newConstraint];
    [parentView layoutIfNeeded];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Managing stepper/label pairs
////////////////////////////////////////////////////////////////////////////////

- (MSDictionary *)steppersByIndexPath
{
    if (!_steppersByIndexPath)
    {
        _steppersByIndexPath = [MSDictionary dictionary];
        _indexPathsByStepper = [MSDictionaryIndex
                                dictionaryIndexForDictionary:(MSDictionary *)_steppersByIndexPath
                                handler:^NSArray *(MSDictionary * dictionary, id key)
                                        {
                                            return @[NSValueWithObjectPointer(dictionary[key]), key];
                                        }
                                ];
        _stepperLabelsByIndexPath   = [@{} mutableCopy];
    }
    return _steppersByIndexPath;
}

- (void)registerStepper:(UIStepper *)stepper
              withLabel:(UILabel *)label
           forIndexPath:(NSIndexPath *)indexPath
{
    assert(stepper && label && indexPath);

    self.steppersByIndexPath[indexPath]    = stepper;
    _stepperLabelsByIndexPath[indexPath]   = label;
}

- (NSIndexPath *)indexPathForStepper:(UIStepper *)stepper
{
    return (stepper ? _indexPathsByStepper[NSValueWithObjectPointer(stepper)] : nil);
}

- (UIStepper *)stepperForIndexPath:(NSIndexPath *)indexPath
{
    return _steppersByIndexPath[indexPath];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Managing picker views
////////////////////////////////////////////////////////////////////////////////


- (MSDictionary *)pickersByIndexPath
{
    if (!_pickersByIndexPath)
    {
        _pickersByIndexPath = [MSDictionary dictionary];
        _indexPathsByPicker = [MSDictionaryIndex
                               dictionaryIndexForDictionary:(MSDictionary *)_pickersByIndexPath
                               handler:^NSArray *(MSDictionary * dictionary, id key)
                                       {
                                           return @[NSValueWithObjectPointer(dictionary[key]), key];
                                       }
                               ];

    }

    return _pickersByIndexPath;
}

- (UIPickerView *)pickerViewForIndexPath:(NSIndexPath *)indexPath
{
    return _pickersByIndexPath[indexPath];
}

- (NSIndexPath *)indexPathForPickerView:(UIPickerView *)pickerView
{
    return _indexPathsByPicker[NSValueWithObjectPointer(pickerView)];
}

- (void)setVisiblePickerCellIndexPath:(NSIndexPath *)visiblePickerCellIndexPath
{
    [self.tableView beginUpdates];
    if (_visiblePickerCellIndexPath)
    {
        [_pickersByIndexPath[_visiblePickerCellIndexPath] setHidden:YES];
    }
    _visiblePickerCellIndexPath = ([_visiblePickerCellIndexPath isEqual:visiblePickerCellIndexPath]
                                   ? nil
                                   : visiblePickerCellIndexPath);

    if (_visiblePickerCellIndexPath)
    {
        UIPickerView * pickerView = self.pickersByIndexPath[_visiblePickerCellIndexPath];
        assert(pickerView);

        [pickerView reloadAllComponents];

        NSUInteger row = 0;

        id object = [self dataForIndexPath:_visiblePickerCellIndexPath
                                      type:BankableDetailPickerViewSelection];

        if (object)
        {
            NSUInteger idx = [[self dataForIndexPath:_visiblePickerCellIndexPath
                                                type:BankableDetailPickerViewData]
                              indexOfObject:object];

            if (idx != NSNotFound) row = idx;
        }

        [pickerView selectRow:row inComponent:0 animated:NO];

        pickerView.hidden = NO;
    }
    [self.tableView endUpdates];
}

- (void)registerPickerView:(UIPickerView *)pickerView forIndexPath:(NSIndexPath *)indexPath
{
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.hidden = YES;
    self.pickersByIndexPath[indexPath] = pickerView;
}

- (void)pickerView:(UIPickerView *)pickerView
   didSelectObject:(id)selection
               row:(NSUInteger)row
         indexPath:(NSIndexPath *)indexPath
{
    UITextField * textField = [self textFieldForIndexPath:indexPath];
    if (textField)
    {
        textField.text = textForSelection(selection);
        if ([textField isFirstResponder])
            [textField resignFirstResponder];
        return;
    }

    self.visiblePickerCellIndexPath = nil;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Picker view data source
////////////////////////////////////////////////////////////////////////////////


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView { return 1; }

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSIndexPath * indexPath = [self indexPathForPickerView:pickerView];
    return (indexPath ? [[self dataForIndexPath:indexPath
                                           type:BankableDetailPickerViewData] count] : 0);
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    NSIndexPath * indexPath = [self indexPathForPickerView:pickerView];
    NSArray * data = [self dataForIndexPath:indexPath type:BankableDetailPickerViewData];
    return (data ? textForSelection(data[row]) : nil);
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Picker view delegate
////////////////////////////////////////////////////////////////////////////////

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    NSIndexPath * indexPath = [self indexPathForPickerView:pickerView];
    assert(indexPath);

    id dataObject = [self dataForIndexPath:indexPath type:BankableDetailPickerViewData][row];
    assert(dataObject);

    [self pickerView:pickerView didSelectObject:dataObject row:row indexPath:indexPath];
    self.visiblePickerCellIndexPath = nil;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Actions
////////////////////////////////////////////////////////////////////////////////

- (IBAction)cancel:(id)sender
{
    NSManagedObjectContext * moc = _item.managedObjectContext;
    [moc performBlockAndWait:^{ [moc rollback]; }];
    [self setEditing:NO animated:YES];
    [self.tableView reloadData];
}

- (IBAction)save:(id)sender
{
    NSManagedObjectContext * moc = _item.managedObjectContext;
    [moc performBlockAndWait:
     ^{
         NSError * error = nil;
         [moc save:&error];
         MSHandleErrors(error);
     }];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Managing text fields
////////////////////////////////////////////////////////////////////////////////

- (MSDictionary *)textFieldsByIndexPath
{
    if (!_textFieldsByIndexPath)
    {
        _textFieldsByIndexPath = [MSDictionary dictionary];
        _indexPathsByTextField = [MSDictionaryIndex
                                  dictionaryIndexForDictionary:(MSDictionary *)_textFieldsByIndexPath
                                  handler:^NSArray *(MSDictionary * dictionary, id key)
                                      {
                                          return @[NSValueWithObjectPointer(dictionary[key]), key];
                                      }
                                  ];
        _textFieldHandlersByIndexPath = [@{} mutableCopy];
    }

    return _textFieldsByIndexPath;
}

- (void)registerTextField:(UITextField *)textField
             forIndexPath:(NSIndexPath *)indexPath
                  handlers:(NSDictionary *)handlers
{
    assert(textField && indexPath);
    textField.delegate = self;
    self.textFieldsByIndexPath[indexPath] = textField;
    if (handlers) _textFieldHandlersByIndexPath[indexPath] = handlers;
}

- (UITextField *)textFieldForIndexPath:(NSIndexPath *)indexPath
{
    return _textFieldsByIndexPath[indexPath];
}

- (NSIndexPath *)indexPathForTextField:(UITextField *)textField
{
    return _indexPathsByTextField[NSValueWithObjectPointer(textField)];
}

- (UIView *)integerKeyboardViewForTextField:(UITextField *)textField
{
    assert(textField);
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];

    NSDictionary * index = @{ @0:@"1",      @1:@"2",    @2:@"3",
                              @3:@"4",      @4:@"5",    @5:@"6",
                              @6:@"7",      @7:@"8",    @8:@"9",
                              @9:@"Erase",  @10: @"0",  @11: @"Done" };

    for (NSUInteger i = 0; i < 12; i++)
    {
        UIButton * b = [UIButton buttonWithType:UIButtonTypeCustom];
        PrepConstraints(b);

        if (i < 11)
        {
            NSString * imageName = $(@"IntegerKeyboard_%@.png", index[@(i)]);
            UIImage * image = [UIImage imageNamed:imageName];
            [b setImage:image forState:UIControlStateNormal];
            imageName = $(@"IntegerKeyboard_%@-Highlighted.png", index[@(i)]);
            image = [UIImage imageNamed:imageName];
            [b setImage:image forState:UIControlStateHighlighted];
        }

        else
        {
            [b setBackgroundColor:UIColorMake(0, 122/255.0, 1, 1)];
            [b setTitle:@"Done" forState:UIControlStateNormal];
            [b setTitleColor:WhiteColor forState:UIControlStateNormal];
        }

        void (^actionBlock)(void) = (i == 9
                                     ? ^{textField.text =
                                         [textField.text
                                          substringToIndex:textField.text.length - 1];}
                                     : (i == 11
                                        ? ^{[textField resignFirstResponder];}
                                        : ^{[textField insertText:index[@(i)]];}));
        [b addActionBlock:actionBlock forControlEvents:UIControlEventTouchUpInside];

        ConstrainHeight(b, (i < 3 ? 54 : 53.5));
        ConstrainWidth(b, (i % 3 && (i + 1) % 3 ? 110 : 104.5));
        [view addSubview:b];

        if (i < 3) AlignViewTop(view, b, 0);
        else if ( i > 8) AlignViewBottom(view, b, 0);

        if (i % 3 == 0) AlignViewLeft(view, b, 0);
        else if ((i + 1) % 3 == 0) AlignViewRight(view, b, 0);
        else CenterViewH(view, b, 0);

        if (i >= 3 && i <= 5) CenterViewV(view, b, -26.75);
        else if (i >= 6 && i <= 8) CenterViewV(view, b, 27.25);
    }
    
    return view;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Text field delegate
////////////////////////////////////////////////////////////////////////////////

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField { return [self isEditing]; }

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField selectAll:nil];

    NSIndexPath * indexPath = [self indexPathForTextField:textField];

    if (indexPath)
        self.visiblePickerCellIndexPath = ([self pickerViewForIndexPath:indexPath]
                                           ? indexPath
                                           : nil);
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _nameTextField)
    {
        if (textField.text.length) self.item.name = textField.text;
        return;
    }

    NSIndexPath * indexPath = [self indexPathForTextField:textField];
    if (!indexPath) return;

    NSDictionary * handlers = _textFieldHandlersByIndexPath[indexPath];

    // validation handled in textFieldShouldEndEditing:
    BankableChangeHandler handler = handlers[BankableChangeHandlerKey];
    if (handler) handler();

    self.visiblePickerCellIndexPath = nil;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSIndexPath * indexPath = [self indexPathForTextField:textField];
    if (!indexPath) return YES;

    NSDictionary * handlers = _textFieldHandlersByIndexPath[indexPath];
    if (!handlers) return YES;

    BankableValidationHandler handler = handlers[BankableValidationHandlerKey];
    if (!handler) return YES;

    return handler();
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {[textField resignFirstResponder]; return NO;}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Text view delegate
////////////////////////////////////////////////////////////////////////////////


- (BOOL)           textView:(UITextView *)textView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text
{
    return YES;
}

- (BOOL)                    textView:(UITextView *)textView
    shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment
                             inRange:(NSRange)characterRange
{
    return NO;
}

- (BOOL)         textView:(UITextView *)textView
    shouldInteractWithURL:(NSURL *)URL
                  inRange:(NSRange)characterRange
{
    return NO;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {}

- (void)textViewDidChange:(UITextView *)textView {}

- (void)textViewDidChangeSelection:(UITextView *)textView {}

- (void)textViewDidEndEditing:(UITextView *)textView {}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView { return YES; }

- (BOOL)textViewShouldEndEditing:(UITextView *)textView { return YES; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view data source
////////////////////////////////////////////////////////////////////////////////


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view delegate
////////////////////////////////////////////////////////////////////////////////


- (void)       tableView:(UITableView *)tableView
    didEndDisplayingCell:(UITableViewCell *)cell
       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_pickersByIndexPath[indexPath])
        [_pickersByIndexPath removeObjectForKey:indexPath];

    if (_textFieldsByIndexPath[indexPath])
    {
        [_textFieldsByIndexPath removeObjectForKey:indexPath];
        if (_textFieldHandlersByIndexPath[indexPath])
            [_textFieldHandlersByIndexPath removeObjectForKey:indexPath];
    }

    if (_steppersByIndexPath[indexPath])
    {
        [_steppersByIndexPath removeObjectForKey:indexPath];
        [_stepperLabelsByIndexPath removeObjectForKey:indexPath];
    }

}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Nibs
////////////////////////////////////////////////////////////////////////////////


- (UINib *)nibForIdentifier:(NSString *)identifier
{
    static const NSDictionary * nibNameIndex = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        nibNameIndex = @{TextFieldCellIdentifier        : TextFieldNibName,
                         LabelCellIdentifier            : LabelNibName,
                         LabelListCellIdentifier        : ListNibName,
                         DetailDisclosureCellIdentifier : DetailDisclosureNibName,
                         ImageCellIdentifier            : ImageNibName,
                         TextViewCellIdentifier         : TextViewNibName,
                         StepperCellIdentifier          : StepperNibName,
                         SwitchCellIdentifier           : SwitchNibName,
                         ButtonCellIdentifier           : ButtonNibName,
                         TableCellIdentifier            : TableNibName};
    });
    NSString * nibName = nibNameIndex[identifier];
    UINib * nib = [UINib nibWithNibName:nibName bundle:nil];
    return nib;
}

- (BankableDetailTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
                                                      forIndexPath:(NSIndexPath *)indexPath
{

    if (!self.registeredNibs[identifier])
    {
        UINib * nib = [self nibForIdentifier:identifier];
        [self.tableView registerNib:nib forCellReuseIdentifier:identifier];
        _registeredNibs[identifier] = nib;
    }

    return [self.tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
}

- (NSMutableDictionary *)registeredNibs
{
    if (!_registeredNibs) _registeredNibs = [@{} mutableCopy];

    return _registeredNibs;
}

@end

