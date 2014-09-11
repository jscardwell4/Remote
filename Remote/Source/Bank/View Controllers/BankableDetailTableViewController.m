//
//  BankableDetailTableViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/24/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankableDetailTableViewController_Private.h"
#import "CoreDataManager.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

MSNAMETAG_DEFINITION(BankableDetailHiddenNeighborConstraint);

MSKEY_DEFINITION(BankableChangeHandler);
MSKEY_DEFINITION(BankableValidationHandler);

const CGFloat BankableDetailDefaultRowHeight  = 38;
const CGFloat BankableDetailExpandedRowHeight = 200;
const CGFloat BankableDetailPreviewRowHeight  = 291;
const CGFloat BankableDetailTextViewRowHeight = 140;


NSString *textForSelection(id selection) {

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


@interface BankableDetailTableViewController ()

@property (nonatomic, strong) MSDictionary        * steppersByIndexPath;
@property (nonatomic, strong) MSDictionary        * indexPathsByStepper;
@property (nonatomic, strong) NSMutableDictionary * stepperLabelsByIndexPath;

@property (nonatomic, strong) MSDictionary        * pickersByIndexPath;
@property (nonatomic, strong) MSDictionary        * indexPathsByPicker;

@property (nonatomic, strong) MSDictionary        * textFieldsByIndexPath;
@property (nonatomic, strong) MSDictionary        * indexPathsByTextField;
@property (nonatomic, strong) NSMutableDictionary * textFieldHandlersByIndexPath;

@end

@implementation BankableDetailTableViewController {
  NSHashTable * _editableViews;
}


/// controllerWithItem:
/// @param item description
/// @return instancetype
+ (instancetype)controllerWithItem:(BankableModelObject *)item {
  return [self controllerWithItem:item editing:NO];
}

/// controllerWithItem:editing:
/// @param item description
/// @param isEditing description
/// @return instancetype
+ (instancetype)controllerWithItem:(BankableModelObject *)item editing:(BOOL)isEditing {
  return [[self alloc] initWithItem:item];
}

/// initWithItem:
/// @param item description
/// @return instancetype
- (instancetype)initWithItem:(BankableModelObject *)item {
  return [self initWithItem:item editing:NO];
}

/// initWithItem:editing:
/// @param item description
/// @param isEditing description
/// @return instancetype
- (instancetype)initWithItem:(BankableModelObject *)item  editing:(BOOL)isEditing {

  if ((self = [super init])) {

    self.item = item;
    self.editing = isEditing;

  }

  return self;

}

/// hidesBottomBarWhenPushed
/// @return BOOL
- (BOOL)hidesBottomBarWhenPushed { return YES; }

/// loadView
- (void)loadView {

  UITableView * tableView = [[UITableView alloc] initWithFrame:MainScreen.bounds
                                                         style:UITableViewStyleGrouped];
  tableView.rowHeight = 38.0;
  tableView.sectionHeaderHeight = 10.0;
  tableView.sectionFooterHeight = 10.0;
  tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  tableView.delegate = self;
  tableView.dataSource = self;
  [tableView registerClass:[BankableDetailTableViewCell class]
    forCellReuseIdentifier:BankableDetailCellLabelStyleIdentifier];
  [tableView registerClass:[BankableDetailTableViewCell class]
    forCellReuseIdentifier:BankableDetailCellListStyleIdentifier];
  [tableView registerClass:[BankableDetailTableViewCell class]
    forCellReuseIdentifier:BankableDetailCellButtonStyleIdentifier];
  [tableView registerClass:[BankableDetailTableViewCell class]
    forCellReuseIdentifier:BankableDetailCellImageStyleIdentifier];
  [tableView registerClass:[BankableDetailTableViewCell class]
    forCellReuseIdentifier:BankableDetailCellSwitchStyleIdentifier];
  [tableView registerClass:[BankableDetailTableViewCell class]
    forCellReuseIdentifier:BankableDetailCellStepperStyleIdentifier];
  [tableView registerClass:[BankableDetailTableViewCell class]
    forCellReuseIdentifier:BankableDetailCellDetailStyleIdentifier];
  [tableView registerClass:[BankableDetailTableViewCell class]
    forCellReuseIdentifier:BankableDetailCellTextViewStyleIdentifier];
  [tableView registerClass:[BankableDetailTableViewCell class]
    forCellReuseIdentifier:BankableDetailCellTextFieldStyleIdentifier];
  [tableView registerClass:[BankableDetailTableViewCell class]
    forCellReuseIdentifier:BankableDetailCellTableStyleIdentifier];
  assert(tableView.scrollEnabled);

  self.tableView = tableView;
  self.view = self.tableView;

}

/// navigationItem
/// @return UINavigationItem *
- (UINavigationItem *)navigationItem {

  UINavigationItem * item = [super navigationItem];

  // Check if we have initialized our navigation bar items
  if (!self.nameTextField) {

    UITextField * nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(70.0, 7.0, 180.0, 30.0)];
    nameTextField.placeholder = @"Name";
    nameTextField.font = [UIFont boldSystemFontOfSize:17.0];
    nameTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    nameTextField.adjustsFontSizeToFitWidth = YES;
    nameTextField.returnKeyType = UIReturnKeyDone;
    nameTextField.enablesReturnKeyAutomatically = YES;
    nameTextField.textAlignment = NSTextAlignmentCenter;
    nameTextField.delegate = self;
    if (self.item) nameTextField.text = self.item.name;

    item.titleView = nameTextField;
    self.nameTextField = nameTextField;

    self.cancelBarButtonItem = SystemBarButton(Cancel, @selector(cancel:));
    item.rightBarButtonItem  = self.editButtonItem;

  }


  return item;

}

/// viewDidLoad
- (void)viewDidLoad {

  [super viewDidLoad];

  if (self.item) [self updateDisplay];

}

/// updateDisplay
- (void)updateDisplay {

  self.nameTextField.text     = self.item.name;
  self.editButtonItem.enabled = [self.item isEditable];
  [_textFieldsByIndexPath enumerateKeysAndObjectsUsingBlock:
   ^(NSIndexPath * indexPath, UITextField * textField, BOOL * stop) {
     textField.text = [self dataForIndexPath:indexPath type:BankableDetailTextFieldData];
   }];

}

/// didReceiveMemoryWarning
- (void)didReceiveMemoryWarning {

  [super didReceiveMemoryWarning];

  if (![self isViewLoaded]) {

    self.cancelBarButtonItem = nil;

  }

}

/// setEditing:animated:
/// @param editing description
/// @param animated description
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {

  [super setEditing:editing animated:animated];

  self.navigationItem.leftBarButtonItem = (editing ? _cancelBarButtonItem : nil);

  [self.editableViews setValue:@(editing) forKeyPath:@"userInteractionEnabled"];


  __weak BankableDetailTableViewController * weakself = self;

  [_steppersByIndexPath enumerateKeysAndObjectsUsingBlock:
   ^(NSIndexPath * indexPath, UIStepper * stepper, BOOL * stop) {

     UILabel * label = _stepperLabelsByIndexPath[indexPath];

     if (!editing)
       [weakself hideAnimationForView:stepper besideView:label];

     else
       [weakself revealAnimationForView:stepper besideView:label];

   }];

  if (!editing) {

    [self save:nil];
    self.visiblePickerCellIndexPath = nil;

  }

}

/// editableViews
/// @return NSArray *
- (NSArray *)editableViews {

  NSMutableArray * array = [@[_nameTextField] mutableCopy];

  if (_editableViews)
    [array addObjectsFromArray:[_editableViews allObjects]];

  if ([_textFieldsByIndexPath count])
    [array addObjectsFromArray:[_textFieldsByIndexPath allValues]];

  if ([_steppersByIndexPath count])
    [array addObjectsFromArray:[_steppersByIndexPath allValues]];

  return array;

}

/// registerEditableView:
/// @param view description
- (void)registerEditableView:(UIView *)view {

  if (!_editableViews)
    _editableViews = [NSHashTable weakObjectsHashTable];

  [_editableViews addObject:view];

}

/// cellForRowAtIndexPath:
/// @param indexPath description
/// @return BankableDetailTableViewCell *
- (BankableDetailTableViewCell *)cellForRowAtIndexPath:(NSIndexPath const *)indexPath {
  return (BankableDetailTableViewCell *)[self.tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath];
}

/// dataForIndexPath:type:
/// @param indexPath description
/// @param type description
/// @return id
- (id)dataForIndexPath:(NSIndexPath *)indexPath type:(BankableDetailDataType)type { return nil; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Bankable detail delegate
////////////////////////////////////////////////////////////////////////////////


/// setItemClass:
/// @param itemClass description
- (void)setItemClass:(Class<BankableModel>)itemClass {}

/// itemClass
/// @return Class<Bankable>
- (Class<BankableModel>)itemClass { return [NSManagedObject class]; }

/// editItem
- (void)editItem { assert(_item && [_item isEditable]); [self setEditing:YES animated:YES]; }

/// setItem:
/// @param item description
- (void)setItem:(BankableModelObject *)item {

  if (![item isKindOfClass:self.itemClass])
    ThrowInvalidArgument(item, "object is of the wrong class for this controller");

  _item = item;

  if ([self isViewLoaded]) [self updateDisplay];

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Animations
////////////////////////////////////////////////////////////////////////////////


/// revealAnimationForView:besideView:
/// @param hiddenView description
/// @param neighborView description
- (void)revealAnimationForView:(UIView *)hiddenView besideView:(UIView *)neighborView {

  assert(  hiddenView
        && neighborView
        && hiddenView.hidden);

  UIView * parentView = neighborView.superview;
  assert(parentView && [hiddenView isDescendantOfView:parentView]);

  NSLayoutConstraint * currentConstraint =
    [[parentView constraintsWithNametag:BankableDetailHiddenNeighborConstraintNametag]
     objectPassingTest:^BOOL (NSLayoutConstraint * obj, NSUInteger idx) {
       return [[@[neighborView, hiddenView] set] isEqualToSet:[@[obj.firstItem, obj.secondItem] set]];
     }];

  //TODO: Fix this, it is broken
  assert(  currentConstraint
        && currentConstraint.relation == NSLayoutRelationEqual
        && (  currentConstraint.firstAttribute == NSLayoutAttributeTrailing
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

/// hideAnimationForView:besideView:
/// @param hiddenView description
/// @param neighborView description
- (void)hideAnimationForView:(UIView *)hiddenView besideView:(UIView *)neighborView {

  assert(  hiddenView
        && neighborView
        && !hiddenView.hidden);

  UIView * parentView = neighborView.superview;
  assert(parentView && [hiddenView isDescendantOfView:parentView]);

  NSLayoutConstraint * currentConstraint =
    [[parentView constraintsWithNametag:BankableDetailHiddenNeighborConstraintNametag]
     objectPassingTest:^BOOL (NSLayoutConstraint * obj, NSUInteger idx)
  {

    return [[@[neighborView, hiddenView] set]
            isEqualToSet:[@[obj.firstItem, obj.secondItem] set]];
  }];

  assert(  currentConstraint
        && currentConstraint.relation == NSLayoutRelationEqual
        && (  (  currentConstraint.firstAttribute == NSLayoutAttributeTrailing
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

/// steppersByIndexPath
/// @return MSDictionary *
- (MSDictionary *)steppersByIndexPath {

  if (!_steppersByIndexPath) {

    _steppersByIndexPath = [MSDictionary dictionary];
    _indexPathsByStepper = [MSDictionary dictionary];
    _stepperLabelsByIndexPath = [@{} mutableCopy];
  }

  return _steppersByIndexPath;

}

/// registerStepper:withLabel:forIndexPath:
/// @param stepper description
/// @param label description
/// @param indexPath description
- (void)registerStepper:(UIStepper *)stepper
              withLabel:(UILabel *)label
           forIndexPath:(NSIndexPath *)indexPath
{

  assert(stepper && label && indexPath);

  self.steppersByIndexPath[indexPath]  = stepper;
  _stepperLabelsByIndexPath[indexPath] = label;
  _indexPathsByStepper[NSValueWithObjectPointer(stepper)] = indexPath;

}

/// indexPathForStepper:
/// @param stepper description
/// @return NSIndexPath *
- (NSIndexPath *)indexPathForStepper:(UIStepper *)stepper {
  return (stepper ? _indexPathsByStepper[NSValueWithObjectPointer(stepper)] : nil);
}

/// stepperForIndexPath:
/// @param indexPath description
/// @return UIStepper *
- (UIStepper *)stepperForIndexPath:(NSIndexPath *)indexPath {
  return _steppersByIndexPath[indexPath];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Managing picker views
////////////////////////////////////////////////////////////////////////////////


/// pickersByIndexPath
/// @return MSDictionary *
- (MSDictionary *)pickersByIndexPath {

  if (!_pickersByIndexPath) {

    _pickersByIndexPath = [MSDictionary dictionary];
    _indexPathsByPicker = [MSDictionary dictionary];
  }

  return _pickersByIndexPath;

}

/// pickerViewForIndexPath:
/// @param indexPath description
/// @return UIPickerView *
- (UIPickerView *)pickerViewForIndexPath:(NSIndexPath *)indexPath {
  return _pickersByIndexPath[indexPath];
}

/// indexPathForPickerView:
/// @param pickerView description
/// @return NSIndexPath *
- (NSIndexPath *)indexPathForPickerView:(UIPickerView *)pickerView {
  return _indexPathsByPicker[NSValueWithObjectPointer(pickerView)];
}

/// setVisiblePickerCellIndexPath:
/// @param visiblePickerCellIndexPath description
- (void)setVisiblePickerCellIndexPath:(NSIndexPath *)visiblePickerCellIndexPath {

  [self.tableView beginUpdates];

  if (_visiblePickerCellIndexPath)
    [_pickersByIndexPath[_visiblePickerCellIndexPath] setHidden:YES];

  _visiblePickerCellIndexPath = ([_visiblePickerCellIndexPath isEqual:visiblePickerCellIndexPath]
                                 ? nil
                                 : visiblePickerCellIndexPath);

  if (_visiblePickerCellIndexPath) {

    UIPickerView * pickerView = self.pickersByIndexPath[_visiblePickerCellIndexPath];
    assert(pickerView);

    [pickerView reloadAllComponents];

    NSUInteger row = 0;

    id object = [self dataForIndexPath:_visiblePickerCellIndexPath type:BankableDetailPickerViewSelection];

    if (object) {

      NSUInteger idx = [[self dataForIndexPath:_visiblePickerCellIndexPath type:BankableDetailPickerViewData]
                        indexOfObject:object];

      if (idx != NSNotFound) row = idx;
    }

    [pickerView selectRow:row inComponent:0 animated:NO];

    pickerView.hidden = NO;
  }

  [self.tableView endUpdates];

}

/// registerPickerView:forIndexPath:
/// @param pickerView description
/// @param indexPath description
- (void)registerPickerView:(UIPickerView *)pickerView forIndexPath:(NSIndexPath *)indexPath {

  pickerView.delegate                = self;
  pickerView.dataSource              = self;
  pickerView.hidden                  = YES;
  self.pickersByIndexPath[indexPath] = pickerView;
  self.indexPathsByPicker[NSValueWithObjectPointer(pickerView)] = indexPath;

}

/// pickerView:didSelectObject:row:indexPath:
/// @param pickerView description
/// @param selection description
/// @param row description
/// @param indexPath description
- (void)pickerView:(UIPickerView *)pickerView
   didSelectObject:(id)selection
               row:(NSUInteger)row
         indexPath:(NSIndexPath *)indexPath
{

  UITextField * textField = [self textFieldForIndexPath:indexPath];

  if (textField) {

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


/// numberOfComponentsInPickerView:
/// @param pickerView description
/// @return NSInteger
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView { return 1; }

/// pickerView:numberOfRowsInComponent:
/// @param pickerView description
/// @param component description
/// @return NSInteger
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {

  NSIndexPath * indexPath = [self indexPathForPickerView:pickerView];
  return (indexPath ? [[self dataForIndexPath:indexPath
                                         type:BankableDetailPickerViewData] count] : 0);

}

/// pickerView:titleForRow:forComponent:
/// @param pickerView description
/// @param row description
/// @param component description
/// @return NSString *
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{

  NSIndexPath * indexPath = [self indexPathForPickerView:pickerView];
  NSArray     * data      = [self dataForIndexPath:indexPath type:BankableDetailPickerViewData];
  return (data ? textForSelection(data[row]) : nil);

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Picker view delegate
////////////////////////////////////////////////////////////////////////////////

/// pickerView:didSelectRow:inComponent:
/// @param pickerView description
/// @param row description
/// @param component description
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

/// cancel:
/// @param sender description
- (IBAction)cancel:(id)sender {

  NSManagedObjectContext * moc = _item.managedObjectContext;
  [moc performBlockAndWait:^{ [moc rollback]; }];
  [self setEditing:NO animated:YES];
  [self.tableView reloadData];

}

/// save:
/// @param sender description
- (IBAction)save:(id)sender {

  NSManagedObjectContext * moc = _item.managedObjectContext;
  [moc performBlockAndWait:^{
    NSError * error = nil;
    [moc save:&error];
    MSHandleErrors(error);
  }];

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Managing text fields
////////////////////////////////////////////////////////////////////////////////

/// textFieldsByIndexPath
/// @return MSDictionary *
- (MSDictionary *)textFieldsByIndexPath {

  if (!_textFieldsByIndexPath) {

    _textFieldsByIndexPath = [MSDictionary dictionary];
    _indexPathsByTextField = [MSDictionary dictionary];

    _textFieldHandlersByIndexPath = [@{} mutableCopy];

  }

  return _textFieldsByIndexPath;

}

/// registerTextField:forIndexPath:handlers:
/// @param textField description
/// @param indexPath description
/// @param handlers description
- (void)registerTextField:(UITextField *)textField
             forIndexPath:(NSIndexPath *)indexPath
                 handlers:(NSDictionary *)handlers {

  assert(textField && indexPath);
  textField.delegate                    = self;
  self.textFieldsByIndexPath[indexPath] = textField;
  self.indexPathsByTextField[NSValueWithObjectPointer(textField)] = indexPath;
  if (handlers) _textFieldHandlersByIndexPath[indexPath] = handlers;

}

/// textFieldForIndexPath:
/// @param indexPath description
/// @return UITextField *
- (UITextField *)textFieldForIndexPath:(NSIndexPath *)indexPath {
  return _textFieldsByIndexPath[indexPath];
}

/// indexPathForTextField:
/// @param textField description
/// @return NSIndexPath *
- (NSIndexPath *)indexPathForTextField:(UITextField *)textField {
  return _indexPathsByTextField[NSValueWithObjectPointer(textField)];
}

/// integerKeyboardViewForTextField:
/// @param textField description
/// @return UIView *
- (UIView *)integerKeyboardViewForTextField:(UITextField *)textField {

  assert(textField);
  UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];

  NSDictionary * index = @{ @0 : @"1",      @1 : @"2",    @2 : @"3",
                            @3 : @"4",      @4 : @"5",    @5 : @"6",
                            @6 : @"7",      @7 : @"8",    @8 : @"9",
                            @9 : @"Erase",  @10 : @"0",  @11 : @"Done" };

  for (NSUInteger i = 0; i < 12; i++) {

    UIButton * b = [UIButton buttonWithType:UIButtonTypeCustom];
    PrepConstraints(b);

    if (i < 11) {

      NSString * imageName = $(@"IntegerKeyboard_%@.png", index[@(i)]);
      UIImage  * image     = [UIImage imageNamed:imageName];
      [b setImage:image forState:UIControlStateNormal];
      imageName = $(@"IntegerKeyboard_%@-Highlighted.png", index[@(i)]);
      image     = [UIImage imageNamed:imageName];
      [b setImage:image forState:UIControlStateHighlighted];

    } else {

      [b setBackgroundColor:UIColorMake(0, 122 / 255.0, 1, 1)];
      [b setTitle:@"Done" forState:UIControlStateNormal];
      [b setTitleColor:WhiteColor forState:UIControlStateNormal];

    }

    void (^actionBlock)(void) = (i == 9
                                 ? ^{ textField.text =
                                        [textField.text
                                         substringToIndex:textField.text.length - 1]; }
                                 : (i == 11
                                    ? ^{ [textField resignFirstResponder]; }
                                    : ^{ [textField insertText:index[@(i)]]; }));

    [b addActionBlock:actionBlock forControlEvents:UIControlEventTouchUpInside];

    ConstrainHeight(b, (i < 3 ? 54 : 53.5));
    ConstrainWidth(b, (i % 3 && (i + 1) % 3 ? 110 : 104.5));
    [view addSubview:b];

    if (i < 3) AlignViewTop(view, b, 0);
    else if (i > 8) AlignViewBottom(view, b, 0);

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

/// textFieldShouldBeginEditing:
/// @param textField description
/// @return BOOL
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField { return [self isEditing]; }

/// textFieldDidBeginEditing:
/// @param textField description
- (void)textFieldDidBeginEditing:(UITextField *)textField {

  [textField selectAll:nil];

  NSIndexPath * indexPath = [self indexPathForTextField:textField];

  if (indexPath)
    self.visiblePickerCellIndexPath = ([self pickerViewForIndexPath:indexPath] ? indexPath : nil);

}

/// textFieldDidEndEditing:
/// @param textField description
- (void)textFieldDidEndEditing:(UITextField *)textField {


  if (textField == _nameTextField) {

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

/// textFieldShouldEndEditing:
/// @param textField description
/// @return BOOL
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {

  NSIndexPath * indexPath = [self indexPathForTextField:textField];

  if (!indexPath) return YES;

  NSDictionary * handlers = _textFieldHandlersByIndexPath[indexPath];

  if (!handlers) return YES;

  BankableValidationHandler handler = handlers[BankableValidationHandlerKey];

  if (!handler) return YES;

  return handler();

}

/// textFieldShouldReturn:
/// @param textField description
/// @return BOOL
- (BOOL)textFieldShouldReturn:(UITextField *)textField { [textField resignFirstResponder]; return NO; }

////////////////////////////////////////////////////////////////////////////////
#pragma mark Text view delegate
////////////////////////////////////////////////////////////////////////////////


/// textView:shouldChangeTextInRange:replacementText:
/// @param textView description
/// @param range description
/// @param text description
/// @return BOOL
- (BOOL)         textView:(UITextView *)textView
  shouldChangeTextInRange:(NSRange)range
          replacementText:(NSString *)text
{
  return YES;
}

/// textView:shouldInteractWithTextAttachment:inRange:
/// @param textView description
/// @param textAttachment description
/// @param characterRange description
/// @return BOOL
- (BOOL)                  textView:(UITextView *)textView
  shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment
                           inRange:(NSRange)characterRange
{
  return NO;
}

/// textView:shouldInteractWithURL:inRange:
/// @param textView description
/// @param URL description
/// @param characterRange description
/// @return BOOL
- (BOOL)       textView:(UITextView *)textView
  shouldInteractWithURL:(NSURL *)URL
                inRange:(NSRange)characterRange
{
  return NO;
}

/// textViewDidBeginEditing:
/// @param textView description
- (void)textViewDidBeginEditing:(UITextView *)textView {}

/// textViewDidChange:
/// @param textView description
- (void)textViewDidChange:(UITextView *)textView {}

/// textViewDidChangeSelection:
/// @param textView description
- (void)textViewDidChangeSelection:(UITextView *)textView {}

/// textViewDidEndEditing:
/// @param textView description
- (void)textViewDidEndEditing:(UITextView *)textView {}

/// textViewShouldBeginEditing:
/// @param textView description
/// @return BOOL
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView { return YES; }

/// textViewShouldEndEditing:
/// @param textView description
/// @return BOOL
- (BOOL)textViewShouldEndEditing:(UITextView *)textView { return YES; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view data source
////////////////////////////////////////////////////////////////////////////////


/// tableView:canEditRowAtIndexPath:
/// @param tableView description
/// @param indexPath description
/// @return BOOL
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return NO;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view delegate
////////////////////////////////////////////////////////////////////////////////


/// tableView:didEndDisplayingCell:forRowAtIndexPath:
/// @param tableView description
/// @param cell description
/// @param indexPath description
- (void)     tableView:(UITableView *)tableView
  didEndDisplayingCell:(UITableViewCell *)cell
     forRowAtIndexPath:(NSIndexPath *)indexPath
{

  if (_pickersByIndexPath[indexPath])
    [_pickersByIndexPath removeObjectForKey:indexPath];

  if (_textFieldsByIndexPath[indexPath]) {

    [_textFieldsByIndexPath removeObjectForKey:indexPath];

    if (_textFieldHandlersByIndexPath[indexPath])
      [_textFieldHandlersByIndexPath removeObjectForKey:indexPath];
  }

  if (_steppersByIndexPath[indexPath]) {

    [_steppersByIndexPath removeObjectForKey:indexPath];
    [_stepperLabelsByIndexPath removeObjectForKey:indexPath];
  }

}

@end
