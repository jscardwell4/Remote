//
// IconEditingViewController.h
// iPhonto
//
// Created by Jason Cardwell on 3/30/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "AttributeEditingViewController.h"
#import "ColorSelectionViewController.h"
#import "IconSelectionViewController.h"

@class   IconEditingViewController;

@protocol IconEditingDelegate <NSObject>

- (void)iconEditorCanceled:(IconEditingViewController *)iconEditor;

- (void)iconEditor:(IconEditingViewController *)iconEditor
     saveRequested:(NSDictionary *)saveValues;

@end

@interface IconEditingViewController : AttributeEditingViewController <ColorSelectionDelegate,
                                                                       IconSelectionDelegate,
                                                                       UITextFieldDelegate>

@property (nonatomic, weak) id <IconEditingDelegate>   delegate;

@end
