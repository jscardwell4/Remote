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

  /**
  JSONDictionary

  :returns: MSDictionary!
  */
  override public func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    dictionary["class"] = "switch"
    appendValueForKey("type", toDictionary: dictionary)
    switch type {
      case .Remote:
        if let targetRemote = Remote.objectWithUUID(target, context: managedObjectContext!) {
          dictionary["target"] = target
        }
      case .Mode:
        dictionary["target"] = target
      default: break
    }

    dictionary.compact()
    dictionary.compress()

    return dictionary
  }

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override public func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)
    if let typeJSON = data["type"] as? String { self.type = SwitchType(JSONValue: typeJSON) }
    if let target = data["target"] as? String { self.target = target }
  }

  override var operation: CommandOperation {
    return SwitchCommandOperation(command: self)
  }
}

extension SwitchCommand.SwitchType: JSONValueConvertible {
  public var JSONValue: String {
    switch self {
      case .Undefined: return "undefined"
      case .Remote:    return "remote"
      case .Mode:      return "mode"
    }
  }

  public init(JSONValue: String) {
    switch JSONValue {
      case SwitchCommand.SwitchType.Remote.JSONValue: self = .Remote
      case SwitchCommand.SwitchType.Mode.JSONValue:   self = .Mode
      default:                                        self = .Undefined
    }
  }
}