//
// DetailedButtonEditingViewController.h
// iPhonto
//
// Created by Jason Cardwell on 3/31/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "RemoteElementEditingViewController.h"

MSKIT_EXTERN_STRING   kDetailedButtonEditingButtonKey;
MSKIT_EXTERN_STRING   kDetailedButtonEditingControlStateKey;

@interface DetailedButtonEditingViewController : RemoteElementEditingViewController

- (void)initializeEditorWithValues:(NSDictionary *)values;

- (void)removeAuxController:(UIViewController *)controller animated:(BOOL)animated;
- (void)addAuxController:(UIViewController *)controller animated:(BOOL)animated;

@end
