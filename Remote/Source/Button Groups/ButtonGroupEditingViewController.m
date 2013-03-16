//
// ButtonGroupEditingViewController.m
// iPhonto
//
// Created by Jason Cardwell on 3/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "ButtonGroupEditingViewController.h"
#import "RemoteElementEditingViewController_Private.h"
#import "ButtonGroup.h"
#import "ButtonGroupView.h"
#import "Button.h"
#import "ControlStateSet.h"
#import "ButtonView.h"
#import "ButtonEditingViewController.h"
#import "RemoteBuilder.h"
#import <QuartzCore/QuartzCore.h>
#import "Painter.h"
#import "GalleryPreview.h"
#import "StoryboardProxy.h"

// static int ddLogLevel = LOG_LEVEL_DEBUG;
static int   ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@interface ButtonGroupEditingViewController () <MSPickerInputButtonDelegate, RemoteElementEditingViewControllerDelegate> {
    __weak ButtonGroupView * _buttonGroupView;
}

@property (strong, nonatomic) IBOutlet MSPickerInputButton * addButtonPicker;
@property (nonatomic, strong) NSArray                      * buttonPreviewImages;
@property (nonatomic, strong) NSLayoutConstraint           * buttonGroupWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint           * buttonGroupHeightConstraint;

@end

@implementation ButtonGroupEditingViewController

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialization and loading
////////////////////////////////////////////////////////////////////////////////

- (void)initializeIVARs {
    [super initializeIVARs];
    self.selectableClass      = [ButtonView class];
    self.presentedElementSize = CGSizeZero;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.remoteElement) self.sourceView = [RemoteElementView remoteElementViewWithElement:(ButtonGroup *)self.remoteElement];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark RemoteElementEditingViewControllerDelegate
////////////////////////////////////////////////////////////////////////////////

- (void)remoteElementEditorDidCancel:(RemoteElementEditingViewController *)remoteElementEditor {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)remoteElementEditorDidSave:(RemoteElementEditingViewController *)remoteElementEditor {
/*
 *  [[self.selectedViews anyObject] setNeedsDisplay];
 *
 *  if (ValueIsNotNil(_freshButton)) {
 *      ButtonView * buttonView = (ButtonView *)[ButtonView
 * remoteElementViewWithElement:_freshButton];
 *      [_buttonGroupView addSubview:buttonView];
 *      buttonView.editingMode = EditingModeEditingButtonGroup;
 *      buttonView.center = CGPointMake(CGRectGetMidX(_buttonGroupView.bounds),
 *                                      CGRectGetMidY(_buttonGroupView.bounds));
 *      [self selectView:buttonView];
 *      self.freshButton = nil;
 *  }
 *
 *  [self dismissViewControllerAnimated:YES completion:nil];
 *
 *  [_buttonGroupView setNeedsDisplay];
 */
}

- (NSArray *)buttonPreviewImages {
    if (!_buttonPreviewImages) self.buttonPreviewImages = [GalleryButtonPreview previewImages];

    return _buttonPreviewImages;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - MSPickerInputButtonDelegate methods
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfComponentsInPickerInput:(MSPickerInputView *)pickerInput {
    return 1;
}

- (NSInteger)   pickerInput:(MSPickerInputView *)pickerInput
    numberOfRowsInComponent:(NSInteger)component {
    return [self.buttonPreviewImages count];
}

- (UIView *)pickerInput:(MSPickerInputView *)pickerInput
             viewForRow:(NSInteger)row
           forComponent:(NSInteger)component
            reusingView:(UIView *)view {
    if (ValueIsNil(view)) view = [[UIImageView alloc] initWithImage:self.buttonPreviewImages[row]];
    else ((UIImageView *)view).image = self.buttonPreviewImages[row];

    CGSize   fittedSize = [((UIImageView *)view).image sizeThatFits : CGSizeMake(200, 50)];

    [view resizeFrameToSize:fittedSize anchored:YES];

    return view;
}

- (CGFloat)pickerInput:(MSPickerInputView *)pickerInput rowHeightForComponent:(NSInteger)component {
    return 50;
}

- (void)pickerInputDidCancel:(MSPickerInputView *)pickerInput {
    [_addButtonPicker resignFirstResponder];
}

- (void)pickerInput:(MSPickerInputView *)pickerInput selectedRows:(NSArray *)rows {
    [_addButtonPicker resignFirstResponder];

/*
 *  NSInteger selection = [rows[0] integerValue] + 1;
 *
 *  ButtonStyleDefault styleDefault = 0;
 *  switch (selection) {
 *      case 1:
 *          styleDefault = ButtonStyleDefault1;
 *          break;
 *
 *      case 2:
 *          styleDefault = ButtonStyleDefault2;
 *          break;
 *
 *      case 3:
 *          styleDefault = ButtonStyleDefault3;
 *          break;
 *
 *      case 4:
 *          styleDefault = ButtonStyleDefault4;
 *          break;
 * }
 * //    self.freshButton = [RemoteBuilder buttonWithDefaultStyle:styleDefault
 * //
 *
 *
 *
 *                                                  context:_buttonGroupModel.managedObjectContext];
 *  _freshButton.parentElement = _buttonGroupModel;
 *
 *  ButtonEditingViewController * buttonEditorVC = [StoryboardProxy buttonEditingViewController];
 *  buttonEditorVC.remoteElement = _freshButton;
 *  buttonEditorVC.delegate = self;
 *
 *  [self presentViewController:buttonEditorVC animated:YES completion:nil];
 */
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - RemoteElementEditingViewController Overrides
////////////////////////////////////////////////////////////////////////////////

- (void)setSourceView:(RemoteElementView *)sourceView {
    [super setSourceView:sourceView];
    _buttonGroupView             = (ButtonGroupView *)self.sourceView;
    _buttonGroupView.editingMode = EditingModeEditingButtonGroup;
    [self.view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
}

- (void)willTranslateSelectedViews {
    [super willTranslateSelectedViews];
    _buttonGroupView.buttonsLocked = NO;
}

- (void)didTranslateSelectedViews {
    [super didTranslateSelectedViews];
// [_buttonGroupView updateModelConstraintsFromView];
    _buttonGroupView.buttonsLocked = YES;
}

@end

