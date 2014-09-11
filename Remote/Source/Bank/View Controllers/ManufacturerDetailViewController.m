//
//  ManufacturerDetailViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/22/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankableDetailTableViewController_Private.h"
#import "BankCollectionViewController.h"
#import "ManufacturerDetailViewController.h"
#import "Manufacturer.h"
#import "BankGroup.h"
#import "IRCode.h"
#import "CoreDataManager.h"
#import "ComponentDevice.h"
static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)
MSSTATIC_STRING_CONST kDeviceCodesetText = @"Device Codes";

@interface ManufacturerDetailViewController ()

@property (nonatomic, weak, readonly) Manufacturer * manufacturer;
@property (nonatomic, strong)         NSArray      * devices;
@property (nonatomic, strong)         NSArray      * codesets;

@end

@implementation ManufacturerDetailViewController
{
  __weak Manufacturer * _manufacturer;
}

// - (Manufacturer *)manufacturer { return (Manufacturer *)self.item; }

/// itemClass
/// @return Class<BankableModel>
- (Class<BankableModel>)itemClass { return [Manufacturer class]; }

/// setItem:
/// @param item description
- (void)setItem:(BankableModelObject *)item {
  [super setItem:item];
  _manufacturer = (Manufacturer *)self.item;

  if (_manufacturer) {
    self.devices = [self.manufacturer.devices allObjects];
    NSSet * codesets = (self.manufacturer.codesets ?: [NSSet set]);
    self.codesets = ([_devices count]
                     ? [@[kDeviceCodesetText] arrayByAddingObjects : codesets]
                     :[codesets allObjects]);
  }

}

/*
   - (void)updateDisplay
   {
    [super updateDisplay];
    if ([self isViewLoaded]) [self.tableView reloadData];
   }
 */

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table view data source
////////////////////////////////////////////////////////////////////////////////

/// numberOfSectionsInTableView:
/// @param tableView description
/// @return NSInteger
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 2; }

/// tableView:numberOfRowsInSection:
/// @param tableView description
/// @param section description
/// @return NSInteger
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return (section ? [_codesets count] : [_devices count]);
}

/// tableView:titleForHeaderInSection:
/// @param tableView description
/// @param section description
/// @return NSString *
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return (section ? @"Codesets" : @"Devices");
}

/// tableView:cellForRowAtIndexPath:
/// @param tableView description
/// @param indexPath description
/// @return UITableViewCell *
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  BankableDetailTableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:BankableDetailCellLabelStyleIdentifier
                                                                            forIndexPath:indexPath];

  if (!indexPath.section) {
    NSString * labelText = ([_devices count]
                            ? [_devices[indexPath.row] valueForKey:@"name"]
                            : @"No Devices");
    cell.infoLabel.text = labelText;
  } else   {
    NSString * labelText = ([_codesets count] ? _codesets[indexPath.row] : @"No Codesets");
    cell.infoLabel.text = labelText;
  }

  return cell;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table view delegate
////////////////////////////////////////////////////////////////////////////////

/// tableView:didSelectRowAtIndexPath:
/// @param tableView description
/// @param indexPath description
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  if (!indexPath.section) {

    ComponentDevice * device = _devices[indexPath.row];

    [self.navigationController pushViewController:device.detailViewController animated:YES];

  }

  else {

    NSString * codeset = _codesets[indexPath.row];

    BOOL isUserCodeset = [codeset isEqualToString:kDeviceCodesetText];

    if (isUserCodeset) codeset = nil;

    BankCollectionViewController * vc =
      UIStoryboardInstantiateSceneByClassName(BankCollectionViewController);

    vc.navigationItem.title = $(@"(%@) %@",
                                self.manufacturer.name,
                                (isUserCodeset ? @"Devices" : codeset));

    NSPredicate * predicate =
      NSPredicateMake(@"(manufacturer = %@) && (codeset = %@)", self.manufacturer, codeset);

    NSString * groupBy = (isUserCodeset ? @"device.name" : nil);

    NSString * sortedBy = (isUserCodeset ? @"device.name,name" : @"name");

    NSManagedObjectContext * moc = self.manufacturer.managedObjectContext;

    NSFetchedResultsController * controller = [IRCode fetchAllGroupedBy:groupBy
                                                          withPredicate:predicate
                                                               sortedBy:sortedBy
                                                              ascending:YES
                                                                context:moc];
    NSError * error = nil;
    [controller performFetch:&error];

    if (!MSHandleErrors(error)) {
      vc.bankableItems = controller;
      vc.itemClass     = [IRCode class];

      if (!isUserCodeset) {
//        BankFlags bf = vc.bankFlags;
//        vc.bankFlags = bf | BankNoSections;
      }

      [self.navigationController pushViewController:vc animated:YES];

    }

  }
}

@end
