//
// ConfigurationDelegate.h
// Remote
//
// Created by Jason Cardwell on 7/11/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
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
@interface REConfigurationDelegate : NSManagedObject

+ (instancetype)delegateForRemoteElement:(RemoteElement *)remoteElement;

- (BOOL)addConfiguration:(RERemoteConfiguration)configuration;

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key;
- (id)objectForKeyedSubscript:(NSString *)key;

- (BOOL)hasConfiguration:(RERemoteConfiguration)key;

@property (nonatomic, strong, readonly) RemoteElement           * remoteElement;
@property (nonatomic, copy)             RERemoteConfiguration     currentConfiguration;
@property (nonatomic, weak, readonly)   NSArray                 * configurationKeys;
@property (nonatomic, strong)           REConfigurationDelegate * delegate;
@property (nonatomic, strong, readonly) NSSet                   * subscribers;

@end

@class RERemote;

@interface RERemoteConfigurationDelegate : REConfigurationDelegate

@property (nonatomic, strong, readonly) RERemote *remote;

@end

@class REButtonGroup, RECommandSet;

@interface REButtonGroupConfigurationDelegate : REConfigurationDelegate

- (void)setCommandSet:(RECommandSet *)commandSet forConfiguration:(RERemoteConfiguration)configuration;
- (void)setLabel:(NSAttributedString *)label forConfiguration:(RERemoteConfiguration)configuration;

@property (nonatomic, strong, readonly) REButtonGroup * buttonGroup;

@end

@class REButton, RECommand, REControlStateTitleSet;

@interface REButtonConfigurationDelegate : REConfigurationDelegate

- (void)setCommand:(RECommand *)command forConfiguration:(RERemoteConfiguration)configuration;
- (void)setTitleSet:(REControlStateTitleSet *)titleSet
   forConfiguration:(RERemoteConfiguration)configuration;

@property (nonatomic, strong, readonly) REButton * button;

@end

