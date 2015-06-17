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
  registerBoolSettingWithKey:withDefaultValue:

  - parameter key: String
  - parameter value: Bool
  */
  public static func registerBoolSettingWithKey(key: String, withDefaultValue value: Bool) {
    registeredSettings[key] = Box<Any>(Transformer<Bool>(fromUserDefaults: {($0 as? NSNumber)?.boolValue},
                                                         toUserDefaults: {$0}))
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
  valueForSetting:

  - parameter setting: String

  - returns: T?
  */
  public static func valueForSetting<T>(setting: String) -> T? {
    if let transformer = (registeredSettings[setting]?.unbox as? Transformer<T>)?.fromUserDefaults {
      return transformer(NSUserDefaults.standardUserDefaults().valueForKey(setting))
    } else { return nil }
  }

}