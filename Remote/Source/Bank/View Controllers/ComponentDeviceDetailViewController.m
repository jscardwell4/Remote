//
//  ComponentDeviceDetailViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/22/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankableDetailTableViewController_Private.h"
#import "ComponentDeviceDetailViewController.h"
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

@interface ComponentDeviceDetailViewController ()

@property (nonatomic, weak, readonly) ComponentDevice * componentDevice;
@property (nonatomic, strong)         NSArray         * inputs;                   // inputsTableView data
@property (nonatomic, strong)         NSArray         * manufacturers;            // picker data
@property (nonatomic, strong)         NSArray         * networkDevices;           // picker data

@end

@implementation ComponentDeviceDetailViewController

/// itemClass
/// @return Class<BankableModel>
- (Class<BankableModel>)itemClass { return [ComponentDevice class]; }

/// initialize
+ (void)initialize {

  if (self == [ComponentDeviceDetailViewController class]) {

    CellIndexPathDefinition(Manufacturer,  0, 0);
    CellIndexPathDefinition(AllCodes,      1, 0);
    CellIndexPathDefinition(NetworkDevice, 0, 1);
    CellIndexPathDefinition(Port,          1, 1);
    CellIndexPathDefinition(PowerOn,       0, 2);
    CellIndexPathDefinition(PowerOff,      1, 2);
    CellIndexPathDefinition(InputPowersOn, 0, 3);
    CellIndexPathDefinition(Inputs,        1, 3);

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
/// @param section description
/// @return NSInteger
- (NSInteger)numberOfRowsInSection:(NSInteger)section { return 2; }

/// sectionHeaderTitles
/// @return NSArray *
- (NSArray *)sectionHeaderTitles { return @[NullObject, @"Network Device", @"Power Commands", @"Inputs"]; }

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
              InputPowersOnCellIndexPath,
              InputsCellIndexPath] set];
  });

  return rows;

}

/// identifiers
/// @return NSArray const *
- (NSArray const *)identifiers {

  static NSArray const * identifiers = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    identifiers = @[ @[BankableDetailCellTextFieldStyleIdentifier,
                       BankableDetailCellDetailStyleIdentifier],
                     @[BankableDetailCellButtonStyleIdentifier,
                       BankableDetailCellStepperStyleIdentifier],
                     @[BankableDetailCellButtonStyleIdentifier,
                       BankableDetailCellButtonStyleIdentifier],
                     @[BankableDetailCellSwitchStyleIdentifier,
                       BankableDetailCellTableStyleIdentifier] ];
  });

  return identifiers;

}

/// tableView:cellForRowAtIndexPath:
/// @param tableView description
/// @param indexPath description
/// @return UITableViewCell *
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  BankableDetailTableViewCell * cell;

  switch (indexPath.section) {

    case 0: {      // Manufacturer and Codes

      switch (indexPath.row) {

        case 0: {
          cell =
          [self dequeueCellForIndexPath:indexPath];
          cell.name = @"Manufacturer";
          cell.info = ([self.componentDevice valueForKeyPath:@"manufacturer.name"] ?: @"No Manufacturer");


          cell.validationHandler = ^BOOL(BankableDetailTableViewCell * cell) {
            NSString * text = cell.info;
            return (text && text.length > 0);
          };


          __weak ComponentDeviceDetailViewController * weakself = self;
          cell.changeHandler = ^(BankableDetailTableViewCell * cell) {

            NSString * text = cell.info;

            if ([@"No Manufacturer" isEqualToString:text]) weakself.componentDevice.manufacturer = nil;

            else {

              Manufacturer * manufacturer =
              [weakself.manufacturers findFirst:^BOOL(Manufacturer * manufacturer) {
                return [manufacturer.name isEqualToString:text];
              }];

              if (!manufacturer) {

                manufacturer =
                [Manufacturer manufacturerWithName:text
                                           context:weakself.componentDevice.managedObjectContext];
                weakself.manufacturers = nil;

              }

              assert(manufacturer);

              weakself.componentDevice.manufacturer = manufacturer;

            }

          };

          cell.pickerSelectionHandler = ^(BankableDetailTableViewCell * cell, NSInteger row) {

            if (row == [weakself.manufacturers lastIndex])
              MSLogDebug(@"right now would be a good time to create a new manufacturer");

            else {

              Manufacturer * selection = weakself.manufacturers[row];
              assert([selection isKindOfClass:[Manufacturer class]]);

              if (selection != weakself.componentDevice.manufacturer)
                weakself.componentDevice.manufacturer = selection;

            }

          };

          cell.pickerData = self.manufacturers;
          cell.pickerSelection = self.componentDevice.manufacturer;

          break;
        }

        case 1: {

          cell = [self dequeueCellForIndexPath:indexPath];
          cell.info = @"Device Codes";
          __weak ComponentDeviceDetailViewController * weakself = self;
          cell.buttonActionHandler = ^(BankableDetailTableViewCell * cell) {
            [weakself viewIRCodes:cell];
          };

          break;
        }
      }

    }

    case 1: {      // Network Device

      switch (indexPath.row) {

        case 0: {          // Network Device Name

          cell      = [self dequeueCellForIndexPath:indexPath];
          cell.name = @"Name";
          cell.info = ([self.componentDevice valueForKeyPath:@"networkDevice.name"]
                       ?: @"No Network Device");

          __weak ComponentDeviceDetailViewController * weakself = self;
          cell.buttonActionHandler = ^(BankableDetailTableViewCell * cell) {
            [cell showPickerView];
          };

          cell.pickerSelectionHandler = ^(BankableDetailTableViewCell * cell, NSInteger row) {

            NetworkDevice * selection = weakself.networkDevices[row];
            self.componentDevice.networkDevice = ([selection isKindOfClass:[NetworkDevice class]]
                                                  ? selection
                                                  : nil);

          };

          cell.pickerData = self.networkDevices;
          cell.pickerSelection = self.componentDevice.networkDevice;

          break;

        }

        case 1: {          // Port

          cell = [self dequeueCellForIndexPath:indexPath];
          cell.name            = @"Port";
          cell.info            = [@(self.componentDevice.port)stringValue];
          cell.stepperMinValue = 1;
          cell.stepperMaxValue = 3;
          cell.stepperWraps    = YES;
          cell.info            = @(self.componentDevice.port);

          __weak ComponentDeviceDetailViewController * weakself = self;
          cell.changeHandler = ^(BankableDetailTableViewCell * cell) {
            weakself.componentDevice.port = (int16_t)[cell.info shortValue];
          };

          break;

        }

      }

      break;

    }

    case 2: {      // Commands

      switch (indexPath.row) {

        case 0: {          // Power On Command

          cell = [self dequeueCellForIndexPath:indexPath];
          cell.name = @"On";
          cell.info = ([self.componentDevice valueForKeyPath:@"onCommand.name"] ?: @"No On Command");

          break;

        }

        case 1: {          // Power Off Command

          cell = [self dequeueCellForIndexPath:indexPath];
          cell.name = @"Off";
          cell.info = ([self.componentDevice valueForKeyPath:@"offCommand.name"] ?: @"No Off Command");

          break;

        }

      }

      break;

    }

    case 3: {      // Inputs

      switch (indexPath.row) {

        case 0: {          // Input powers on device

          cell = [self dequeueCellForIndexPath:indexPath];
          cell.name = @"Inputs Power On Device";
          cell.info = @(self.componentDevice.inputPowersOn);

          __weak ComponentDeviceDetailViewController * weakself = self;
          cell.changeHandler = ^(BankableDetailTableViewCell * cell) {
            weakself.componentDevice.inputPowersOn = [cell.info boolValue];
          };

          break;

        }

        case 1: {          // Inputs table

          cell = [self dequeueCellForIndexPath:indexPath];
          cell.tableData = self.inputs;

          break;

        }

      }

      break;

    }

  }

  return cell;

}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view delegate
////////////////////////////////////////////////////////////////////////////////


/// tableView:accessoryButtonTappedForRowWithIndexPath:
/// @param tableView description
/// @param indexPath description
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
  if ([indexPath isEqual:AllCodesCellIndexPath])
    [self viewIRCodes:nil];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Actions
////////////////////////////////////////////////////////////////////////////////


/// viewIRCodes:
/// @param sender description
- (IBAction)viewIRCodes:(id)sender {

  BankCollectionViewController * vc = UIStoryboardInstantiateSceneByClassName(BankCollectionViewController);
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

    vc.bankableItems = controller;
    vc.itemClass     = [IRCode class];
    [self.navigationController pushViewController:vc animated:YES];

  }

}

@end
