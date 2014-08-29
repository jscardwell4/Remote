//
// RemoteElement.h
// Remote
//
// Created by Jason Cardwell on 10/3/12.
// Copyright © 2012 Moondeer Studios. All rights reserved.
//

#import "RemoteElement.h"

@class ControlStateTitleSet, ControlStateImageSet, ControlStateColorSet;
@class Command, ImageView, TitleAttributes;

/**
 * `Button` is an `NSManagedObject` subclass that models a button for a home theater remote
 * control. Its main function is to represent the visual attributes of the button, which are used
 * by a <ButtonView> in the user interface, and to be a means for executing commands, which are
 * encapsulated in a <Command> object. Different styles and behaviors can be achieved by changing
 * the button's `type` attribute. <ActivityButton> subclasses `Button` to coordinate launching and
 * exiting activities, which are coordinated by a <RemoteController>.
 */
@interface Button : RemoteElement

@property (nonatomic, assign, readwrite) REState state;

@property (nonatomic, strong, readonly) NSAttributedString * title;
@property (nonatomic, strong, readonly) ImageView          * icon;
@property (nonatomic, strong, readonly) ImageView          * image;

@property (nonatomic, strong, readwrite) Command * command;
@property (nonatomic, strong, readwrite) Command * longPressCommand;

@property (nonatomic, assign, readwrite) UIEdgeInsets titleEdgeInsets;
@property (nonatomic, assign, readwrite) UIEdgeInsets imageEdgeInsets;
@property (nonatomic, assign, readwrite) UIEdgeInsets contentEdgeInsets;

@property (nonatomic, assign, readwrite, getter = isSelected)    BOOL   selected;
@property (nonatomic, assign, readwrite, getter = isEnabled)     BOOL   enabled;
@property (nonatomic, assign, readwrite, getter = isHighlighted) BOOL   highlighted;

@property (nonatomic, strong, readonly) ControlStateTitleSet * titles;
@property (nonatomic, strong, readonly) ControlStateImageSet * icons;
@property (nonatomic, strong, readonly) ControlStateColorSet * backgroundColors;
@property (nonatomic, strong, readonly) ControlStateImageSet * images;


- (void)executeCommandWithOptions:(CommandOptions)options
                       completion:(CommandCompletionHandler)completion;

- (void)setCommand:(Command *)command mode:(NSString *)mode;
- (void)setLongPressCommand:(Command *)longPressCommand mode:(NSString *)mode;
- (void)setTitles:(ControlStateTitleSet *)titleSet mode:(NSString *)mode;
- (void)setBackgroundColors:(ControlStateColorSet *)colors mode:(NSString *)mode;
- (void)setIcons:(ControlStateImageSet *)icons mode:(NSString *)mode;
- (void)setImages:(ControlStateImageSet *)images mode:(NSString *)mode;

- (Command *)commandForMode:(NSString *)mode;
- (Command *)longPressCommandForMode:(NSString *)mode;
- (ControlStateTitleSet *)titlesForMode:(NSString *)mode;
- (ControlStateColorSet *)backgroundColorsForMode:(NSString *)mode;
- (ControlStateImageSet *)iconsForMode:(NSString *)mode;
- (ControlStateImageSet *)imagesForMode:(NSString *)mode;

@end
