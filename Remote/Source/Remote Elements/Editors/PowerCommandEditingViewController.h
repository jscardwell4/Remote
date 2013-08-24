//
// PowerCommandEditingViewController.h
// Remote
//
// Created by Jason Cardwell on 4/5/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommandDetailViewController.h"

@interface PowerCommandEditingViewController : CommandDetailViewController <MSPickerInputButtonDelegate>

@property (nonatomic, strong) REPowerCommand * command;

@end
