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

  public var commandSets: OrderedSet<CommandSet> {
    get {
      willAccessValueForKey("commandSets")
      let commandSets = primitiveValueForKey("commandSets") as? OrderedSet<CommandSet>
      didAccessValueForKey("commandSets")
      return commandSets ?? []
    }
    set {
      willChangeValueForKey("commandSets")
      setPrimitiveValue(newValue as NSOrderedSet, forKey: "commandSets")
      didChangeValueForKey("commandSets")
    }
  }

  /**
  subscript:

  :param: label String

  :returns: CommandSet?
  */
  public subscript(label: String) -> CommandSet? {
    get { return (containerIndex[label] ?>> managedObjectContext!.objectForURI) as? CommandSet }
    set { containerIndex[label] = newValue?.permanentURI() }
  }

  public subscript(index: Int) -> CommandSet? { return commandSetAtIndex(index) }

  /**
  labelForCommandSet:

  :param: commandSet CommandSet

  :returns: String?
  */
  public func labelForCommandSet(commandSet: CommandSet) -> String? {
    return findFirst(containerIndex.keyValuePairs, {$1 as! String == commandSet.uuid})?.0
  }

  /**
  commandSetAtIndex:

  :param: idx Int

  :returns: CommandSet?
  */
  public func commandSetAtIndex(idx: Int) -> CommandSet? { return commandSets.count > idx ? commandSets[idx] : nil }

  /**
  labelAtIndex:

  :param: idx Int

  :returns: String?
  */
  public func labelAtIndex(idx: Int) -> String? { return idx < commandSets.count ? labelForCommandSet(commandSets[idx]) : nil }

  /**
  updateWithData:

  :param: data ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)

    if let moc = managedObjectContext {
      for (_, label, jsonValue) in data {
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
    containerIndex ➤ {_, k, _ in obj[k] = self[k]?.jsonValue}
    return obj.jsonValue
  }


}