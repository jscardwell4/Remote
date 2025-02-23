//
// SwitchToRemoteCommandEditingViewController.m
// Remote
//
// Created by Jason Cardwell on 4/5/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "SwitchToRemoteCommandEditingViewController.h"
//#import "RemoteElement.h"
#import "ViewDecorator.h"
//#import "Remote.h"
#import "Remote-Swift.h"

@interface SwitchToRemoteCommandEditingViewController ()

@property (strong, nonatomic) IBOutlet MSPickerInputButton * pickerInputButton;
@property (nonatomic, strong) NSArray                      * remotes;
@property (nonatomic, strong) Remote                     * selectedRemote;

@end

@implementation SwitchToRemoteCommandEditingViewController
@synthesize
selectedRemote    = _selectedRemote,
pickerInputButton = _pickerInputButton,
remotes           = _remotes,
command           = _command;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [ViewDecorator decorateButton:_pickerInputButton];
    _pickerInputButton.inputView.cancelBarButtonItem = [ViewDecorator
                                                        pickerInputCancelBarButtonItem];
    _pickerInputButton.inputView.selectBarButtonItem = [ViewDecorator
                                                        pickerInputSelectBarButtonItem];

    if (ValueIsNotNil(_command))
    {
//        self.selectedRemote = self.command.remote;
//        self.remotes        = [_command.remote.controller.remotes allObjects];
    }
}

- (void)setSelectedRemote:(Remote *)selectedRemote {
    _selectedRemote = selectedRemote;
    if (ValueIsNotNil(_selectedRemote))
        [_pickerInputButton setTitle:_selectedRemote.name
                            forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self setPickerInputButton:nil];
    if ([self isViewLoaded] && self.view.window == nil) self.view = nil;
}

- (NSInteger)numberOfComponentsInPickerInput:(MSPickerInputView *)pickerInput {
    return 1;
}

- (NSInteger)pickerInput:(MSPickerInputView *)pickerInput numberOfRowsInComponent:(NSInteger)component {
    return [self.remotes count];
}

- (NSString *)pickerInput:(MSPickerInputView *)pickerInput titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return ((Remote *)self.remotes[row]).name;
}

- (void)pickerInputDidCancel:(MSPickerInputView *)pickerInput {
    [_pickerInputButton resignFirstResponder];
}

- (void)pickerInput:(MSPickerInputView *)pickerInput selectedRows:(NSArray *)rows {
    if (ValueIsNotNil(rows)) {
        NSInteger   remoteIndex = [(NSNumber *)rows[0] integerValue];

        self.selectedRemote = self.remotes[remoteIndex];
//        _command.remote  = _selectedRemote;
    }

    [_pickerInputButton resignFirstResponder];
}

@end
