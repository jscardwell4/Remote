//
// ConfigurationDelegate.h
// iPhonto
//
// Created by Jason Cardwell on 7/11/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

MSKIT_EXTERN_STRING   kCurrentConfigurationDidChangeNotification;
MSKIT_EXTERN_STRING   kDefaultConfiguration;
MSKIT_EXTERN_STRING   kConfigurationKey;
@class                Button, Command, ButtonGroup, CommandSet, ControlStateTitleSet;

@interface ConfigurationDelegate : NSManagedObject

- (void)addNewConfiguration:(NSString *)configuration;
- (BOOL)containsConfigurationForKey:(NSString *)key;
- (void)registerForConfigurationChangeNotifications;

@property (nonatomic, strong) NSArray * configurationKeys;

@end

@interface ButtonConfigurationDelegate : ConfigurationDelegate

+ (ButtonConfigurationDelegate *)buttonConfigurationDelegateForButton:(Button *)button;
- (void)registerCommand:(Command *)buttonCommand forConfiguration:(NSString *)configuration;
- (void)registerLabel:(id)buttonLabel forConfiguration:(NSString *)configuration;
- (void)registerTitleSet:(ControlStateTitleSet *)titleSet forConfiguration:(NSString *)configuration;
@property (nonatomic, strong) Button * button;

@end

@interface ButtonGroupConfigurationDelegate : ConfigurationDelegate

+ (ButtonGroupConfigurationDelegate *)buttonGroupConfigurationDelegateForButtonGroup:(ButtonGroup *)buttonGroup;
- (void)loadConfiguration:(NSString *)configuration;
- (void)registerCommandSet:(CommandSet *)set forConfiguration:(NSString *)configuration;
- (void)registerLabel:(NSString *)label forConfiguration:(NSString *)configuration;

@property (nonatomic, strong) ButtonGroup * buttonGroup;

@end
