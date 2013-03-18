//
// Button.h
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "RemoteElement.h"
#import "Command.h"
#import "ControlStateSet.h"

typedef NS_ENUM (uint64_t, REButtonType) {
    REButtonTypeDefault          = RETypeButton,
    REButtonTypeNumberPad        = 0xC,
    REButtonTypeConnectionStatus = 0x14,
    REButtonTypeBatteryStatus    = 0x1C,
    REButtonTypeCommandManager   = 0x24,
    REButtonTypeActivityButton   = 0x2C,
    REButtonTypeReserved         = 0xFFC0,
    REButtonTypeMask             = RETypeMask
};

typedef NS_ENUM (uint64_t, REButtonSubtype) {
    REButtonSubtypeUnspecified      = RESubtypeUndefined,
    REButtonSubtypeActivityOn       = 0x10000,
    REButtonSubtypeReserved         = 0xFC0000,
    REButtonSubtypeButtonGroupPiece = 0xFF000000,
    REButtonSubtypeMask             = RESubtypeMask
};

typedef NS_OPTIONS (uint64_t, REButtonState) {
    REButtonStateNormal      = REStateDefault,
    REButtonStateDisabled    = 0x1000000000000,
    REButtonStateSelected    = 0x2000000000000,
    REButtonStateHighlighted = 0x4000000000000,
    REButtonStateReserved    = 0xFFF8000000000000,
    REButtonStateMask        = REStateMask
};

typedef NS_OPTIONS (uint64_t, REButtonShape) {
    REButtonShapeCustom           = REShapeUndefined,
    REButtonShapeRoundedRectangle = REShapeRoundedRectangle,
    REButtonShapeOval             = REShapeOval,
    REButtonShapeRectangle        = REShapeRectangle,
    REButtonShapeTriangle         = REShapeTriangle,
    REButtonShapeDiamond          = REShapeDiamond,
    REButtonShapeReserved         = REShapeReserved,
    REButtonShapeMask             = REShapeMask
};

typedef NS_OPTIONS (uint64_t, REButtonStyle) {
    REButtonStyleBare        = REStyleUndefined,
    REButtonStyleApplyGloss  = REStyleApplyGloss,
    REButtonStyleDrawBorder  = REStyleDrawBorder,
    REButtonStyleStretchable = REStyleStretchable,
    REButtonStyleReserved    = REStyleReserved,
    REButtonStyleMask        = REStyleMask
};

typedef NS_ENUM (NSInteger, REButtonStyleDefault) {
    REButtonStyleDefault1 = 0,
    REButtonStyleDefault2 = 1,
    REButtonStyleDefault3 = 2,
    REButtonStyleDefault4 = 3,
    REButtonStyleDefault5 = 4
};

typedef NS_OPTIONS (NSUInteger, CommandOptions) {
    CommandOptionsDefault               = 0 << 0,
    CommandOptionsLongPress             = 1 << 0,
    CommandOptionsNotifyComponentDevice = 1 << 1
};

@class   ButtonConfigurationDelegate, REButtonGroup, ComponentDevice;

/**
 * `Button` is an `NSManagedObject` subclass that models a button for a home theater remote
 * control. Its main function is to represent the visual attributes of the button, which are used
 * by a <ButtonView> in the user interface, and to be a means for executing commands, which are
 * encapsulated in a <Command> object. Different styles and behaviors can be achieved by changing
 * the button's `type` attribute. <ActivityButton> subclasses `Button` to coordinate launching and
 * exiting activities, which are coordinated by a <RemoteController>.
 */
@interface REButton : RemoteElement <CommandDelegate>

@property (nonatomic, strong) ButtonConfigurationDelegate  * configurationDelegate;
@property (nonatomic, strong) ControlStateTitleSet         * titles;
@property (nonatomic, assign) UIEdgeInsets                   titleEdgeInsets;
@property (nonatomic, strong) ControlStateIconImageSet     * icons;
@property (nonatomic, assign) UIEdgeInsets                   imageEdgeInsets;
@property (nonatomic, strong) ControlStateColorSet         * backgroundColors;
@property (nonatomic, strong) ControlStateButtonImageSet   * images;
@property (nonatomic, assign) UIEdgeInsets                   contentEdgeInsets;
@property (nonatomic, strong) Command                      * command;
@property (nonatomic, strong) Command                      * longPressCommand;

@property (nonatomic, assign, getter = isSelected)    BOOL   selected;
@property (nonatomic, assign, getter = isEnabled)     BOOL   enabled;
@property (nonatomic, assign, getter = isHighlighted) BOOL   highlighted;


- (void)executeCommandWithOptions:(CommandOptions)options delegate:(id <CommandDelegate> )delegate;

@end

@interface REButton (ControlStateIconImageSet)

- (UIImage *)iconUIImageForState:(UIControlState)state;
- (void)setIcon:(REIconImage *)icon forState:(UIControlState)state;
- (REIconImage *)iconImageForState:(UIControlState)state;

- (UIColor *)iconColorForState:(UIControlState)state;
- (void)setIconColor:(UIColor *)color forState:(UIControlState)state;

@end

@interface REButton (ControlStateTitleSet)

- (NSAttributedString *)titleForState:(UIControlState)state;
- (void)setTitle:(NSAttributedString *)title forState:(UIControlState)state;

@end

@interface REButton (ControlStateButtonImageSet)

- (UIImage *)buttonUIImageForState:(UIControlState)state;
- (void)setButtonImage:(REButtonImage *)image forState:(UIControlState)state;

@end

@interface REButton (ControlStateColorSet)

- (UIColor *)backgroundColorForState:(UIControlState)state;
- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state;

@end

typedef NS_ENUM (uint64_t, REActivityButtonType) {
    REActivityButtonTypeBegin = REButtonSubtypeActivityOn,
    REActivityButtonTypeEnd   = REButtonSubtypeUnspecified
};

/**
 * ActivityButton is a subclass of Button that can be used to trigger a change in the
 * `currentActivity` of a RemoteController. The `key` should be set to the match the name
 * of the associated activity. ActivityButton maintains a set of `DeviceConfiguration` objects to
 * associate with the **activity**. The remote controller associated with the button uses this
 * set to determine what state devices should be in when switching from one activity to another.
 */
@interface REActivityButton : REButton

@property (nonatomic, strong) NSSet              * deviceConfigurations;
@property (nonatomic, assign) REActivityButtonType   activityButtonType;

@end
