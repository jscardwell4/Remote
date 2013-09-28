//
// AttributeEditingViewController.m
// Remote
//
// Created by Jason Cardwell on 4/2/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "AttributeEditingViewController.h"
#import "AttributeEditingViewController_Private.h"
#import "RemoteElementEditingViewController.h"

MSSTRING_CONST   kAttributeEditingFontSizeKey     = @"kAttributeEditingFontSizeKey";
MSSTRING_CONST   kAttributeEditingFontNameKey     = @"kAttributeEditingFontNameKey";
MSSTRING_CONST   kAttributeEditingEdgeInsetsKey   = @"kAttributeEditingEdgeInsetsKey";
MSSTRING_CONST   kAttributeEditingTitleTextKey    = @"kAttributeEditingTitleTextKey";
MSSTRING_CONST   kAttributeEditingColorKey        = @"kAttributeEditingColorKey";
MSSTRING_CONST   kAttributeEditingTitleColorKey   = @"kAttributeEditingTitleColorKey";
MSSTRING_CONST   kAttributeEditingBoundsKey       = @"kAttributeEditingBoundsKey";
MSSTRING_CONST   kAttributeEditingButtonKey       = @"kAttributeEditingButtonKey";
MSSTRING_CONST   kAttributeEditingControlStateKey = @"kAttributeEditingControlStateKey";
MSSTRING_CONST   kAttributeEditingImageKey        = @"kAttributeEditingImageKey";

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
