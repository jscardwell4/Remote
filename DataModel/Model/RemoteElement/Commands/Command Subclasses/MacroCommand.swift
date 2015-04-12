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

  public var commands: OrderedSet<Command> {
    get {
      willAccessValueForKey("commands")
      let commands = primitiveValueForKey("commands") as? OrderedSet<Command>
      didAccessValueForKey("commands")
      return commands ?? []
    }
    set {
      willChangeValueForKey("commands")
      setPrimitiveValue(newValue as NSOrderedSet, forKey: "commands")
      didChangeValueForKey("commands")
    }
  }

  public var count: Int { return commands.count }
  public let queue = NSOperationQueue(name: "com.moondeerstudios.macro")

  override var operation: CommandOperation { return MacroCommandOperation(command: self) }

  override public var indicator: Bool { return true }

  public subscript(index: Int) -> Command {
    get {
      precondition(0..<commands.count ~= index, "index out of bounds")
      return commands[index]
    }
    set {
      precondition(0..<commands.count ~= index, "index out of bounds")
      mutableOrderedSetValueForKey("commands").insertObject(newValue, atIndex: index)
    }
  }

  /**
  execute:
  
  :param: completion Optional block to invoke after command execution completes
  */
  override public func execute(completion: ((success: Bool, error: NSError?) -> Void)? = nil) {
    if commands.count > 0 {
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
        let errors = compressedMap(operations, {$0.error})
        if errors.count == 1 { error = errors.last }
        else if errors.count > 1 { error = NSError(domain: "MacroCommandExecution", code: -1, underlyingErrors: errors) }
        completion?(success: success, error: error)
      }
      queue.addOperations((operations as NSOrderedSet).array, waitUntilFinished: false)
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

    if let commandsData = ArrayJSONValue(data["commands"]) {
      var commands: OrderedSet<Command> = []
      for commandData in compressedMap(commandsData, {ObjectJSONValue($0)}) {
        if let commandClassNameJSON = String(commandData.value["class"]), let moc = managedObjectContext {
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
      self.commands = commands
    }

  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["class"] = "macro"
    obj["commands"] = .Array(map(commands, {$0.jsonValue}))
    return obj.jsonValue
  }


}