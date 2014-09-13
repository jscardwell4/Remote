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

const CGFloat BankableDetailDefaultRowHeight  = 38.0;
const CGFloat BankableDetailExpandedRowHeight = 200.0;
const CGFloat BankableDetailPreviewRowHeight  = 291.0;
const CGFloat BankableDetailTextViewRowHeight = 140.0;
const CGFloat BankableDetailTableRowHeight    = 120.0;


////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankableDetailTableViewController
////////////////////////////////////////////////////////////////////////////////


@interface BankableDetailTableViewController () <UITextFieldDelegate>

@property (nonatomic, strong, readwrite)          NSMutableArray * expandedRows;
@property (nonatomic, weak,   readwrite) IBOutlet UITextField    * nameTextField;
@property (nonatomic, strong, readonly )          NSArray        * sectionHeaderTitles;


@end

@implementation BankableDetailTableViewController

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

  if ([item isKindOfClass:[self itemClass]] && (self = [super init])) {

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
  tableView.rowHeight = BankableDetailDefaultRowHeight;
  tableView.sectionHeaderHeight = 10.0;
  tableView.sectionFooterHeight = 10.0;
  tableView.allowsSelection = NO;
  tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  tableView.delegate = self;
  tableView.dataSource = self;

  [BankableDetailTableViewCell registerIdentifiersWithTableView:tableView];

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
    nameTextField.clearsOnBeginEditing = YES;
    nameTextField.delegate = self;
    if (self.item) nameTextField.text = self.item.name;

    item.titleView = nameTextField;
    self.nameTextField = nameTextField;
    item.rightBarButtonItem  = self.editButtonItem;

  }


  return item;

}

/// viewWillAppear:
- (void)viewWillAppear:(BOOL)animated {

  [super viewWillAppear:animated];

  if (self.item) [self updateDisplay];

}

/// updateDisplay
- (void)updateDisplay {

  self.nameTextField.text     = self.item.name;
  self.editButtonItem.enabled = [self.item isEditable];

  [self.tableView reloadData];

}

/// expandedRows
/// @return NSMutableArray *
- (NSMutableArray *)expandedRows {
  if (!_expandedRows) self.expandedRows = [@[] mutableCopy];
  return _expandedRows;
}

/// identifiersByIndexPath
/// @return NSArray const *
- (NSArray const *)identifiers { return nil; }

/// dequeueCellForIndexPath:
/// @param indexPath description
/// @return BankableDetailTableViewCell *
- (BankableDetailTableViewCell *)dequeueCellForIndexPath:(NSIndexPath * )indexPath {

  BankableDetailTableViewCell * cell = nil;

  NSString * identifier = self.identifiers[indexPath.section][indexPath.row];

  if ([BankableDetailTableViewCell isValidIentifier:identifier]) {

    cell = [self.tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];

    __weak BankableDetailTableViewController * weakself = self;
    cell.pickerDisplayCallback = ^(BankableDetailTableViewCell * cell, BOOL hidden) {

      [weakself.tableView beginUpdates];
      if (hidden) [weakself.expandedRows removeObject:indexPath];
      else [weakself.expandedRows addObject:indexPath];
      [weakself.tableView endUpdates];

    };

  }

  return cell;

}

/// setEditing:animated:
/// @param editing description
/// @param animated description
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {

  if (self.editing != editing) {

    self.navigationItem.leftBarButtonItem = (editing ? SystemBarButton(Cancel, @selector(cancel:)) : nil);

    self.nameTextField.userInteractionEnabled = editing;

    [super setEditing:editing animated:animated];

/*
    for (NSIndexPath * indexPath in self.editableRows) {
      BankableDetailTableViewCell * cell = [self cellForRowAtIndexPath:indexPath];
      [cell setEditing:editing];
    }
*/

  }

}

/// cellForRowAtIndexPath:
/// @param indexPath description
/// @return BankableDetailTableViewCell *
- (BankableDetailTableViewCell *)cellForRowAtIndexPath:(NSIndexPath const *)indexPath {
  return (BankableDetailTableViewCell *)[self.tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Bankable detail delegate
////////////////////////////////////////////////////////////////////////////////


/// itemClass
/// @return Class<Bankable>
- (Class<BankableModel>)itemClass { return [NSManagedObject class]; }

/// editItem
- (void)editItem { if(_item && [_item isEditable]) [self setEditing:YES animated:YES]; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Animations
////////////////////////////////////////////////////////////////////////////////


/// revealAnimationForStepper:
/// @param stepper description
- (void)revealAnimationForStepper:(UIStepper *)stepper {



}

/// hideAnimationForStepper:
/// @param stepper description
- (void)hideAnimationForStepper:(UIStepper *)stepper {



}


/// revealAnimationForView:besideView:
/// @param hiddenView description
/// @param neighborView description
- (void)revealAnimationForView:(UIView *)hiddenView besideView:(UIView *)neighborView {

  if (!hiddenView)        ThrowInvalidNilArgument(hiddenView);
  if (!neighborView)      ThrowInvalidNilArgument(neighborView);
  if (!hiddenView.hidden) ThrowInvalidInternalInconsistency("cannot reveal a view that is not hidden");

  UIView * parentView = neighborView.superview;

//  NSArray * views = @[neighborView, parentView];

  NSPredicate * predicate =
  [NSPredicate predicateWithFormat:
   [@" && " join:@[ @"((firstAttribute == %@) || (secondAttribute == %@))",
                    @"((firstAttribute == %@) || (secondAttribute == %@))",
                    @"((firstItem == %@) || (secondItem == %@))",
                    @"((firstItem == %@) || (secondItem == %@))",
                    @"(firstAttribute != secondAttribute)",
                    @"(firstItem != secondItem)",
                    @"(relation == %@)"]],
   @(NSLayoutAttributeTrailing),
   @(NSLayoutAttributeTrailing),
   @(NSLayoutAttributeLeading),
   @(NSLayoutAttributeLeading),
   neighborView,
   neighborView,
   parentView,
   parentView,
   @(NSLayoutRelationEqual)];

  NSLayoutConstraint * oldConstraint = [parentView constraintMatching:predicate];

  CGFloat constant = (oldConstraint.firstAttribute == NSLayoutAttributeTrailing ? -16.0 : 16.0);

  NSLayoutConstraint * newConstraint = [NSLayoutConstraint constraintWithItem:neighborView
                                                                    attribute:NSLayoutAttributeTrailing
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:hiddenView
                                                                    attribute:NSLayoutAttributeLeading
                                                                   multiplier:1.0
                                                                     constant:constant];

  hiddenView.hidden = NO;
  [parentView removeConstraint:oldConstraint];
  [parentView addConstraint:newConstraint];
  [parentView layoutIfNeeded];

}

/// hideAnimationForView:besideView:
/// @param hiddenView description
/// @param neighborView description
- (void)hideAnimationForView:(UIView *)hiddenView besideView:(UIView *)neighborView {

  if (!hiddenView)       ThrowInvalidNilArgument(hiddenView);
  if (!neighborView)     ThrowInvalidNilArgument(neighborView);
  if (hiddenView.hidden) ThrowInvalidInternalInconsistency("cannot hide a view that is already hidden");

  UIView * parentView = neighborView.superview;

//  NSArray * views = @[neighborView, parentView];

  NSPredicate * predicate =
  [NSPredicate predicateWithFormat:
   [@" && " join:@[ @"((firstAttribute == %@) || (secondAttribute == %@))",
                    @"((firstAttribute == %@) || (secondAttribute == %@))",
                    @"((firstItem == %@) || (secondItem == %@))",
                    @"((firstItem == %@) || (secondItem == %@))",
                    @"(firstAttribute != secondAttribute)",
                    @"(firstItem != secondItem)",
                    @"(relation == %@)"]],
   @(NSLayoutAttributeTrailing),
   @(NSLayoutAttributeTrailing),
   @(NSLayoutAttributeLeading),
   @(NSLayoutAttributeLeading),
   neighborView,
   neighborView,
   parentView,
   parentView,
   @(NSLayoutRelationEqual)];

  NSLayoutConstraint * oldConstraint = [parentView constraintMatching:predicate];

  CGFloat constant = (oldConstraint.firstAttribute == NSLayoutAttributeTrailing ? -8.0 : 8.0);

  NSLayoutConstraint * newConstraint = [NSLayoutConstraint constraintWithItem:neighborView
                                                                    attribute:NSLayoutAttributeTrailing
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:hiddenView
                                                                    attribute:NSLayoutAttributeLeading
                                                                   multiplier:1.0
                                                                     constant:constant];

  hiddenView.hidden = YES;
  [parentView removeConstraint:oldConstraint];
  [parentView addConstraint:newConstraint];
  [parentView layoutIfNeeded];

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

  [self setEditing:NO animated:YES];

}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextFieldDelegate
////////////////////////////////////////////////////////////////////////////////


/// textFieldDidEndEditing:
/// @param textField description
- (void)textFieldDidEndEditing:(UITextField *)textField {
   if (textField == self.nameTextField && textField.text.length) self.item.name = textField.text;
}

/// textFieldShouldReturn:
/// @param textField description
/// @return BOOL
//- (BOOL)textFieldShouldReturn:(UITextField *)textField { [textField resignFirstResponder]; return NO; }



////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate
////////////////////////////////////////////////////////////////////////////////


/// tableView:editingStyleForRowAtIndexPath:
/// @param tableView description
/// @param indexPath description
/// @return UITableViewCellEditingStyle
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return UITableViewCellEditingStyleNone;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableViewDataSource
////////////////////////////////////////////////////////////////////////////////


/// editableRows
/// @return NSSet const *
- (NSSet const *)editableRows { return nil; }

/// numberOfSections
/// @return NSInteger
- (NSInteger)numberOfSections { return 1; }

/// sectionHeaderTitles
/// @return NSArray *
- (NSArray *)sectionHeaderTitles { return nil; }

/// numberOfRowsInSection:
/// @param section description
/// @return NSInteger
- (NSInteger)numberOfRowsInSection:(NSInteger)section { return 0; }


/// numberOfSectionsInTableView:
/// @param tableView description
/// @return NSInteger
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return self.numberOfSections; }

/// tableView:numberOfRowsInSection:
/// @param tableView description
/// @param section description
/// @return NSInteger
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self numberOfRowsInSection:section];
}

/// tableView:titleForHeaderInSection:
/// @param tableView description
/// @param section description
/// @return NSString *
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return NilSafe(self.sectionHeaderTitles[section]);
}

/// tableView:heightForRowAtIndexPath:
/// @param tableView description
/// @param indexPath description
/// @return CGFloat
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

  NSString * identifier = self.identifiers[indexPath.section][indexPath.row];
  assert(identifier);

  if ([identifier isEqualToString:BankableDetailCellTextViewStyleIdentifier])
    return BankableDetailTextViewRowHeight;

  else if ([identifier isEqualToString:BankableDetailCellImageStyleIdentifier])
    return BankableDetailPreviewRowHeight;

  else if ([identifier isEqualToString:BankableDetailCellTableStyleIdentifier])
    return BankableDetailTableRowHeight;

  else if ([self.expandedRows containsObject:indexPath])
    return BankableDetailExpandedRowHeight;

  else
    return BankableDetailDefaultRowHeight;

}

/// tableView:canEditRowAtIndexPath:
/// @param tableView description
/// @param indexPath description
/// @return BOOL
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return [self.editableRows containsObject:indexPath];
}

@end
