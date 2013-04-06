//
//  REConfigurationDelegate_Private.h
//  Remote
//
//  Created by Jason Cardwell on 3/22/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "REConfigurationDelegate.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark Abstract Configuration Delegate
////////////////////////////////////////////////////////////////////////////////

@interface REConfigurationDelegate ()

@property (nonatomic, strong)            NSDictionary        * configurations;
@property (nonatomic, strong, readwrite) NSSet               * subscribers;
@property (nonatomic, strong, readwrite) RemoteElement       * remoteElement;

- (void)updateConfigForConfiguration:(NSString *)configuration;

@end

@interface REConfigurationDelegate (CoreDataGeneratedAccessors)

@property (nonatomic) REConfigurationDelegate * primitiveDelegate;
@property (nonatomic) NSDictionary            * primitiveConfigurations;
@property (nonatomic) RemoteElement           * primitiveRemoteElement;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark Remote Configuration Delegate
////////////////////////////////////////////////////////////////////////////////

@interface RERemoteConfigurationDelegate ()



@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark ButtonGroup Configuration Delegate
////////////////////////////////////////////////////////////////////////////////

@interface REButtonGroupConfigurationDelegate ()

@property (nonatomic, strong) NSSet * commandSets;

@end

@interface REButtonGroupConfigurationDelegate (CoreDataGeneratedAccessors)

- (void)addCommandSetsObject:(RECommandSet *)commandSet;
- (void)removeCommandSetsObject:(RECommandSet *)commandSet;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark Button Configuration Delegate
////////////////////////////////////////////////////////////////////////////////

@interface REButtonConfigurationDelegate ()

@property (nonatomic, strong) NSSet * commands;
@property (nonatomic, strong) NSSet * titleSets;

@end

@interface REButtonConfigurationDelegate (CoreDataGeneratedAccessors)

- (void)addCommandsObject:(RECommand *)command;
- (void)addTitleSetsObject:(REControlStateTitleSet *)titleSet;
- (void)removeCommandsObject:(RECommand *)command;
- (void)removeTitleSetsObject:(REControlStateTitleSet *)titleSet;

@end

#import "RemoteElement_Private.h"
