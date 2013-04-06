//
// RemoteEditingViewController.m
// Remote
//
// Created by Jason Cardwell on 5/26/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//
#import "REEditingViewController_Private.h"

#define SCALE_USES_TRANSFORM NO
#define BLOCK_MODEL_UPDATES

static int   ddLogLevel   = LOG_LEVEL_DEBUG;
static int   msLogContext = REMOTE_F_C;

@implementation RERemoteEditingViewController

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialization and loading
////////////////////////////////////////////////////////////////////////////////

+ (Class)subelementClass { return [REButtonGroupView class]; }

+ (Class)elementClass { return [RERemoteView class]; }

+ (REEditingMode)editingModeForElement { return RERemoteEditingMode; }

- (void)setMockParentSize:(CGSize)mockParentSize {}

- (CGSize)mockParentSize { return MainScreen.bounds.size; }

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote button group panels
////////////////////////////////////////////////////////////////////////////////

- (NSString *)panelKeyForLocation:(NSInteger)location
                  numberOfTouches:(NSInteger)numberOfTouches
{
    switch (location)
    {
        case 0:  return $(@"RERemoteTopPanel%iKey",   (numberOfTouches + 1));
        case 1:  return $(@"RERemoteLeftPanel%iKey",  (numberOfTouches + 1));
        case 2:  return $(@"RERemoteBottomPanel%iKey",(numberOfTouches + 1));
        case 3:  return $(@"RERemoteRightPanel%iKey", (numberOfTouches + 1));
        default: MSLogErrorTag(@"invalid row index for panel location");  return nil;
    }
}

- (void)processPanelSelectionForLocation:(NSInteger)location
                         numberOfTouches:(NSInteger)numberOfTouches
{
    if (self.sourceView[[self panelKeyForLocation:location numberOfTouches:numberOfTouches]])
        _panelPickerButton.selectBarButtonItem.title = @"Edit";
    else
        _panelPickerButton.selectBarButtonItem.title = @"Create";
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - MSPickerInputButtonDelegate methods
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfComponentsInPickerInput:(MSPickerInputView *)pickerInput
{
    return (pickerInput.pickerInputButton == _panelPickerButton ? 2 : 0);
}

- (NSInteger)pickerInput:(MSPickerInputView *)pickerInput numberOfRowsInComponent:(NSInteger)component
{
    return (pickerInput.pickerInputButton == _panelPickerButton ? (component == 0 ? 4 : 3) : 0);
}

- (void)pickerInputDidCancel:(MSPickerInputView *)pickerInput
{
    [pickerInput.pickerInputButton resignFirstResponder];
}

- (void)pickerInput:(MSPickerInputView *)pickerInput selectedRows:(NSArray *)rows
{

    if (pickerInput.pickerInputButton == _panelPickerButton)
    {
        [_panelPickerButton resignFirstResponder];
        
        REButtonGroupView * selectedPanel =
            (REButtonGroupView *)self.sourceView[[self panelKeyForLocation:NSIntegerValue(rows[0])
                                                           numberOfTouches:NSIntegerValue(rows[1])]];

        if (selectedPanel) [self openSubelementInEditor:selectedPanel.model];

        // else
        // TODO: Create new button group and open in editor
    }
}

- (NSString *)pickerInput:(MSPickerInputView *)pickerInput
              titleForRow:(NSInteger)row
             forComponent:(NSInteger)component
{
    NSString * title = nil;

    if (pickerInput.pickerInputButton == _panelPickerButton)
    {
        if (component == 0)
        {
            switch (row) {
                case 0:  title = @"Top";    break;
                case 1:  title = @"Left";   break;
                case 2:  title = @"Bottom"; break;
                default: title = @"Right";  break;
            }
        }
        
        else
            title = $(@"%i", row + 1);
    }

    return title;
}

- (void)pickerInput:(MSPickerInputView *)pickerInput
       didSelectRow:(NSInteger)row
        inComponent:(NSInteger)component
{
    if (pickerInput.pickerInputButton == _panelPickerButton)
        [self processPanelSelectionForLocation:[pickerInput selectedRowInComponent:0]
                               numberOfTouches:[pickerInput selectedRowInComponent:1]];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Group Editor
////////////////////////////////////////////////////////////////////////////////

- (void)openSubelementInEditor:(REButtonGroup *)buttonGroup
{
    self.buttonGroupEditor                  = [StoryboardProxy buttonGroupEditingViewController];
    _buttonGroupEditor.mockParentSize       = self.sourceView.bounds.size;
    _buttonGroupEditor.remoteElement        = buttonGroup;
    _buttonGroupEditor.delegate             = self;

    [self presentViewController:_buttonGroupEditor animated:YES completion:nil];
}

@end
