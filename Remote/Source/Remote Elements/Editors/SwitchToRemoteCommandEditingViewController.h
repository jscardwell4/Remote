//
// SwitchToRemoteCommandEditingViewController.h
// Remote
//
// Created by Jason Cardwell on 4/5/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
@import CocoaLumberjack;
@import MoonKit;
#import "MSRemoteMacros.h"
#import "Remote-Swift.h"

@import UIKit;
#import "CommandDetailViewController.h"

@interface SwitchToRemoteCommandEditingViewController : CommandDetailViewController
    <MSPickerInputButtonDelegate>

@property (nonatomic, strong) SwitchCommand * command;
@end
