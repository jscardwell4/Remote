//
// SettingsManager.h
// Remote
//
// Created by Jason Cardwell on 3/2/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
@import CocoaLumberjack;
@import MoonKit;
#import "MSRemoteMacros.h"

MSEXTERN_NOTIFICATION(SMSettingAutoListenDidChange       );
MSEXTERN_NOTIFICATION(SMSettingProximitySensorDidChange  );
MSEXTERN_NOTIFICATION(SMSettingStatusBarDidChange        );

typedef NS_ENUM(NSInteger, SMSetting) {
  SMSettingAutoListen,
  SMSettingProximitySensor,
  SMSettingStatusBar,
  SMSettingBankViewingMode
};

@interface SettingsManager : NSObject

+ (void)setValue:(id)value forSetting:(SMSetting)setting;
+ (id)valueForSetting:(SMSetting)setting;

@end
