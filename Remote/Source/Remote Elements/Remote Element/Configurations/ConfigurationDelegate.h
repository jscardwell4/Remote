//
// ConfigurationDelegate.h
// Remote
//
// Created by Jason Cardwell on 7/11/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "ModelObject.h"
#import "RETypedefs.h"
MSEXTERN_STRING REDefaultConfiguration;

@class RemoteElement;

/**
 Monitors changes to the current configuration of a `RemoteElement` and responds by updating
 various attributes with values registered with the `REConfigurationDelegate` for the active
 configuration. All `RemoteElement` objects can have a configuration delegate but their use
 is not mandatory. For example, the element need to use the delegate if its attributes never
 change regardless of the current configuration.
 */
@interface ConfigurationDelegate : ModelObject

+ (instancetype)configurationDelegate;

- (BOOL)addConfiguration:(RERemoteConfiguration)configuration;

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key;
- (id)objectForKeyedSubscript:(NSString *)key;

- (BOOL)hasConfiguration:(RERemoteConfiguration)key;

- (void)refresh;

@property (nonatomic, copy)             RERemoteConfiguration     currentConfiguration;
@property (nonatomic, weak, readonly)   NSArray                 * configurationKeys;
@property (nonatomic, strong)           ConfigurationDelegate * delegate;
@property (nonatomic, strong, readonly) NSSet                   * subscribers;
@property (nonatomic, strong, readonly) RemoteElement           * element;
@property (nonatomic, assign)           BOOL                      autoPopulateFromDefaultConfiguration;

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
              configuration:(RERemoteConfiguration)config;
- (void)setLabel:(NSAttributedString *)label configuration:(RERemoteConfiguration)config;

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

- (NSAttributedString *)titleForState:(REState)state;

- (void)setCommand:(Command *)command
  configuration:(RERemoteConfiguration)config;

- (void)setTitle:(id)title configuration:(RERemoteConfiguration)config;

- (void)setTitles:(ControlStateTitleSet *)titleSet configuration:(RERemoteConfiguration)config;

- (void)setBackgroundColors:(ControlStateColorSet *)colors
           configuration:(RERemoteConfiguration)config;

- (void)setIcons:(ControlStateImageSet *)icons
configuration:(RERemoteConfiguration)config;

- (void)setImages:(ControlStateImageSet *)images
 configuration:(RERemoteConfiguration)config;

- (Button *)button;

@property (nonatomic, assign, readonly) ControlStateTitleSet   * titles;
@property (nonatomic, assign, readonly) ControlStateColorSet   * backgroundColors;
@property (nonatomic, assign, readonly) ControlStateImageSet   * icons;
@property (nonatomic, assign, readonly) ControlStateImageSet   * images;


@end

