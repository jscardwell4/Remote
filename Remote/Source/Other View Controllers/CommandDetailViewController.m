//
// CommandDetailViewController.m
//
//
// Created by Jason Cardwell on 4/5/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "CommandDetailViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation CommandDetailViewController
@synthesize
popButton            = _popButton,
commandLabel         = _commandLabel,
delegate             = _delegate,
nestedHeaderView     = _nestedHeaderView,
controllerNested     = _controllerNested,
contentContainerView = _contentContainerView;

@dynamic command;

// - (void)viewWillAppear:(BOOL)animated {
// }

- (void)viewDidLoad {
// self.view.layer.borderWidth = 2.0;
// self.view.layer.borderColor = [[UIColor colorWithRed:0 green:175/255.0 blue:1.0 alpha:1.0]
// CGColor];
    CGFloat   headerHeight = _nestedHeaderView.frame.size.height + 2 * _nestedHeaderView.frame.origin.y;
    CGRect    contentFrame = _contentContainerView.frame;

    _nestedHeaderView.hidden           = !_controllerNested;
    contentFrame.origin.y              = _controllerNested ? headerHeight : 0;
    contentFrame.size.height          += _controllerNested ? 0 : headerHeight;
    _contentContainerView.frame        = contentFrame;
    _popButton.titleLabel.shadowOffset = _commandLabel.shadowOffset;
    [_popButton setTitleColor:_commandLabel.textColor forState:UIControlStateNormal];
    [_popButton setTitleShadowColor:_commandLabel.shadowColor forState:UIControlStateNormal];
    _popButton.titleLabel.font = [UIFont fontWithName:@"Fico" size:14];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if ([parent isMemberOfClass:[CommandEditingViewController class]]) self.delegate = (CommandEditingViewController *)parent;
    else self.delegate = nil;
}

- (IBAction)pop:(id)sender {
    [_delegate popChildController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self setNestedHeaderView:nil];
    [self setContentContainerView:nil];
    [self setPopButton:nil];
    [self setCommandLabel:nil];
    if ([self isViewLoaded] && self.view.window == nil) self.view = nil;
}

@end
