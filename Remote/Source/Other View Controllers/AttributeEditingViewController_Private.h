//
// AttributeEditingViewController_Private.h
// iPhonto
//
// Created by Jason Cardwell on 4/2/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "AttributeEditingViewController.h"
#import "DetailedButtonEditingViewController.h"
#import "Button.h"

@interface AttributeEditingViewController ()

@property (nonatomic, weak) DetailedButtonEditingViewController * detailedButtonEditor;
@property (nonatomic, weak) Button                              * button;

- (void)storeCurrentValues;
- (void)restoreCurrentValues;
- (void)syncCurrentValuesWithIntialValues;

@end
