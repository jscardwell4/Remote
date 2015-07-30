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

  - parameter key: String
  - parameter fromDefaults: (AnyObject?) -> T?
  - parameter toDefaults: (T) -> AnyObject?
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
  registerSettingWithKey:fromDefaults:toDefaults:

  - parameter key: K
  - parameter fromDefaults: (AnyObject?) -> T?
  - parameter toDefaults: (T) -> AnyObject?
  */
  public static func registerSettingWithKey<T, K:RawRepresentable where K.RawValue == String>(key: K,
                              withDefaultValue value: T? = nil,
                                  fromDefaults: (AnyObject?) -> T?,
                                    toDefaults: (T) -> AnyObject?)
  {
    registerSettingWithKey(key.rawValue, withDefaultValue: value, fromDefaults: fromDefaults, toDefaults: toDefaults)
  }

  /**
  registerBoolSettingWithKey:withDefaultValue:

  - parameter key: String
  - parameter value: Bool
  */
  public static func registerBoolSettingWithKey(key: String, withDefaultValue value: Bool) {
    registeredSettings[key] = Box<Any>(Transformer<Bool>(fromUserDefaults: {($0 as? NSNumber)?.boolValue},
                                                         toUserDefaults: {$0}))
  }

  /**
  registerBoolSettingWithKey:withDefaultValue:

  - parameter key: K
  - parameter value: Bool
  */
  public static func registerBoolSettingWithKey<K:RawRepresentable where K.RawValue == String>(key: K,
                               withDefaultValue value: Bool)
  {
    registerBoolSettingWithKey(key.rawValue, withDefaultValue: value)
  }

  /**
  setValue:forSetting:

  - parameter value: T
  - parameter setting: String
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
  setValue:forSetting:

  - parameter value: T
  - parameter setting: K
  */
  public static func setValue<T, K:RawRepresentable where K.RawValue == String>(value: T, forSetting setting: K) {
    setValue(value, forSetting: setting.rawValue)
  }

  /**
  valueForSetting:

  - parameter setting: String

  - returns: T?
  */
  public static func valueForSetting<T>(setting: String) -> T? {
    if let transformer = (registeredSettings[setting]?.unbox as? Transformer<T>)?.fromUserDefaults {
      return transformer(NSUserDefaults.standardUserDefaults().valueForKey(setting))
    } else { return nil }
  }

  /**
  valueForSetting:

  - parameter setting: K

  - returns: T?
  */
  public static func valueForSetting<T, K:RawRepresentable where K.RawValue == String>(setting: K) -> T? {
    return valueForSetting(setting.rawValue)
  }

}