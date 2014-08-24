//
// ConfigurationDelegate.h
// Remote
//
// Created by Jason Cardwell on 7/11/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "ModelObject.h"
#import "RETypedefs.h"


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

