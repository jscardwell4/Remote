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
class CommandSet: CommandContainer {

  @NSManaged var commands: NSSet?

  static let sharedKeysByType: [CommandSetType:Set<RemoteElement.Role>] = [
    .Dpad: Set<RemoteElement.Role>([.Up, .Down, .Left, .Right, .Center]),
    .Transport: Set<RemoteElement.Role>([.Play, .Stop, .Pause, .Skip, .Replay, .FF, .Rewind, .Record]),
    .Numberpad: Set<RemoteElement.Role>([.One, .Two, .Three, .Four, .Five, .Six, .Seven, .Eight, .Nine, .Zero, .Aux1, .Aux2]),
    .Rocker: Set<RemoteElement.Role>([.Top, .Bottom])
  ]

  @objc enum CommandSetType: Int { case Unspecified, Dpad, Transport, Numberpad, Rocker }
  @NSManaged var primitiveType: NSNumber
  var type: CommandSetType {
    get {
      willAccessValueForKey("type")
      let type = primitiveType
      didAccessValueForKey("type")
      return CommandSetType(rawValue: type.integerValue) ?? .Unspecified
    }
    set {
      willChangeValueForKey("type")
      primitiveType = newValue.rawValue
      didChangeValueForKey("type")
      if let sharedKeys = CommandSet.sharedKeysByType[newValue] {
        index = MSDictionary(sharedKeys: Array(map(sharedKeys){$0.rawValue}))
      } else {
        index = MSDictionary()
      }
    }
  }

  /**
  subscript:

  :param: key RemoteElement.Role

  :returns: Command?
  */
  subscript(key: RemoteElement.Role) -> Command? {
    get { return index[key.rawValue] as? Command }
    set { index[key.rawValue] = newValue }
  }

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)

    if let moc = managedObjectContext,
      let typeJSON = data["type"] as? String {
      let type = CommandSetType(JSONValue: typeJSON)
      if type != .Unspecified {
        self.type = type
        let commands = data - "type"
        for (roleJSON, roleData) in commands {
          if let commandData = roleData as? [String:AnyObject],
            let command = Command.importObjectWithData(commandData, context: moc) {
              self[RemoteElement.Role(JSONValue: roleJSON)] = command
          }
        }
      }
    }
  }

  /**
  JSONDictionary

  :returns: MSDictionary!
  */
  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    dictionary["type"] = type.JSONValue
    index.enumerateKeysAndObjectsUsingBlock { (key, uri, _) -> Void in
      if let command = self.managedObjectContext?.objectForURI(uri as! NSURL) as? Command {
        dictionary[RemoteElement.Role(rawValue: (key as! NSNumber).integerValue).JSONValue] = command.JSONDictionary()
      }
    }

    dictionary.compact()
    dictionary.compress()

    return dictionary
  }


}

extension CommandSet.CommandSetType: JSONValueConvertible {
  var JSONValue: String {
    switch self {
      case .Dpad:      return "dpad"
      case .Transport: return "transport"
      case .Numberpad: return "numberpad"
      case .Rocker:    return "rocker"
      default:         return "unspecified"
    }
  }

  init(JSONValue: String) {
    switch JSONValue {
      case "dpad":      self = .Dpad
      case "transport": self = .Transport
      case "numberpad": self = .Numberpad
      case "rocker":    self = .Rocker
      default:          self = .Unspecified
    }
  }
}