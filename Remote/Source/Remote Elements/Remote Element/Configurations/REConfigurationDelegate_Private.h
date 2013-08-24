//
//  REConfigurationDelegate_Private.h
//  Remote
//
//  Created by Jason Cardwell on 3/22/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "REConfigurationDelegate.h"
#import "REControlStateSetProxy.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark Abstract Configuration Delegate
////////////////////////////////////////////////////////////////////////////////

@interface REConfigurationDelegate ()

@property (nonatomic, strong)            NSDictionary        * configurations;
@property (nonatomic, strong, readwrite) NSSet               * subscribers;
@property (nonatomic, strong, readwrite) RemoteElement       * element;

- (void)updateForConfiguration:(NSString *)configuration;

@end

@interface REConfigurationDelegate (CoreDataGeneratedAccessors)

@property (nonatomic) REConfigurationDelegate * primitiveDelegate;
@property (nonatomic) NSDictionary            * primitiveConfigurations;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark ButtonGroup Configuration Delegate
////////////////////////////////////////////////////////////////////////////////

@interface REButtonGroupConfigurationDelegate ()

@property (nonatomic, strong, readwrite) NSSet * commandContainers;

@end

@interface REButtonGroupConfigurationDelegate (CoreDataGeneratedAccessors)

- (void)addCommandContainersObject:(RECommandContainer *)container;
- (void)removeCommandContainersObject:(RECommandContainer *)container;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark Button Configuration Delegate
////////////////////////////////////////////////////////////////////////////////

@interface REButtonConfigurationDelegate ()

@property (nonatomic, strong, readwrite) NSSet    * commands;
@property (nonatomic, strong, readwrite) NSSet    * titleSets;
@property (nonatomic, strong, readwrite) NSSet    * backgroundColorSets;
@property (nonatomic, strong, readwrite) NSSet    * iconSets;
@property (nonatomic, strong, readwrite) NSSet    * imageSets;

@property (nonatomic, assign, readwrite) RECommand              * command;
@property (nonatomic, assign, readwrite) REControlStateTitleSet * titles;
@property (nonatomic, assign, readwrite) REControlStateColorSet * backgroundColors;
@property (nonatomic, assign, readwrite) REControlStateImageSet * icons;
@property (nonatomic, assign, readwrite) REControlStateImageSet * images;

@property (nonatomic, strong, readwrite) MSKVOReceptionist * kvoReceptionist;

- (void)kvoRegistration;
- (void)updateButtonForState:(REState)state;

@end

@interface REButtonConfigurationDelegate (CoreDataGeneratedAccessors)

- (void)addCommandsObject:(RECommand *)command;
- (void)addTitleSetsObject:(REControlStateTitleSet *)titleSet;
- (void)addIconSetsObject:(REControlStateImageSet *)iconSet;
- (void)addImageSetsObject:(REControlStateImageSet *)imageSet;
- (void)addBackgroundColorSetsObject:(REControlStateColorSet *)colorSet;

- (void)removeCommandsObject:(RECommand *)command;
- (void)removeTitleSetsObject:(REControlStateTitleSet *)titleSet;
- (void)removeIconSetsObject:(REControlStateImageSet *)iconSet;
- (void)removeImageSetsObject:(REControlStateImageSet *)imageSet;
- (void)removeBackgroundColorSetsObject:(REControlStateColorSet *)colorSet;

@end

#import "RemoteElement_Private.h"
