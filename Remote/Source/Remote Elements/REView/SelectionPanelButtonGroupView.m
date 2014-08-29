//
// ModeSelectionView.m
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

@interface ModeSelectionView ()
@property (nonatomic, weak) ButtonView * selectedButton;
@end

@implementation ModeSelectionView

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ButtonGroupView overrides
////////////////////////////////////////////////////////////////////////////////

- (void)addSubelementView:(ButtonView *)view {
  [super addSubelementView:view];

  if (!_selectedButton) [self selectButton:view];

  __weak ModeSelectionView * weakself = self;
  __weak ButtonView        * weakview = view;
  view.tapAction = ^{ [weakself handleSelection:weakview]; };

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Selection Handling
////////////////////////////////////////////////////////////////////////////////

- (void)selectButton:(ButtonView *)newSelection {
  if (_selectedButton != newSelection && StringIsNotEmpty(newSelection.key)) {

    if (_selectedButton) _selectedButton.model.selected = NO;
    newSelection.model.selected = YES;
    _selectedButton = newSelection;

    RemoteController * controller = [RemoteController remoteController:self.model.managedObjectContext];
    controller.currentRemote.currentMode = newSelection.key;

  }
}

/// Button action attached to the view's button's as they are added as subviews. This method
/// updates the value of `selectedButton` with the `ButtonView` that invoked the method.
/// @param sender The `ButtonView` that has been touched.
- (void)handleSelection:(ButtonView *)sender {
  if (_selectedButton != sender) [self selectButton:sender];
  if (self.model.autohide) [self performSelector:@selector(tuck) withObject:nil afterDelay:1.0];
}

- (void)drawBackdropInContext:(CGContextRef)ctx inRect:(CGRect)rect {
  REPanelLocation panelLocation = self.model.panelLocation;

  CGContextClearRect(ctx, self.bounds);

  NSUInteger roundedCorners = (panelLocation == REPanelLocationRight
                               ? UIRectCornerTopLeft | UIRectCornerBottomLeft
                               : (panelLocation == REPanelLocationLeft
                                  ? UIRectCornerTopRight | UIRectCornerBottomRight
                                  : 0));

  UIBezierPath * bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                    byRoundingCorners:roundedCorners
                                                          cornerRadii:CGSizeMake(15, 15)];

  self.borderPath = bezierPath;

  [defaultBGColor() setFill];

  [bezierPath fillWithBlendMode:kCGBlendModeNormal alpha:0.9];

  CGRect  insetRect = CGRectInset(self.bounds, 0, 3);
  CGFloat tx        = (panelLocation == REPanelLocationRight ? 3 : -3);

  insetRect = CGRectApplyAffineTransform(insetRect, CGAffineTransformMakeTranslation(tx, 0));

  bezierPath = [UIBezierPath bezierPathWithRoundedRect:insetRect
                                     byRoundingCorners:roundedCorners
                                           cornerRadii:CGSizeMake(12, 12)];
  bezierPath.lineWidth = 2.0;
  [bezierPath strokeWithBlendMode:kCGBlendModeClear alpha:1.0];
}

@end
