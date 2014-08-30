//
// SelectionPanelButtonGroupView.m
// Remote
//
// Created by Jason Cardwell on 3/20/13.
// Copyright 2013 Moondeer Studios. All rights reserved.
//
#import "RemoteElementView_Private.h"
#import "ButtonGroup.h"
#import "Button.h"
#import "Remote.h"
#import "RemoteController.h"

static int ddLogLevel   = DefaultDDLogLevel;
static int msLogContext = (LOG_CONTEXT_REMOTE | LOG_CONTEXT_FILE | LOG_CONTEXT_CONSOLE);

@interface SelectionPanelButtonGroupView ()
@property (nonatomic, weak) ButtonView * selectedButton;
@end

@implementation SelectionPanelButtonGroupView

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ButtonGroupView overrides
////////////////////////////////////////////////////////////////////////////////

- (void)addSubelementView:(ButtonView *)view {
  [super addSubelementView:view];

    if (!_selectedButton) [self selectButton:view];

  __weak SelectionPanelButtonGroupView * weakself = self;
  __weak ButtonView                    * weakview = view;

  [view setActionHandler:^{ [weakself handleSelection:weakview]; } forAction:RESingleTapAction];

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Selection Handling
////////////////////////////////////////////////////////////////////////////////

- (void)selectButton:(ButtonView *)newSelection {
  if (_selectedButton != newSelection && StringIsNotEmpty(newSelection.key)) {

    RemoteController * controller = [RemoteController remoteController:self.model.managedObjectContext];
    controller.currentRemote.currentMode = newSelection.key;

    if (_selectedButton) _selectedButton.model.selected = NO;

    _selectedButton                = newSelection;
    _selectedButton.model.selected = YES;
  }
}

/**
 * Button action attached to the view's button's as they are added as subviews. This method
 * updates the value of `selectedButton` with the `ButtonView` that invoked the method.
 * @param sender The `ButtonView` that has been touched.
 */
- (void)handleSelection:(ButtonView *)sender {
  if (_selectedButton != sender) [self selectButton:sender];
  if (self.autohide) [self performSelector:@selector(tuck) withObject:nil afterDelay:1.0];
}

- (void)drawBackdropInContext:(CGContextRef)ctx inRect:(CGRect)rect {
  [self drawRoundedPanelInContext:ctx inRect:rect];
}

@end
