//
//  Editor.m
//  Remote
//
//  Created by Jason Cardwell on 9/14/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "Editor.h"
#import "StoryboardProxy.h"
#import "RemoteElementEditingViewController.h"
#import "RemoteElement.h"

@interface Editor ()

@property (nonatomic, strong, readwrite) UIViewController * viewController;

@end

@implementation Editor

- (UIViewController *)viewController
{
    if (!_viewController)
    {
        RemoteEditingViewController * editorVC = [StoryboardProxy remoteEditingViewController];
        Remote * remote   = [Remote remoteElementInContext:[NSManagedObjectContext MR_defaultContext]];

        editorVC.remoteElement = remote;
        editorVC.delegate      = nil;
        self.viewController = editorVC;
    }

    return _viewController;
}

@end
