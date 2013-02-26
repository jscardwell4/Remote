//
// SettingsManager.h
// iPhonto
//
// Created by Jason Cardwell on 3/2/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

MSKIT_EXTERN_STRING   kAutoConnectKey;
MSKIT_EXTERN_STRING   kProximitySensorKey;
MSKIT_EXTERN_STRING   kStatusBarKey;
MSKIT_EXTERN_STRING   kInactivityTimeoutKey;
MSKIT_EXTERN_STRING   MSSettingsManagerAutoConnectSettingDidChangeNotification;
MSKIT_EXTERN_STRING   MSSettingsManagerProximitySensorSettingDidChangeNotification;
MSKIT_EXTERN_STRING   MSSettingsManagerStatusBarSettingDidChangeNotification;
MSKIT_EXTERN_STRING   MSSettingsManagerInactivityTimeoutSettingDidChangeNotification;
extern int            globalDDLogLevel;

@interface SettingsManager : NSObject

+ (void)             registerDefaults;
+ (SettingsManager *)sharedSettingsManager;
+ (id)               valueForSetting:(NSString *)setting;
+ (void)setValue:(id)value forSetting:(NSString *)setting;
+ (BOOL)boolForSetting:(NSString *)setting;
+ (void)setBool:(BOOL)value forSetting:(NSString *)setting;
+ (CGFloat)floatForSetting:(NSString *)setting;
+ (void)setFloat:(CGFloat)value forSetting:(NSString *)setting;
+ (void)             applyUserSettings;

@end
