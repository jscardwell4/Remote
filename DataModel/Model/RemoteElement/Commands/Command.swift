//
//  Command.swift
//  Remote
//
//  Created by Jason Cardwell on 3/2/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

/**
  The `Command` class subclasses `NSManagedObject` to model a command to be executed. Most of the
  time the command is executed as a result of the user pressing a button; however, some commands
  execute other commands and chain the result back up to the command that initiated the execution.
  `Command` objects are not intended to be created directly. Instead, there are many subclasses
  that customize behavior for particular tasks: <PowerCommand>, <MacroCommand>, <DelayCommand>,
  <SystemCommand>, <SendIRCommand>, <HTTPCommand>, <SwitchToRemoteCommand>.
*/
@objc(Command)
public class Command: NamedModelObject {

  /** Simple enumeration for specifying execution behavior. */
  public enum Option { case Default, LongPress }

  @NSManaged var primitiveIndicator: NSNumber
  public var indicator: Bool {
    get {
      willAccessValueForKey("indicator")
      let indicator = primitiveIndicator
      didAccessValueForKey("indicator")
      return indicator.boolValue
    }
    set {
      willChangeValueForKey("indicator")
      primitiveIndicator = newValue
      didChangeValueForKey("indicator")
    }
  }

  /**
  execute:error:

  :param: completion The block to invoke upon completing command execution
  */
  public func execute(completion: ((success: Bool, error: NSError?) -> Void)? = nil) {
    let operation = self.operation
    operation.completionBlock = {completion?(success: operation.success, error: operation.error)}
    operation.start()
  }

  /**
  importObjectWithData:context:

  :param: data ObjectJSONValue
  :param: context NSManagedObjectContext!

  :returns: Command?
  */
  override public class func importObjectWithData(data: [String:AnyObject], context: NSManagedObjectContext) -> Command? {
    if self === Command.self, let classJSONValue = data["class"] as? String {
      switch classJSONValue {
        case "power":  return PowerCommand(data: data, context: context)
        case "delay":  return DelayCommand(data: data, context: context)
        case "sendir": return SendIRCommand(data: data, context: context)
        case "http":   return HTTPCommand(data: data, context: context)
        case "system": return SystemCommand(data: data, context: context)
        case "macro":  return MacroCommand(data: data, context: context)
        default:       return nil
      }
    } else {
      return super.importObjectWithData(data, context: context) as? Command
    }
  }

  var operation: CommandOperation { return CommandOperation(command: self) }

}