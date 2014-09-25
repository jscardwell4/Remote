//
//  ManufacturerViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/22/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankItemViewController_Private.h"
#import "ManufacturerViewController.h"
#import "Manufacturer.h"
#import "IRCode.h"
#import "CoreDataManager.h"
#import "ComponentDevice.h"
#import "Remote-Swift.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)
MSSTATIC_STRING_CONST kDeviceCodesetText = @"Device Codes";

CellIndexPathDeclaration(Devices);
CellIndexPathDeclaration(Codesets);

SectionHeadersDeclaration;

@interface ManufacturerViewController ()

@property (nonatomic, weak, readonly) Manufacturer * manufacturer;
@property (nonatomic, strong)         NSArray      * devices;
@property (nonatomic, strong)         NSArray      * codesets;

@end

@implementation ManufacturerViewController

/// initialize
+ (void)initialize {

  if (self == [ManufacturerViewController class]) {

    CellIndexPathDefinition(Devices,  0, 0);
    CellIndexPathDefinition(Codesets, 0, 1);

    SectionHeadersDefinition(@"Devices", @"Codesets");
    
  }

}

/// itemClass
/// @return Class<BankableModel>
- (Class<BankableModel>)itemClass { return [Manufacturer class]; }

/// manufacturer
/// @return Manufacturer *
- (Manufacturer *)manufacturer { return (Manufacturer *)self.item; }

/// devices
/// @return NSArray *
- (NSArray *)devices {
  if (_devices) self.devices = [self.manufacturer.devices allObjects];
  return _devices;
}

/// codesets
/// @return NSArray *
- (NSArray *)codesets {
  if (!_codesets) self.codesets = [self.manufacturer.codesets allObjects];
  return _codesets;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table view data source
////////////////////////////////////////////////////////////////////////////////

/// numberOfSections
/// @return NSInteger
- (NSInteger)numberOfSections { return 2; }

/// numberOfRowsInSection:
/// @param section
/// @return NSInteger
- (NSInteger)numberOfRowsInSection:(NSInteger)section {
  return (section == 0 ? self.devices.count : self.codesets.count);
}

/// sectionHeaderTitles
/// @return NSArray const*
- (NSArray const *)sectionHeaderTitles { return TableSectionHeaders; }

/// identifiers
/// @return NSArray const *
- (NSArray const *)identifiers {

  static NSArray const * identifiers = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    identifiers = @[ @[BankItemCellTableStyleIdentifier],
                     @[BankItemCellTableStyleIdentifier] ];
  });

  return identifiers;

}

/// decorateCell:forIndexPath:
/// @param cell
/// @param indexPath
- (void)decorateCell:(BankItemTableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {

  if ([indexPath isEqual:DevicesCellIndexPath])
    cell.tableData = self.devices;

  else if ([indexPath isEqual:CodesetsCellIndexPath])
    cell.tableData = self.codesets;


  return cell;

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table view delegate
////////////////////////////////////////////////////////////////////////////////

/// tableView:didSelectRowAtIndexPath:
/// @param tableView
/// @param indexPath
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  if (!indexPath.section) {

    ComponentDevice * device = _devices[indexPath.row];

    [self.navigationController pushViewController:device.detailViewController animated:YES];

  }

  else {

    NSString * codeset = _codesets[indexPath.row];

    BOOL isUserCodeset = [codeset isEqualToString:kDeviceCodesetText];

    if (isUserCodeset) codeset = nil;

    NSPredicate * predicate = NSPredicateMake(@"(manufacturer = %@) && (codeset = %@)", self.manufacturer, codeset);

    NSString * groupBy  = (isUserCodeset ? @"device.name" : nil);
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
      BankCollectionController * vc = [[BankCollectionController alloc] initWithItems:controller];
      vc.navigationItem.title = $(@"(%@) %@", self.manufacturer.name, (isUserCodeset ? @"Devices" : codeset));
      [self.navigationController pushViewController:vc animated:YES];
    }

  }
  
}

@end
