//
// RemoteElementEditingViewController.h
//
//
// Created by Jason Cardwell on 4/20/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

@class   RemoteElement;

@protocol RemoteElementEditingViewControllerDelegate;

@interface RemoteElementEditingViewController : UIViewController

@property (nonatomic, strong) RemoteElement                                 * remoteElement;
@property (nonatomic, weak) id <RemoteElementEditingViewControllerDelegate>   delegate;

@end

@protocol RemoteElementEditingViewControllerDelegate <NSObject>

- (void)remoteElementEditorDidCancel:(RemoteElementEditingViewController *)editor;
- (void)remoteElementEditorDidSave:(RemoteElementEditingViewController *)editor;

@end

@class   GalleryImage;

@protocol EditableBackground <NSObject>

@property (nonatomic, strong) UIColor      * backgroundColor;
@property (nonatomic, strong) GalleryImage * backgroundImage;

@end
