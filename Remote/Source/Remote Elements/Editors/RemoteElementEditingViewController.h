//
// RemoteElementEditingViewController.h
//
//
// Created by Jason Cardwell on 4/20/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
@class RemoteElement, RemoteView, ButtonGroup, Button, RemoteElementEditingViewController;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Controller Delegate Protocol
////////////////////////////////////////////////////////////////////////////////

@protocol RemoteElementEditingDelegate <NSObject>

- (void)remoteElementEditorDidCancel:(RemoteElementEditingViewController *)editor;
- (void)remoteElementEditorDidSave:(RemoteElementEditingViewController *)editor;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Editor
////////////////////////////////////////////////////////////////////////////////
@interface RemoteElementEditingViewController : UIViewController

@property (nonatomic, strong) RemoteElement            * remoteElement;
@property (nonatomic, weak)   id <RemoteElementEditingDelegate>     delegate;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Editing
////////////////////////////////////////////////////////////////////////////////
@interface RemoteEditingViewController : RemoteElementEditingViewController @end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Group Editing
////////////////////////////////////////////////////////////////////////////////
@interface ButtonGroupEditingViewController : RemoteElementEditingViewController

//@property (nonatomic, assign) CGSize   presentedElementSize;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Editing
////////////////////////////////////////////////////////////////////////////////
@interface ButtonEditingViewController : RemoteElementEditingViewController

- (id)initWithButton:(Button *)button delegate:(UIViewController <RemoteElementEditingDelegate> *)delegate;
- (void)removeAuxController:(UIViewController *)controller animated:(BOOL)animated;
- (void)addAuxController:(UIViewController *)controller animated:(BOOL)animated;

@property (nonatomic, assign) UIControlState   presentedControlState;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Detailed Button Editing
////////////////////////////////////////////////////////////////////////////////

MSKIT_EXTERN_STRING   REDetailedButtonEditingButtonKey;
MSKIT_EXTERN_STRING   REDetailedButtonEditingControlStateKey;

@interface DetailedButtonEditingViewController : RemoteElementEditingViewController

- (void)initializeEditorWithValues:(NSDictionary *)values;

- (void)removeAuxController:(UIViewController *)controller animated:(BOOL)animated;
- (void)addAuxController:(UIViewController *)controller animated:(BOOL)animated;

@end
