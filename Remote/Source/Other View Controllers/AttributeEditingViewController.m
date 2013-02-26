//
// AttributeEditingViewController.m
// iPhonto
//
// Created by Jason Cardwell on 4/2/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "AttributeEditingViewController.h"
#import "AttributeEditingViewController_Private.h"

NSString * const   kAttributeEditingFontSizeKey     = @"kAttributeEditingFontSizeKey";
NSString * const   kAttributeEditingFontNameKey     = @"kAttributeEditingFontNameKey";
NSString * const   kAttributeEditingEdgeInsetsKey   = @"kAttributeEditingEdgeInsetsKey";
NSString * const   kAttributeEditingTitleTextKey    = @"kAttributeEditingTitleTextKey";
NSString * const   kAttributeEditingColorKey        = @"kAttributeEditingColorKey";
NSString * const   kAttributeEditingTitleColorKey   = @"kAttributeEditingTitleColorKey";
NSString * const   kAttributeEditingBoundsKey       = @"kAttributeEditingBoundsKey";
NSString * const   kAttributeEditingButtonKey       = @"kAttributeEditingButtonKey";
NSString * const   kAttributeEditingControlStateKey = @"kAttributeEditingControlStateKey";
NSString * const   kAttributeEditingImageKey        = @"kAttributeEditingImageKey";

@implementation AttributeEditingViewController

@synthesize detailedButtonEditor, button;

- (void)setInitialValuesFromDictionary:(NSDictionary *)initialValues {
    self.button = NilSafeValue(initialValues[kAttributeEditingButtonKey]);
}

- (void)resetToInitialState
{}

- (void)storeCurrentValues
{}

- (void)restoreCurrentValues
{}

- (void)syncCurrentValuesWithIntialValues
{}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if ([parent isMemberOfClass:[DetailedButtonEditingViewController class]]) self.detailedButtonEditor = (DetailedButtonEditingViewController *)parent;
    else self.detailedButtonEditor = nil;
}

@end
