//
// RemoteEditingViewController.m
// iPhonto
//
// Created by Jason Cardwell on 5/26/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import "RemoteEditingViewController.h"
#import "UserCodesViewController.h"
#import "ButtonGroup.h"
#import "ButtonGroupView.h"
#import "ButtonGroupEditingViewController.h"
#import "BackgroundEditingViewController.h"
#import "RemoteElementEditingViewController_Private.h"
#import "CoreDataManager.h"
#import "Remote.h"
#import "RemoteView.h"
#import "ButtonView.h"
#import "RemoteController.h"
#import "StoryboardProxy.h"
#import <MSKit/MSKit.h>

#define SCALE_USES_TRANSFORM NO
#define BLOCK_MODEL_UPDATES

static int   ddLogLevel = LOG_LEVEL_DEBUG;

@interface RemoteEditingViewController () <RemoteElementEditingViewControllerDelegate, MSPickerInputButtonDelegate> {
    __weak RemoteView * _remoteView;
}
@property (strong, nonatomic) IBOutlet MSPickerInputButton     * addGroupPickerButton;
@property (strong, nonatomic) IBOutlet MSPickerInputButton     * panelPickerButton;
@property (nonatomic, strong) ButtonGroupEditingViewController * buttonGroupEditor;
@end

@implementation RemoteEditingViewController

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialization and loading
////////////////////////////////////////////////////////////////////////////////

- (void)initializeIVARs {
    [super initializeIVARs];
    self.selectableClass = [ButtonGroupView class];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.remoteElement) self.sourceView = [RemoteElementView remoteElementViewWithElement:(Remote *)self.remoteElement];
}

- (void)setSourceView:(RemoteElementView *)sourceView {
    assert([sourceView isKindOfClass:[RemoteView class]]);
    self.mockParentSize = MainScreen.bounds.size;
    [super setSourceView:sourceView];
    _remoteView             = (RemoteView *)sourceView;
    _remoteView.editingMode = EditingModeEditingRemote;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote button group panels
////////////////////////////////////////////////////////////////////////////////

- (NSString *)panelKeyForLocation:(NSInteger)location
                  numberOfTouches:(NSInteger)numberOfTouches {
    NSString * panelKey = @"k";

    switch (location) {
        case 0 :
            panelKey = [panelKey stringByAppendingString:@"TopButtonGroupPanel"];
            break;

        case 1 :
            panelKey = [panelKey stringByAppendingString:@"LeftButtonGroupPanel"];
            break;

        case 2 :
            panelKey = [panelKey stringByAppendingString:@"BottomButtonGroupPanel"];
            break;

        case 3 :
            panelKey = [panelKey stringByAppendingString:@"RightButtonGroupPanel"];
            break;

        default :
            DDLogError(@"%@\n\tinvalid row index for panel location", ClassTagString);
            break;
    }  /* switch */

    switch (numberOfTouches) {
        case 0 :
            panelKey = [panelKey stringByAppendingString:@"OneFingerKey"];
            break;

        case 1 :
            panelKey = [panelKey stringByAppendingString:@"TwoFingerKey"];
            break;

        case 2 :
            panelKey = [panelKey stringByAppendingString:@"ThreeFingerKey"];
            break;

        default :
            DDLogError(@"%@\n\tinvalid row index for number of touches", ClassTagString);
            break;
    }  /* switch */

    return panelKey;
}

- (void)processPanelSelectionForLocation:(NSInteger)location
                         numberOfTouches:(NSInteger)numberOfTouches {
    if ([(RemoteView *)self.sourceView panelForKey :[self panelKeyForLocation:location
                                                              numberOfTouches:numberOfTouches]]) _panelPickerButton.selectBarButtonItem.title = @"Edit";
    else _panelPickerButton.selectBarButtonItem.title = @"Create";
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Moving the selected views
////////////////////////////////////////////////////////////////////////////////

/*
 * - (BOOL)shouldMoveSelectionFrom:(CGRect)fromUnion to:(CGRect)toUnion {
 *  //TODO: Handle scrolling if new location is off screen
 *  BOOL shouldMoveSelection = [super shouldMoveSelectionFrom:fromUnion to:toUnion];
 *  if (shouldMoveSelection) {
 *      CGFloat maxY = CGRectGetMaxY(toUnion);
 *      CGFloat minY = CGRectGetMinY(toUnion);
 *      CGFloat newOffset = 0.0f;
 *      if (   maxY > CGRectGetMinY(self.currentToolbar.frame) - 10
 *          && self.sourceViewCenterYConstraint.constant !=
 * self.flags.allowableSourceViewYOffset.lower)
 *          newOffset = self.flags.allowableSourceViewYOffset.lower;
 *      else if (   minY < CGRectGetMaxY(self.topToolbar.frame) + 10
 *               && self.sourceViewCenterYConstraint.constant !=
 * self.flags.allowableSourceViewYOffset.upper)
 *          newOffset = self.flags.allowableSourceViewYOffset.upper;
 *      if (newOffset)
 *          [UIView animateWithDuration:0.25f
 *                                delay:0.0f
 *                              options:UIViewAnimationOptionBeginFromCurrentState
 *                           animations:^{
 *                               self.sourceViewCenterYConstraint.constant = newOffset;
 *                               [self.view layoutIfNeeded];
 *                           }
 *                           completion:nil];
 *  }
 *  return shouldMoveSelection;
 * }
 */

/*
 * - (void)willMoveSelectedViews {
 *  [super willMoveSelectedViews];
 *  _remoteView.buttonGroupsLocked = NO;
 * }
 *
 * - (void)didMoveSelectedViews {
 *  [super didMoveSelectedViews];
 *  _remoteView.buttonGroupsLocked = YES;
 * }
 */

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Scaling the selected views
////////////////////////////////////////////////////////////////////////////////

/*
 * - (void)willScaleSelectedViews {
 *  [super willScaleSelectedViews];
 *  [self.selectedViews setValue:@YES forKey:@"resizable"];
 *  [self.selectedViews setValue:@YES forKey:@"moveable"];
 * }
 *
 * - (void)didScaleSelectedViews {
 *  [super didScaleSelectedViews];
 *  [self.selectedViews setValue:@NO forKey:@"resizable"];
 *  [self.selectedViews setValue:@NO forKey:@"moveable"];
 * }
 */

////////////////////////////////////////////////////////////////////////////////
#pragma mark - MSPickerInputButtonDelegate methods
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfComponentsInPickerInput:(MSPickerInputView *)pickerInput {
    MSPickerInputButton * pickerButton       = (MSPickerInputButton *)pickerInput.pickerInputButton;
    NSInteger             numberOfComponents = 0;

    if (pickerButton == _panelPickerButton) numberOfComponents = 2;
    else if (pickerButton == _addGroupPickerButton) numberOfComponents = 0;

    return numberOfComponents;
}

- (NSInteger)   pickerInput:(MSPickerInputView *)pickerInput
    numberOfRowsInComponent:(NSInteger)component {
    MSPickerInputButton * pickerButton = (MSPickerInputButton *)pickerInput.pickerInputButton;
    NSInteger             numberOfRows = 0;

    if (pickerButton == _panelPickerButton) numberOfRows = (component == 0) ? 4 : 3;
    else if (pickerButton == _addGroupPickerButton) numberOfRows = 0;

    return numberOfRows;
}

- (void)pickerInputDidCancel:(MSPickerInputView *)pickerInput {
    MSPickerInputButton * pickerButton = (MSPickerInputButton *)pickerInput.pickerInputButton;

    [pickerButton resignFirstResponder];
}

- (void)pickerInput:(MSPickerInputView *)pickerInput selectedRows:(NSArray *)rows {
    [pickerInput.pickerInputButton resignFirstResponder];
    if (pickerInput.pickerInputButton == _panelPickerButton) {
        NSString * panelKey = [self panelKeyForLocation:NSIntegerValue(rows[0])
                                        numberOfTouches:NSIntegerValue(rows[1])];
        ButtonGroupView * selectedPanel = [((RemoteView *)self.sourceView)panelForKey : panelKey];

        if (ValueIsNotNil(selectedPanel)) [self openButtonGroupInEditor:(ButtonGroupView *)selectedPanel];

        // else
        // TODO: Create new button group and open in editor
    }  // else {

    // TODO: Add handling of new button group addition
    // }
}

- (NSString *)pickerInput:(MSPickerInputView *)pickerInput
              titleForRow:(NSInteger)row
             forComponent:(NSInteger)component {
    NSString * title = nil;

    if (pickerInput.pickerInputButton == _panelPickerButton) {
        if (component == 0) {
            switch (row) {
                case 0 :
                    title = @"Top"; break;

                case 1 :
                    title = @"Left"; break;

                case 2 :
                    title = @"Bottom"; break;

                default :
                    title = @"Right"; break;
            }
        } else
            title = [NSString stringWithFormat:@"%i", row + 1];
    }

    return title;
}

- (void)pickerInput:(MSPickerInputView *)pickerInput
       didSelectRow:(NSInteger)row
        inComponent:(NSInteger)component {
    if (pickerInput.pickerInputButton == _panelPickerButton)
        [self processPanelSelectionForLocation:[pickerInput selectedRowInComponent:0]
                               numberOfTouches:[pickerInput selectedRowInComponent:1]];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark RemoteElementEditingViewControllerDelegate
////////////////////////////////////////////////////////////////////////////////

- (void)remoteElementEditorDidSave:(RemoteElementEditingViewController *)remoteElementEditor {
// ButtonGroup * buttonGroup = (ButtonGroup *)remoteElementEditor.remoteElement;
// [self insertNewRemoteView];
// ButtonGroupView * buttonGroupView = [((RemoteView *)self.sourceView)
// buttonGroupViewForKey:buttonGroup.key];
// if (buttonGroupView)
// [self selectView:buttonGroupView];
    [self dismissViewControllerAnimated:YES completion:nil];
// [buttonGroupView updateConstraintsFromModel];
}

- (void)remoteElementEditorDidCancel:(RemoteElementEditingViewController *)remoteElementEditor {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)openButtonGroupInEditor:(ButtonGroupView *)buttonGroupView {
    assert(buttonGroupView);

    self.buttonGroupEditor                  = [StoryboardProxy buttonGroupEditingViewController];
    _buttonGroupEditor.mockParentSize       = _remoteView.bounds.size;
    _buttonGroupEditor.remoteElement        = buttonGroupView.remoteElement;
    _buttonGroupEditor.delegate             = self;
    _buttonGroupEditor.presentedElementSize = buttonGroupView.frame.size;

    [self presentViewController:_buttonGroupEditor animated:YES completion:nil];
}

@end
