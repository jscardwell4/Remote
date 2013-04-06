//
// SendIRCommandEditingViewController.m
// Remote
//
// Created by Jason Cardwell on 4/5/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "SendIRCommandEditingViewController.h"
#import "BankObject.h"
#import "BankObject.h"
#import "ViewDecorator.h"

@interface SendIRCommandEditingViewController ()

@property (strong, nonatomic) IBOutlet MSPickerInputButton * deviceButton;
@property (strong, nonatomic) IBOutlet UIButton            * codeButton;

@property (nonatomic, strong) NSArray * devices;
@property (nonatomic, strong) NSArray * codes;

@property (nonatomic, strong) BOComponentDevice * selectedDevice;
@property (nonatomic, strong) BOIRCode          * selectedCode;

- (IBAction)showPicker:(id)sender;

@end

@implementation SendIRCommandEditingViewController
@synthesize
codes          = _codes,
deviceButton   = _deviceButton,
selectedCode   = _selectedCode,
selectedDevice = _selectedDevice,
devices        = _devices,
codeButton     = _codeButton,
command        = _command;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [ViewDecorator decorateButton:_deviceButton];
    _deviceButton.inputView.cancelBarButtonItem = [ViewDecorator pickerInputCancelBarButtonItem];
    _deviceButton.inputView.selectBarButtonItem = [ViewDecorator pickerInputSelectBarButtonItem];

    [ViewDecorator decorateButton:_codeButton];

    self.selectedDevice = _command.device;
    _selectedCode       = _command.code;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self setDeviceButton:nil];
    [self setCodeButton:nil];
    if ([self isViewLoaded] && self.view.window == nil) self.view = nil;
}

- (IBAction)showPicker:(id)sender {
    [_deviceButton becomeFirstResponder];
}

- (NSInteger)numberOfComponentsInPickerInput:(MSPickerInputView *)pickerInput {
    return 2;
}

- (NSInteger)   pickerInput:(MSPickerInputView *)pickerInput
    numberOfRowsInComponent:(NSInteger)component {
    return component == 0 ?[self.devices count] :[self.codes count];
}

- (NSString *)pickerInput:(MSPickerInputView *)pickerInput
              titleForRow:(NSInteger)row
             forComponent:(NSInteger)component {
    NSString * title = nil;

    if (component == 0) title = ((BOComponentDevice *)self.devices[row]).name;
    else title = ((BOIRCode *)self.codes[row]).name;

    return title;
}

- (void)pickerInput:(MSPickerInputView *)pickerInput
       didSelectRow:(NSInteger)row
        inComponent:(NSInteger)component {
    if (component == 0) {
        self.selectedDevice = self.devices[row];
        [pickerInput reloadComponent:1];
    }
}

- (void)pickerInputButtonWillShowPicker:(MSPickerInputButton *)pickerInputButton {
    NSInteger   deviceIndex = 0;

    if (ValueIsNotNil(_selectedDevice)) deviceIndex = [self.devices indexOfObject:_selectedDevice];

    NSInteger   codeIndex = 0;

    if (ValueIsNotNil(_selectedCode)) codeIndex = [self.codes indexOfObject:_selectedCode];

    [pickerInputButton selectRow:deviceIndex inComponent:0 animated:NO];
    [pickerInputButton selectRow:codeIndex inComponent:1 animated:NO];
}

- (void)pickerInputDidCancel:(MSPickerInputView *)pickerInput {
    self.selectedDevice = _command.device;
    self.selectedCode   = _command.code;
    [_deviceButton resignFirstResponder];
}

- (void)pickerInput:(MSPickerInputView *)pickerInput selectedRows:(NSArray *)rows {
    if (ValueIsNotNil(rows)) {
// NSInteger deviceIndex = [(NSNumber *) rows[0] integerValue];
// self.selectedDevice = self.devices[deviceIndex];

        NSInteger   codeIndex = [(NSNumber *)rows[1] integerValue];

        self.selectedCode = self.codes[codeIndex];

        _command.code = _selectedCode;
    }

    [_deviceButton resignFirstResponder];
}

- (void)setSelectedCode:(BOIRCode *)selectedCode {
    _selectedCode = selectedCode;
    if (ValueIsNotNil(_selectedCode))
        [_codeButton setTitle:_selectedCode.name forState:UIControlStateNormal];
// [_deviceButton setTitle:_selectedCode.device.deviceName forState:UIControlStateNormal];
// _selectedDevice = _selectedCode.device;
    else
        [_codeButton setTitle:@"Select Code" forState:UIControlStateNormal];
// if (ValueIsNil(_selectedDevice))
// _codeButton.enabled = NO;
}

- (void)setSelectedDevice:(BOComponentDevice *)selectedDevice {
    _selectedDevice = selectedDevice;
    if (ValueIsNotNil(_selectedDevice)) {
        [_deviceButton setTitle:_selectedDevice.name forState:UIControlStateNormal];
// _codeButton.enabled = YES;
        self.codes = [_selectedDevice.codes allObjects];
    } else {
        [_deviceButton setTitle:@"Select Device" forState:UIControlStateNormal];
        _selectedCode = nil;
        self.codes    = nil;
    }
}

- (NSArray *)devices {
    if (ValueIsNotNil(_devices)) return _devices;

    NSManagedObjectContext * context = _command.managedObjectContext;

    [context performBlockAndWait:^{
                 NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ComponentDevice"];

                 NSError * error = nil;
                 self.devices = [context          executeFetchRequest:fetchRequest
                                                       error:&error];
                 if (_devices == nil) self.devices = [NSArray array];
             }

    ];

    return _devices;
}

@end
