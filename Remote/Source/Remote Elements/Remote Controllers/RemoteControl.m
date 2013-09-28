//
//  RemoteControl.m
//  Remote
//
//  Created by Jason Cardwell on 9/13/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "RemoteControl.h"
#import "RemoteViewController.h"

static id _sharedInstance;

@interface RemoteControl ()

@property (nonatomic, strong, readwrite) UIViewController * viewController;

@end

@implementation RemoteControl

- (UIViewController *)viewController
{
    if (!_viewController)
    {
        self.viewController = [RemoteViewController new];
    }
    
    return _viewController;
}

@end
