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
#import "Lumberjack/Lumberjack.h"
#import "MSKit/MSKit.h"
#import "MSRemoteMacros.h"

MSEXTERN_NOTIFICATION(SMAutoListenSettingDidChange       );
MSEXTERN_NOTIFICATION(SMProximitySensorSettingDidChange  );
MSEXTERN_NOTIFICATION(SMStatusBarSettingDidChange        );

typedef NS_ENUM(uint8_t, SMSetting) {
  SMAutoListenSetting,
  SMProximitySensorSetting,
  SMStatusBarSetting
};

@interface SettingsManager : NSObject

+ (void)setValue:(id)value forSetting:(SMSetting)setting;
+ (id)valueForSetting:(SMSetting)setting;

@end
