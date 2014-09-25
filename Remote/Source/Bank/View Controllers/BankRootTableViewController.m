//
//  BankTableViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/15/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankRootTableViewController.h"
#import "MSRemoteAppController.h"
#import "Bank.h"
#import "Remote-Swift.h"

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

/// rootItems
/// @return MSDictionary *
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

/// numberOfSectionsInTableView:
/// @param tableView
/// @return NSInteger
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

/// tableView:numberOfRowsInSection:
/// @param tableView
/// @param section
/// @return NSInteger
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.rootItems count];
}

/// tableView:cellForRowAtIndexPath:
/// @param tableView
/// @param indexPath
/// @return UITableViewCell *
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  MSSTATIC_STRING_CONST kCellIdentifier = @"Cell";
  UITableViewCell     * cell            = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier
                                                                          forIndexPath:indexPath];

  // Configure the cell...
  cell.textLabel.text = self.rootItems[indexPath.row];

  return cell;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate
////////////////////////////////////////////////////////////////////////////////


/// tableView:didSelectRowAtIndexPath:
/// @param tableView
/// @param indexPath
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  Class                      itemClass      = [_rootItems keyAtIndex:indexPath.row];
  BankCollectionController * viewController = [[BankCollectionController alloc] initWithItemClass:itemClass];
  [self.navigationController pushViewController:viewController animated:YES];

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Actions
////////////////////////////////////////////////////////////////////////////////

/// importBankObject:
/// @param sender
- (IBAction)importBankObject:(UIBarButtonItem *)sender { MSLogDebug(@"%@", ClassTagSelectorString); }

/// exportBankObject:
/// @param sender
- (IBAction)exportBankObject:(UIBarButtonItem *)sender { MSLogDebug(@"%@", ClassTagSelectorString); }

/// searchBankObjects:
/// @param sender
- (IBAction)searchBankObjects:(UIBarButtonItem *)sender { MSLogDebug(@"%@", ClassTagSelectorString); }

/// dismiss:
/// @param sender
- (IBAction)dismiss:(id)sender {
  [AppController dismissViewController:[Bank viewController] completion:nil];
}

@end
