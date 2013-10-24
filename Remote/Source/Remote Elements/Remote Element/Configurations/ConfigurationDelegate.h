//
// ConfigurationDelegate.h
// Remote
//
// Created by Jason Cardwell on 7/11/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "ModelObject.h"
#import "RETypedefs.h"

MSEXTERN_STRING REDefaultMode;

@class RemoteElement;

/**
 Monitors changes to the current mode of a `RemoteElement` and responds by updating
 various attributes with values registered with the `REConfigurationDelegate` for the active
 mode. All `RemoteElement` objects can have a mode delegate but their use
 is not mandatory. For example, the element need to use the delegate if its attributes never
 change regardless of the current mode.
 */
@interface ConfigurationDelegate : ModelObject

+ (instancetype)configurationDelegateForElement:(RemoteElement *)element;

- (BOOL)addMode:(RERemoteMode)mode;

- (void)setObject:(id)object forKeyedSubscript:(id)key;
- (id)objectForKeyedSubscript:(id)key;

- (BOOL)hasMode:(RERemoteMode)key;

- (void)refresh;

@property (nonatomic, copy)             RERemoteMode     currentMode;
@property (nonatomic, weak, readonly)   NSArray                 * modeKeys;
@property (nonatomic, strong)           ConfigurationDelegate   * delegate;
@property (nonatomic, strong, readonly) NSSet                   * subscribers;
@property (nonatomic, strong, readonly) RemoteElement           * element;
@property (nonatomic, assign)           BOOL                      autoPopulateFromDefaultMode;

@end

@interface ConfigurationDelegate (AbstractPropertiesAndMethods)

+ (instancetype)delegateForRemoteElement:(RemoteElement *)remoteElement;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - RemoteConfigurationDelegate
////////////////////////////////////////////////////////////////////////////////
@class Remote;

@interface RemoteConfigurationDelegate : ConfigurationDelegate

- (Remote *)remote;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ButtonGroupConfigurationDelegate
////////////////////////////////////////////////////////////////////////////////
@class ButtonGroup, CommandContainer;

@interface ButtonGroupConfigurationDelegate : ConfigurationDelegate

- (void)setCommandContainer:(CommandContainer *)container
              mode:(RERemoteMode)mode;
- (void)setLabel:(NSAttributedString *)label mode:(RERemoteMode)mode;

- (ButtonGroup *)buttonGroup;

@property (nonatomic, weak, readonly) CommandContainer * commandContainer;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - ButtonConfigurationDelegate
////////////////////////////////////////////////////////////////////////////////
@class Button,
       Command,
       ControlStateTitleSet,
       ControlStateImageSet,
       ControlStateColorSet;

@interface ButtonConfigurationDelegate : ConfigurationDelegate

//- (NSAttributedString *)titleForState:(REState)state;

- (void)setCommand:(Command *)command mode:(RERemoteMode)mode;
- (Command *)commandForMode:(RERemoteMode)mode;

- (void)setTitle:(id)title mode:(RERemoteMode)mode;

- (void)setTitles:(ControlStateTitleSet *)titleSet mode:(RERemoteMode)mode;
- (ControlStateTitleSet *)titlesForMode:(RERemoteMode)mode;

- (void)setBackgroundColors:(ControlStateColorSet *)colors
           mode:(RERemoteMode)mode;
- (ControlStateColorSet *)backgroundColorsForMode:(RERemoteMode)mode;

- (void)setIcons:(ControlStateImageSet *)icons mode:(RERemoteMode)mode;
- (ControlStateImageSet *)iconsForMode:(RERemoteMode)mode;

- (void)setImages:(ControlStateImageSet *)images  mode:(RERemoteMode)mode;
- (ControlStateImageSet *)imagesForMode:(RERemoteMode)mode;

- (Button *)button;

@property (nonatomic, assign, readonly) ControlStateTitleSet   * titles;
@property (nonatomic, assign, readonly) ControlStateColorSet   * backgroundColors;
@property (nonatomic, assign, readonly) ControlStateImageSet   * icons;
@property (nonatomic, assign, readonly) ControlStateImageSet   * images;


@end

