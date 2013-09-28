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
- (instancetype)initWithModel:(RemoteElement *)model;

- (RemoteElementView *)objectAtIndexedSubscript:(NSUInteger)idx;
- (RemoteElementView *)objectForKeyedSubscript:(NSString *)key;

@property (nonatomic, readonly) CGSize minimumSize;
@property (nonatomic, readonly) CGSize maximumSize;

@end

@interface RemoteElementView (AbstractProperties)

@property (nonatomic, strong, readonly)  RemoteElement * model;
@property (nonatomic, weak,   readonly)  RemoteElementView        * parentElementView;

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

@property (nonatomic, assign)                            REEditingMode    editingMode;
@property (nonatomic, readonly, getter = isEditing)      BOOL             editing;
@property (nonatomic, assign)                            REEditingState   editingState;
@property (nonatomic, getter = isResizable)              BOOL             resizable;
@property (nonatomic, getter = isMoveable)               BOOL             moveable;
@property (nonatomic, assign, getter = shouldShrinkwrap) BOOL             shrinkwrap;
@property (nonatomic, assign)                            CGFloat          appliedScale;

- (void)updateSubelementOrderFromView;

- (void)translateSubelements:(NSSet *)subelementViews translation:(CGPoint)translation;

- (void)scaleSubelements:(NSSet *)subelementViews scale:(CGFloat)scale;

- (void)alignSubelements:(NSSet *)subelementViews
               toSibling:(RemoteElementView *)siblingView
               attribute:(NSLayoutAttribute)attribute;

- (void)resizeSubelements:(NSSet *)subelementViews
                toSibling:(RemoteElementView *)siblingView
                attribute:(NSLayoutAttribute)attribute;

- (void)willResizeViews:(NSSet *)views;
- (void)didResizeViews:(NSSet *)views;

- (void)willScaleViews:(NSSet *)views;
- (void)scale:(CGFloat)scale;
- (void)didScaleViews:(NSSet *)views;

- (void)willAlignViews:(NSSet *)views;
- (void)didAlignViews:(NSSet *)views;

- (void)willTranslateViews:(NSSet *)views;
- (void)didTranslateViews:(NSSet *)views;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Surrogate
////////////////////////////////////////////////////////////////////////////////

@interface RemoteElementView (RemoteElement)

@property (nonatomic, copy)             NSString                * key;
@property (nonatomic, copy)             NSString                * uuid;
@property (nonatomic, copy)             NSString                * name;
@property (nonatomic, assign)           CGFloat                   backgroundImageAlpha;
@property (nonatomic, strong)           UIColor                 * backgroundColor;
@property (nonatomic, strong)           Image                 * backgroundImage;
@property (nonatomic, strong)           RemoteController      * controller;
@property (nonatomic, strong)           RemoteElement           * parentElement;
@property (nonatomic, strong)           NSOrderedSet            * subelements;
@property (nonatomic, strong, readonly) LayoutConfiguration   * layoutConfiguration;
@property (nonatomic, strong)           ConfigurationDelegate * configurationDelegate;
@property (nonatomic, assign)           BOOL                      proportionLock;
@property (nonatomic, assign)           REShape                   shape;
@property (nonatomic, assign)           REStyle                   style;
@property (nonatomic, readonly)         REType                    type;
@property (nonatomic, readonly)         RESubtype                 subtype;
@property (nonatomic, assign)           REOptions                 options;
@property (nonatomic, readonly)         REState                   state;

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

NSString * prettyRemoteElementConstraint(NSLayoutConstraint * constraint);

@end


MSSTATIC_INLINE NSDictionary *viewFramesByIdentifier(RemoteElementView * remoteElementView)
{
    NSMutableDictionary * viewFrames =
        [NSMutableDictionary dictionaryWithObjects:[remoteElementView.subelementViews
                                                    valueForKeyPath:@"frame"]
                                           forKeys:[remoteElementView.subelementViews
                  valueForKeyPath:@"uuid"]];

    viewFrames[remoteElementView.uuid] = NSValueWithCGRect(remoteElementView.frame);

    if (remoteElementView.parentElementView)
        viewFrames[remoteElementView.parentElementView.uuid] =
            NSValueWithCGRect(remoteElementView.parentElementView.frame);

    return viewFrames;
}

MSSTATIC_INLINE BOOL REStringIdentifiesREView(NSString * identifier, RemoteElementView * view) {
    return REStringIdentifiesRemoteElement(identifier, view.model);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - RemoteView
////////////////////////////////////////////////////////////////////////////////



@class ButtonGroupView;

@interface RemoteView : RemoteElementView

@property (nonatomic, strong, readonly)  Remote * model;
@property (nonatomic, assign)   	 		 BOOL       locked;
@property (nonatomic, readonly) 			 NSString * currentConfiguration;
@property (nonatomic, readonly) 			 NSArray  * registeredConfigurations;

- (ButtonGroupView *)objectAtIndexedSubscript:(NSUInteger)idx;
- (ButtonGroupView *)objectForKeyedSubscript:(NSString *)key;

@end

@interface RemoteView (RERemote)

@property (nonatomic, assign, getter = isTopBarHiddenOnLoad) BOOL   topBarHiddenOnLoad;

- (BOOL)registerConfiguration:(NSString *)configuration;
- (BOOL)switchToConfiguration:(NSString *)configuration;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ButtonGroupView
////////////////////////////////////////////////////////////////////////////////
#define ButtonGroupTucksVertically(buttonGroup) \
(  buttonGroup.panelLocation                \
== REPanelLocationTop         \
|| buttonGroup.panelLocation                \
== REPanelLocationBottom)

#define ButtonGroupTucksHorizontally(buttonGroup) \
(  buttonGroup.panelLocation                  \
== REPanelLocationLeft          \
|| buttonGroup.panelLocation                  \
== REPanelLocationRight)

MSEXTERN_NAMETAG(ButtonGroupViewInternal);
MSEXTERN_NAMETAG(ButtonGroupViewLabel);

/**
 * The `ButtonGroupView` class is a subclass of `UIView` designed to display itself
 * according to the <ButtonGroup> model object it has been assigned. Multiple button group
 * views are typically attached as subviews for a `RemoteView` to construct a fully
 * realized interface to the user's home theater system. Subclasses include
 * <PickerLabelButtonGroupView>, <RoundedPanelButtonGroupView>, and
 * <SelectionPanelButtonGroupView>.
 */
@class   ButtonView, RemoteView;

@interface ButtonGroupView : RemoteElementView

@property (nonatomic, strong, readonly)  ButtonGroup * model;
@property (nonatomic, weak,   readonly)  RemoteView  * parentElementView;
@property (nonatomic, assign)            BOOL            autohide;
@property (nonatomic, assign)            BOOL            locked;

- (ButtonView *)objectAtIndexedSubscript:(NSUInteger)idx;
- (ButtonView *)objectForKeyedSubscript:(NSString *)key;
- (void)tuck;
- (void)untuck;

@end

#pragma mark - Properties forwarded to the model object

@interface ButtonGroupView (REButtonGroup)

@property (nonatomic, assign) REPanelLocation   panelLocation;

@end

@interface ButtonGroupView (Drawing)

- (void)drawRoundedPanelInContext:(CGContextRef)ctx inRect:(CGRect)rect;

@end
////////////////////////////////////////////////////////////////////////////////
#pragma mark - Subclasses of ButtonGroupView
////////////////////////////////////////////////////////////////////////////////
/**
 * `SelectionPanelButtonGroupView` subclasses <RoundedPanelButtonGroupView> to add
 * configuration management functionality. Configurations are specified by the `key`
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

@property (nonatomic, strong, readonly)  Button           * model;
@property (nonatomic, weak,   readonly)  ButtonGroupView  * parentElementView;
@property (nonatomic, assign, readonly)  UIControlState       state;

@end

@class ButtonConfigurationDelegate;

/// Properties forwared to model object.
@interface ButtonView (REButton)

@property (nonatomic, assign, getter = isHighlighted) BOOL     highlighted;
@property (nonatomic, assign, getter = isSelected) BOOL        selected;
@property (nonatomic, assign, getter = isEnabled) BOOL         enabled;
@property (nonatomic, assign) UIEdgeInsets                     titleEdgeInsets;
@property (nonatomic, assign) UIEdgeInsets                     imageEdgeInsets;
@property (nonatomic, assign) UIEdgeInsets                     contentEdgeInsets;
@property (nonatomic, strong) Command                      * command;
@property (nonatomic, strong) ButtonConfigurationDelegate  * configurationDelegate;

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
