//
// CommandDetailViewController.h
//
//
// Created by Jason Cardwell on 4/5/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "CommandEditingViewController.h"

@class Command;

@interface CommandDetailViewController : UIViewController

@property (nonatomic, strong) Command * command;

@property (nonatomic, weak) CommandEditingViewController * delegate;
@property (strong, nonatomic) IBOutlet UIButton          * popButton;
@property (strong, nonatomic) IBOutlet UILabel           * commandLabel;

- (IBAction)pop:(id)sender;

@property (nonatomic, strong) IBOutlet MSView * nestedHeaderView;

@property (nonatomic, strong) IBOutlet UIView * contentContainerView;

@property (nonatomic, assign, getter = isControllerNested) BOOL   controllerNested;

@end
