//
// SettingsManager.m
// Remote
//
// Created by Jason Cardwell on 3/2/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "SettingsManager.h"

MSKIT_STRING_CONST                   kAutoConnectKey                                                = @"kAutoConnectKey";
MSKIT_STRING_CONST                   kProximitySensorKey                                            = @"kProximitySensorKey";
MSKIT_STRING_CONST                   kStatusBarKey                                                  = @"kStatusBarKey";
MSKIT_STRING_CONST                   kInactivityTimeoutKey                                          = @"kInactivityTimeoutKey";
MSKIT_STRING_CONST                   MSSettingsManagerAutoConnectSettingDidChangeNotification       = @"MSSettingsManagerAutoConnectSettingDidChangeNotification";
MSKIT_STRING_CONST                   MSSettingsManagerProximitySensorSettingDidChangeNotification   = @"MSSettingsManagerProximitySensorSettingDidChangeNotification";
MSKIT_STRING_CONST                   MSSettingsManagerStatusBarSettingDidChangeNotification         = @"MSSettingsManagerStatusBarSettingDidChangeNotification";
MSKIT_STRING_CONST                   MSSettingsManagerInactivityTimeoutSettingDidChangeNotification = @"MSSettingsManagerInactivityTimeoutSettingDidChangeNotification";
static NSMutableDictionary const * settingsCache;
static NSSet const               * validSettings;
static NSDictionary const        * notifications;
static int                         ddLogLevel       = DefaultDDLogLevel;
int                                globalDDLogLevel = DefaultDDLogLevel;

@implementation SettingsManager

+ (void)initialize {
    if (self == [SettingsManager class]) {
        settingsCache = [@{
                             kAutoConnectKey : @YES,
                             kStatusBarKey : @YES,
                             kProximitySensorKey : @YES,
                             kInactivityTimeoutKey : @0.0f
                         }
                         mutableCopy];
        validSettings = [NSSet setWithArray:[settingsCache allKeys]];
        notifications = @{
            kAutoConnectKey : MSSettingsManagerAutoConnectSettingDidChangeNotification,
            kStatusBarKey : MSSettingsManagerStatusBarSettingDidChangeNotification,
            kProximitySensorKey : MSSettingsManagerProximitySensorSettingDidChangeNotification,
            kInactivityTimeoutKey : MSSettingsManagerInactivityTimeoutSettingDidChangeNotification
        };
    }
}

+ (id)sharedSettingsManager {
    static dispatch_once_t   pred          = 0;
    __strong static id       _sharedObject = nil;

    dispatch_once(&pred, ^{_sharedObject = [[self alloc] init]; }

                  );

    return _sharedObject;
}

+ (void)registerDefaults {
    [UserDefaults registerDefaults:[settingsCache copy]];
    DDLogVerbose(@"registered defaults:%@", settingsCache);
}

+ (void)applyUserSettings {
    // FIXME: Not sure where this method fits in the overall scheme.
    SharedApp.statusBarHidden = [self boolForSetting:kStatusBarKey];
}

+ (BOOL)validSetting:(NSString *)setting {
    return ([validSettings member:setting] != nil);
}

+ (void)setValue:(id)value forSetting:(NSString *)setting {
    if ([self validSetting:setting]) {
        settingsCache[setting] = (value ? value : NullObject);
        UserDefaults[setting]  = settingsCache[setting];
        [self postNotification:notifications[setting]];
    }
}

+ (id)valueForSetting:(NSString *)setting {
    return settingsCache[setting];
}

+ (BOOL)boolForSetting:(NSString *)setting {
    if ([self validSetting:setting]) {
        id   value = [self valueForSetting:setting];

        if ([value isKindOfClass:[NSNumber class]]) return [value boolValue];
    }

    return NO;
}

+ (void)setBool:(BOOL)value forSetting:(NSString *)setting {
    [self setValue:@(value) forSetting:setting];
}

+ (CGFloat)floatForSetting:(NSString *)setting {
    if ([self validSetting:setting]) {
        id   value = [self valueForSetting:setting];

        if ([value isKindOfClass:[NSNumber class]]) return [value floatValue];
    }

    return NO;
}

+ (void)setFloat:(CGFloat)value forSetting:(NSString *)setting {
    [self setValue:@(value) forSetting:setting];
}

+ (void)postNotification:(NSString *)notificationName {
    [NotificationCenter postNotificationName:notificationName object:[self sharedSettingsManager]];
}

+ (int)ddLogLevel {
    return ddLogLevel;
}

+ (void)ddSetLogLevel:(int)logLevel {
    ddLogLevel       = logLevel;
    globalDDLogLevel = ddLogLevel;
}

@end
