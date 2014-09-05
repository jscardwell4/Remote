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

MSSTATIC_KEY(SMAutoListen);
MSSTATIC_KEY(SMProximitySensor);
MSSTATIC_KEY(SMStatusBar);

MSNOTIFICATION_DEFINITION(SMAutoListenSettingDidChange);
MSNOTIFICATION_DEFINITION(SMProximitySensorSettingDidChange);
MSNOTIFICATION_DEFINITION(SMStatusBarSettingDidChange);

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

@implementation SettingsManager

+ (void)load {

  [UserDefaults registerDefaults:@{ SMAutoListenKey      : @YES,
                                    SMProximitySensorKey : @YES,
                                    SMStatusBarKey       : @YES }];


  void(^connectionStatusBlock)(NSNotification *) = ^(NSNotification * note) {
    BOOL wifiAvailable = [ConnectionManager isWifiAvailable];
    BOOL autoListen    = [[SettingsManager valueForSetting:SMAutoListenSetting] boolValue];
    if (autoListen && wifiAvailable && ![ConnectionManager isDetectingNetworkDevices])
      [ConnectionManager startDetectingDevices:nil];
  };

  [NotificationCenter addObserverForName:CMConnectionStatusNotification
                                  object:[ConnectionManager class]
                                   queue:MainQueue
                              usingBlock:connectionStatusBlock];
  connectionStatusBlock(nil);
}

+ (void)setValue:(id)value forSetting:(SMSetting)setting {

  NSString * key          = nil;
  NSString * notification = nil;

  switch (setting) {
    case SMAutoListenSetting:
      if ([value isKindOfClass:[NSNumber class]]) {
        key = SMAutoListenKey;
        notification = SMAutoListenSettingDidChangeNotification;
      }
      break;

    case SMStatusBarSetting:
      if ([value isKindOfClass:[NSNumber class]]) {
        key = SMStatusBarKey;
        notification = SMStatusBarSettingDidChangeNotification;
      }
      break;

    case SMProximitySensorSetting:
      if ([value isKindOfClass:[NSNumber class]]) {
        key = SMProximitySensorKey;
        notification = SMProximitySensorSettingDidChangeNotification;
      }
      break;

    default:
      break;
  }

  if (key && notification) {
    UserDefaults[key] = value;
    [NotificationCenter postNotificationName:notification object:self];
  }

}

+ (id)valueForSetting:(SMSetting)setting {
  switch (setting) {
    case SMAutoListenSetting:      return UserDefaults[SMAutoListenKey];
    case SMProximitySensorSetting: return UserDefaults[SMProximitySensorKey];
    case SMStatusBarSetting:       return UserDefaults[SMStatusBarKey];
    default:                       return nil;
  }
}

@end
