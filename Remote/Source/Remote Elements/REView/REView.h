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
@interface REView : UIView

+ (instancetype)viewWithModel:(RemoteElement *)model;
- (instancetype)initWithModel:(RemoteElement *)model;

- (REView *)objectAtIndexedSubscript:(NSUInteger)idx;
- (REView *)objectForKeyedSubscript:(NSString *)key;

@property (nonatomic, readonly) CGSize minimumSize;
@property (nonatomic, readonly) CGSize maximumSize;

@end

@interface REView (AbstractProperties)

@property (nonatomic, strong, readonly)  RemoteElement * model;
@property (nonatomic, weak,   readonly)  REView        * parentElementView;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - SubelementViews
////////////////////////////////////////////////////////////////////////////////
@interface REView (SubelementViews)

@property (nonatomic, strong, readonly)  NSArray * subelementViews;

- (void)addSubelementViews:(NSSet *)views;
- (void)addSubelementView:(REView *)view;

- (void)removeSubelementViews:(NSSet *)views;
- (void)removeSubelementView:(REView *)view;

- (void)bringSubelementViewToFront:(REView *)subelementView;
- (void)sendSubelementViewToBack:(REView *)subelementView;

- (void)insertSubelementView:(REView *)subelementView
         aboveSubelementView:(REView *)siblingSubelementView;
- (void)insertSubelementView:(REView *)subelementView atIndex:(NSInteger)index;
- (void)insertSubelementView:(REView *)subelementView
         belowSubelementView:(REView *)siblingSubelementView;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Editing
////////////////////////////////////////////////////////////////////////////////

@interface REView (Editing)

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
               toSibling:(REView *)siblingView
               attribute:(NSLayoutAttribute)attribute;

- (void)resizeSubelements:(NSSet *)subelementViews
                toSibling:(REView *)siblingView
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

@interface REView (RemoteElement)

@property (nonatomic, copy)             NSString                * key;
@property (nonatomic, copy)             NSString                * uuid;
@property (nonatomic, copy)             NSString                * name;
@property (nonatomic, assign)           CGFloat                   backgroundImageAlpha;
@property (nonatomic, strong)           UIColor                 * backgroundColor;
@property (nonatomic, strong)           BOImage                 * backgroundImage;
@property (nonatomic, strong)           RERemoteController      * controller;
@property (nonatomic, strong)           RemoteElement           * parentElement;
@property (nonatomic, strong)           NSOrderedSet            * subelements;
@property (nonatomic, strong, readonly) RELayoutConfiguration   * layoutConfiguration;
@property (nonatomic, strong)           REConfigurationDelegate * configurationDelegate;
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

@interface REView (Debugging)

- (NSString *)appearanceDescription;
- (MSDictionary *)appearanceDescriptionDictionary;
- (NSString *)framesDescription;
- (NSString *)constraintsDescription;
- (NSString *)viewConstraintsDescription;
- (NSString *)modelConstraintsDescription;

NSString * prettyRemoteElementConstraint(NSLayoutConstraint * constraint);

@end


MSKIT_STATIC_INLINE NSDictionary *viewFramesByIdentifier(REView * remoteElementView)
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

MSKIT_STATIC_INLINE BOOL REStringIdentifiesREView(NSString * identifier, REView * view) {
    return REStringIdentifiesRemoteElement(identifier, view.model);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - RERemoteView
////////////////////////////////////////////////////////////////////////////////



@class REButtonGroupView;

@interface RERemoteView : REView

@property (nonatomic, strong, readonly)  RERemote * model;
@property (nonatomic, assign)   	 		 BOOL       locked;
@property (nonatomic, readonly) 			 NSString * currentConfiguration;
@property (nonatomic, readonly) 			 NSArray  * registeredConfigurations;

- (REButtonGroupView *)objectAtIndexedSubscript:(NSUInteger)idx;
- (REButtonGroupView *)objectForKeyedSubscript:(NSString *)key;

@end

@interface RERemoteView (RERemote)

@property (nonatomic, assign, getter = isTopBarHiddenOnLoad) BOOL   topBarHiddenOnLoad;

- (BOOL)registerConfiguration:(NSString *)configuration;
- (BOOL)switchToConfiguration:(NSString *)configuration;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - REButtonGroupView
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

MSKIT_EXTERN_NAMETAG(REButtonGroupViewInternal);
MSKIT_EXTERN_NAMETAG(REButtonGroupViewLabel);

/**
 * The `ButtonGroupView` class is a subclass of `UIView` designed to display itself
 * according to the <ButtonGroup> model object it has been assigned. Multiple button group
 * views are typically attached as subviews for a `RemoteView` to construct a fully
 * realized interface to the user's home theater system. Subclasses include
 * <PickerLabelButtonGroupView>, <RoundedPanelButtonGroupView>, and
 * <SelectionPanelButtonGroupView>.
 */
@class   REButtonView, RERemoteView;

@interface REButtonGroupView : REView

@property (nonatomic, strong, readonly)  REButtonGroup * model;
@property (nonatomic, weak,   readonly)  RERemoteView  * parentElementView;
@property (nonatomic, assign)            BOOL            autohide;
@property (nonatomic, assign)            BOOL            locked;

- (REButtonView *)objectAtIndexedSubscript:(NSUInteger)idx;
- (REButtonView *)objectForKeyedSubscript:(NSString *)key;
- (void)tuck;
- (void)untuck;

@end

#pragma mark - Properties forwarded to the model object

@interface REButtonGroupView (REButtonGroup)

@property (nonatomic, assign) REPanelLocation   panelLocation;

@end

@interface REButtonGroupView (Drawing)

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
@interface RESelectionPanelButtonGroupView : REButtonGroupView @end

MSKIT_EXTERN_NAMETAG(REPickerLabelButtonGroupViewInternal);
MSKIT_EXTERN_NAMETAG(REPickerLabelButtonGroupViewLabelContainer);

@interface REPickerLabelButtonGroupView : REButtonGroupView @end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - REButtonView
////////////////////////////////////////////////////////////////////////////////


MSKIT_EXTERN_NAMETAG(REButtonViewInternal);
MSKIT_EXTERN_NAMETAG(REButtonViewLabel);
MSKIT_EXTERN_NAMETAG(REButtonViewActivityIndicator);


/**
 * The `ButtonView` class is a subclass of `UIControl` that is designed to display itself
 * according to the <Button> model object it has been assigned. These views can be grouped
 * and contained by a `ButtonGroupView` to piece together a very versatile user interface
 * for home theater remote control. Subclasses include <ConnectionStatusButtonView> and
 * <BatteryStatusButtonView>
 */
@interface REButtonView : REView

- (void)setActionHandler:(REActionHandler)handler
               forAction:(REAction)action;

@property (nonatomic, strong, readonly)  REButton           * model;
@property (nonatomic, weak,   readonly)  REButtonGroupView  * parentElementView;
@property (nonatomic, assign, readonly)  UIControlState       state;

@end

@class REButtonConfigurationDelegate;

/// Properties forwared to model object.
@interface REButtonView (REButton)

@property (nonatomic, assign, getter = isHighlighted) BOOL     highlighted;
@property (nonatomic, assign, getter = isSelected) BOOL        selected;
@property (nonatomic, assign, getter = isEnabled) BOOL         enabled;
@property (nonatomic, assign) UIEdgeInsets                     titleEdgeInsets;
@property (nonatomic, assign) UIEdgeInsets                     imageEdgeInsets;
@property (nonatomic, assign) UIEdgeInsets                     contentEdgeInsets;
@property (nonatomic, strong) RECommand                      * command;
@property (nonatomic, strong) REButtonConfigurationDelegate  * configurationDelegate;

@end

/**
 * <ButtonView> subclass that has been specialized to display network connection status
 * information through notifications posted by <ConnectionManager>.
 */
@interface REConnectionStatusButtonView : REButtonView @end

/**
 * <ButtonView> subclass that has been specialized to display battery status information.
 */
@interface REBatteryStatusButtonView : REButtonView

@property (nonatomic, strong) UIColor * frameColor;      /// Color to make the battery frame.
@property (nonatomic, strong) UIColor * plugColor;       /// Color to make the 'plug'.
@property (nonatomic, strong) UIColor * lightningColor;  /// Color to make the 'thunderbolt'.
@property (nonatomic, strong) UIColor * fillColor;       /// Color to make the 'charged' fill.
@property (nonatomic, strong) UIImage * frameIcon;       /// Image to draw for battery frame.
@property (nonatomic, strong) UIImage * plugIcon;        /// Image to draw for 'plug'.
@property (nonatomic, strong) UIImage * lightningIcon;   /// Image to draw when charging.

@end
