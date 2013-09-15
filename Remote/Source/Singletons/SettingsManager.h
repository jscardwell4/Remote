//
// SettingsManager.h
// Remote
//
// Created by Jason Cardwell on 3/2/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

MSKIT_EXTERN_KEY(MSSettingsAutoListen       );
MSKIT_EXTERN_KEY(MSSettingsAutoConnect      );
MSKIT_EXTERN_KEY(MSSettingsProximitySensor  );
MSKIT_EXTERN_KEY(MSSettingsStatusBar        );
MSKIT_EXTERN_KEY(MSSettingsInactivityTimeout);

MSKIT_EXTERN_NOTIFICATION(MSSettingsManagerAutoConnectSettingDidChange      );
MSKIT_EXTERN_NOTIFICATION(MSSettingsManagerAutoListenSettingDidChange       );
MSKIT_EXTERN_NOTIFICATION(MSSettingsManagerProximitySensorSettingDidChange  );
MSKIT_EXTERN_NOTIFICATION(MSSettingsManagerStatusBarSettingDidChange        );
MSKIT_EXTERN_NOTIFICATION(MSSettingsManagerInactivityTimeoutSettingDidChange);

extern int globalDDLogLevel;

@interface SettingsManager : MSSingletonController

+ (void)registerDefaults;

+ (id)valueForSetting:(NSString *)setting;
+ (void)setValue:(id)value forSetting:(NSString *)setting;

+ (BOOL)boolForSetting:(NSString *)setting;
+ (void)setBool:(BOOL)value forSetting:(NSString *)setting;

+ (CGFloat)floatForSetting:(NSString *)setting;
+ (void)setFloat:(CGFloat)value forSetting:(NSString *)setting;

+ (void)applyUserSettings;

@end
