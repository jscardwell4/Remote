//
//  CommandSet.swift
//  Remote
//
//  Created by Jason Cardwell on 3/2/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(CommandSet)
public final class CommandSet: CommandContainer {

  @NSManaged public var commands: NSSet?

  static let sharedKeysByType: [CommandSetType:Set<RemoteElement.Role>] = [
    .Dpad: Set<RemoteElement.Role>([.Up, .Down, .Left, .Right, .Center]),
    .Transport: Set<RemoteElement.Role>([.Play, .Stop, .Pause, .Skip, .Replay, .FF, .Rewind, .Record]),
    .Numberpad: Set<RemoteElement.Role>([.One, .Two, .Three, .Four, .Five, .Six, .Seven, .Eight, .Nine, .Zero, .Aux1, .Aux2]),
    .Rocker: Set<RemoteElement.Role>([.Top, .Bottom])
  ]

  @objc public enum CommandSetType: Int16 { case Unspecified, Dpad, Transport, Numberpad, Rocker }
  public var type: CommandSetType {
    get {
      willAccessValueForKey("type")
      let type = (primitiveValueForKey("type")  as! NSNumber).shortValue
      didAccessValueForKey("type")
      return CommandSetType(rawValue: type)!
    }
    set {
      willChangeValueForKey("type")
      setPrimitiveValue(NSNumber(short: newValue.rawValue), forKey: "type")
      didChangeValueForKey("type")
      if let sharedKeys = CommandSet.sharedKeysByType[newValue] {
        containerIndex = MSDictionary(sharedKeys: map(sharedKeys){Int($0.rawValue)}) as! OrderedDictionary<String, NSURL>
      } else {
        containerIndex = [:]
      }
    }
  }

  /**
  subscript:

  :param: key RemoteElement.Role

  :returns: Command?
  */
  public subscript(role: RemoteElement.Role) -> Command? {
    get { return self[String(role.jsonValue)!]}
    set { self[String(role.jsonValue)!] = newValue }
  }

  /**
  subscript:

  :param: key String

  :returns: Command?
  */
  public subscript(key: String) -> Command? {
    get { return (containerIndex[key] ?>> managedObjectContext!.objectForURI) as? Command }
    set { containerIndex[key] = newValue?.permanentURI() }
  }

  /**
  updateWithData:

  :param: data ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)

    if let moc = managedObjectContext,
      let typeJSON = data["type"] {
      let type = CommandSetType(jsonValue: typeJSON)
      if type != .Unspecified {
        self.type = type
        for (_, roleJSON, jsonValue) in data {
          if let role = RemoteElement.Role(roleJSON.jsonValue),
            commandData = ObjectJSONValue(jsonValue),
            command = Command.importObjectWithData(commandData, context: moc)
          {
              self[role] = command
          }
        }
      }
    }
  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["type"] = type.jsonValue
    obj += containerIndex.compressedMap({_, k, _ in self[k]?.jsonValue})
    return obj.jsonValue
  }


}

extension CommandSet.CommandSetType: StringValueConvertible {
  public var stringValue: String {
    switch self {
      case .Dpad:      return "dpad"
      case .Transport: return "transport"
      case .Numberpad: return "numberpad"
      case .Rocker:    return "rocker"
      default:         return "unspecified"
    }
  }
}

extension CommandSet.CommandSetType: JSONValueConvertible {
  public var jsonValue: JSONValue { return stringValue.jsonValue }

  public init(jsonValue: JSONValue) {
    switch String(jsonValue) {
      case let s where s == "dpad":      self = .Dpad
      case let s where s == "transport": self = .Transport
      case let s where s == "numberpad": self = .Numberpad
      case let s where s == "rocker":    self = .Rocker
      default:                           self = .Unspecified
    }
  }
}