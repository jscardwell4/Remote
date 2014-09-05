//
// ColorSelectionViewController.h
// Remote
//
// Created by Jason Cardwell on 3/28/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
#import "MSKit/MSKit.h"
#import "MSRemoteMacros.h"

@class   ColorSelectionViewController;

@protocol ColorSelectionDelegate <NSObject>

- (void)colorSelector:(ColorSelectionViewController *)controller didSelectColor:(UIColor *)color;

- (void)colorSelectorDidCancel:(ColorSelectionViewController *)controller;

@end

#import "SelectionViewController.h"

@interface ColorSelectionViewController : SelectionViewController <UIPickerViewDelegate,
                                                                   UIPickerViewDataSource>
@property (nonatomic, strong) UIColor                   * initialColor;
@property (nonatomic, weak) id <ColorSelectionDelegate>   delegate;
@property (nonatomic, assign) BOOL                        hidesToolbar;

- (void)hideButtonAtIndex:(NSUInteger)index;

@end
