//
//  MacroCommand.swift
//  Remote
//
//  Created by Jason Cardwell on 3/2/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

/**
  `MacroCommand` is a `Command` subclass that can execute a series of commands.
*/
@objc(MacroCommand)
class MacroCommand: Command {

  @NSManaged var commands: NSOrderedSet?

  var count: Int { return commands?.count ?? 0 }
  let queue = NSOperationQueue(name: "com.moondeerstudios.macro")

  override var operation: CommandOperation { return MacroCommandOperation(command: self) }

  /** awakeFromInsert */
  override func awakeFromInsert() {
    super.awakeFromInsert()
    indicator = true
  }

  subscript(index: Int) -> Command {
    get {
      precondition(commands != nil && index >= 0 && index < commands!.count, "index out of bounds")
      return commands?[index] as! Command
    }
    set {
      precondition(commands != nil && index >= 0 && index < commands!.count, "index out of bounds")
      mutableOrderedSetValueForKey("commands").insertObject(newValue, atIndex: index)
    }
  }

  /**
  execute:
  
  :param: completion Optional block to invoke after command execution completes
  */
  override func execute(completion: ((success: Bool, error: NSError?) -> Void)? = nil) {
    if let commands = self.commands?.array as? [Command] {
      let operations = commands.map {$0.operation}
      var precedingOperation: CommandOperation?
      for operation in operations {
        if precedingOperation != nil { operation.addDependency(precedingOperation!) }
        precedingOperation = operation
      }
      precedingOperation?.completionBlock = {
        MSLogDebug("command dispatch complete")
        let success = operations.filter{$0.success == false}.count > 0
        var error: NSError?
        let errors = operations.map{$0.error}.filter{$0 != nil}.map{$0!}
        if errors.count == 1 { error = errors.last }
        else if errors.count > 1 { error = NSError(domain: "MacroCommandExecution", code: -1, underlyingErrors: errors) }
        completion?(success: success, error: error)
      }
      queue.addOperations(operations, waitUntilFinished: false)
    } else { completion?(success: true, error: nil) }
  }

//  override var name: String? {
//    get {
//      willAccessValueForKey("name")
//      var name = primitiveValueForKey("name") as? String
//      didAccessValueForKey("name")
//
//      return name ?? "\u{2192}".join(commands?.valueForKeyPath("className") as? Array<String> ?? [])
//    }
//    set { super.name = newValue }
//  }

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)

    if let commandsData = data["commands"] as? [[String:AnyObject]] {
      var commands: [Command] = []
      for commandData in commandsData {
        if let commandClassNameJSON = commandData["class"] as? String, let moc = managedObjectContext {
          let command: Command?
          switch commandClassNameJSON {
            case "power":    command = PowerCommand.fetchOrImportObjectWithData(commandData, context: moc)
            case "sendir":   command = SendIRCommand.fetchOrImportObjectWithData(commandData, context: moc)
            case "http":     command = HTTPCommand.fetchOrImportObjectWithData(commandData, context: moc)
            case "delay":    command = DelayCommand.fetchOrImportObjectWithData(commandData, context: moc)
            case "macro":    command = MacroCommand.fetchOrImportObjectWithData(commandData, context: moc)
            case "system":   command = SystemCommand.fetchOrImportObjectWithData(commandData, context: moc)
            case "switch":   command = SwitchCommand.fetchOrImportObjectWithData(commandData, context: moc)
            case "activity": command = ActivityCommand.fetchOrImportObjectWithData(commandData, context: moc)
            default:         command = nil
          }
          if command != nil { commands.append(command!) }
        }
      }
      self.commands = NSOrderedSet(array: commands)
    }

  }

  /**
  JSONDictionary

  :returns: MSDictionary!
  */
  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    dictionary["class"] = "macro"
    safeSetValueForKeyPath("commands.JSONDictionary", forKey: "commands", inDictionary: dictionary)

    dictionary.compact()
    dictionary.compress()

    return dictionary
  }


}