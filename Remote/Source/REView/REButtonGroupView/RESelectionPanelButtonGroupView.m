//
// RESelectionPanelButtonGroupView.m
// Remote
//
// Created by Jason Cardwell on 3/20/13.
// Copyright 2013 Moondeer Studios. All rights reserved.
//
#import "REView_Private.h"

static int   ddLogLevel   = DefaultDDLogLevel;
static int   msLogContext = REMOTE_F_C;

@implementation RESelectionPanelButtonGroupView

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ButtonGroupView overrides
////////////////////////////////////////////////////////////////////////////////
- (void)initializeIVARs
{
    [super initializeIVARs];
    self.autohide = YES;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview) {
        for (REButtonView * view in self.subelementViews) {
            if (![self.parentElementView registerConfiguration:view.key])
                MSLogWarnTag(@"failed to register configuration '%@' with remote controller..."
                          "perhaps it was already registered?", view.key);
            else
                MSLogDebugTag(@"new configuration '%@' registered successfully with remote controller",
                           view.key);
        }
        if (!_selectedButton && self[REDefaultConfiguration])
            [self selectButton:self[REDefaultConfiguration]];
    }
}

- (void)addSubelementView:(REButtonView *)view
{
    [super addSubelementView:view];

    if (self.parentElementView) {
        if (![self.parentElementView registerConfiguration:view.key])
            MSLogWarnTag(@"failed to register configuration '%@' with remote controller..."
                      "perhaps it was already registered?", view.key);
        else
            MSLogDebugTag(@"new configuration '%@' registered successfully with remote controller",
                       view.key);
        if (!_selectedButton && [REDefaultConfiguration isEqualToString:view.key])
            [self selectButton:view];
    }
    __weak RESelectionPanelButtonGroupView * weakself = self;
    __weak REButtonView * weakview = view;
    [view setActionHandler:^{ [weakself handleSelection:weakview]; }
                 forAction:RESingleTapAction];

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Selection Handling
////////////////////////////////////////////////////////////////////////////////

- (void)selectButton:(REButtonView *)newSelection
{
    if (   _selectedButton != newSelection
        && [self.parentElementView switchToConfiguration:newSelection.key])
    {

        if (_selectedButton) _selectedButton.model.selected = NO;
        _selectedButton = newSelection;
        _selectedButton.model.selected = YES;
        MSLogDebugTag(@"selected button with key '%@'", _selectedButton.key);
    }
}

/**
 * Button action attached to the view's button's as they are added as subviews. This method
 * updates the value of `selectedButton` with the `ButtonView` that invoked the method.
 * @param sender The `ButtonView` that has been touched.
 */
- (void)handleSelection:(REButtonView *)sender
{
    if (_selectedButton == sender)
    {
        MSLogDebugTag(@"sender(%@) is already selected", sender.key);
        return;
    }

    assert(StringIsNotEmpty(sender.key));
    [self selectButton:sender];

    if (self.autohide) [self performSelector:@selector(tuck) withObject:nil afterDelay:1.0];
}

- (void)drawBackdropInContext:(CGContextRef)ctx inRect:(CGRect)rect {
    [self drawRoundedPanelInContext:ctx inRect:rect];
}

@end

