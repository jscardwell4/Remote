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
  public var targetType: SwitchType {
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

  override public var description: String {
    var result = super.description
    result += "\n\ttargetType = \(targetType.stringValue)"
    result += "\n\ttarget = \(target)"
    return result
  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["targetType"] = targetType.jsonValue
    obj["target"] = target.jsonValue
    return obj.jsonValue
  }

  /**
  updateWithData:

  :param: data ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)
    if let type = SwitchType(data["targetType"]) { self.targetType = type }
    if let target = String(data["target"]) { self.target = target }
  }

  override var operation: CommandOperation {
    return SwitchCommandOperation(command: self)
  }
}

extension SwitchCommand.SwitchType: StringValueConvertible {
  public var stringValue: String { return String(jsonValue)! }
}

extension SwitchCommand.SwitchType: JSONValueConvertible {
  public var jsonValue: JSONValue {
    switch self {
      case .Undefined: return "undefined"
      case .Remote:    return "remote"
      case .Mode:      return "mode"
    }
  }
}

extension SwitchCommand.SwitchType: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if let string = String(jsonValue) {
      switch string {
        case String(SwitchCommand.SwitchType.Remote.jsonValue)!: self = .Remote
        case String(SwitchCommand.SwitchType.Mode.jsonValue)!:   self = .Mode
        default:                                                 self = .Undefined
      }
    } else { return nil }
  }
}