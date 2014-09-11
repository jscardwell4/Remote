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
@import ObjectiveC;

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

  static NSArray * classes = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{

    unsigned int outcount = 0;
    Class * allClasses = objc_copyClassList(&outcount);
    NSMutableArray * bankableModelClasses = [@[] mutableCopy];

    // Build a list of classes that inherit `BankableModel` conformance
    for (unsigned int i = 0; i < outcount; i++) {

      Class class = allClasses[i];
      while ( class && class_getSuperclass(class) != [BankableModelObject class])
        class = class_getSuperclass(class);

      if (class && class_getSuperclass(allClasses[i]) == [BankableModelObject class])
        [bankableModelClasses addObject:allClasses[i]];

    }

    [bankableModelClasses filter:^BOOL(Class class) {
      NSArray * matches = [ClassString(class) capturedStringsByMatchingFirstOccurrenceOfRegex:@"^([a-zA-Z0-9]+)_\\1_$"];
      return (![matches count]);
    }];


    [bankableModelClasses map:^NSString *(Class class, NSUInteger idx) {
      return ClassString(class);
    }];

    classes = [bankableModelClasses copy];

  });

  return classes;
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
