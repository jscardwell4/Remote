//
// ConfigurationDelegate.m
// Remote
//
// Created by Jason Cardwell on 7/11/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "ConfigurationDelegate.h"
#import "RERemoteView.h"

static int         ddLogLevel                                 = DefaultDDLogLevel;
MSKIT_STRING_CONST   kCurrentConfigurationDidChangeNotification = @"kCurrentConfigurationDidChangeNotification";
MSKIT_STRING_CONST   kDefaultConfiguration                      = @"kDefaultConfiguration";
MSKIT_STRING_CONST   kConfigurationKey                          = @"kConfigurationKey";

@interface ConfigurationDelegate ()

- (void)configurationDidChangeNotification:(NSNotification *)note;

@end

@implementation ConfigurationDelegate
@dynamic configurationKeys;

- (void)registerForConfigurationChangeNotifications {
    DDLogDebug(@"%@\n\tregsitering for notification of configuration changes", ClassTagSelectorString);
    [NotificationCenter addObserver:self
                           selector:@selector(configurationDidChangeNotification:)
                               name:kCurrentConfigurationDidChangeNotification
                             object:nil];
}

- (void)configurationDidChangeNotification:(NSNotification *)note {
    DDLogDebug(@"%@\n\treceived notification of configuration change to configuration:'%@'",
               ClassTagSelectorString, [[note userInfo] objectForKey:kConfigurationKey]);
}

- (void)addNewConfiguration:(NSString *)configuration {
    if (ValueIsNil(configuration)) return;

    NSArray * configurationsArray = self.configurationKeys;

    if (ValueIsNil(configurationsArray)) self.configurationKeys = @[configuration];
    else self.configurationKeys = [configurationsArray arrayByAddingObject:configuration];
}

- (BOOL)containsConfigurationForKey:(NSString *)key {
    if (ValueIsNil(key)) return NO;

    NSArray * configurationsArray = self.configurationKeys;

    if (ValueIsNil(configurationsArray)) return NO;
    else return [configurationsArray containsObject:key];
}

- (void)awakeFromInsert {
    [super awakeFromInsert];
    [self registerForConfigurationChangeNotifications];
}

- (void)awakeFromFetch {
    [super awakeFromFetch];
    [self registerForConfigurationChangeNotifications];
}

- (void)dealloc {
    [NotificationCenter removeObserver:self];
}

@end
