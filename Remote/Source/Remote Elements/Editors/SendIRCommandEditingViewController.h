//
// SendIRCommandEditingViewController.h
// Remote
//
// Created by Jason Cardwell on 4/5/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
@import MoonKit;
#import "MSRemoteMacros.h"

@import UIKit;
#import "CommandDetailViewController.h"

@interface SendIRCommandEditingViewController : CommandDetailViewController
    <MSPickerInputButtonDelegate>
@property (nonatomic, strong) SendIRCommand * command;
@end
