//
// ButtonView.h
// iPhonto
//
// Created by Jason Cardwell on 5/24/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//
#import "RemoteElementView.h"
#import "Button.h"
#import "Command.h"
#import <QuartzCore/QuartzCore.h>
#import "RemoteElementEditingViewController.h"

typedef void (^ ButtonViewActionHandler)(void);
typedef         NS_ENUM (NSUInteger, ButtonViewAction) {
    ButtonViewSingleTapAction = 0,
    ButtonViewLongPressAction = 1
};

/**
 * The `ButtonView` class is a subclass of `UIControl` that is designed to display itself
 * according to the <Button> model object it has been assigned. These views can be grouped
 * and contained by a `ButtonGroupView` to piece together a very versatile user interface
 * for home theater remote control. Subclasses include <ConnectionStatusButtonView> and
 * <BatteryStatusButtonView>
 */
@interface ButtonView : RemoteElementView <CommandDelegate>

- (void)setActionHandler:(ButtonViewActionHandler)handler
               forAction:(ButtonViewAction)action;

@end

@class   GalleryButtonImage, GalleryIconImage;

/// Properties forwared to model object.
@interface ButtonView (ButtonModelMethodsAndProperties)
@property (nonatomic, assign, getter = isHighlighted) BOOL   highlighted;
@property (nonatomic, assign, getter = isSelected) BOOL      selected;
@property (nonatomic, assign, getter = isEnabled) BOOL       enabled;
@property (nonatomic, assign) UIEdgeInsets                   titleEdgeInsets;
@property (nonatomic, assign) UIEdgeInsets                   imageEdgeInsets;
@property (nonatomic, assign) UIEdgeInsets                   contentEdgeInsets;
@property (nonatomic, strong) Command                      * command;
@property (nonatomic, strong) ButtonConfigurationDelegate  * configurationDelegate;

- (UIColor *)backgroundColorForState:(UIControlState)state;
- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state;

- (UIImage *)iconForState:(UIControlState)state;
- (void)setIcon:(GalleryIconImage *)icon forState:(UIControlState)state;

- (UIImage *)buttonImageForState:(UIControlState)state;
- (void)setButtonImage:(GalleryButtonImage *)image forState:(UIControlState)state;

- (NSAttributedString *)titleForState:(UIControlState)state;
- (void)setTitle:(NSAttributedString *)title forState:(UIControlState)state;

- (UIColor *)iconColorForState:(UIControlState)state;
- (void)setIconColor:(UIColor *)color forState:(UIControlState)state;

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
@property (nonatomic, strong) UIColor * frameColor;              /// Color to make the battery
                                                                 // frame.
@property (nonatomic, strong) UIColor * plugColor;               /// Color to make the 'plug'.
@property (nonatomic, strong) UIColor * lightningColor;          /// Color to make the
                                                                 // 'thunderbolt'.
@property (nonatomic, strong) UIColor * fillColor;               /// Color to make the 'charged'
                                                                 // fill.
@property (nonatomic, strong) GalleryIconImage * frameIcon;      /// Image to draw for battery
                                                                 // frame.
@property (nonatomic, strong) GalleryIconImage * plugIcon;       /// Image to draw for 'plug'.
@property (nonatomic, strong) GalleryIconImage * lightingIcon;   /// Image to draw when charging.
@end
