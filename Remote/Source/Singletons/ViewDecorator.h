//
// ViewDecorator.h
// Remote
//
// Created by Jason Cardwell on 4/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
@import Moonkit;
#import "MSRemoteMacros.h"

@interface ViewDecorator : NSObject

+ (UIBarButtonItem *)pickerInputCancelBarButtonItem;
+ (UIBarButtonItem *)pickerInputSelectBarButtonItem;

+ (void)decorateButton:(id)button;

+ (void)decorateButton:(id)button excludedStates:(UIControlState)states;

+ (void)decorateLabel:(UILabel *)label;

+ (NSAttributedString *)fontAwesomeTitleWithName:(NSString *)name size:(CGFloat)size;

+ (MSBarButtonItem *)fontAwesomeBarButtonItemWithName:(NSString *)name
                                               target:(id)target
                                             selector:(SEL)selector;

@end
