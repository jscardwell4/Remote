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

SectionHeadersDeclaration;

@interface ISYDeviceDetailViewController ()

@property (nonatomic, weak, readonly) ISYDevice   * iSYDevice;
@property (nonatomic, strong)         NSArray     * devices;
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

    SectionHeadersDefinition(NullObject, @"Model", @"Manufacturer", @"Nodes", @"Groups", @"Component Devices");

  }

}

/// itemClass
/// @return Class<Bankable>
- (Class<BankableModel>)itemClass { return [ISYDevice class]; }


/// iSYDevice
/// @return NetworkDevice *
- (ISYDevice *)iSYDevice { return(ISYDevice *)self.item; }

/// devices
/// @return NSArray *
- (NSArray *)devices { if (!_devices) _devices = [self.iSYDevice.componentDevices allObjects]; return _devices; }

/// nodes
/// @return NSArray *
- (NSArray *)nodes { if (!_nodes) _nodes = [self.iSYDevice.nodes allObjects]; return _nodes; }
/// groups
/// @return NSArray *
- (NSArray *)groups { if (!_groups) _groups = [self.iSYDevice.groups allObjects]; return _groups; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view data source
////////////////////////////////////////////////////////////////////////////////


/// numberOfSections
/// @return NSInteger
- (NSInteger)numberOfSections { return 6; }

/// numberOfRowsInSection:
/// @param section description
/// @return NSInteger
- (NSInteger)numberOfRowsInSection:(NSInteger)section {
  switch (section) {
    case 0:
    case 2:  return 2;
    case 1:  return 4;
    case 3:
    case 4:
    case 5:  return 1;
    default: return 0;
  }
}

/// sectionHeaderTitles
/// @return NSArray const *
- (NSArray const *)sectionHeaderTitles { return TableSectionHeaders; }

/// identifiers
/// @return NSArray const *
- (NSArray const *)identifiers {

  static NSArray const * identifiers = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    identifiers = @[ @[BankableDetailCellLabelStyleIdentifier,
                       BankableDetailCellLabelStyleIdentifier],
                     @[BankableDetailCellLabelStyleIdentifier,
                       BankableDetailCellLabelStyleIdentifier,
                       BankableDetailCellLabelStyleIdentifier,
                       BankableDetailCellLabelStyleIdentifier],
                     @[BankableDetailCellLabelStyleIdentifier,
                       BankableDetailCellLabelStyleIdentifier],
                     @[BankableDetailCellTableStyleIdentifier],
                     @[BankableDetailCellTableStyleIdentifier],
                     @[BankableDetailCellTableStyleIdentifier] ];
  });

  return identifiers;

}

/// decorateCell:forIndexPath:
/// @param cell description
/// @param indexPath description
- (void)decorateCell:(BankableDetailTableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {

  // Some static arrays for filling our primary table view cells
  static NSArray const * kNames = nil, * kKeys = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{

    kNames = @[ @[ @"Identifier", @"Base URL" ],
                @[ @"Name", @"Number", @"Description", @"Friendly Name" ],
                @[ @"Name", @"URL" ] ];

    kKeys = @[ @[ @"uniqueIdentifier", @"baseURL" ],
               @[ @"modelName", @"modelNumber", @"modelDescription", @"friendlyName" ],
               @[ @"manufacturer", @"manufacturerURL" ] ];

  });


  // Check if the cell is for our first section of the primary table view
  if (indexPath.section < [kNames count] && indexPath.row < [kNames[indexPath.section] count]) {

    cell.name = kNames[indexPath.section][indexPath.row];
    cell.info = [self.iSYDevice valueForKey:kKeys[indexPath.section][indexPath.row]];

  }

  else if (indexPath == ComponentDevicesCellIndexPath) cell.info = self.devices;

  else if (indexPath == NodesCellIndexPath) cell.info = self.nodes;

  else if (indexPath == GroupsCellIndexPath) cell.info = self.groups;

}

@end
