//
// RemoteElement.h
// Remote
//
// Created by Jason Cardwell on 10/3/12.
// Copyright © 2012 Moondeer Studios. All rights reserved.
//

#import "RemoteElement.h"

@class ButtonGroup, ControlStateTitleSet, ControlStateImageSet, ControlStateColorSet, Command, Image;

/**
 * `Button` is an `NSManagedObject` subclass that models a button for a home theater remote
 * control. Its main function is to represent the visual attributes of the button, which are used
 * by a <ButtonView> in the user interface, and to be a means for executing commands, which are
 * encapsulated in a <Command> object. Different styles and behaviors can be achieved by changing
 * the button's `type` attribute. <ActivityButton> subclasses `Button` to coordinate launching and
 * exiting activities, which are coordinated by a <RemoteController>.
 */
@interface Button : RemoteElement

@property (nonatomic, strong, readonly ) ButtonGroup                 * parentElement;
@property (nonatomic, weak,   readonly ) Remote                      * remote;
@property (nonatomic, weak,   readonly ) ButtonConfigurationDelegate * buttonConfigurationDelegate;

@property (nonatomic, copy,   readwrite) id                              title;
@property (nonatomic, strong, readwrite) UIImage                       * icon;
@property (nonatomic, strong, readwrite) UIImage                       * image;

@property (nonatomic, strong, readwrite) Command                     * command;
@property (nonatomic, strong, readwrite) Command                     * longPressCommand;

@property (nonatomic, assign, readwrite) UIEdgeInsets                    titleEdgeInsets;
@property (nonatomic, assign, readwrite) UIEdgeInsets                    imageEdgeInsets;
@property (nonatomic, assign, readwrite) UIEdgeInsets                    contentEdgeInsets;

@property (nonatomic, assign, readwrite, getter = isSelected)    BOOL   selected;
@property (nonatomic, assign, readwrite, getter = isEnabled)     BOOL   enabled;
@property (nonatomic, assign, readwrite, getter = isHighlighted) BOOL   highlighted;

+ (instancetype)buttonWithRole:(RERole)role;
+ (instancetype)buttonWithRole:(RERole)role context:(NSManagedObjectContext *)moc;
+ (instancetype)buttonWithTitle:(id)title;
+ (instancetype)buttonWithTitle:(id)title context:(NSManagedObjectContext *)moc;
+ (instancetype)buttonWithRole:(RERole)role title:(id)title;
+ (instancetype)buttonWithRole:(RERole)role title:(id)title context:(NSManagedObjectContext *)moc;


- (void)executeCommandWithOptions:(CommandOptions)options
                       completion:(CommandCompletionHandler)completion;

@end

@interface Button (REButtonConfigurationDelegate)

@property (nonatomic, strong, readonly ) NSSet                         * commands;
@property (nonatomic, strong, readonly ) ControlStateTitleSet        * titles;
@property (nonatomic, strong, readonly ) ControlStateImageSet        * icons;
@property (nonatomic, strong, readonly ) ControlStateColorSet        * backgroundColors;
@property (nonatomic, strong, readonly ) ControlStateImageSet        * images;

- (void)setCommand:(Command *)command mode:(RERemoteMode)mode;

- (void)setTitle:(id)title mode:(RERemoteMode)mode;
- (void)setTitles:(ControlStateTitleSet *)titleSet mode:(RERemoteMode)mode;

- (void)setBackgroundColors:(ControlStateColorSet *)colors
              mode:(RERemoteMode)mode;

- (void)setIcons:(ControlStateImageSet *)icons mode:(RERemoteMode)mode;

- (void)setImages:(ControlStateImageSet *)images mode:(RERemoteMode)mode;

@end
