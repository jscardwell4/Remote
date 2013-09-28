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

    NSString * text = ([self.componentDevice valueForKeyPath:@"manufacturer.name"]
                       ?: @"No Manufacturer");
    [self.manufacturerButton setTitle:text forState:UIControlStateNormal];

    text = @"No Network Device";  // TODO: implement Network Device for ComponentDevice
    [self.deviceNameButton setTitle:text forState:UIControlStateNormal];

    self.devicePortLabel.text     = [@(self.componentDevice.port)description];
    self.devicePortStepper.value  = self.componentDevice.port;

    text = ([self.componentDevice valueForKeyPath:@"onCommand.name"] ?: @"No On Command");
    [self.powerOnButton setTitle:text forState:UIControlStateNormal];

    text = ([self.componentDevice valueForKeyPath:@"offCommand.name"] ?: @"No Off Command");
    [self.powerOffButton setTitle:text forState:UIControlStateNormal];

    self.inputPowersOnSwitch.on = self.componentDevice.inputPowersOn;
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
        [self revealAnimationForView:_devicePortStepper besideView:_devicePortLabel];

    else
        [self hideAnimationForView:_devicePortStepper besideView:_devicePortLabel];
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
    _devicePortLabel.text = [@(sender.value) description];
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

- (void)tableView:(UITableView *)tableView didDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if (section == 2)
    {
        UITableViewHeaderFooterView * headerView = (UITableViewHeaderFooterView *)view;
        UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button setTitle:@"View All" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(viewAllCodes:) forControlEvents:UIControlEventTouchUpInside];
        [headerView.contentView addSubview:button];
        [headerView.contentView addConstraints:
         [NSLayoutConstraint
          constraintsByParsingString:@"button.baseline = title.baseline\n"
                                      "button.right = view.right - 20"
                               views:@{@"view": headerView.contentView,
                                       @"title": headerView.textLabel,
                                       @"button": button}]];

    }
}

@end
