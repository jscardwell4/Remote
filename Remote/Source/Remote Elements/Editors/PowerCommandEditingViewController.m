//
// PowerCommandEditingViewController.m
// Remote
//
// Created by Jason Cardwell on 4/5/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "PowerCommandEditingViewController.h"
#import "ComponentDevice.h"
#import "ViewDecorator.h"

@interface PowerCommandEditingViewController ()
@property (strong, nonatomic) IBOutlet MSPickerInputButton * deviceButton;
@property (strong, nonatomic) IBOutlet UIButton            * stateButton;
@property (nonatomic, strong) NSArray                      * devices;
@property (nonatomic, strong) ComponentDevice              * selectedDevice;
- (IBAction)toggleState:(id)sender;

@end

@implementation PowerCommandEditingViewController
@synthesize
selectedDevice = _selectedDevice,
devices        = _devices,
deviceButton   = _deviceButton,
stateButton    = _stateButton,
command        = _command;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [ViewDecorator decorateButton:_deviceButton];
    _deviceButton.inputView.cancelBarButtonItem = [ViewDecorator pickerInputCancelBarButtonItem];
    _deviceButton.inputView.selectBarButtonItem = [ViewDecorator pickerInputSelectBarButtonItem];

    self.selectedDevice = _command.device;

    [_stateButton setTitle:_command.state ? @"On":@"Off" forState:UIControlStateNormal];
}

- (void)setSelectedDevice:(ComponentDevice *)selectedDevice {
    _selectedDevice = selectedDevice;
    if (ValueIsNotNil(_selectedDevice)) [_deviceButton setTitle:_selectedDevice.name forState:UIControlStateNormal];
    else [_deviceButton setTitle:@"Select Device" forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self setDeviceButton:nil];
    [self setStateButton:nil];
    if ([self isViewLoaded] && self.view.window == nil) self.view = nil;
}

- (NSArray *)devices {
    if (ValueIsNotNil(_devices)) return _devices;

    NSManagedObjectContext * context = _command.managedObjectContext;

    [context performBlockAndWait:^{
                 NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
                 NSEntityDescription * entity = [NSEntityDescription entityForName:@"ComponentDevice"
                                                   inManagedObjectContext:context];
                 [fetchRequest setEntity:entity];

                 NSError * error = nil;
                 self.devices = [context          executeFetchRequest:fetchRequest
                                                       error:&error];
                 if (_devices == nil) self.devices = @[];
             }

    ];

    return _devices;
}

- (NSInteger)numberOfComponentsInPickerInput:(MSPickerInputView *)pickerInput {
    return 1;
}

- (NSInteger)   pickerInput:(MSPickerInputView *)pickerInput
    numberOfRowsInComponent:(NSInteger)component {
    return [self.devices count];
}

- (NSString *)pickerInput:(MSPickerInputView *)pickerInput
              titleForRow:(NSInteger)row
             forComponent:(NSInteger)component {
    return ((ComponentDevice *)self.devices[row]).name;
}

- (void)pickerInputDidCancel:(MSPickerInputView *)pickerInput {
    [_deviceButton resignFirstResponder];
}

- (void)pickerInput:(MSPickerInputView *)pickerInput selectedRows:(NSArray *)rows {
    if (ValueIsNotNil(rows)) {
        NSInteger   deviceIndex = [(NSNumber *)rows[0] integerValue];

        self.selectedDevice = self.devices[deviceIndex];
        _command.device     = _selectedDevice;
    }

    [_deviceButton resignFirstResponder];
}

- (IBAction)toggleState:(id)sender {
    _command.state = !_command.state;
    [_stateButton setTitle:_command.state ? @"On":@"Off" forState:UIControlStateNormal];
}

@end
