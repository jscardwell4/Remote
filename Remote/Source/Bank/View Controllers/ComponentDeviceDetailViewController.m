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

static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel, msLogContext)


@interface ComponentDeviceDetailViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic)   IBOutlet UIButton    * manufacturerButton;
@property (weak, nonatomic)   IBOutlet UIButton    * deviceNameButton;
@property (weak, nonatomic)   IBOutlet UILabel     * devicePortLabel;
@property (weak, nonatomic)   IBOutlet UIStepper   * devicePortStepper;
@property (weak, nonatomic)   IBOutlet UIButton    * powerOnButton;
@property (weak, nonatomic)   IBOutlet UIButton    * powerOffButton;
@property (weak, nonatomic)   IBOutlet UITableView * inputsTableView;
@property (weak, nonatomic)   IBOutlet UISwitch    * inputPowersOnSwitch;

@property (weak, nonatomic, readonly) ComponentDevice * componentDevice;
@property (strong, nonatomic)         NSArray         * inputs;

@end

@implementation ComponentDeviceDetailViewController

- (ComponentDevice *)componentDevice { return (ComponentDevice *)self.item; }

+ (Class)itemClass { return [ComponentDevice class]; }

- (void)updateDisplay
{
    [super updateDisplay];
    self.inputs = nil;  // TODO: Implement inputs for ComponentDevice
    self.tableDelegate.rowItems = _inputs;

//    NSString * text = ([self.componentDevice valueForKeyPath:@"manufacturer.name"]
//                       ?: @"No Manufacturer");
//    [self.manufacturerButton setTitle:text forState:UIControlStateNormal];
//
//    text = @"No Network Device";  // TODO: implement Network Device for ComponentDevice
//    [self.deviceNameButton setTitle:text forState:UIControlStateNormal];
//
//    self.devicePortLabel.text     = [@(self.componentDevice.port)description];
//    self.devicePortStepper.value  = self.componentDevice.port;
//
//    text = ([self.componentDevice valueForKeyPath:@"onCommand.name"] ?: @"No On Command");
//    [self.powerOnButton setTitle:text forState:UIControlStateNormal];
//
//    text = ([self.componentDevice valueForKeyPath:@"offCommand.name"] ?: @"No Off Command");
//    [self.powerOffButton setTitle:text forState:UIControlStateNormal];
//
//    self.inputPowersOnSwitch.on = self.componentDevice.inputPowersOn;
}

- (NSArray *)editableViews
{
    return [[super editableViews] arrayByAddingObjectsFromArray:@[_manufacturerButton,
                                                                  _deviceNameButton,
                                                                  _devicePortStepper,
                                                                  _powerOnButton,
                                                                  _powerOffButton,
                                                                  _inputPowersOnSwitch]];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    if (editing)
        [self revealAnimationForView:self.devicePortStepper besideView:self.devicePortLabel];

    else
        [self hideAnimationForView:self.devicePortStepper besideView:self.devicePortLabel];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Picker view data source
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 0;
}



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Actions
////////////////////////////////////////////////////////////////////////////////


- (IBAction)selectManufacturer:(id)sender
{
    MSLogDebug(@"");
}

- (IBAction)selectNetworkDevice:(id)sender
{
    MSLogDebug(@"");
}

- (IBAction)portValueDidChange:(UIStepper *)sender
{
    MSLogDebug(@"");
    self.devicePortLabel.text = [@(sender.value) description];
    self.componentDevice.port = (uint16_t)sender.value;
}

- (IBAction)toggleInputPowersOn:(UISwitch *)sender
{
    MSLogDebug(@"");
    self.componentDevice.inputPowersOn = sender.on;
}

- (IBAction)selectOnCommand:(id)sender
{
    MSLogDebug(@"");
}

- (IBAction)selectOffCommand:(id)sender
{
    MSLogDebug(@"");
}

- (IBAction)viewAllCodes:(id)sender
{

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view data source
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 4; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:  return 1;
        case 1:
        case 2:
        case 3:  return 2;
        default: return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 3 && indexPath.row == 1 ? 120 : 38);
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BankableDetailTableViewCell * cell;

    switch (indexPath.section)
    {
        case 3:
        {
            switch (indexPath.row)
            {
                case 1:
                {
                    cell = [self.tableView
                            dequeueReusableCellWithIdentifier:@"InnerTableCellIdentifier"
                                                 forIndexPath:indexPath];
                    UITableView * tableView = (UITableView *)[cell viewWithTag:1];
                    tableView.delegate = self.tableDelegate;
                    tableView.dataSource = self.tableDelegate;
                    self.inputsTableView = tableView;
                    self.tableDelegate.tableView = tableView;
                } break;
                    
                case 0:
                {
                    cell = [self.tableView dequeueReusableCellWithIdentifier:SliderCellIdentifier
                                                                forIndexPath:indexPath];
                    cell.nameLabel.text = @"Inputs Power On Device";
                    cell.infoSwitch.on = self.componentDevice.inputPowersOn;
                    [cell.infoSwitch addTarget:self
                                        action:@selector(toggleInputPowersOn:)
                              forControlEvents:UIControlEventTouchUpInside];
                    self.inputPowersOnSwitch = cell.infoSwitch;
                } break;
            }


        } break;

        case 2:
        {
            switch (indexPath.row)
            {
                case 1:
                {
                    cell = [self.tableView dequeueReusableCellWithIdentifier:ButtonCellIdentifier
                                                                forIndexPath:indexPath];
                    cell.nameLabel.text = @"Off";
                    NSString * text = ([self.componentDevice valueForKeyPath:@"offCommand.name"]
                                       ?: @"No Off Command");
                    [cell.infoButton setTitle:text forState:UIControlStateNormal];
                    [cell.infoButton addTarget:self
                                        action:@selector(selectOffCommand:)
                              forControlEvents:UIControlEventTouchUpInside];
                    self.powerOffButton = cell.infoButton;
                } break;

                case 0:
                {
                    cell = [self.tableView dequeueReusableCellWithIdentifier:ButtonCellIdentifier
                                                                forIndexPath:indexPath];
                    cell.nameLabel.text = @"On";
                    NSString * text = ([self.componentDevice valueForKeyPath:@"onCommand.name"]
                                       ?: @"No On Command");
                    [cell.infoButton setTitle:text forState:UIControlStateNormal];
                    [cell.infoButton addTarget:self
                                        action:@selector(selectOnCommand:)
                              forControlEvents:UIControlEventTouchUpInside];
                    self.powerOnButton = cell.infoButton;
                }
            } break;
        } break;

        case 1:
        {
            switch (indexPath.row)
            {
                case 1:
                {
                    cell = [self.tableView dequeueReusableCellWithIdentifier:StepperCellIdentifier
                                                                forIndexPath:indexPath];
                    cell.nameLabel.text = @"Port";
                    cell.infoLabel.text = [@(self.componentDevice.port)description];
                    self.devicePortLabel = cell.infoLabel;
                    [cell.infoStepper addTarget:self
                                         action:@selector(portValueDidChange:)
                               forControlEvents:UIControlEventTouchUpInside];
                    self.devicePortStepper = cell.infoStepper;
                } break;

                case 0:
                {
                    cell = [self.tableView dequeueReusableCellWithIdentifier:ButtonCellIdentifier
                                                                forIndexPath:indexPath];
                    cell.nameLabel.text = @"Name";
                    [cell.infoButton setTitle:@"No Network Device" forState:UIControlStateNormal];
                    [cell.infoButton addTarget:self
                                        action:@selector(selectNetworkDevice:)
                              forControlEvents:UIControlEventTouchUpInside];
                    self.deviceNameButton = cell.infoButton;
                }
            } break;
        } break;

        case 0:
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:ButtonCellIdentifier
                                                        forIndexPath:indexPath];
            cell.nameLabel.text = @"Manufacturer";
            NSString * text = ([self.componentDevice valueForKeyPath:@"manufacturer.name"]
                               ?: @"No Manufacturer");
            [cell.infoButton setTitle:text forState:UIControlStateNormal];
            [cell.infoButton addTarget:self
                                action:@selector(selectManufacturer:)
                      forControlEvents:UIControlEventTouchUpInside];
            self.manufacturerButton = cell.infoButton;
        } break;
    }

    return cell;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view delegate
////////////////////////////////////////////////////////////////////////////////

- (void)       tableView:(UITableView *)tableView
    didDisplayHeaderView:(UIView *)view
              forSection:(NSInteger)section
{
    if (section == 2)
    {
        UITableViewHeaderFooterView * headerView = (UITableViewHeaderFooterView*)view;
        UIButton                    * button     = [UIButton buttonWithType:UIButtonTypeSystem];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button setTitle:@"View All" forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(viewAllCodes:)
         forControlEvents:UIControlEventTouchUpInside];
        [headerView.contentView addSubview:button];
        [headerView.contentView addConstraints:
         [NSLayoutConstraint
          constraintsByParsingString:@"button.baseline = title.baseline\n"
                                     "button.right = view.right - 20"
          views:@{ @"view" : headerView.contentView,
                   @"title" : headerView.textLabel,
                   @"button" : button }]];
    }
}

@end
