//
//  SystemCommand.swift
//  Remote
//
//  Created by Jason Cardwell on 3/2/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

/**
  `SystemCommand` subclasses `Command` to perform tasks that interact with `UIKit` objects like
  `UIDevice`. Currently it is capable of toggling proximity monitoring on and off; however,
  this application as it stands does not use `SystemCommand` for anything.
*/
@objc(SystemCommand)
class SystemCommand: Command {

  @objc enum SystemCommandType: Int {
    case Undefined, ProximitySensor, URLRequest, LaunchScreen, OpenSettings, OpenEditor
  }

  @NSManaged var primitiveType: NSNumber
  var type: SystemCommandType {
    get {
      willAccessValueForKey("type")
      let type = primitiveType
      didAccessValueForKey("type")
      return SystemCommandType(rawValue: type.integerValue) ?? .Undefined
    }
    set {
      willChangeValueForKey("type")
      primitiveType = newValue.rawValue
      didChangeValueForKey("type")
    }
  }

  /**
  updateWithData:

  :param: data [NSObject:AnyObject]!
  */
  override func updateWithData(data: [NSObject:AnyObject]!) {
    super.updateWithData(data)

    if let typeJSON = data["type"] as? String { type = SystemCommandType(JSONValue: typeJSON) }
  }

  /**
  JSONDictionary

  :returns: MSDictionary!
  */
  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    dictionary["class"] = "system"
    setIfNotDefault("type", inDictionary: dictionary)

    dictionary.compact()
    dictionary.compress()

    return dictionary
  }

  override var operation: CommandOperation { return SystemCommandOperation(forCommand: self) }
}

extension SystemCommand.SystemCommandType: JSONValueConvertible {
  var JSONValue: String {
    switch self {
      case .ProximitySensor: return "proximity-sensor"
      case .URLRequest:      return "url-request"
      case .LaunchScreen:    return "launch-screen"
      case .OpenSettings:    return "open-settings"
      case .OpenEditor:      return "open-editor"
      default:               return "undefined"
    }
  }

  init(JSONValue: String) {
    switch JSONValue {
      case "proximity-sensor": self = .ProximitySensor
      case "url-request":      self = .URLRequest
      case "launch-screen":    self = .LaunchScreen
      case "open-settings":    self = .OpenSettings
      case "open-editor":      self = .OpenEditor
      default:                 self = .Undefined
    }
  }
}