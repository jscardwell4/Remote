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

MSKIT_STRING_CONST   kAttributeEditingFontSizeKey     = @"kAttributeEditingFontSizeKey";
MSKIT_STRING_CONST   kAttributeEditingFontNameKey     = @"kAttributeEditingFontNameKey";
MSKIT_STRING_CONST   kAttributeEditingEdgeInsetsKey   = @"kAttributeEditingEdgeInsetsKey";
MSKIT_STRING_CONST   kAttributeEditingTitleTextKey    = @"kAttributeEditingTitleTextKey";
MSKIT_STRING_CONST   kAttributeEditingColorKey        = @"kAttributeEditingColorKey";
MSKIT_STRING_CONST   kAttributeEditingTitleColorKey   = @"kAttributeEditingTitleColorKey";
MSKIT_STRING_CONST   kAttributeEditingBoundsKey       = @"kAttributeEditingBoundsKey";
MSKIT_STRING_CONST   kAttributeEditingButtonKey       = @"kAttributeEditingButtonKey";
MSKIT_STRING_CONST   kAttributeEditingControlStateKey = @"kAttributeEditingControlStateKey";
MSKIT_STRING_CONST   kAttributeEditingImageKey        = @"kAttributeEditingImageKey";

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
