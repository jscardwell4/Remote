//
//  SettingsManager.swift
//  Remote
//
//  Created by Jason Cardwell on 4/20/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit

struct Transformer<T> {
  let fromUserDefaults: (AnyObject?) -> T?
  let toUserDefaults: (T) -> AnyObject?
}

public final class SettingsManager {

  public static let NotificationName = "SMSettingDidChangeNotification"
  public static let ChangedSettingKey = "SMChangedSettingKey"
  public static let NewValueKey = "SMNewValueKey"

  private static var registeredSettings: [String:Box<Any>] = [:]

  /**
  registerSettingWithKey:fromDefaults:toDefaults:

  :param: key String
  :param: fromDefaults (AnyObject?) -> T?
  :param: toDefaults (T) -> AnyObject?
  */
  public static func registerSettingWithKey<T>(key: String,
                              withDefaultValue value: T? = nil,
                                  fromDefaults: (AnyObject?) -> T?,
                                    toDefaults: (T) -> AnyObject?)
  {
    registeredSettings[key] = Box<Any>(Transformer(fromUserDefaults: fromDefaults, toUserDefaults: toDefaults))
    if value != nil, let defaultValue: AnyObject = toDefaults(value!)  {
      NSUserDefaults.standardUserDefaults().registerDefaults([key: defaultValue])
    }
  }

  /**
  setValue:forSetting:

  :param: value T
  :param: setting String
  */
  public static func setValue<T>(value: T, forSetting setting: String) {
    if let transformer = (registeredSettings[setting]?.unbox as? Transformer<T>)?.toUserDefaults {
      let newValue: AnyObject? = transformer(value)
      NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: setting)
      NSNotificationCenter.defaultCenter().postNotificationName(NotificationName,
                                                         object: self,
                                                       userInfo: [ChangedSettingKey:setting, NewValueKey: newValue ?? NSNull()])
    }
  }

  /**
  valueForSetting:

  :param: setting String

  :returns: T?
  */
  public static func valueForSetting<T>(setting: String) -> T? {
    if let transformer = (registeredSettings[setting]?.unbox as? Transformer<T>)?.fromUserDefaults {
      return transformer(NSUserDefaults.standardUserDefaults().valueForKey(setting))
    } else { return nil }
  }

}