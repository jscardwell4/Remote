//
//  CommandSetCollection.swift
//  Remote
//
//  Created by Jason Cardwell on 3/2/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(CommandSetCollection)
public final class CommandSetCollection: CommandContainer {

  @NSManaged public var commandSets: NSOrderedSet?

  /**
  subscript:

  :param: label String

  :returns: CommandSet?
  */
  public subscript(label: String) -> CommandSet? {
    get {
      if let commandSetUUID = containerIndex[label] as? String,
        let moc = managedObjectContext,
        let commandSet = CommandSet.objectWithUUID(commandSetUUID, context: moc) {
      return commandSet }
      else { return nil }
    }
    set {
      if let existingUUID = containerIndex[label] as? String where newValue == nil,
        let moc = managedObjectContext,
        let existingCommandSet = CommandSet.objectWithUUID(existingUUID, context: moc) {
          let mutableCommandSets = mutableOrderedSetValueForKey("commandSets")
          mutableCommandSets.removeObject(existingCommandSet)
      }
      containerIndex[label] = newValue?.uuid
    }
  }

  /**
  labelForCommandSet:

  :param: commandSet CommandSet

  :returns: String?
  */
  public func labelForCommandSet(commandSet: CommandSet) -> String? { return containerIndex.keyForObject(commandSet.uuid) as? String }

  /**
  commandSetAtIndex:

  :param: idx Int

  :returns: CommandSet?
  */
  public func commandSetAtIndex(idx: Int) -> CommandSet? {
    if let commandSetCount = commandSets?.count where idx < commandSetCount {
      return commandSets![idx] as? CommandSet
    } else { return nil }
  }

  /**
  labelAtIndex:

  :param: idx Int

  :returns: String?
  */
  public func labelAtIndex(idx: Int) -> String? { return idx < Int(count) ? containerIndex.keyAtIndex(UInt(idx)) as? String : nil }

  /**
  updateWithData:

  :param: data ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)

    if let moc = managedObjectContext {
      for (label, jsonValue) in data {
        if let commandSetData = ObjectJSONValue(jsonValue),
          commandSet: CommandSet = CommandSet.importObjectWithData(commandSetData, context: moc)
        {
          self[label] = commandSet
        }
      }
    }

  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!

    // TODO: fill in stub
    return obj.jsonValue
  }


}