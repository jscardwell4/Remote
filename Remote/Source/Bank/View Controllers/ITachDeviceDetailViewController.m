//
//  ITachDeviceDetailViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/9/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

#import "BankableDetailTableViewController_Private.h"
#import "ITachDeviceDetailViewController.h"
#import "ITachDevice.h"
#import "ComponentDevice.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

CellIndexPathDeclaration(UniqueIdentifier);
CellIndexPathDeclaration(Make);
CellIndexPathDeclaration(Model);
CellIndexPathDeclaration(ConfigURL);
CellIndexPathDeclaration(Revision);
CellIndexPathDeclaration(PcbPN);
CellIndexPathDeclaration(PkgLevel);
CellIndexPathDeclaration(SDKClass);
CellIndexPathDeclaration(ComponentDevices);

static const CGFloat kComponentDevicesTableRowHeight = 120;

@interface ITachDeviceDetailViewController ()

@property (nonatomic, weak) IBOutlet  UITableView * componentDevicesTableView;
@property (nonatomic, weak, readonly) ITachDevice * iTachDevice;
@property (nonatomic, strong)         UINib       * componentDevicesTableViewCellNib;
@property (nonatomic, strong)         NSArray     * componentDevices;

@end

@implementation ITachDeviceDetailViewController

/// initialize
+ (void)initialize {

  if (self == [ITachDeviceDetailViewController class]) {

    CellIndexPathDefinition(UniqueIdentifier, 0, 0);
    CellIndexPathDefinition(Make,             1, 0);
    CellIndexPathDefinition(Model,            2, 0);
    CellIndexPathDefinition(ConfigURL,        3, 0);
    CellIndexPathDefinition(Revision,         4, 0);
    CellIndexPathDefinition(PcbPN,            5, 0);
    CellIndexPathDefinition(PkgLevel,         6, 0);
    CellIndexPathDefinition(SDKClass,         7, 0);
    CellIndexPathDefinition(ComponentDevices, 0, 1);

  }

}

/// itemClass
/// @return Class<Bankable>
- (Class<BankableModel>)itemClass { return [ITachDevice class]; }


/// updateDisplay
- (void)updateDisplay {

  [super updateDisplay];
  [self.componentDevicesTableView reloadData];

}

/// componentDevices
/// @return NSArray *
- (NSArray *)componentDevices {

  if (!_componentDevices && self.iTachDevice)
    _componentDevices = [self.iTachDevice.componentDevices allObjects];

  return _componentDevices;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Aliased properties
////////////////////////////////////////////////////////////////////////////////


/// iTachDevice
/// @return NetworkDevice *
- (ITachDevice *)iTachDevice { return(ITachDevice *)self.item; }

/// setComponentDevicesTableView:
/// @param componentDevicesTableView description
- (void)setComponentDevicesTableView:(UITableView *)componentDevicesTableView {

  _componentDevicesTableView            = componentDevicesTableView;
  _componentDevicesTableView.delegate   = self;
  _componentDevicesTableView.dataSource = self;

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view data source
////////////////////////////////////////////////////////////////////////////////


/// numberOfSectionsInTableView:
/// @param tableView description
/// @return NSInteger
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return (tableView == self.componentDevicesTableView ? 1 : 2);
}

/// tableView:numberOfRowsInSection:
/// @param tableView description
/// @param section description
/// @return NSInteger
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (tableView == self.componentDevicesTableView) return [self.componentDevices count];
  else
    switch (section) {
      case 0:  return 8;
      case 1:  return 1;
      default: return 0;
    }
}

/// tableView:titleForHeaderInSection:
/// @param tableView description
/// @param section description
/// @return NSString *
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return (section == 1 ? @"Component Devices" : nil);
}


/// tableView:cellForRowAtIndexPath:
/// @param tableView description
/// @param indexPath description
/// @return UITableViewCell *
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  // Some static arrays for filling our primary table view cells
  static NSArray const * kNames = nil, * kKeys = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{

    kNames =
      @[@"Identifier", @"Make", @"Model", @"Config-URL", @"Revision", @"PCB_PN", @"Pkg_Level", @"SDKClass"];

    kKeys =
      @[@"uniqueIdentifier", @"make", @"model", @"configURL", @"revision", @"pcbPN", @"pkgLevel", @"sdkClass"];

  });

  // Create a reference for the cell we shall return
  BankableDetailTableViewCell * cell = nil;

  // Check if the cell is for our list of component devices
  if (tableView == self.componentDevicesTableView) {

    cell = [self.componentDevicesTableView dequeueReusableCellWithIdentifier:BankableDetailCellListStyleIdentifier
                                                                forIndexPath:indexPath];

    cell.infoLabel.text = ((ComponentDevice *)self.componentDevices[indexPath.row]).name;

  }

  // Otherwise provide a cell for our primary table view
  else {

    // Check if the cell is for our first section of the primary table view
    if (indexPath.row < kNames.count && indexPath.section == 0) {

      cell = [self.tableView dequeueReusableCellWithIdentifier:BankableDetailCellLabelStyleIdentifier forIndexPath:indexPath];
      cell.name = kNames[indexPath.row];
      cell.infoLabel.text = [self.iTachDevice valueForKey:kKeys[indexPath.row]];

    }

    // Otherwise make sure it is for our cell that will hold the list of component devices
    else if (indexPath.section == 1 && indexPath.row == 0) {

      cell = [self.tableView dequeueReusableCellWithIdentifier:BankableDetailCellTableStyleIdentifier forIndexPath:indexPath];
      self.componentDevicesTableView = cell.infoTableView;

    }

  }

  // Return the cell
  return cell;


}

@end
