//
// CommandEditingViewController.h
// Remote
//
// Created by Jason Cardwell on 4/2/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
#import "MSKit/MSKit.h"
#import "MSRemoteMacros.h"

#import "AttributeEditingViewController.h"

@class   Command;

@interface CommandEditingViewController : AttributeEditingViewController <MSPickerInputButtonDelegate>

+ (NSString *)titleForClassOfCommand:(Command *)command;

+ (NSArray *)createableCommands;

+ (NSDictionary *)commandTypes;

- (void)pushChildControllerForCommand:(Command *)command;

- (void)popChildController;

@end
