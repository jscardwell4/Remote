//
// AttributeEditingViewController_Private.h
// Remote
//
// Created by Jason Cardwell on 4/2/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "AttributeEditingViewController.h"
#import "RemoteElement.h"

@class REDetailedButtonEditingViewController;

@interface AttributeEditingViewController ()

@property (nonatomic, weak) REDetailedButtonEditingViewController * detailedButtonEditor;
@property (nonatomic, weak) REButton                              * button;

- (void)storeCurrentValues;
- (void)restoreCurrentValues;
- (void)syncCurrentValuesWithIntialValues;

@end
