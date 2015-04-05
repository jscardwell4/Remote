//
//  SwitchCommand.swift
//  Remote
//
//  Created by Jason Cardwell on 3/2/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(SwitchCommand)
public final class SwitchCommand: Command {

  /** Holds the target's `uuid` when type is remote and the mode value when the type is mode */
  @NSManaged public var target: String

  @objc public enum SwitchType: Int { case Undefined = 0, Remote = 1, Mode = 2 }

  @NSManaged var primitiveType: NSNumber
  public var type: SwitchType {
    get {
      willAccessValueForKey("type")
      let type = primitiveType
      didAccessValueForKey("type")
      return SwitchType(rawValue: type.integerValue) ?? .Undefined
    }
    set {
      willChangeValueForKey("type")
      primitiveType = newValue.rawValue
      didChangeValueForKey("type")
    }
  }

  override public var jsonValue: JSONValue {
    var dict = super.jsonValue.value as! JSONValue.ObjectValue

    dict["class"] = "switch"
    appendValueForKey("type", toDictionary: &dict)
    switch type {
      case .Remote:
        if let targetRemote = Remote.objectWithUUID(target, context: managedObjectContext!) {
          dict["target"] = target.jsonValue
        }
      case .Mode:
        dict["target"] = target.jsonValue
      default: break
    }
    return .Object(dict)
  }

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override public func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)
    if let typeJSON = data["type"] as? String { self.type = SwitchType(jsonValue: typeJSON.jsonValue) }
    if let target = data["target"] as? String { self.target = target }
  }

  override var operation: CommandOperation {
    return SwitchCommandOperation(command: self)
  }
}

extension SwitchCommand.SwitchType: JSONValueConvertible {
  public var jsonValue: JSONValue {
    switch self {
      case .Undefined: return "undefined"
      case .Remote:    return "remote"
      case .Mode:      return "mode"
    }
  }

  public init(jsonValue: JSONValue) {
    switch jsonValue.value as? String ?? "" {
      case SwitchCommand.SwitchType.Remote.jsonValue.value as! String: self = .Remote
      case SwitchCommand.SwitchType.Mode.jsonValue.value as! String:   self = .Mode
      default:                                                         self = .Undefined
    }
  }
}