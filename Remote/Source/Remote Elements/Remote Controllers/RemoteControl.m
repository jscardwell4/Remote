//
//  RemoteControl.m
//  Remote
//
//  Created by Jason Cardwell on 9/13/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "RemoteControl.h"
#import "RemoteViewController.h"

@interface RemoteControl ()

@property (nonatomic, assign) RemoteViewController * remoteViewController;
@property (nonatomic, strong, readwrite) UIViewController * viewController;

@end

@implementation RemoteControl

- (RemoteViewController *)viewController
{
    if (!_remoteViewController)
    {
        self.viewController = [RemoteViewController new];
        self.remoteViewController = (RemoteViewController *)_viewController;
    }
    
    return _remoteViewController;
}

@end
