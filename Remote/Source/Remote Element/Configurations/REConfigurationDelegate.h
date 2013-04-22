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

@property (nonatomic, copy)             RERemoteConfiguration     currentConfiguration;
@property (nonatomic, weak, readonly)   NSArray                 * configurationKeys;
@property (nonatomic, strong)           REConfigurationDelegate * delegate;
@property (nonatomic, strong, readonly) NSSet                   * subscribers;
@property (nonatomic, strong, readonly) RemoteElement           * element;

@end

@interface REConfigurationDelegate (AbstractPropertiesAndMethods)

+ (instancetype)delegateForRemoteElement:(RemoteElement *)remoteElement;

@end

@class RERemote;

@interface RERemoteConfigurationDelegate : REConfigurationDelegate

//@property (nonatomic, strong, readonly) RERemote *element;

@end

@class REButtonGroup, RECommandSet;

@interface REButtonGroupConfigurationDelegate : REConfigurationDelegate

- (void)setCommandSet:(RECommandSet *)commandSet forConfiguration:(RERemoteConfiguration)config;
- (void)setLabel:(NSAttributedString *)label forConfiguration:(RERemoteConfiguration)config;

//@property (nonatomic, strong, readonly) REButtonGroup * element;

@end

@class REButton,
       RECommand,
       REControlStateTitleSet,
       REControlStateIconImageSet,
       REControlStateButtonImageSet,
       REControlStateColorSet,
       REControlStateTitleSetProxy,
       REControlStateIconImageSetProxy,
       REControlStateButtonImageSetProxy,
       REControlStateColorSetProxy;

@interface REButtonConfigurationDelegate : REConfigurationDelegate

- (void)setCommand:(RECommand *)command forConfiguration:(RERemoteConfiguration)config;

- (void)setTitles:(REControlStateTitleSet *)titleSet forConfiguration:(RERemoteConfiguration)config;
- (void)setTitle:(id)title forConfiguration:(RERemoteConfiguration)config;

- (void)setBackgroundColors:(REControlStateColorSet *)colors
           forConfiguration:(RERemoteConfiguration)config;

- (void)setIcons:(REControlStateIconImageSet *)icons forConfiguration:(RERemoteConfiguration)config;

- (void)setImages:(REControlStateButtonImageSet *)images
 forConfiguration:(RERemoteConfiguration)config;

//@property (nonatomic, strong, readonly) REButton                          * element;
@property (nonatomic, strong, readonly) REControlStateTitleSetProxy       * titlesProxy;
@property (nonatomic, strong, readonly) REControlStateIconImageSetProxy   * iconsProxy;
@property (nonatomic, strong, readonly) REControlStateButtonImageSetProxy * imagesProxy;
@property (nonatomic, strong, readonly) REControlStateColorSetProxy       * backgroundColorsProxy;

@end

