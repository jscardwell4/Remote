//
// SettingsManager.m
// Remote
//
// Created by Jason Cardwell on 3/2/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "SettingsManager.h"
#import "StoryboardProxy.h"
#import "ConnectionManager.h"

MSKEY_DEFINITION(MSSettingsAutoConnect);
MSKEY_DEFINITION(MSSettingsAutoListen);
MSKEY_DEFINITION(MSSettingsProximitySensor);
MSKEY_DEFINITION(MSSettingsStatusBar);
MSKEY_DEFINITION(MSSettingsInactivityTimeout);

MSNOTIFICATION_DEFINITION(MSSettingsManagerAutoConnectSettingDidChange);
MSNOTIFICATION_DEFINITION(MSSettingsManagerAutoListenSettingDidChange);
MSNOTIFICATION_DEFINITION(MSSettingsManagerProximitySensorSettingDidChange);
MSNOTIFICATION_DEFINITION(MSSettingsManagerStatusBarSettingDidChange);
MSNOTIFICATION_DEFINITION(MSSettingsManagerInactivityTimeoutSettingDidChange);

static NSMutableDictionary const * settingsCache;
static NSSet const               * validSettings;
static NSDictionary const        * notifications;
static int                         ddLogLevel = DefaultDDLogLevel;
int globalDDLogLevel = DefaultDDLogLevel;

@implementation SettingsManager

+ (void)initialize {
  if (self == [SettingsManager class]) {
    settingsCache = [@{
                       MSSettingsAutoConnectKey       : ([UserDefaults valueForKey:@"autoconnect"] ?: @YES),
                       MSSettingsAutoListenKey        : ([UserDefaults valueForKey:@"autolisten"] ?: @YES),
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

+ (UIViewController *)viewController {
  return (UIViewController *)[StoryboardProxy settingsViewController];
}

+ (void)applyUserSettings {
  UIApp.statusBarHidden = [self boolForSetting:MSSettingsStatusBarKey];
  if ([self boolForSetting:MSSettingsAutoListenKey])
    [ConnectionManager detectNetworkDevices:nil];
}

+ (BOOL)validSetting:(NSString *)setting {
  return ([validSettings member:setting] != nil);
}

+ (void)setValue:(id)value forSetting:(NSString *)setting {

  if ([self validSetting:setting]) {

    settingsCache[setting] = (value  ?: NullObject);
    UserDefaults[setting]  = settingsCache[setting];
    [NotificationCenter postNotificationName:notifications[setting] object:self];

  }

}

+ (id)valueForSetting:(NSString *)setting {
  return settingsCache[setting];
}

+ (BOOL)boolForSetting:(NSString *)setting {

  if ([self validSetting:setting]) {

    id value = [self valueForSetting:setting];
    if ([value isKindOfClass:[NSNumber class]]) return [value boolValue];

  }

  return NO;
}

+ (void)setBool:(BOOL)value forSetting:(NSString *)setting {
  [self setValue:@(value) forSetting:setting];
}

+ (CGFloat)floatForSetting:(NSString *)setting {

  if ([self validSetting:setting]) {

    id value = [self valueForSetting:setting];
    if ([value isKindOfClass:[NSNumber class]]) return [(NSNumber *)value floatValue];

  }

  return 0.0;
}

+ (void)setFloat:(CGFloat)value forSetting:(NSString *)setting {
  [self setValue:@(value) forSetting:setting];
}

@end
