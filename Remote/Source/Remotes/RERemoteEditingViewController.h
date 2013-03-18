//
// RemoteEditingViewController.h
// Remote
//
// Created by Jason Cardwell on 5/26/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

// #import <UIKit/UIKit.h>
// #import <QuartzCore/QuartzCore.h>
#import "REEditingViewController.h"

// #import "RemoteView.h"
// @class ButtonGroupView;
// @class ButtonView;
// @class Remote;
@class   RERemoteView;

@protocol RERemoteEditing <NSObject>

- (void)didFinishEditingRemote:(RERemoteView *)remote;

@end

@interface RERemoteEditingViewController : REEditingViewController @end
