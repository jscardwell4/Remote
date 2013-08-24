//
// RemoteElementEditingViewController.h
//
//
// Created by Jason Cardwell on 4/20/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
@class RemoteElement, RERemoteView, REButtonGroup, REButton, REEditingViewController;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Controller Delegate Protocol
////////////////////////////////////////////////////////////////////////////////

@protocol REEditingDelegate <NSObject>

- (void)remoteElementEditorDidCancel:(REEditingViewController *)editor;
- (void)remoteElementEditorDidSave:(REEditingViewController *)editor;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Editor
////////////////////////////////////////////////////////////////////////////////
@interface REEditingViewController : UIViewController

@property (nonatomic, strong) RemoteElement            * remoteElement;
@property (nonatomic, weak)   id <REEditingDelegate>     delegate;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Editing
////////////////////////////////////////////////////////////////////////////////
@interface RERemoteEditingViewController : REEditingViewController @end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Group Editing
////////////////////////////////////////////////////////////////////////////////
@interface REButtonGroupEditingViewController : REEditingViewController

//@property (nonatomic, assign) CGSize   presentedElementSize;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Editing
////////////////////////////////////////////////////////////////////////////////
@interface REButtonEditingViewController : REEditingViewController

- (id)initWithButton:(REButton *)button delegate:(UIViewController <REEditingDelegate> *)delegate;
- (void)removeAuxController:(UIViewController *)controller animated:(BOOL)animated;
- (void)addAuxController:(UIViewController *)controller animated:(BOOL)animated;

@property (nonatomic, assign) UIControlState   presentedControlState;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Detailed Button Editing
////////////////////////////////////////////////////////////////////////////////

MSKIT_EXTERN_STRING   REDetailedButtonEditingButtonKey;
MSKIT_EXTERN_STRING   REDetailedButtonEditingControlStateKey;

@interface REDetailedButtonEditingViewController : REEditingViewController

- (void)initializeEditorWithValues:(NSDictionary *)values;

- (void)removeAuxController:(UIViewController *)controller animated:(BOOL)animated;
- (void)addAuxController:(UIViewController *)controller animated:(BOOL)animated;

@end
