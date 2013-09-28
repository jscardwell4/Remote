//
// SettingsManager.h
// Remote
//
// Created by Jason Cardwell on 3/2/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

MSEXTERN_KEY(MSSettingsAutoListen       );
MSEXTERN_KEY(MSSettingsAutoConnect      );
MSEXTERN_KEY(MSSettingsProximitySensor  );
MSEXTERN_KEY(MSSettingsStatusBar        );
MSEXTERN_KEY(MSSettingsInactivityTimeout);

MSEXTERN_NOTIFICATION(MSSettingsManagerAutoConnectSettingDidChange      );
MSEXTERN_NOTIFICATION(MSSettingsManagerAutoListenSettingDidChange       );
MSEXTERN_NOTIFICATION(MSSettingsManagerProximitySensorSettingDidChange  );
MSEXTERN_NOTIFICATION(MSSettingsManagerStatusBarSettingDidChange        );
MSEXTERN_NOTIFICATION(MSSettingsManagerInactivityTimeoutSettingDidChange);

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
