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

static const CGFloat kInputsTableRowHeight = 120;

@interface ComponentDeviceDetailViewController ()

@property (nonatomic, weak) IBOutlet  UITableView     * inputsTableView;
@property (nonatomic, weak, readonly) ComponentDevice * componentDevice;
@property (nonatomic, strong)         UINib           * inputsTableViewCellNib;
@property (nonatomic, strong)         NSArray         * inputs;                   // inputsTableView data
@property (nonatomic, strong)         NSArray         * manufacturers;            // picker data
@property (nonatomic, strong)         NSArray         * networkDevices;           // picker data

@end

@implementation ComponentDeviceDetailViewController {
  __weak ComponentDevice * _componentDevice;
}

- (Class<BankableModel>)itemClass { return [ComponentDevice class]; }

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

- (void)updateDisplay {

  [super updateDisplay];
  [self.inputsTableView reloadData];

}

- (NSArray *)inputs {

  if (!_inputs) {
    // TODO: add inputs to component device model
    _inputs = @[@"➕ New Input"];
  }

  return _inputs;
}

- (id)dataForIndexPath:(NSIndexPath *)indexPath type:(BankableDetailDataType)type {

  switch (type) {

    case BankableDetailPickerViewData:
      return ([indexPath isEqual:ManufacturerCellIndexPath]
              ? self.manufacturers
              : self.networkDevices);

    case BankableDetailPickerViewSelection:
      return ([indexPath isEqual:ManufacturerCellIndexPath]
              ? self.componentDevice.manufacturer
              : self.componentDevice.networkDevice);

    case BankableDetailTextFieldData:
      return ([_componentDevice valueForKeyPath:@"manufacturer.name"]
              ?: @"No Manufacturer");

    default:
      return nil;

  }

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Aliased properties
////////////////////////////////////////////////////////////////////////////////

- (void)setItem:(BankableModelObject *)item {

  [super setItem:item];
  _componentDevice = (ComponentDevice *)self.item;

}

- (void)setInputsTableView:(UITableView *)inputsTableView {

  _inputsTableView            = inputsTableView;
  _inputsTableView.delegate   = self;
  _inputsTableView.dataSource = self;

  // ???: reload data here?

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Managing picker views
////////////////////////////////////////////////////////////////////////////////


- (NSArray *)manufacturers {

  if (!_manufacturers)
    self.manufacturers = [@[@"No Manufacturer",
                            [Manufacturer findAllSortedBy:@"name"
                                                ascending:YES
                                                  context:self.item.managedObjectContext]] flattened];

  return _manufacturers;

}

- (NSArray *)networkDevices {

  if (!_networkDevices)
    self.networkDevices = [@[@"No Network Device",
                             [NetworkDevice findAllSortedBy:@"name"
                                                  ascending:YES
                                                    context:self.item.managedObjectContext]] flattened];

  return _networkDevices;

}

- (void)pickerView:(UIPickerView *)pickerView
   didSelectObject:(id)selection
               row:(NSUInteger)row
         indexPath:(NSIndexPath *)indexPath
{

  if ([indexPath isEqual:ManufacturerCellIndexPath]) {

    if (row == [_manufacturers lastIndex])
      MSLogDebug(@"right now would be a good time to create a new manufacturer");

    else if (selection != self.componentDevice.manufacturer)
      self.componentDevice.manufacturer = ([selection isKindOfClass:[Manufacturer class]] ? selection : nil);


  } else if ([indexPath isEqual:NetworkDeviceCellIndexPath])
    self.componentDevice.networkDevice = ([selection isKindOfClass:[NetworkDevice class]] ? selection : nil);

  [super pickerView:pickerView didSelectObject:selection row:row indexPath:indexPath];

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view data source
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return (tableView == _inputsTableView ? 1 : 4);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return (tableView == _inputsTableView ? [self.inputs count] : 2);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return (tableView == _inputsTableView
          ? BankableDetailDefaultRowHeight
          : ([indexPath isEqual:InputsCellIndexPath]
             ? kInputsTableRowHeight
             : ([indexPath isEqual:self.visiblePickerCellIndexPath]
                ? BankableDetailExpandedRowHeight
                : BankableDetailDefaultRowHeight)));
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

  switch (section) {
    case 1:  return @"Network Device";
    case 2:  return @"Power Commands";
    case 3:  return @"Inputs";
    default: return nil;
  }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  BankableDetailTableViewCell * cell;

  if (tableView == _inputsTableView) {

    cell = [_inputsTableView dequeueReusableCellWithIdentifier:BankableDetailCellListStyleIdentifier
                                                  forIndexPath:indexPath];

    cell.infoLabel.text = self.inputs[indexPath.row];

  }

  else
    switch (indexPath.section) {

      case 0: {      // Manufacturer and Codes

        switch (indexPath.row) {

          case 0: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:BankableDetailCellTextFieldStyleIdentifier
                                                        forIndexPath:indexPath];
            cell.name = @"Manufacturer";
            cell.text = ([_componentDevice valueForKeyPath:@"manufacturer.name"] ?: @"No Manufacturer");

            BankableValidationHandler validationHandler = ^{ return (BOOL)(cell.text && cell.text.length > 0); };

            BankableChangeHandler changeHandler = ^{

              NSString * text = cell.text;

              if ([@"No Manufacturer" isEqualToString:text]) _componentDevice.manufacturer = nil;

              else {

                Manufacturer * manufacturer =
                [_manufacturers objectPassingTest:^BOOL (id obj, NSUInteger idx) {
                  return (  [obj isKindOfClass:[Manufacturer class]]
                          && [[obj valueForKey:@"name"] isEqualToString:text]);
                }];

                if (!manufacturer) {

                  manufacturer = [Manufacturer manufacturerWithName:text
                                                            context:_componentDevice.managedObjectContext];
                  _manufacturers = nil;

                }

                assert(manufacturer);

                _componentDevice.manufacturer = manufacturer;

              }

            };

            [self registerTextField:cell.infoTextField
                       forIndexPath:indexPath
                           handlers:@{ BankableValidationHandlerKey : validationHandler,
                                       BankableChangeHandlerKey     : changeHandler }];

            [self registerPickerView:cell.pickerView forIndexPath:indexPath];

            break;
          }

          case 1: {

            cell = [self.tableView dequeueReusableCellWithIdentifier:BankableDetailCellDetailStyleIdentifier
                                                        forIndexPath:indexPath];
            cell.text = @"Device Codes";
            [cell.infoButton addTarget:self
                                action:@selector(viewIRCodes:)
                      forControlEvents:UIControlEventTouchUpInside];
            break;
          }
        }

      }

      case 1: {      // Network Device

        switch (indexPath.row) {

          case 0: {          // Network Device Name

            cell = [self.tableView dequeueReusableCellWithIdentifier:BankableDetailCellButtonStyleIdentifier forIndexPath:indexPath];
            cell.name = @"Name";
            cell.text = ([_componentDevice valueForKeyPath:@"networkDevice.name"] ?: @"No Network Device");

            __weak ComponentDeviceDetailViewController * weakself = self;
            void (^actionBlock)(void) = ^{ weakself.visiblePickerCellIndexPath = indexPath; };

            [cell.infoButton addActionBlock:actionBlock forControlEvents:UIControlEventTouchUpInside];

            [self registerEditableView:cell.infoButton];
            [self registerPickerView:cell.pickerView forIndexPath:indexPath];

            break;

          }

          case 1: {          // Port

            cell = [self.tableView dequeueReusableCellWithIdentifier:BankableDetailCellStepperStyleIdentifier forIndexPath:indexPath];
            cell.name                     = @"Port";
            cell.text                     = [@(self.componentDevice.port)stringValue];
            cell.infoStepper.minimumValue = 1;
            cell.infoStepper.maximumValue = 3;
            cell.infoStepper.wraps        = YES;
            cell.infoStepper.value        = self.componentDevice.port;

            void (^actionBlock)(void) = ^{
              _componentDevice.port = (int16_t)cell.infoStepper.value;
              cell.infoLabel.text   = [@(cell.infoStepper.value)description];
            };

            [cell.infoStepper addActionBlock:actionBlock forControlEvents:UIControlEventValueChanged];

            [self registerStepper:cell.infoStepper withLabel:cell.infoLabel forIndexPath:indexPath];

            break;

          }

        }

        break;

      }

      case 2: {      // Commands

        switch (indexPath.row) {

          case 0: {          // Power On Command

            cell = [self.tableView dequeueReusableCellWithIdentifier:BankableDetailCellButtonStyleIdentifier forIndexPath:indexPath];
            cell.name = @"On";
            cell.text = ([self.componentDevice valueForKeyPath:@"onCommand.name"] ?: @"No On Command");

            void (^actionBlock)(void) = ^{ MSLogDebug(@"Need to implement on command selection/creation"); };

            [cell.infoButton addActionBlock:actionBlock forControlEvents:UIControlEventTouchUpInside];

            [self registerEditableView:cell.infoButton];

            break;

          }

          case 1: {          // Power Off Command

            cell = [self.tableView dequeueReusableCellWithIdentifier:BankableDetailCellButtonStyleIdentifier forIndexPath:indexPath];
            cell.name = @"Off";
            cell.text = ([self.componentDevice valueForKeyPath:@"offCommand.name"] ?: @"No Off Command");

            void (^actionBlock)(void) = ^{ MSLogDebug(@"Need to implement off command selection/creation"); };

            [cell.infoButton addActionBlock:actionBlock forControlEvents:UIControlEventTouchUpInside];

            [self registerEditableView:cell.infoButton];

            break;

          }

        }

        break;

      }

      case 3: {      // Inputs

        switch (indexPath.row) {

          case 0: {          // Input powers on device

            cell = [self.tableView dequeueReusableCellWithIdentifier:BankableDetailCellSwitchStyleIdentifier forIndexPath:indexPath];
            cell.name          = @"Inputs Power On Device";
            cell.infoSwitch.on = _componentDevice.inputPowersOn;

            void (^actionBlock)(void) = ^{ _componentDevice.inputPowersOn = cell.infoSwitch.on; };

            [cell.infoSwitch addActionBlock:actionBlock forControlEvents:UIControlEventValueChanged];

            [self registerEditableView:cell.infoSwitch];

            break;

          }

          case 1: {          // Inputs table

            cell = [self.tableView dequeueReusableCellWithIdentifier:BankableDetailCellTableStyleIdentifier forIndexPath:indexPath];
            self.inputsTableView = cell.infoTableView;

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

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
  if (tableView == self.tableView && [indexPath isEqual:AllCodesCellIndexPath])
    [self viewIRCodes:nil];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Actions
////////////////////////////////////////////////////////////////////////////////

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
    BankFlags bf = vc.bankFlags;
    vc.bankFlags = bf | BankNoSections;
    [self.navigationController pushViewController:vc animated:YES];

  }

}

@end
