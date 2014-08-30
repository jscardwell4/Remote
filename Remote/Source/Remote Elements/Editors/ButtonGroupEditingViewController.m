//
// ButtonGroupEditingViewController.m
// Remote
//
// Created by Jason Cardwell on 3/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteElementEditingViewController_Private.h"
#import "RemoteElementView.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int   msLogContext = (LOG_CONTEXT_EDITOR|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel,msLogContext)


@implementation ButtonGroupEditingViewController

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialization and loading
////////////////////////////////////////////////////////////////////////////////

+ (Class)subelementClass { return [ButtonView class]; }

+ (Class)elementClass { return [ButtonGroupView class]; }

+ (REEditingMode)editingModeForElement { return REButtonGroupEditingMode; }

////////////////////////////////////////////////////////////////////////////////
#pragma mark - MSPickerInputButtonDelegate methods
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfComponentsInPickerInput:(MSPickerInputView *)pickerInput { return 1; }

- (NSInteger)pickerInput:(MSPickerInputView *)pickerInput
 numberOfRowsInComponent:(NSInteger)component
{
    return [self.buttonPreviewImages count];
}

- (UIView *)pickerInput:(MSPickerInputView *)pickerInput
             viewForRow:(NSInteger)row
           forComponent:(NSInteger)component
            reusingView:(UIView *)view
{
    if (ValueIsNil(view))
        view = [[UIImageView alloc] initWithImage:self.buttonPreviewImages[row]];

    else
        ((UIImageView *)view).image = self.buttonPreviewImages[row];

    CGSize   fittedSize = [((UIImageView *)view).image sizeThatFits:CGSizeMake(200, 50)];

    [view resizeFrameToSize:fittedSize anchored:YES];

    return view;
}

- (CGFloat)pickerInput:(MSPickerInputView *)pickerInput rowHeightForComponent:(NSInteger)component
{
    return 50;
}

- (void)pickerInputDidCancel:(MSPickerInputView *)pickerInput
{
    [_addButtonPicker resignFirstResponder];
}

- (void)pickerInput:(MSPickerInputView *)pickerInput selectedRows:(NSArray *)rows
{
    [_addButtonPicker resignFirstResponder];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - RemoteElementEditingViewController Overrides
////////////////////////////////////////////////////////////////////////////////

- (void)willTranslateSelectedViews {
    [super willTranslateSelectedViews];
    [self.sourceView setValue:@NO forKey:@"locked"];
}

- (void)didTranslateSelectedViews {
    [super didTranslateSelectedViews];
    [self.sourceView setValue:@YES forKey:@"locked"];
}

@end

