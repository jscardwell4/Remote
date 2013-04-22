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
- (void)updateConfigForConfiguration:(NSString *)configuration;

@end

@interface REConfigurationDelegate (PrivateAbstractProperties)

//- (void)setElement:(RemoteElement *)element;

@end

@interface REConfigurationDelegate (CoreDataGeneratedAccessors)

@property (nonatomic) REConfigurationDelegate * primitiveDelegate;
@property (nonatomic) NSDictionary            * primitiveConfigurations;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark Remote Configuration Delegate
////////////////////////////////////////////////////////////////////////////////

@interface RERemoteConfigurationDelegate ()

//@property (nonatomic, strong, readwrite) RERemote * element;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark ButtonGroup Configuration Delegate
////////////////////////////////////////////////////////////////////////////////

@interface REButtonGroupConfigurationDelegate ()

@property (nonatomic, strong, readwrite) NSSet         * commandSets;
//@property (nonatomic, strong, readwrite) REButtonGroup * element;

@end

@interface REButtonGroupConfigurationDelegate (CoreDataGeneratedAccessors)

- (void)addCommandSetsObject:(RECommandSet *)commandSet;
- (void)removeCommandSetsObject:(RECommandSet *)commandSet;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark Button Configuration Delegate
////////////////////////////////////////////////////////////////////////////////

@interface REButtonConfigurationDelegate () <REControlStateSetProxyDelegate>
{
    REControlStateTitleSetProxy       * __titlesProxy;
    REControlStateIconImageSetProxy   * __iconsProxy;
    REControlStateButtonImageSetProxy * __imagesProxy;
    REControlStateColorSetProxy       * __backgroundColorsProxy;

}

@property (nonatomic, strong, readwrite) NSSet    * commands;
@property (nonatomic, strong, readwrite) NSSet    * titles;
@property (nonatomic, strong, readwrite) NSSet    * backgroundColors;
@property (nonatomic, strong, readwrite) NSSet    * icons;
@property (nonatomic, strong, readwrite) NSSet    * images;
//@property (nonatomic, strong, readwrite) REButton * element;

@end

@interface REButtonConfigurationDelegate (CoreDataGeneratedAccessors)

- (void)addCommandsObject:(RECommand *)command;
- (void)addTitlesObject:(REControlStateTitleSet *)titleSet;
- (void)addIconsObject:(REControlStateIconImageSet *)iconSet;
- (void)addImagesObject:(REControlStateButtonImageSet *)imageSet;
- (void)addBackgroundColorsObject:(REControlStateColorSet *)colorSet;

- (void)removeCommandsObject:(RECommand *)command;
- (void)removeTitlesObject:(REControlStateTitleSet *)titleSet;
- (void)removeIconsObject:(REControlStateIconImageSet *)iconSet;
- (void)removeImagesObject:(REControlStateButtonImageSet *)imageSet;
- (void)removeBackgroundColorsObject:(REControlStateColorSet *)colorSet;

@end

#import "RemoteElement_Private.h"
