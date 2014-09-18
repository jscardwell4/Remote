//
//  ComponentDeviceViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/22/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankItemViewController_Private.h"
#import "ComponentDeviceViewController.h"
#import "ComponentDevice.h"
#import "Manufacturer.h"
#import "IRCode.h"
#import "NetworkDevice.h"
#import "BankCollectionViewController.h"


static int       ddLogLevel   = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel, msLogContext)

CellIndexPathDeclaration(Manufacturer);
CellIndexPathDeclaration(AllCodes);
CellIndexPathDeclaration(NetworkDevice);
CellIndexPathDeclaration(Port);
CellIndexPathDeclaration(PowerOn);
CellIndexPathDeclaration(PowerOff);
CellIndexPathDeclaration(InputPowersOn);
CellIndexPathDeclaration(Inputs);

SectionHeadersDeclaration;

@interface ComponentDeviceViewController ()

@property (nonatomic, weak, readonly) ComponentDevice * componentDevice;
@property (nonatomic, strong)         NSArray         * inputs;                   // inputsTableView data
@property (nonatomic, strong)         NSArray         * manufacturers;            // picker data
@property (nonatomic, strong)         NSArray         * networkDevices;           // picker data

@end

@implementation ComponentDeviceViewController

/// itemClass
/// @return Class<BankableModel>
- (Class<BankableModel>)itemClass { return [ComponentDevice class]; }

/// initialize
+ (void)initialize {

  if (self == [ComponentDeviceViewController class]) {

    CellIndexPathDefinition(Manufacturer,  0, 0);
    CellIndexPathDefinition(AllCodes,      1, 0);
    CellIndexPathDefinition(NetworkDevice, 0, 1);
    CellIndexPathDefinition(Port,          1, 1);
    CellIndexPathDefinition(PowerOn,       0, 2);
    CellIndexPathDefinition(PowerOff,      1, 2);
    CellIndexPathDefinition(InputPowersOn, 0, 3);
    CellIndexPathDefinition(Inputs,        1, 3);

    SectionHeadersDefinition(NullObject, @"Network Device", @"Power Commands", @"Inputs");

  }

}

/// inputs
/// @return NSArray *
- (NSArray *)inputs {

  if (!_inputs) {
    // TODO: add inputs to component device model
    _inputs = @[@"➕ New Input"];
  }

  return _inputs;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Aliased properties
////////////////////////////////////////////////////////////////////////////////


/// componentDevice
/// @return ComponentDevice *
- (ComponentDevice *)componentDevice { return (ComponentDevice *)self.item; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Managing picker views
////////////////////////////////////////////////////////////////////////////////


/// manufacturers
/// @return NSArray *
- (NSArray *)manufacturers {

  if (!_manufacturers)
    self.manufacturers = [@[@"No Manufacturer",
                            [Manufacturer findAllSortedBy:@"name"
                                                ascending:YES
                                                  context:self.item.managedObjectContext]] flattened];

  return _manufacturers;

}

/// networkDevices
/// @return NSArray *
- (NSArray *)networkDevices {

  if (!_networkDevices)
    self.networkDevices = [@[@"No Network Device",
                             [NetworkDevice findAllSortedBy:@"name"
                                                  ascending:YES
                                                    context:self.item.managedObjectContext]] flattened];

  return _networkDevices;

}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view data source
////////////////////////////////////////////////////////////////////////////////


/// numberOfSections
/// @return NSInteger
- (NSInteger)numberOfSections { return 4; }

/// numberOfRowsInSection:
/// @param section
/// @return NSInteger
- (NSInteger)numberOfRowsInSection:(NSInteger)section { return 2; }

/// sectionHeaderTitles
/// @return NSArray const *
- (NSArray const *)sectionHeaderTitles { return TableSectionHeaders; }

/// editableRows
/// @return NSSet const *
- (NSSet const *)editableRows {

  static NSSet const * rows = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    rows = [@[ManufacturerCellIndexPath,
              AllCodesCellIndexPath,
              NetworkDeviceCellIndexPath,
              PortCellIndexPath,
              PowerOnCellIndexPath,
              PowerOffCellIndexPath,
              InputPowersOnCellIndexPath] set];
  });

  return rows;

}

/// identifiers
/// @return NSArray const *
- (NSArray const *)identifiers {

  static NSArray const * identifiers = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    identifiers = @[ @[BankItemCellTextFieldStyleIdentifier,
                       BankItemCellDetailStyleIdentifier],
                     @[BankItemCellButtonStyleIdentifier,
                       BankItemCellStepperStyleIdentifier],
                     @[BankItemCellButtonStyleIdentifier,
                       BankItemCellButtonStyleIdentifier],
                     @[BankItemCellSwitchStyleIdentifier,
                       BankItemCellTableStyleIdentifier] ];
  });

  return identifiers;

}

/// decorateCell:forIndexPath:
/// @param cell
/// @param indexPath
- (void)decorateCell:(BankItemTableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {

  __weak ComponentDeviceViewController * weakself = self;

  if (indexPath == ManufacturerCellIndexPath) {

    cell.name = @"Manufacturer";
    cell.info = (self.componentDevice.manufacturer ?: @"No Manufacturer");


    cell.pickerSelectionHandler = ^(BankItemTableViewCell * cell) {
      id selection = cell.pickerSelection;
      weakself.componentDevice.manufacturer = ([selection isKindOfClass:[Manufacturer class]] ? selection : nil);
    };

    cell.pickerData = self.manufacturers;
    cell.pickerSelection = self.componentDevice.manufacturer;

  }

  else if (indexPath == AllCodesCellIndexPath) {

    cell.info = @"Device Codes";

    cell.buttonActionHandler = ^(BankItemTableViewCell * cell) {
      [weakself viewIRCodes:cell];
    };

  }

  else if (indexPath == NetworkDeviceCellIndexPath) {

    cell.name = @"Network Device";
    cell.info = (self.componentDevice.networkDevice ?: @"No Network Device");

    cell.pickerSelectionHandler = ^(BankItemTableViewCell * cell) {
      id selection = cell.pickerSelection;
      weakself.componentDevice.networkDevice = ([selection isKindOfClass:[NetworkDevice class]] ? selection : nil);
    };

    cell.pickerData = self.networkDevices;
    cell.pickerSelection = self.componentDevice.networkDevice;

  }

  else if (indexPath == PortCellIndexPath) {

    cell.name            = @"Port";
    cell.info            = [@(self.componentDevice.port)stringValue];
    cell.stepperMinValue = 1;
    cell.stepperMaxValue = 3;
    cell.stepperWraps    = YES;
    cell.info            = @(self.componentDevice.port);

    cell.changeHandler = ^(BankItemTableViewCell * cell) {
      weakself.componentDevice.port = (int16_t)[cell.info shortValue];
    };

  }

  else if (indexPath == PowerOnCellIndexPath) {

    cell.name = @"On";
    cell.info = (self.componentDevice.onCommand ?: @"No On Command");

  }

  else if (indexPath == PowerOffCellIndexPath) {
    
    cell.name = @"Off";
    cell.info = (self.componentDevice.offCommand ?: @"No Off Command");

  }

  else if (indexPath == InputPowersOnCellIndexPath) {
    
    cell.name = @"Inputs Power On Device";
    cell.info = @(self.componentDevice.inputPowersOn);

    cell.changeHandler = ^(BankItemTableViewCell * cell) {
      weakself.componentDevice.inputPowersOn = [cell.info boolValue];
    };

  }

  else if (indexPath == InputsCellIndexPath)
    cell.info = self.inputs;

}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view delegate
////////////////////////////////////////////////////////////////////////////////


/// tableView:accessoryButtonTappedForRowWithIndexPath:
/// @param tableView
/// @param indexPath
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
  if ([indexPath isEqual:AllCodesCellIndexPath])
    [self viewIRCodes:nil];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Actions
////////////////////////////////////////////////////////////////////////////////


/// viewIRCodes:
/// @param sender
- (IBAction)viewIRCodes:(id)sender {

  UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Bank" bundle:MainBundle];
  BankCollectionViewController * vc = (BankCollectionViewController *)
    [storyBoard instantiateViewControllerWithClassNameIdentifier:[BankCollectionViewController class]];
  vc.navigationItem.title = $(@"%@ Codes", self.componentDevice.name);

  NSFetchedResultsController * controller =
    [IRCode fetchAllGroupedBy:nil
                withPredicate:NSPredicateMake(@"device = %@", self.componentDevice)
                     sortedBy:@"name"
                    ascending:YES
                      context:self.componentDevice.managedObjectContext];

  NSError * error = nil;
  [controller performFetch:&error];

  if (!MSHandleErrors(error)) {

    vc.allItems = controller;
    vc.itemClass     = [IRCode class];
    [self.navigationController pushViewController:vc animated:YES];

  }

}

@end
