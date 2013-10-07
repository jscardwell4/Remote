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

static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel, msLogContext)

static NSIndexPath * kManufacturerCellIndexPath;
static NSIndexPath * kNetworkDeviceCellIndexPath;
static NSIndexPath * kPortCellIndexPath;
static NSIndexPath * kPowerOnCellIndexPath;
static NSIndexPath * kPowerOffCellIndexPath;
static NSIndexPath * kInputPowersOnCellIndexPath;
static NSIndexPath * kInputsCellIndexPath;

static const CGFloat kInputsTableRowHeight = 120;

@interface ComponentDeviceDetailViewController ()

@property (nonatomic, weak) IBOutlet UITableView  * inputsTableView;

@property (nonatomic, weak, readonly) ComponentDevice * componentDevice;

@property (nonatomic, strong) UINib * inputsTableViewCellNib;

@property (nonatomic, strong) NSArray * inputs;         // inputsTableView data
@property (nonatomic, strong) NSArray * manufacturers;  // picker data
@property (nonatomic, strong) NSArray * networkDevices; // picker data
@property (nonatomic, strong) NSArray * codes;          // picker data

@end

@implementation ComponentDeviceDetailViewController
{
    __weak ComponentDevice * _componentDevice;
}

- (Class<Bankable>)itemClass { return [ComponentDevice class]; }

+ (void)initialize
{
    if (self == [ComponentDeviceDetailViewController class])
    {
        kManufacturerCellIndexPath  = [NSIndexPath indexPathForRow:0 inSection:0];
        kNetworkDeviceCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        kPortCellIndexPath          = [NSIndexPath indexPathForRow:1 inSection:1];
        kPowerOnCellIndexPath       = [NSIndexPath indexPathForRow:0 inSection:2];
        kPowerOffCellIndexPath      = [NSIndexPath indexPathForRow:1 inSection:2];
        kInputPowersOnCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:3];
        kInputsCellIndexPath        = [NSIndexPath indexPathForRow:1 inSection:3];
    }
}

- (void)updateDisplay
{
    [super updateDisplay];
    [self.inputsTableView reloadData];
}

- (NSArray *)inputs
{
    if (!_inputs)
    {
        // TODO: add inputs to component device model
        _inputs = @[@"➕ New Input"];
    }
    return _inputs;
}

- (UINib *)inputsTableViewCellNib
{
    if (!_inputsTableViewCellNib)
        self.inputsTableViewCellNib = [self nibForIdentifier:LabelListCellIdentifier];

    return _inputsTableViewCellNib;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Aliased properties
////////////////////////////////////////////////////////////////////////////////

- (ComponentDevice *)componentDevice
{
    if (!_componentDevice) _componentDevice = (ComponentDevice *)self.item;
    return _componentDevice;
}

- (void)setInputsTableView:(UITableView *)inputsTableView
{
    _inputsTableView = inputsTableView;
    _inputsTableView.delegate   = self;
    _inputsTableView.dataSource = self;
    [_inputsTableView registerNib:self.inputsTableViewCellNib
           forCellReuseIdentifier:LabelListCellIdentifier];
    //???: reload data here?
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Managing picker views
////////////////////////////////////////////////////////////////////////////////


- (NSArray *)manufacturers
{
    if (!_manufacturers)
    {
        self.manufacturers = [@[@"No Manufacturer",
                                [Manufacturer MR_findAllSortedBy:@"info.name"
                                                       ascending:YES
                                                       inContext:self.item.managedObjectContext],
                                @"➕ New Manufacturer"] flattenedArray];
    }

    return _manufacturers;
}

- (NSArray *)networkDevices
{
    if (!_networkDevices)
    {
        self.networkDevices = @[@"No Network Device", @"➕ New Network Device"];
    }
    return _networkDevices;
}

- (NSArray *)codes
{
    if (!_codes)
        self.codes = [@[[self.componentDevice.codes allObjects], @"➕ New Code"] flattenedArray];

    return _codes;
}

- (id)dataForIndexPath:(NSIndexPath *)indexPath type:(BankableDetailDataType)type
{
    if ([indexPath isEqual:kManufacturerCellIndexPath])
        return (type == BankableDetailPickerButtonData
                ? (self.componentDevice.manufacturer ?: @"No Manufacturer")
                : self.manufacturers);

    else if ([indexPath isEqual:kNetworkDeviceCellIndexPath])
        return (type == BankableDetailPickerButtonData
                ? (self.componentDevice.networkDevice ?: @"No Network Device")
                : self.networkDevices);

    else if ([indexPath isEqual:kPowerOnCellIndexPath])
        return [@[@"No On Command"] arrayByAddingObjectsFromArray:self.codes];

    else if ([indexPath isEqual:kPowerOffCellIndexPath])
        return [@[@"No Off Command"] arrayByAddingObjectsFromArray:self.codes];

    else return nil;
}


- (void)pickerView:(UIPickerView *)pickerView
   didSelectObject:(id)selection
               row:(NSUInteger)row
         indexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:kManufacturerCellIndexPath])
    {
        if (row == [_manufacturers lastIndex])
        {
            MSLogDebug(@"right now would be a good time to create a new manufacturer");
        }

        else if (selection != self.componentDevice.manufacturer)
        {
            self.componentDevice.manufacturer = ([selection isKindOfClass:[Manufacturer class]]
                                                 ? selection
                                                 : nil);
        }


    }

    else if ([indexPath isEqual:kNetworkDeviceCellIndexPath])
    {
        MSLogDebug(@"Network Device for Component Device not yet implemented");
    }
    
    [super pickerView:pickerView didSelectObject:selection row:row indexPath:indexPath];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Actions
////////////////////////////////////////////////////////////////////////////////


- (IBAction)selectOnCommand:(id)sender
{
    MSLogDebug(@"");
    // need to edit or create command here
}

- (IBAction)selectOffCommand:(id)sender
{
    MSLogDebug(@"");
    // need to edit or create command here
}

- (IBAction)viewAllCodes:(id)sender
{
    MSLogDebug(@"");
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view data source
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (tableView == _inputsTableView ? 1 : 4);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _inputsTableView)
        return [self.inputs count];

    else
        return (section ? 2 : 1);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (tableView == _inputsTableView
            ? BankableDetailDefaultRowHeight
            : ([indexPath isEqual:kInputsCellIndexPath]
               ? kInputsTableRowHeight
               : ([indexPath isEqual:self.visiblePickerCellIndexPath]
                  ? BankableDetailExpandedRowHeight
                  : BankableDetailDefaultRowHeight)));
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 1:  return @"Network Device";
        case 2:  return @"Codes";
        case 3:  return @"Inputs";
        default: return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BankableDetailTableViewCell * cell;
    __weak ComponentDeviceDetailViewController * weakself = self;

    if (tableView == _inputsTableView)
    {
        cell = [_inputsTableView dequeueReusableCellWithIdentifier:LabelListCellIdentifier
                                                      forIndexPath:indexPath];
        cell.infoLabel.text = self.inputs[indexPath.row];
    }

    else
        switch (indexPath.section)
        {
            case 0: // Manufacturer
            {
                cell = [self dequeueReusableCellWithIdentifier:ButtonCellIdentifier
                                                  forIndexPath:indexPath];
                cell.nameLabel.text = @"Manufacturer";
                [cell.infoButton setTitle:([self.componentDevice valueForKeyPath:@"manufacturer.name"]
                                           ?: @"No Manufacturer")
                 forState:UIControlStateNormal];

                void (^actionBlock)(void) = ^{
                    id selection = (_componentDevice.manufacturer ?: @"No Manufacturer");
                    [weakself showPickerViewForIndexPath:indexPath selectedObject:selection];
                };

                [cell.infoButton addActionBlock:actionBlock
                               forControlEvents:UIControlEventTouchUpInside];
                [self registerEditableView:cell.infoButton];
            } break;

            case 1: // Network Device
            {
                switch (indexPath.row)
                {
                    case 0: // Network Device Name
                    {
                        cell = [self dequeueReusableCellWithIdentifier:ButtonCellIdentifier
                                                          forIndexPath:indexPath];
                        cell.nameLabel.text = @"Name";
                        [cell.infoButton setTitle:@"No Network Device"
                                         forState:UIControlStateNormal];

                        void (^actionBlock)(void) = ^{
                            id selection = @"No Network Device";
                            [weakself showPickerViewForIndexPath:indexPath selectedObject:selection];
                        };

                        [cell.infoButton addActionBlock:actionBlock
                                       forControlEvents:UIControlEventTouchUpInside];
                        [self registerEditableView:cell.infoButton];
                    } break;

                    case 1: // Port
                    {
                        cell = [self dequeueReusableCellWithIdentifier:StepperCellIdentifier
                                                          forIndexPath:indexPath];
                        cell.nameLabel.text = @"Port";
                        cell.infoLabel.text = [@(self.componentDevice.port) description];
                        cell.infoStepper.minimumValue = 1;
                        cell.infoStepper.maximumValue = 3;
                        cell.infoStepper.wraps = YES;
                        cell.infoStepper.value = self.componentDevice.port;
                        [cell.infoStepper addActionBlock:
                        ^{
                            weakself.componentDevice.port = (int16_t)cell.infoStepper.value;
                            cell.infoLabel.text = [@(cell.infoStepper.value) description];
                        } forControlEvents:UIControlEventValueChanged];
                        [self registerStepper:cell.infoStepper
                                    withLabel:cell.infoLabel
                                 forIndexPath:indexPath];
                    } break;
                }
            } break;

            case 2: // Codes
            {
                switch (indexPath.row)
                {
                    case 0: //Power On Command
                    {
                        cell = [self dequeueReusableCellWithIdentifier:ButtonCellIdentifier
                                                          forIndexPath:indexPath];
                        cell.nameLabel.text = @"On";
                        [cell.infoButton setTitle:([self.componentDevice
                                                    valueForKeyPath:@"onCommand.name"]
                                                   ?: @"No On Command")
                                         forState:UIControlStateNormal];
                        [cell.infoButton addActionBlock:
                        ^{
                            MSLogDebug(@"Need to implement on command selection/creation");
                        } forControlEvents:UIControlEventTouchUpInside];
                        [self registerEditableView:cell.infoButton];
                    } break;

                    case 1: //Power Off Command
                    {
                        cell = [self dequeueReusableCellWithIdentifier:ButtonCellIdentifier
                                                          forIndexPath:indexPath];
                        cell.nameLabel.text = @"Off";
                        [cell.infoButton setTitle:([self.componentDevice
                                                    valueForKeyPath:@"offCommand.name"]
                                                   ?: @"No Off Command")
                                         forState:UIControlStateNormal];
                        [cell.infoButton addActionBlock:
                         ^{
                             MSLogDebug(@"Need to implement off command selection/creation");
                         } forControlEvents:UIControlEventTouchUpInside];
                        [self registerEditableView:cell.infoButton];
                    } break;
                }
            } break;

            case 3: // Inputs
            {
                switch (indexPath.row)
                {
                    case 0: // Input powers on device
                    {
                        cell = [self dequeueReusableCellWithIdentifier:SwitchCellIdentifier
                                                          forIndexPath:indexPath];
                        cell.nameLabel.text = @"Inputs Power On Device";
                        cell.infoSwitch.on = self.componentDevice.inputPowersOn;
                        [cell.infoSwitch addActionBlock:
                         ^{
                             weakself.componentDevice.inputPowersOn = cell.infoSwitch.on;
                         } forControlEvents:UIControlEventValueChanged];
                        [self registerEditableView:cell.infoSwitch];
                    } break;

                    case 1: // Inputs table
                    {
                        cell = [self dequeueReusableCellWithIdentifier:TableCellIdentifier
                                                          forIndexPath:indexPath];
                        self.inputsTableView = cell.infoTableView;
                    } break;
                }
            } break;

        }

    return cell;
}

@end
