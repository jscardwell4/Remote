//
//  REConfigurationDelegate_Private.h
//  Remote
//
//  Created by Jason Cardwell on 3/22/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "ConfigurationDelegate.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark Abstract Configuration Delegate
////////////////////////////////////////////////////////////////////////////////

@interface ConfigurationDelegate ()

@property (nonatomic, strong)            NSDictionary        * configurations;
@property (nonatomic, strong, readwrite) NSSet               * subscribers;
@property (nonatomic, strong, readwrite) RemoteElement       * element;

- (void)updateForMode:(NSString *)mode;

@end

@interface ConfigurationDelegate (CoreDataGeneratedAccessors)

@property (nonatomic) ConfigurationDelegate * primitiveDelegate;
@property (nonatomic) NSDictionary            * primitiveConfigurations;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark ButtonGroup Configuration Delegate
////////////////////////////////////////////////////////////////////////////////

@interface ButtonGroupConfigurationDelegate ()

@property (nonatomic, strong, readwrite) NSSet * commandContainers;

@end

@interface ButtonGroupConfigurationDelegate (CoreDataGeneratedAccessors)

- (void)addCommandContainersObject:(CommandContainer *)container;
- (void)removeCommandContainersObject:(CommandContainer *)container;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark Button Configuration Delegate
////////////////////////////////////////////////////////////////////////////////

@interface ButtonConfigurationDelegate ()

@property (nonatomic, strong, readwrite) NSSet    * commands;
@property (nonatomic, strong, readwrite) NSSet    * titleSets;
@property (nonatomic, strong, readwrite) NSSet    * backgroundColorSets;
@property (nonatomic, strong, readwrite) NSSet    * iconSets;
@property (nonatomic, strong, readwrite) NSSet    * imageSets;

@property (nonatomic, assign, readwrite) Command              * command;
@property (nonatomic, assign, readwrite) ControlStateTitleSet * titles;
@property (nonatomic, assign, readwrite) ControlStateColorSet * backgroundColors;
@property (nonatomic, assign, readwrite) ControlStateImageSet * icons;
@property (nonatomic, assign, readwrite) ControlStateImageSet * images;

@property (nonatomic, strong, readwrite) MSKVOReceptionist * kvoReceptionist;

- (void)kvoRegistration;
- (void)updateButtonForState:(REState)state;

@end

@interface ButtonConfigurationDelegate (CoreDataGeneratedAccessors)

- (void)addCommandsObject:(Command *)command;
- (void)addTitleSetsObject:(ControlStateTitleSet *)titleSet;
- (void)addIconSetsObject:(ControlStateImageSet *)iconSet;
- (void)addImageSetsObject:(ControlStateImageSet *)imageSet;
- (void)addBackgroundColorSetsObject:(ControlStateColorSet *)colorSet;

- (void)removeCommandsObject:(Command *)command;
- (void)removeTitleSetsObject:(ControlStateTitleSet *)titleSet;
- (void)removeIconSetsObject:(ControlStateImageSet *)iconSet;
- (void)removeImageSetsObject:(ControlStateImageSet *)imageSet;
- (void)removeBackgroundColorSetsObject:(ControlStateColorSet *)colorSet;

@end

#import "RemoteElement_Private.h"
