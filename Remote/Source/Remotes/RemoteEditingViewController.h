//
// RemoteEditingViewController.h
// iPhonto
//
// Created by Jason Cardwell on 5/26/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

// #import <UIKit/UIKit.h>
// #import <QuartzCore/QuartzCore.h>
#import "RemoteElementEditingViewController.h"

// #import "RemoteView.h"
// @class ButtonGroupView;
// @class ButtonView;
// @class Remote;
@class   RemoteView;

@protocol RemoteEditing <NSObject>

- (void)didFinishEditingRemote:(RemoteView *)remote;

@end

@interface RemoteEditingViewController : RemoteElementEditingViewController @end
