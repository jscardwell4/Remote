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
#import "CoreDataManager.h"
#import "Remote.h"

static id _sharedInstance;

@interface Editor ()

@property (nonatomic, strong, readwrite) UIViewController * viewController;

@end

@implementation Editor

- (UIViewController *)viewController {
  if (!_viewController) {
    RemoteEditingViewController * editorVC = [StoryboardProxy remoteEditingViewController];
    editorVC.remoteElement = [Remote createInContext:[CoreDataManager defaultContext]];;
    editorVC.delegate      = nil;
    self.viewController    = editorVC;
  }

  return _viewController;
}

@end
