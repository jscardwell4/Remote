//
// ConfigurationDelegate.h
// Remote
//
// Created by Jason Cardwell on 7/11/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "MSModelObject.h"
#import "RETypedefs.h"
MSKIT_EXTERN_STRING REDefaultConfiguration;

@class RemoteElement;

/**
 Monitors changes to the current configuration of a `RemoteElement` and responds by updating
 various attributes with values registered with the `REConfigurationDelegate` for the active
 configuration. All `RemoteElement` objects can have a configuration delegate but their use
 is not mandatory. For example, the element need to use the delegate if its attributes never
 change regardless of the current configuration.
 */
@interface REConfigurationDelegate : MSModelObject

+ (instancetype)configurationDelegate;

- (BOOL)addConfiguration:(RERemoteConfiguration)configuration;

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key;
- (id)objectForKeyedSubscript:(NSString *)key;

- (BOOL)hasConfiguration:(RERemoteConfiguration)key;

- (void)refresh;

@property (nonatomic, copy)             RERemoteConfiguration     currentConfiguration;
@property (nonatomic, weak, readonly)   NSArray                 * configurationKeys;
@property (nonatomic, strong)           REConfigurationDelegate * delegate;
@property (nonatomic, strong, readonly) NSSet                   * subscribers;
@property (nonatomic, strong, readonly) RemoteElement           * element;
@property (nonatomic, assign)           BOOL                      autoPopulateFromDefaultConfiguration;

@end

@interface REConfigurationDelegate (AbstractPropertiesAndMethods)

+ (instancetype)delegateForRemoteElement:(RemoteElement *)remoteElement;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - RERemoteConfigurationDelegate
////////////////////////////////////////////////////////////////////////////////
@class RERemote;

@interface RERemoteConfigurationDelegate : REConfigurationDelegate

- (RERemote *)remote;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - REButtonGroupConfigurationDelegate
////////////////////////////////////////////////////////////////////////////////
@class REButtonGroup, RECommandContainer;

@interface REButtonGroupConfigurationDelegate : REConfigurationDelegate

- (void)setCommandContainer:(RECommandContainer *)container
              configuration:(RERemoteConfiguration)config;
- (void)setLabel:(NSAttributedString *)label configuration:(RERemoteConfiguration)config;

- (REButtonGroup *)buttonGroup;

@property (nonatomic, weak, readonly) RECommandContainer * commandContainer;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - REButtonConfigurationDelegate
////////////////////////////////////////////////////////////////////////////////
@class REButton,
       RECommand,
       REControlStateTitleSet,
       REControlStateImageSet,
       REControlStateColorSet;

@interface REButtonConfigurationDelegate : REConfigurationDelegate

- (NSAttributedString *)titleForState:(REState)state;

- (void)setCommand:(RECommand *)command
  configuration:(RERemoteConfiguration)config;

- (void)setTitle:(id)title configuration:(RERemoteConfiguration)config;

- (void)setTitles:(REControlStateTitleSet *)titleSet configuration:(RERemoteConfiguration)config;

- (void)setBackgroundColors:(REControlStateColorSet *)colors
           configuration:(RERemoteConfiguration)config;

- (void)setIcons:(REControlStateImageSet *)icons
configuration:(RERemoteConfiguration)config;

- (void)setImages:(REControlStateImageSet *)images
 configuration:(RERemoteConfiguration)config;

- (REButton *)button;

@property (nonatomic, assign, readonly) REControlStateTitleSet   * titles;
@property (nonatomic, assign, readonly) REControlStateColorSet   * backgroundColors;
@property (nonatomic, assign, readonly) REControlStateImageSet   * icons;
@property (nonatomic, assign, readonly) REControlStateImageSet   * images;


@end

