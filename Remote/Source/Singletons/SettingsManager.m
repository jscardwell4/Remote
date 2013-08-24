//
// SettingsManager.m
// Remote
//
// Created by Jason Cardwell on 3/2/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "SettingsManager.h"

MSKIT_KEY_DEFINITION(MSSettingsAutoConnect      );
MSKIT_KEY_DEFINITION(MSSettingsAutoListen       );
MSKIT_KEY_DEFINITION(MSSettingsProximitySensor  );
MSKIT_KEY_DEFINITION(MSSettingsStatusBar        );
MSKIT_KEY_DEFINITION(MSSettingsInactivityTimeout);

MSKIT_NOTIFICATION_DEFINITION(MSSettingsManagerAutoConnectSettingDidChange      );
MSKIT_NOTIFICATION_DEFINITION(MSSettingsManagerAutoListenSettingDidChange       );
MSKIT_NOTIFICATION_DEFINITION(MSSettingsManagerProximitySensorSettingDidChange  );
MSKIT_NOTIFICATION_DEFINITION(MSSettingsManagerStatusBarSettingDidChange        );
MSKIT_NOTIFICATION_DEFINITION(MSSettingsManagerInactivityTimeoutSettingDidChange);

static NSMutableDictionary const * settingsCache;
static NSSet const               * validSettings;
static NSDictionary const        * notifications;
static int                         ddLogLevel       = DefaultDDLogLevel;
int                                globalDDLogLevel = DefaultDDLogLevel;

@implementation SettingsManager

+ (void)initialize {
    if (self == [SettingsManager class])
    {
        settingsCache = [@{
             MSSettingsAutoConnectKey       : ([UserDefaults valueForKey:@"autoconnect"] ? : @YES),
             MSSettingsAutoListenKey        : ([UserDefaults valueForKey:@"autolisten" ] ? : @YES),
             MSSettingsStatusBarKey         : @YES,
             MSSettingsProximitySensorKey   : @YES,
             MSSettingsInactivityTimeoutKey : @0.0f
         } mutableCopy];

        validSettings = [NSSet setWithArray:[settingsCache allKeys]];
        notifications = @{
            MSSettingsAutoConnectKey       : MSSettingsManagerAutoConnectSettingDidChangeNotification,
            MSSettingsStatusBarKey         : MSSettingsManagerStatusBarSettingDidChangeNotification,
            MSSettingsProximitySensorKey   : MSSettingsManagerProximitySensorSettingDidChangeNotification,
            MSSettingsInactivityTimeoutKey : MSSettingsManagerInactivityTimeoutSettingDidChangeNotification
        };
    }
}

+ (void)registerDefaults {
    [UserDefaults registerDefaults:[settingsCache copy]];
    DDLogVerbose(@"registered defaults:%@", settingsCache);
}

+ (void)applyUserSettings {
    // FIXME: Not sure where this method fits in the overall scheme.
    UIApp.statusBarHidden = [self boolForSetting:MSSettingsStatusBarKey];
}

+ (BOOL)validSetting:(NSString *)setting {
    return ([validSettings member:setting] != nil);
}

+ (void)setValue:(id)value forSetting:(NSString *)setting {
    if ([self validSetting:setting]) {
        settingsCache[setting] = (value  ? : NullObject);
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

        if ([value isKindOfClass:[NSNumber class]]) return [(NSNumber *)value floatValue];
    }

    return NO;
}

+ (void)setFloat:(CGFloat)value forSetting:(NSString *)setting {
    [self setValue:@(value) forSetting:setting];
}

+ (void)postNotification:(NSString *)notificationName {
    [NotificationCenter postNotificationName:notificationName object:[self class]];
}

+ (int)ddLogLevel {
    return ddLogLevel;
}

+ (void)ddSetLogLevel:(int)logLevel {
    ddLogLevel       = logLevel;
    globalDDLogLevel = ddLogLevel;
}

@end
