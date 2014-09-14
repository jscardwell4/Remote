//
//  BankTableViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/15/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankRootTableViewController.h"
#import "MSRemoteAppController.h"
#import "BankCollectionViewController.h"
#import "Bank.h"

static int       ddLogLevel   = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel, msLogContext)

////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankRootTableViewController class extension
////////////////////////////////////////////////////////////////////////////////

@interface BankRootTableViewController ()<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) MSDictionary * rootItems;
@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankTableViewController implementation
////////////////////////////////////////////////////////////////////////////////


@implementation BankRootTableViewController

- (MSDictionary *)rootItems {
  if (!_rootItems) {
    self.rootItems = [MSDictionary dictionary];

    for (NSString * className in [Bank registeredClasses]) {
      id class = NSClassFromString(className);
      assert(class);
      assert([class conformsToProtocol:@protocol(BankableModel)]);
      NSString * directoryLabel = [class valueForKey:@"directoryLabel"];
      assert(directoryLabel);
      _rootItems[class] = directoryLabel;
    }
  }

  return _rootItems;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table view data source
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.rootItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  MSSTATIC_STRING_CONST kCellIdentifier = @"Cell";
  UITableViewCell     * cell            = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier
                                                                          forIndexPath:indexPath];

  // Configure the cell...
  cell.textLabel.text = self.rootItems[indexPath.row];

  return cell;
}

- (void)   tableView:(UITableView *)tableView
  commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
   forRowAtIndexPath:(NSIndexPath *)indexPath
{}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate
////////////////////////////////////////////////////////////////////////////////


/// tableView:didSelectRowAtIndexPath:
/// @param tableView description
/// @param indexPath description
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  Class itemClass = [_rootItems keyAtIndex:indexPath.row];
  BankCollectionViewController * viewController =
    [BankCollectionViewController controllerWithItemClass:itemClass];
  [self.navigationController pushViewController:viewController animated:YES];

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Navigation
////////////////////////////////////////////////////////////////////////////////

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([@"Push Bank Items" isEqualToString:segue.identifier]) {
    BankCollectionViewController * viewController = segue.destinationViewController;
    NSInteger                      idx            = [self.tableView indexPathForSelectedRow].row;
    viewController.navigationItem.title = _rootItems[idx];
    viewController.itemClass            = [_rootItems keyAtIndex:idx];
  }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Actions
////////////////////////////////////////////////////////////////////////////////

- (IBAction)importBankObject:(UIBarButtonItem *)sender { MSLogDebug(@"%@", ClassTagSelectorString); }

- (IBAction)exportBankObject:(UIBarButtonItem *)sender { MSLogDebug(@"%@", ClassTagSelectorString); }

- (IBAction)searchBankObjects:(UIBarButtonItem *)sender { MSLogDebug(@"%@", ClassTagSelectorString); }

- (IBAction)dismiss:(id)sender {
  [AppController dismissViewController:[Bank viewController] completion:nil];
}

@end
