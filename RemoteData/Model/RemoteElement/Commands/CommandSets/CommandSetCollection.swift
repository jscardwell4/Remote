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
class CommandSetCollection: CommandContainer {

  @NSManaged var commandSets: NSOrderedSet?

  /**
  subscript:

  :param: label String

  :returns: CommandSet?
  */
  subscript(label: String) -> CommandSet? {
    get {
      if let commandSetUUID = index[label] as? String,
        let moc = managedObjectContext,
        let commandSet = CommandSet.objectWithUUID(commandSetUUID, context: moc) {
      return commandSet }
      else { return nil }
    }
    set {
      if let existingUUID = index[label] as? String where newValue == nil,
        let moc = managedObjectContext,
        let existingCommandSet = CommandSet.objectWithUUID(existingUUID, context: moc) {
          let mutableCommandSets = mutableOrderedSetValueForKey("commandSets")
          mutableCommandSets.removeObject(existingCommandSet)
      }
      index[label] = newValue?.uuid
    }
  }

  /**
  labelForCommandSet:

  :param: commandSet CommandSet

  :returns: String?
  */
  func labelForCommandSet(commandSet: CommandSet) -> String? { return index.keyForObject(commandSet.uuid) as? String }

  /**
  commandSetAtIndex:

  :param: idx Int

  :returns: CommandSet?
  */
  func commandSetAtIndex(idx: Int) -> CommandSet? {
    if let commandSetCount = commandSets?.count where idx < commandSetCount {
      return commandSets![idx] as? CommandSet
    } else { return nil }
  }

  /**
  labelAtIndex:

  :param: idx Int

  :returns: String?
  */
  func labelAtIndex(idx: Int) -> String? { return idx < Int(count) ? index.keyAtIndex(UInt(idx)) as? String : nil }

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)

    if let commandSetsData = data as? [String:[String:AnyObject]], let moc = managedObjectContext {
      for (label, commandSetData) in commandSetsData {
        if let commandSet = CommandSet.importObjectWithData(commandSetData, context: moc) {
          self[label] = commandSet
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



    dictionary.compact()
    dictionary.compress()

    return dictionary
  }


}