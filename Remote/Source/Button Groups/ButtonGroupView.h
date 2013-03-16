//
// ButtonGroupView.h
// iPhonto
//
// Created by Jason Cardwell on 5/24/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RemoteElementEditingViewController.h"
#import "ButtonGroup.h"
#import "RemoteElementView.h"

#define ButtonGroupTucksVertically(buttonGroup) \
    (  buttonGroup.panelLocation                \
       == ButtonGroupPanelLocationTop           \
    || buttonGroup.panelLocation                \
       == ButtonGroupPanelLocationBottom)

#define ButtonGroupTucksHorizontally(buttonGroup) \
    (  buttonGroup.panelLocation                  \
       == ButtonGroupPanelLocationLeft            \
    || buttonGroup.panelLocation                  \
       == ButtonGroupPanelLocationRight)

MSKIT_EXTERN_STRING   kTuckButtonKey;

/**
 * The `ButtonGroupView` class is a subclass of `UIView` designed to display itself
 * according to the <ButtonGroup> model object it has been assigned. Multiple button group
 * views are typically attached as subviews for a `RemoteView` to construct a fully
 * realized interface to the user's home theater system. Subclasses include
 * <PickerLabelButtonGroupView>, <RoundedPanelButtonGroupView>, and
 * <SelectionPanelButtonGroupView>.
 */
@class   ButtonView;

@interface ButtonGroupView : RemoteElementView

@property (nonatomic, assign) BOOL   buttonsEnabled;
@property (nonatomic, assign) BOOL   autohide;
@property (nonatomic, assign) BOOL   buttonsLocked;

@end

#pragma mark - Properties forwarded to the model object

@interface ButtonGroupView (ButtonGroupModelMethodsAndProperties)
@property (nonatomic, assign) ButtonGroupSubtype   panelLocation;
@end

#pragma mark - Subclasses of ButtonGroupView

/**
 * `RoundedPanelButtonGroupView` subclasses <ButtonGroupView> to create a specific visual
 * style by overriding `drawRect:`. As the name implies, the style is well suited for use
 * as a panel for <RemoteView> objects. <SelectionPanelButtonGroupView> subclasses
 * `RoundedPanelButtonGroupView`, providing specific button behaviors designed to allow
 * for easily switching command configurations.
 */
@interface RoundedPanelButtonGroupView : ButtonGroupView @end

/**
 * `SelectionPanelButtonGroupView` subclasses <RoundedPanelButtonGroupView> to add
 * configuration management functionality. Configurations are specified by the `key`
 * values of the view's buttons. Pressing one of the buttons causes the view to post a
 * change notification to the default notification center. Instances of
 * <ConfigurationDelegate> registered for the notification can swap out <Command> or
 * <CommandSet> for the <Button> or <ButtonGroup> to which the delegate has been assigned.
 */
@interface SelectionPanelButtonGroupView : RoundedPanelButtonGroupView @end

@interface PickerLabelButtonGroupView : ButtonGroupView @end
