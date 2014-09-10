//
//  Bank.m
//  Remote
//
//  Created by Jason Cardwell on 9/13/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "Bank.h"
#import "BankCollectionViewController.h"
#import "BankableDetailTableViewController.h"
#import "BankableModelObject.h"

static int       ddLogLevel   = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel, msLogContext)

@interface Bank ()

@property (nonatomic, strong, readwrite) UIViewController * viewController;

@end

@implementation Bank

/// registeredClasses
/// @return NSArray *
+ (NSArray *)registeredClasses {
  return @[@"IRCode", @"Image", @"ComponentDevice", @"Preset", @"Manufacturer", @"NetworkDevice"];
}

/// viewController
/// @return UIViewController *
- (UIViewController *)viewController {
  if (!_viewController)
    self.viewController = [[UIStoryboard storyboardWithName:@"Bank" bundle:nil]
                           instantiateInitialViewController];

  return _viewController;
}

@end
