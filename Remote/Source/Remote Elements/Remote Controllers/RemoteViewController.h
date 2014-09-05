//
// RemoteViewController.h
// Remote
//
// Created by Jason Cardwell on 5/3/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
#import "MSKit/MSKit.h"
#import "MSRemoteMacros.h"

@class RemoteController;

/// `RemoteViewController` is the `UIViewController` subclass responsible for controlling the
/// display of the home theater remote control user interface. It utilizes the <RemoteController>
/// model object to coordinate the switching in and out of <RemoteView> subviews that provide the
/// various screens of the overall controller. It also maintains it's own toolbar providing such
/// actions as launching its <RemoteEditingViewController> for editing the current remote and basics
/// like returning to the launch screen.
@interface RemoteViewController : UIViewController<UIGestureRecognizerDelegate>

/// @name ￼Getting the RemoteViewController

+ (instancetype)viewControllerWithModel:(RemoteController *)model;

@property (nonatomic, weak, readonly) RemoteController * remoteController;

@end
