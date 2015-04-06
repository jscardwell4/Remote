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
public final class MacroCommand: Command {

  @NSManaged public var commands: NSOrderedSet?

  public var count: Int { return commands?.count ?? 0 }
  public let queue = NSOperationQueue(name: "com.moondeerstudios.macro")

  override var operation: CommandOperation { return MacroCommandOperation(command: self) }

  /** awakeFromInsert */
  override public func awakeFromInsert() {
    super.awakeFromInsert()
    indicator = true
  }

  public subscript(index: Int) -> Command {
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
  override public func execute(completion: ((success: Bool, error: NSError?) -> Void)? = nil) {
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

  :param: data ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)

    if let commandsData = ArrayJSONValue(data["commands"] ?? .Null) {
      var commands: [Command] = []
      for commandData in commandsData.compressedMap({ObjectJSONValue($0)}) {
        if let commandClassNameJSON = commandData.value["class"]?.value as? String, let moc = managedObjectContext {
          let command: Command?
          switch commandClassNameJSON {
            case "power":    command = PowerCommand.importObjectWithData(commandData, context: moc)
            case "sendir":   command = SendIRCommand.importObjectWithData(commandData, context: moc)
            case "http":     command = HTTPCommand.importObjectWithData(commandData, context: moc)
            case "delay":    command = DelayCommand.importObjectWithData(commandData, context: moc)
            case "macro":    command = MacroCommand.importObjectWithData(commandData, context: moc)
            case "system":   command = SystemCommand.importObjectWithData(commandData, context: moc)
            case "switch":   command = SwitchCommand.importObjectWithData(commandData, context: moc)
            case "activity": command = ActivityCommand.importObjectWithData(commandData, context: moc)
            default:         command = nil
          }
          if command != nil { commands.append(command!) }
        }
      }
      self.commands = NSOrderedSet(array: commands)
    }

  }

  override public var jsonValue: JSONValue {
    var dict = super.jsonValue.value as! JSONValue.ObjectValue

    dict["class"] = "macro"
    appendValueForKey("commands", toDictionary: &dict)
    return .Object(dict)
  }


}