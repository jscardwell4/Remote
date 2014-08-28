//
// REView.h
//
//
// Created by Jason Cardwell on 10/13/12.
//
//
#import "RETypedefs.h"
#import "RemoteElement.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Remote View
////////////////////////////////////////////////////////////////////////////////
@interface RemoteElementView : UIView

+ (instancetype)viewWithModel:(RemoteElement *)model;

@property (nonatomic, readonly) NSDictionary * viewFrames;
@property (nonatomic, readonly) CGSize         minimumSize;
@property (nonatomic, readonly) CGSize         maximumSize;
@property (nonatomic, readonly) NSString     * uuid;
@property (nonatomic, readonly) NSString     * key;
@property (nonatomic, readonly) NSString     * name;
@property (nonatomic, readonly) BOOL           proportionLock;
@property (nonatomic, readonly) NSString     * currentMode;

@end

@interface RemoteElementView (AbstractProperties)

- (RemoteElementView *)objectAtIndexedSubscript:(NSUInteger)idx;
- (RemoteElementView *)objectForKeyedSubscript:(NSString *)key;

@property (nonatomic, strong, readonly)  RemoteElement     * model;
@property (nonatomic, weak,   readonly)  RemoteElementView * parentElementView;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - SubelementViews
////////////////////////////////////////////////////////////////////////////////
@interface RemoteElementView (SubelementViews)

@property (nonatomic, strong, readonly)  NSArray * subelementViews;

- (void)addSubelementViews:(NSSet *)views;
- (void)addSubelementView:(RemoteElementView *)view;

- (void)removeSubelementViews:(NSSet *)views;
- (void)removeSubelementView:(RemoteElementView *)view;

- (void)bringSubelementViewToFront:(RemoteElementView *)subelementView;
- (void)sendSubelementViewToBack:(RemoteElementView *)subelementView;

- (void)insertSubelementView:(RemoteElementView *)subelementView
         aboveSubelementView:(RemoteElementView *)siblingSubelementView;
- (void)insertSubelementView:(RemoteElementView *)subelementView atIndex:(NSInteger)index;
- (void)insertSubelementView:(RemoteElementView *)subelementView
         belowSubelementView:(RemoteElementView *)siblingSubelementView;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Editing
////////////////////////////////////////////////////////////////////////////////

@interface RemoteElementView (Editing)

@property (nonatomic, assign, getter = isLocked)         BOOL           locked;
@property (nonatomic, assign)                            REEditingMode  editingMode;
@property (nonatomic, readonly, getter = isEditing)      BOOL           editing;
@property (nonatomic, assign)                            REEditingState editingState;
@property (nonatomic, getter = isResizable)              BOOL           resizable;
@property (nonatomic, getter = isMoveable)               BOOL           moveable;
@property (nonatomic, assign, getter = shouldShrinkwrap) BOOL           shrinkwrap;
@property (nonatomic, assign)                            CGFloat        appliedScale;

- (void)updateSubelementOrderFromView;

- (void)translateSubelements:(NSSet *)subelementViews translation:(CGPoint)translation;

- (void)scaleSubelements:(NSSet *)subelementViews scale:(CGFloat)scale;

- (void)alignSubelements:(NSSet *)subelementViews
               toSibling:(RemoteElementView *)siblingView
               attribute:(NSLayoutAttribute)attribute;

- (void)resizeSubelements:(NSSet *)subelementViews
                toSibling:(RemoteElementView *)siblingView
                attribute:(NSLayoutAttribute)attribute;

- (void)scale:(CGFloat)scale;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Debugging
////////////////////////////////////////////////////////////////////////////////

@interface RemoteElementView (Debugging)

- (NSString *)appearanceDescription;
- (MSDictionary *)appearanceDescriptionDictionary;
- (NSString *)framesDescription;
- (NSString *)constraintsDescription;
- (NSString *)viewConstraintsDescription;
- (NSString *)modelConstraintsDescription;

NSString *prettyRemoteElementConstraint(NSLayoutConstraint * constraint);

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - RemoteView
////////////////////////////////////////////////////////////////////////////////


@class ButtonGroupView, Remote;

@interface RemoteView : RemoteElementView @end

@interface RemoteView (ButtonGroupViews)

@property (nonatomic, strong, readonly) Remote   * model;
- (ButtonGroupView *)objectAtIndexedSubscript:(NSUInteger)idx;
- (ButtonGroupView *)objectForKeyedSubscript:(NSString *)key;

@end

@interface RemoteView (RERemote)

@property (nonatomic, assign, getter = isTopBarHidden) BOOL topBarHidden;

- (BOOL)registerMode:(NSString *)mode;
- (BOOL)switchToMode:(NSString *)mode;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ButtonGroupView
////////////////////////////////////////////////////////////////////////////////
#define ButtonGroupTucksVertically(buttonGroup) \
  (  buttonGroup.panelLocation == REPanelLocationTop || buttonGroup.panelLocation == REPanelLocationBottom)

#define ButtonGroupTucksHorizontally(buttonGroup) \
  (  buttonGroup.panelLocation == REPanelLocationLeft || buttonGroup.panelLocation == REPanelLocationRight)


/**
 * The `ButtonGroupView` class is a subclass of `UIView` designed to display itself
 * according to the <ButtonGroup> model object it has been assigned. Multiple button group
 * views are typically attached as subviews for a `RemoteView` to construct a fully
 * realized interface to the user's home theater system. Subclasses include
 * <PickerLabelButtonGroupView>, <RoundedPanelButtonGroupView>, and
 * <SelectionPanelButtonGroupView>.
 */
@class ButtonView, ButtonGroup, RemoteView;

@interface ButtonGroupView : RemoteElementView

@property (nonatomic, assign) REPanelLocation   panelLocation;
@property (nonatomic, assign) BOOL              autohide;
@property (nonatomic, weak)   UILabel         * label;

- (void)tuck;
- (void)untuck;

@end

@interface ButtonGroupView (SubclassSpecific)

@property (nonatomic, strong, readonly)  ButtonGroup * model;
@property (nonatomic, weak,   readonly)  RemoteView  * parentElementView;

- (ButtonView *)objectAtIndexedSubscript:(NSUInteger)idx;
- (ButtonView *)objectForKeyedSubscript:(NSString *)key;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Subclasses of ButtonGroupView
////////////////////////////////////////////////////////////////////////////////

/**
 * `SelectionPanelButtonGroupView` subclasses <RoundedPanelButtonGroupView> to add
 * mode management functionality. Configurations are specified by the `key`
 * values of the view's buttons. Pressing one of the buttons causes the view to post a
 * change notification to the default notification center. Instances of
 * <ConfigurationDelegate> registered for the notification can swap out <Command> or
 * <CommandSet> for the <Button> or <ButtonGroup> to which the delegate has been assigned.
 */
@interface SelectionPanelButtonGroupView : ButtonGroupView @end

MSEXTERN_NAMETAG(REPickerLabelButtonGroupViewInternal);
MSEXTERN_NAMETAG(REPickerLabelButtonGroupViewLabelContainer);

@interface PickerLabelButtonGroupView : ButtonGroupView @end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - REButtonView
////////////////////////////////////////////////////////////////////////////////


MSEXTERN_NAMETAG(REButtonViewInternal);
MSEXTERN_NAMETAG(REButtonViewLabel);
MSEXTERN_NAMETAG(REButtonViewActivityIndicator);

@class Button, Command;

/**
 * The `ButtonView` class is a subclass of `UIControl` that is designed to display itself
 * according to the <Button> model object it has been assigned. These views can be grouped
 * and contained by a `ButtonGroupView` to piece together a very versatile user interface
 * for home theater remote control. Subclasses include <ConnectionStatusButtonView> and
 * <BatteryStatusButtonView>
 */
@interface ButtonView : RemoteElementView

- (void)setActionHandler:(REActionHandler)handler
               forAction:(REAction)action;

@property (nonatomic, strong, readonly)  Button          * model;
@property (nonatomic, weak,   readonly)  ButtonGroupView * parentElementView;
@property (nonatomic, assign, readonly)  UIControlState    state;

@end

/// Properties forwared to model object.
@interface ButtonView (REButton)

@property (nonatomic, assign, getter = isHighlighted) BOOL         highlighted;
@property (nonatomic, assign, getter = isSelected)    BOOL         selected;
@property (nonatomic, assign, getter = isEnabled)     BOOL         enabled;
@property (nonatomic, assign)                         UIEdgeInsets titleEdgeInsets;
@property (nonatomic, assign)                         UIEdgeInsets imageEdgeInsets;
@property (nonatomic, assign)                         UIEdgeInsets contentEdgeInsets;
@property (nonatomic, strong)                         Command    * command;

@end

/**
 * <ButtonView> subclass that has been specialized to display network connection status
 * information through notifications posted by <ConnectionManager>.
 */
@interface ConnectionStatusButtonView : ButtonView @end

/**
 * <ButtonView> subclass that has been specialized to display battery status information.
 */
@interface BatteryStatusButtonView : ButtonView

@property (nonatomic, strong) UIColor * frameColor;      /// Color to make the battery frame.
@property (nonatomic, strong) UIColor * plugColor;       /// Color to make the 'plug'.
@property (nonatomic, strong) UIColor * lightningColor;  /// Color to make the 'thunderbolt'.
@property (nonatomic, strong) UIColor * fillColor;       /// Color to make the 'charged' fill.
@property (nonatomic, strong) UIImage * frameIcon;       /// Image to draw for battery frame.
@property (nonatomic, strong) UIImage * plugIcon;        /// Image to draw for 'plug'.
@property (nonatomic, strong) UIImage * lightningIcon;   /// Image to draw when charging.

@end
