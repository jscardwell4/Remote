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
MSSTATIC_KEY(SMBankViewingMode);

MSNOTIFICATION_DEFINITION(SMSettingAutoListenDidChange);
MSNOTIFICATION_DEFINITION(SMSettingProximitySensorDidChange);
MSNOTIFICATION_DEFINITION(SMSettingStatusBarDidChange);

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

@implementation SettingsManager

+ (void)load {

  [UserDefaults registerDefaults:@{ SMAutoListenKey      : @YES,
                                    SMProximitySensorKey : @YES,
                                    SMStatusBarKey       : @YES,
                                    SMBankViewingModeKey : @0 }];


  void(^connectionStatusBlock)(NSNotification *) = ^(NSNotification * note) {
    BOOL wifiAvailable = [ConnectionManager isWifiAvailable];
    BOOL autoListen    = [[SettingsManager valueForSetting:SMSettingAutoListen] boolValue];
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
    case SMSettingAutoListen:
      if ([value isKindOfClass:[NSNumber class]]) {
        key = SMAutoListenKey;
        notification = SMSettingAutoListenDidChangeNotification;
      }
      break;

    case SMSettingStatusBar:
      if ([value isKindOfClass:[NSNumber class]]) {
        key = SMStatusBarKey;
        notification = SMSettingStatusBarDidChangeNotification;
      }
      break;

    case SMSettingProximitySensor:
      if ([value isKindOfClass:[NSNumber class]]) {
        key = SMProximitySensorKey;
        notification = SMSettingProximitySensorDidChangeNotification;
      }
      break;

    case SMSettingBankViewingMode:
      if ([value isKindOfClass:[NSNumber class]]) {
        key = SMBankViewingModeKey;
      }
    default:
      break;
  }

  if (key) UserDefaults[key] = value;
  if (notification)  [NotificationCenter postNotificationName:notification object:self];

}

+ (id)valueForSetting:(SMSetting)setting {
  switch (setting) {
    case SMSettingAutoListen:      return UserDefaults[SMAutoListenKey];
    case SMSettingProximitySensor: return UserDefaults[SMProximitySensorKey];
    case SMSettingStatusBar:       return UserDefaults[SMStatusBarKey];
    case SMSettingBankViewingMode: return UserDefaults[SMBankViewingModeKey];
    default:                       return nil;
  }
}

@end
