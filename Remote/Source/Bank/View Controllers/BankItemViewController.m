//
//  BankItemViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/24/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankItemViewController_Private.h"
#import "CoreDataManager.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

const CGFloat BankItemDefaultRowHeight  = 38.0;
const CGFloat BankItemPreviewRowHeight  = 291.0;
const CGFloat BankItemTextViewRowHeight = 140.0;
const CGFloat BankItemTableRowHeight    = 120.0;


////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankItemViewController
////////////////////////////////////////////////////////////////////////////////


@interface BankItemViewController () <UITextFieldDelegate>

@property (nonatomic, strong, readwrite)          NSMutableArray * expandedRows;
@property (nonatomic, weak,   readwrite) IBOutlet UITextField    * nameTextField;
@property (nonatomic, strong, readonly )          NSArray        * sectionHeaderTitles;


@end

@implementation BankItemViewController

/// controllerWithItem:
/// @param item
/// @return instancetype
+ (instancetype)controllerWithItem:(BankableModelObject *)item {
  return [self controllerWithItem:item editing:NO];
}

/// controllerWithItem:editing:
/// @param item
/// @param isEditing
/// @return instancetype
+ (instancetype)controllerWithItem:(BankableModelObject *)item editing:(BOOL)isEditing {
  return [[self alloc] initWithItem:item];
}

/// initWithItem:
/// @param item
/// @return instancetype
- (instancetype)initWithItem:(BankableModelObject *)item {
  return [self initWithItem:item editing:NO];
}

/// initWithItem:editing:
/// @param item
/// @param isEditing
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
  tableView.rowHeight = BankItemDefaultRowHeight;
  tableView.sectionHeaderHeight = 10.0;
  tableView.sectionFooterHeight = 10.0;
  tableView.allowsSelection = NO;
  tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  tableView.delegate = self;
  tableView.dataSource = self;

  [BankItemTableViewCell registerIdentifiersWithTableView:tableView];

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

/// setEditing:animated:
/// @param editing
/// @param animated
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {

  if (self.editing != editing) {

    self.navigationItem.leftBarButtonItem = (editing ? SystemBarButton(Cancel, @selector(cancel:)) : nil);

    self.nameTextField.userInteractionEnabled = editing;

    [super setEditing:editing animated:animated];

    if (editing) {
      [self.editButtonItem setAction:@selector(save:)];
      self.editButtonItem.title = @"Save";
    } else {
      [self.editButtonItem setAction:@selector(edit:)];
      self.editButtonItem.title = @"Edit";
    }

  }

}

/// cellForRowAtIndexPath:
/// @param indexPath
/// @return BankItemTableViewCell *
- (BankItemTableViewCell *)cellForRowAtIndexPath:(NSIndexPath const *)indexPath {
  return (BankItemTableViewCell *)[self.tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath];
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
#pragma mark Actions
////////////////////////////////////////////////////////////////////////////////


/// cancel:
/// @param sender
- (IBAction)cancel:(id)sender {

  NSManagedObjectContext * moc = _item.managedObjectContext;
  [moc performBlockAndWait:^{
    [moc processPendingChanges];
    [moc rollback];
  }];
  [self setEditing:NO animated:YES];
  [self.tableView reloadData];

}

/// edit:
/// @param sender
- (IBAction)edit:(id)sender { if (!self.isEditing) [self setEditing:YES animated:YES]; }

/// save:
/// @param sender
- (IBAction)save:(id)sender {

  NSManagedObjectContext * moc = _item.managedObjectContext;
  [moc performBlockAndWait:^{
    [moc processPendingChanges];
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
/// @param textField
- (void)textFieldDidEndEditing:(UITextField *)textField {
   if (textField == self.nameTextField && textField.text.length) self.item.name = textField.text;
}

/// textFieldShouldReturn:
/// @param textField
/// @return BOOL
//- (BOOL)textFieldShouldReturn:(UITextField *)textField { [textField resignFirstResponder]; return NO; }



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Managing the table view
////////////////////////////////////////////////////////////////////////////////


/// editableRows
/// @return NSSet const *
- (NSSet const *)editableRows { return nil; }

/// numberOfSections
/// @return NSInteger
- (NSInteger const)numberOfSections { return 1; }

/// sectionHeaderTitles
/// @return NSArray const *
- (NSArray const *)sectionHeaderTitles { return nil; }

/// numberOfRowsInSection:
/// @param section
/// @return NSInteger
- (NSInteger)numberOfRowsInSection:(NSInteger)section { return 0; }

/// heightForSubTableAtIndexPath:
/// @param indexPath
/// @return CGFloat
- (CGFloat)heightForSubTableAtIndexPath:(NSIndexPath *)indexPath { return 0.0; }

/// dequeueCellForIndexPath:
/// @param indexPath
/// @return BankItemTableViewCell *
- (BankItemTableViewCell *)dequeueCellForIndexPath:(NSIndexPath * )indexPath {

  BankItemTableViewCell * cell = nil;

  NSString * identifier = self.identifiers[indexPath.section][indexPath.row];

  if ([BankItemTableViewCell isValidIentifier:identifier]) {

    cell = [self.tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];

    __weak BankItemViewController * weakself = self;
    cell.shouldShowPicker = ^BOOL(BankItemTableViewCell * cell) {
      [weakself.tableView beginUpdates];
      [weakself.expandedRows addObject:indexPath];
      return YES;
    };
    cell.shouldHidePicker = ^BOOL(BankItemTableViewCell * cell) {
      [weakself.tableView beginUpdates];
      [weakself.expandedRows removeObject:indexPath];
      return YES;
    };
    cell.didShowPicker = ^(BankItemTableViewCell * cell) {
      [weakself.tableView endUpdates];
    };

    cell.didHidePicker = ^(BankItemTableViewCell * cell) {
      [weakself.tableView endUpdates];
    };


  }

  return cell;

}

/// decorateCell:forIndexPath:
/// @param cell
/// @param indexPath
- (void)decorateCell:(BankItemTableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {}


/// UITableViewDelegate
////////////////////////////////////////////////////////////////////////////////


/// tableView:editingStyleForRowAtIndexPath:
/// @param tableView
/// @param indexPath
/// @return UITableViewCellEditingStyle
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return UITableViewCellEditingStyleNone;
}


/// UITableViewDataSource
////////////////////////////////////////////////////////////////////////////////


/// tableView:cellForRowAtIndexPath:
/// @param tableView
/// @param indexPath
/// @return UITableViewCell *
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  BankItemTableViewCell * cell = [self dequeueCellForIndexPath:indexPath];
  [self decorateCell:cell forIndexPath:indexPath];

  return cell;

}

/// numberOfSectionsInTableView:
/// @param tableView
/// @return NSInteger
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return self.numberOfSections; }

/// tableView:numberOfRowsInSection:
/// @param tableView
/// @param section
/// @return NSInteger
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self numberOfRowsInSection:section];
}

/// tableView:titleForHeaderInSection:
/// @param tableView
/// @param section
/// @return NSString *
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return NilSafe(self.sectionHeaderTitles[section]);
}

/// tableView:heightForRowAtIndexPath:
/// @param tableView
/// @param indexPath
/// @return CGFloat
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

  NSString * identifier = self.identifiers[indexPath.section][indexPath.row];

  CGFloat height = 0.0;

  if ([identifier isEqualToString:BankItemCellTextViewStyleIdentifier])
    height = BankItemTextViewRowHeight;

  else if ([identifier isEqualToString:BankItemCellImageStyleIdentifier])
    height = BankItemPreviewRowHeight;

  else if ([identifier isEqualToString:BankItemCellTableStyleIdentifier])
    height = [self heightForSubTableAtIndexPath:indexPath];

  else
    height = BankItemDefaultRowHeight;

  if ([self.expandedRows containsObject:indexPath])
    height += BankItemCellPickerHeight;

  return height;

}

/// tableView:canEditRowAtIndexPath:
/// @param tableView
/// @param indexPath
/// @return BOOL
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return [self.editableRows containsObject:indexPath];
}

@end
