//
// Button.h
// iPhonto
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "RemoteElement.h"
#import "Command.h"
#import "ControlStateSet.h"

typedef NS_ENUM (uint64_t, ButtonType) {
    ButtonTypeDefault          = RemoteElementButtonType,
    ButtonTypeNumberPad        = 0xC,
    ButtonTypeConnectionStatus = 0x14,
    ButtonTypeBatteryStatus    = 0x1C,
    ButtonTypeCommandManager   = 0x24,
    ButtonTypeActivityButton   = 0x2C,
    ButtonTypeReserved         = 0xFFC0,
    ButtonTypeMask             = RemoteElementTypeMask
};
typedef NS_ENUM (uint64_t, ButtonSubtype) {
    ButtonSubtypeUnspecified      = RemoteElementUnspecifiedSubtype,
    ButtonSubtypeActivityOn       = 0x10000,
    ButtonSubtypeReserved         = 0xFC0000,
    ButtonSubtypeButtonGroupPiece = 0xFF000000,
    ButtonSubtypeMask             = RemoteElementSubtypeMask
};
typedef NS_OPTIONS (uint64_t, ButtonState) {
    ButtonStateNormal      = RemoteElementDefaultState,
    ButtonStateDisabled    = 0x1000000000000,
    ButtonStateSelected    = 0x2000000000000,
    ButtonStateHighlighted = 0x4000000000000,
    ButtonStateReserved    = 0xFFF8000000000000,
    ButtonStateMask        = RemoteElementStateMask
};
typedef NS_OPTIONS (uint64_t, ButtonShape) {
    ButtonShapeCustom           = RemoteElementShapeUndefined,
    ButtonShapeRoundedRectangle = RemoteElementShapeRoundedRectangle,
    ButtonShapeOval             = RemoteElementShapeOval,
    ButtonShapeRectangle        = RemoteElementShapeRectangle,
    ButtonShapeTriangle         = RemoteElementShapeTriangle,
    ButtonShapeDiamond          = RemoteElementShapeDiamond,
    ButtonShapeReserved         = RemoteElementShapeReserved,
    ButtonShapeMask             = RemoteElementShapeMask
};
typedef NS_OPTIONS (uint64_t, ButtonStyle) {
    ButtonStyleBare        = RemoteElementNoStyle,
    ButtonStyleApplyGloss  = RemoteElementStyleApplyGloss,
    ButtonStyleDrawBorder  = RemoteElementStyleDrawBorder,
    ButtonStyleStretchable = RemoteElementStyleStretchable,
    ButtonStyleReserved    = RemoteElementStyleReserved,
    ButtonStyleMask        = RemoteElementStyleMask
};
typedef NS_ENUM (uint64_t, ActivityButtonType) {
    ActivityButtonTypeBegin = ButtonSubtypeActivityOn,
    ActivityButtonTypeEnd   = ButtonSubtypeUnspecified
};
typedef NS_ENUM (NSInteger, ButtonStyleDefault) {
    ButtonStyleDefault1 = 0,
    ButtonStyleDefault2 = 1,
    ButtonStyleDefault3 = 2,
    ButtonStyleDefault4 = 3,
    ButtonStyleDefault5 = 4
};
typedef NS_OPTIONS (NSUInteger, CommandOptions) {
    CommandOptionsDefault                   = 0 << 0,
        CommandOptionsLongPress             = 1 << 0,
        CommandOptionsNotifyComponentDevice = 1 << 1
};

@class   ButtonConfigurationDelegate, ButtonGroup, ComponentDevice;

/**
 * `Button` is an `NSManagedObject` subclass that models a button for a home theater remote
 * control. Its main function is to represent the visual attributes of the button, which are used
 * by a <ButtonView> in the user interface, and to be a means for executing commands, which are
 * encapsulated in a <Command> object. Different styles and behaviors can be achieved by changing
 * the button's `type` attribute. <ActivityButton> subclasses `Button` to coordinate launching and
 * exiting activities, which are coordinated by a <RemoteController>.
 */
@interface Button : RemoteElement <CommandDelegate>

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Text
////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, strong) ControlStateTitleSet * titles;

- (NSAttributedString *)titleForState:(UIControlState)state;
- (void)setTitle:(NSAttributedString *)title forState:(UIControlState)state;

@property (nonatomic, assign) UIEdgeInsets   titleEdgeInsets;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Icon
////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, strong) ControlStateIconImageSet * icons;

- (UIImage *)iconForState:(UIControlState)state;
- (GalleryIconImage *)galleryIconImageForState:(UIControlState)state;
- (void)setIcon:(GalleryIconImage *)icon forState:(UIControlState)state;
- (UIColor *)iconColorForState:(UIControlState)state;
- (void)setIconColor:(UIColor *)color forState:(UIControlState)state;

@property (nonatomic, assign) UIEdgeInsets   imageEdgeInsets;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Background
////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, strong) ControlStateColorSet * backgroundColors;

- (UIColor *)backgroundColorForState:(UIControlState)state;
- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state;

@property (nonatomic, strong) ControlStateButtonImageSet * images;

- (UIImage *)buttonImageForState:(UIControlState)state;
- (void)setButtonImage:(GalleryButtonImage *)image forState:(UIControlState)state;

@property (nonatomic, assign) UIEdgeInsets   contentEdgeInsets;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Commands
////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, strong) Command * command;
@property (nonatomic, strong) Command * longPressCommand;

- (void)executeCommandWithOptions:(CommandOptions)options delegate:(id <CommandDelegate> )delegate;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Configuration And State
////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, strong) ButtonConfigurationDelegate  * configurationDelegate;
@property (nonatomic, assign, getter = isSelected) BOOL      selected;
@property (nonatomic, assign, getter = isEnabled) BOOL       enabled;
@property (nonatomic, assign, getter = isHighlighted) BOOL   highlighted;

@end

/**
 * ActivityButton is a subclass of Button that can be used to trigger a change in the
 * `currentActivity` of a RemoteController. The `key` should be set to the match the name
 * of the associated activity. ActivityButton maintains a set of `DeviceConfiguration` objects to
 * associate with the **activity**. The remote controller associated with the button uses this
 * set to determine what state devices should be in when switching from one activity to another.
 */
@interface ActivityButton : Button

@property (nonatomic, strong) NSSet              * deviceConfigurations;
@property (nonatomic, assign) ActivityButtonType   activityButtonType;

@end
