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
public final class SystemCommand: Command {

  @objc public enum SystemCommandType: Int {
    case Undefined, ProximitySensor, URLRequest, LaunchScreen, OpenSettings, OpenEditor
  }

  @NSManaged var primitiveType: NSNumber
  public var type: SystemCommandType {
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

  :param: data ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)

    if let typeJSON = String(data["type"]) { type = SystemCommandType(jsonValue: typeJSON.jsonValue) }
  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["class"] = "system".jsonValue
    obj["type"] = type.jsonValue
    return obj.jsonValue
  }

  override var operation: CommandOperation { return SystemCommandOperation(command: self) }
}

extension SystemCommand.SystemCommandType: StringValueConvertible {
  public var stringValue: String { return String(jsonValue)! }
}

extension SystemCommand.SystemCommandType: JSONValueConvertible {
  public var jsonValue: JSONValue {
    switch self {
      case .ProximitySensor: return "proximity-sensor"
      case .URLRequest:      return "url-request"
      case .LaunchScreen:    return "launch-screen"
      case .OpenSettings:    return "open-settings"
      case .OpenEditor:      return "open-editor"
      default:               return "undefined"
    }
  }

  public init(jsonValue: JSONValue) {
    switch jsonValue.value as? String ?? "" {
      case String(SystemCommand.SystemCommandType.ProximitySensor.jsonValue)!: self = .ProximitySensor
      case String(SystemCommand.SystemCommandType.URLRequest.jsonValue)!:      self = .URLRequest
      case String(SystemCommand.SystemCommandType.LaunchScreen.jsonValue)!:    self = .LaunchScreen
      case String(SystemCommand.SystemCommandType.OpenSettings.jsonValue)!:    self = .OpenSettings
      case String(SystemCommand.SystemCommandType.OpenEditor.jsonValue)!:      self = .OpenEditor
      default:                                                                 self = .Undefined
    }
  }
}