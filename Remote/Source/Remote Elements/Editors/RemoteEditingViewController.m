//
// RemoteEditingViewController.m
// Remote
//
// Created by Jason Cardwell on 5/26/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//
#import "RemoteElementEditingViewController_Private.h"
#import "ButtonGroup.h"

#define SCALE_USES_TRANSFORM NO
#define BLOCK_MODEL_UPDATES

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int   msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);

@implementation RemoteEditingViewController

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialization and loading
////////////////////////////////////////////////////////////////////////////////

+ (Class)subelementClass { return [ButtonGroupView class]; }

+ (Class)elementClass { return [RemoteView class]; }

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
        case 0:  return $(@"RERemoteTopPanel%liKey",   (long)(numberOfTouches + 1));
        case 1:  return $(@"RERemoteLeftPanel%liKey",  (long)(numberOfTouches + 1));
        case 2:  return $(@"RERemoteBottomPanel%liKey",(long)(numberOfTouches + 1));
        case 3:  return $(@"RERemoteRightPanel%liKey", (long)(numberOfTouches + 1));
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
        
        ButtonGroupView * selectedPanel =
            (ButtonGroupView *)self.sourceView[[self panelKeyForLocation:IntegerValue(rows[0])
                                                           numberOfTouches:IntegerValue(rows[1])]];

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
            title = $(@"%li", (long)(row + 1));
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

- (void)openSubelementInEditor:(ButtonGroup *)buttonGroup
{
    self.buttonGroupEditor                  = [StoryboardProxy buttonGroupEditingViewController];
    _buttonGroupEditor.mockParentSize       = self.sourceView.bounds.size;
    _buttonGroupEditor.remoteElement        = buttonGroup;
    _buttonGroupEditor.delegate             = self;

    [self presentViewController:_buttonGroupEditor animated:YES completion:nil];
}

@end
