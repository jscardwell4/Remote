//
// RemoteElementEditingViewController.h
//
//
// Created by Jason Cardwell on 4/20/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

@class   RemoteElement;

@protocol REEditingViewControllerDelegate;

@interface REEditingViewController : UIViewController

@property (nonatomic, strong) RemoteElement                                 * remoteElement;
@property (nonatomic, weak) id <REEditingViewControllerDelegate>   delegate;

@end

@protocol REEditingViewControllerDelegate <NSObject>

- (void)remoteElementEditorDidCancel:(REEditingViewController *)editor;
- (void)remoteElementEditorDidSave:(REEditingViewController *)editor;

@end

@class   REImage;

@protocol EditableBackground <NSObject>

@property (nonatomic, strong) UIColor      * backgroundColor;
@property (nonatomic, strong) REImage * backgroundImage;

@end
