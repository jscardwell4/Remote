//
// SendIRCommandEditingViewController.h
// iPhonto
//
// Created by Jason Cardwell on 4/5/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommandDetailViewController.h"

@interface SendIRCommandEditingViewController : CommandDetailViewController
    <MSPickerInputButtonDelegate>
@property (nonatomic, strong) SendIRCommand * command;
@end
