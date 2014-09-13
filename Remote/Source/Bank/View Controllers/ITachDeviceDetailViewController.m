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

SectionHeadersDeclaration

@interface ITachDeviceDetailViewController ()

@property (nonatomic, weak, readonly) ITachDevice * iTachDevice;
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

    SectionHeadersDefinition(NullObject, @"Component Devices");

  }

}

/// itemClass
/// @return Class<Bankable>
- (Class<BankableModel>)itemClass { return [ITachDevice class]; }


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


////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view data source
////////////////////////////////////////////////////////////////////////////////


/// numberOfSections
/// @return NSInteger
- (NSInteger)numberOfSections { return 2; }

/// numberOfRowsInSection:
/// @param section description
/// @return NSInteger
- (NSInteger)numberOfRowsInSection:(NSInteger)section {

  switch (section) {
    case 0:  return 8;
    case 1:  return 1;
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
                       BankableDetailCellLabelStyleIdentifier,
                       BankableDetailCellLabelStyleIdentifier,
                       BankableDetailCellLabelStyleIdentifier,
                       BankableDetailCellLabelStyleIdentifier,
                       BankableDetailCellLabelStyleIdentifier,
                       BankableDetailCellLabelStyleIdentifier,
                       BankableDetailCellLabelStyleIdentifier],
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

    kNames = @[ @"Identifier",
                @"Make",
                @"Model",
                @"Config-URL",
                @"Revision",
                @"PCB_PN",
                @"Pkg_Level",
                @"SDKClass" ];

    kKeys = @[ @"uniqueIdentifier",
               @"make",
               @"model",
               @"configURL",
               @"revision",
               @"pcbPN",
               @"pkgLevel",
               @"sdkClass" ];

  });

  // Check if the cell is for our first section of the primary table view
  if (indexPath.row < kNames.count && indexPath.section == 0) {

    cell.name = kNames[indexPath.row];
    cell.info = [self.iTachDevice valueForKey:kKeys[indexPath.row]];

  }

  // Otherwise make sure it is for our cell that will hold the list of component devices
  else if (indexPath == ComponentDevicesCellIndexPath) cell.info = self.componentDevices;

}

@end
