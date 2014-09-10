//
//  ISYDeviceDetailViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/9/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

#import "BankableDetailTableViewController_Private.h"
#import "ISYDeviceDetailViewController.h"
#import "ComponentDevice.h"
#import "ISYDevice.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

CellIndexPathDeclaration(UniqueIdentifier);
CellIndexPathDeclaration(BaseURL);
CellIndexPathDeclaration(ModelName);
CellIndexPathDeclaration(ModelNumber);
CellIndexPathDeclaration(ModelDescription);
CellIndexPathDeclaration(FriendlyName);
CellIndexPathDeclaration(Manufacturer);
CellIndexPathDeclaration(ManufacturerURL);
CellIndexPathDeclaration(Nodes);
CellIndexPathDeclaration(Groups);
CellIndexPathDeclaration(ComponentDevices);

static const CGFloat kComponentDevicesTableRowHeight = 120;

@interface ISYDeviceDetailViewController ()

@property (nonatomic, weak) IBOutlet  UITableView * componentDevicesTableView;
@property (nonatomic, weak) IBOutlet  UITableView * nodesTableView;
@property (nonatomic, weak) IBOutlet  UITableView * groupsTableView;
@property (nonatomic, weak, readonly) ISYDevice   * iSYDevice;
@property (nonatomic, strong)         UINib       * subTableViewCellNib;
@property (nonatomic, strong)         NSArray     * componentDevices;
@property (nonatomic, strong)         NSArray     * nodes;
@property (nonatomic, strong)         NSArray     * groups;

@end


@implementation ISYDeviceDetailViewController

/// initialize
+ (void)initialize {

  if (self == [ISYDeviceDetailViewController class]) {


    CellIndexPathDefinition(UniqueIdentifier, 0, 0);
    CellIndexPathDefinition(BaseURL,          1, 0);
		CellIndexPathDefinition(ModelName,        0, 1);
    CellIndexPathDefinition(ModelNumber,      1, 1);
    CellIndexPathDefinition(ModelDescription, 2, 1);
    CellIndexPathDefinition(FriendlyName,     3, 1);
    CellIndexPathDefinition(Manufacturer,     0, 2);
    CellIndexPathDefinition(ManufacturerURL,  1, 2);
    CellIndexPathDefinition(Nodes,            0, 3);
    CellIndexPathDefinition(Groups,           0, 4);
    CellIndexPathDefinition(ComponentDevices, 0, 5);

  }

}

/// itemClass
/// @return Class<Bankable>
- (Class<BankableModel>)itemClass { return [ISYDevice class]; }

/// updateDisplay
- (void)updateDisplay {

  [super updateDisplay];
  [self.componentDevicesTableView reloadData];
  [self.nodesTableView            reloadData];
  [self.groupsTableView           reloadData];

}

/// componentDevices
/// @return NSArray *
- (NSArray *)componentDevices {

  if (!_componentDevices && self.iSYDevice)
    _componentDevices = [self.iSYDevice.componentDevices allObjects];

  return _componentDevices;
}

/// nodes
/// @return NSArray *
- (NSArray *)nodes {

  if (!_nodes && self.iSYDevice)
    _nodes = [self.iSYDevice.nodes allObjects];

  return _nodes;
}

/// groups
/// @return NSArray *
- (NSArray *)groups {

  if (!_groups && self.iSYDevice)
    _groups = [self.iSYDevice.groups allObjects];

  return _groups;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Aliased properties
////////////////////////////////////////////////////////////////////////////////


/// iSYDevice
/// @return NetworkDevice *
- (ISYDevice *)iSYDevice { return(ISYDevice *)self.item; }

/// setComponentDevicesTableView:
/// @param componentDevicesTableView description
- (void)setComponentDevicesTableView:(UITableView *)componentDevicesTableView {

  _componentDevicesTableView            = componentDevicesTableView;
  _componentDevicesTableView.delegate   = self;
  _componentDevicesTableView.dataSource = self;

}

/// setNodesTableView:
/// @param nodesTableView description
- (void)setNodesTableView:(UITableView *)nodesTableView {

  _nodesTableView            = nodesTableView;
  _nodesTableView.delegate   = self;
  _nodesTableView.dataSource = self;

}

/// setGroupsTableView:
/// @param groupsTableView description
- (void)setGroupsTableView:(UITableView *)groupsTableView {

  _groupsTableView            = groupsTableView;
  _groupsTableView.delegate   = self;
  _groupsTableView.dataSource = self;

}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view data source
////////////////////////////////////////////////////////////////////////////////

/// tableView:heightForRowAtIndexPath:
/// @param tableView description
/// @param indexPath description
/// @return CGFloat
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section > 2) return 120.0;
  else return 37.0;
}


/// numberOfSectionsInTableView:
/// @param tableView description
/// @return NSInteger
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (tableView == self.tableView ? 6 : 1);
}

/// tableView:numberOfRowsInSection:
/// @param tableView description
/// @param section description
/// @return NSInteger
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (tableView == self.componentDevicesTableView) return [self.componentDevices count];
  else if (tableView == self.nodesTableView)       return [self.nodes            count];
  else if (tableView == self.groupsTableView)      return [self.groups           count];
  else
    switch (section) {
      case 0:  return 2;
      case 1:  return 4;
      case 2:  return 2;
      case 3:
      case 4:
      case 5:  return 1;
      default: return 0;
    }
}

/// tableView:titleForHeaderInSection:
/// @param tableView description
/// @param section description
/// @return NSString *
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

	switch (section) {
    case 1:  return @"Model";
    case 2:  return @"Manufacturer";
		case 3:  return @"Nodes";
		case 4:  return @"Groups";
		case 5:  return @"Component Devices";
		default: return nil;

	}

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
      @[@[@"Identifier", @"Base URL"], @[@"Name", @"Number", @"Description",
        @"Friendly Name"], @[@"Name", @"URL"]];

    kKeys =
    @[@[@"uniqueIdentifier", @"baseURL"], @[@"modelName", @"modelNumber", @"modelDescription",
        @"friendlyName"], @[@"manufacturer", @"manufacturerURL"]];

  });

  // Create a reference for the cell we shall return
  BankableDetailTableViewCell * cell = nil;

  // Check if the cell is for our list of component devices
  if (tableView == self.componentDevicesTableView) {

    cell =
    [self.componentDevicesTableView dequeueReusableCellWithIdentifier:BankableDetailCellListStyleIdentifier
                                                         forIndexPath:indexPath];

    cell.infoLabel.text = ((ComponentDevice *)self.componentDevices[indexPath.row]).name;

  }

  else if (tableView == self.nodesTableView) {

    cell = [self.nodesTableView dequeueReusableCellWithIdentifier:BankableDetailCellListStyleIdentifier
                                                     forIndexPath:indexPath];

    cell.infoLabel.text = ((ISYDeviceNode *)self.nodes[indexPath.row]).name;
    
  }

  else if (tableView == self.groupsTableView) {

    cell = [self.groupsTableView dequeueReusableCellWithIdentifier:BankableDetailCellListStyleIdentifier
                                                      forIndexPath:indexPath];

    cell.infoLabel.text = ((ISYDeviceGroup *)self.groups[indexPath.row]).name;
    
  }

  // Otherwise provide a cell for our primary table view
  else {

    // Check if the cell is for our first section of the primary table view
    if (indexPath.section < [kNames count] && indexPath.row < [kNames[indexPath.section] count]) {

      cell = [self.tableView dequeueReusableCellWithIdentifier:BankableDetailCellLabelStyleIdentifier
                                                  forIndexPath:indexPath];
      cell.name = kNames[indexPath.section][indexPath.row];
      cell.infoLabel.text = [self.iSYDevice valueForKey:kKeys[indexPath.section][indexPath.row]];

    }

    // Otherwise make sure it is for our cell that will hold the list of component devices
    else if (indexPath == ComponentDevicesCellIndexPath) {

      cell = [self.tableView dequeueReusableCellWithIdentifier:BankableDetailCellTableStyleIdentifier
                                                  forIndexPath:indexPath];
      self.componentDevicesTableView = cell.infoTableView;

    }

    else if (indexPath == NodesCellIndexPath) {

      cell = [self.tableView dequeueReusableCellWithIdentifier:BankableDetailCellTableStyleIdentifier
                                                  forIndexPath:indexPath];
      self.nodesTableView = cell.infoTableView;

    }

    else if (indexPath == GroupsCellIndexPath) {

      cell = [self.tableView dequeueReusableCellWithIdentifier:BankableDetailCellTableStyleIdentifier
                                                  forIndexPath:indexPath];
      self.groupsTableView = cell.infoTableView;

    }

  }

  // Return the cell
  return cell;


}

@end
