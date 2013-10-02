//
//  Bank.m
//  Remote
//
//  Created by Jason Cardwell on 9/13/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "Bank.h"
#import "BankCollectionViewController.h"

static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel, msLogContext)

@interface Bank ()

@property (nonatomic, strong, readwrite) UIViewController * viewController;

@end

@implementation Bank

+ (NSArray *)registeredClasses
{
    return @[@"IRCode", @"Image", @"ComponentDevice", @"Preset", @"Manufacturer"];
}

- (UIViewController *)viewController
{
    if (!_viewController)
        self.viewController = [[UIStoryboard storyboardWithName:@"Bank" bundle:nil]
                               instantiateInitialViewController];
    return _viewController;
}

+ (UIViewController<BankableDetailDelegate> *)detailControllerForItem:(id<Bankable>)item
{
    MSLogDebug(@"item name: %@", item.name);
    Class itemDetailClass = [[item class] detailViewControllerClass];
    assert(   itemDetailClass
           && [itemDetailClass conformsToProtocol:@protocol(BankableDetailDelegate)]);
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Bank" bundle:nil];
    UIViewController<BankableDetailDelegate> * viewController =
    (UIViewController<BankableDetailDelegate> *)
    [storyboard instantiateViewControllerWithClassNameIdentifier:itemDetailClass];
    viewController.item = item;
    return viewController;
}

+ (UIViewController<BankableDetailDelegate> *)editingControllerForItem:(id<Bankable>)item
{
    UIViewController<BankableDetailDelegate> * viewController = [self detailControllerForItem:item];
    [viewController editItem];
    return viewController;
}

@end

@implementation BankInfo

@dynamic category, name, user;

@end