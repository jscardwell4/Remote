//
// BackgroundEditingViewController.h
// Remote
//
// Created by Jason Cardwell on 4/25/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

//#import "ColorSelectionViewController.h"
#import "REEditableBackground.h"

@interface BackgroundEditingViewController : UIViewController

@property (nonatomic, weak) NSManagedObject <REEditableBackground> * sourceObject;

@end