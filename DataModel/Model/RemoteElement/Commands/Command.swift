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
public class Command: ModelObject {

  /** Simple enumeration for specifying execution behavior. */
  public enum Option { case Default, LongPress }

  public var indicator: Bool { return false }

  /**
  execute:error:

  :param: completion The block to invoke upon completing command execution
  */
  public func execute(completion: ((success: Bool, error: NSError?) -> Void)? = nil) {
    MSLogDebug("beginning execution of \(self.dynamicType.className())…")
    let operation = self.operation
    operation.completionBlock = {
      MSLogDebug("execution complete  - success = \(operation.success) error = \(toString(descriptionForError(operation.error)))")
      completion?(success: operation.success, error: operation.error)
    }
    operation.start()
  }

  private static let ActivityCommandKeys  = Set(["activity"])
  private static let DelayCommandKeys     = Set(["delay"])
  private static let HTTPCommandKeys      = Set(["url"])
  private static let PowerCommandKeys     = Set(["device", "state"])
  private static let SendIRCommandKeys    = Set(["code"])
  private static let SwitchCommandKeys    = Set(["targetType", "target"])
  private static let SystemCommandKeys    = Set(["type"])
  private static let MacroCommandKeys     = Set(["commands"])

  /**
  importTypeForKeys:

  :param: keys [String]

  :returns: Command.Type
  */
  private static func importTypeForKeys(keys: [String]) -> Command.Type? {
    if ActivityCommandKeys ⊇ keys { return ActivityCommand.self}
    if DelayCommandKeys ⊇ keys { return DelayCommand.self}
    if HTTPCommandKeys ⊇ keys { return HTTPCommand.self}
    if PowerCommandKeys ⊇ keys { return PowerCommand.self}
    if SendIRCommandKeys ⊇ keys { return SendIRCommand.self}
    if SwitchCommandKeys ⊇ keys { return SwitchCommand.self}
    if SystemCommandKeys ⊇ keys { return SystemCommand.self}
    if MacroCommandKeys ⊇ keys { return MacroCommand.self}
    return nil
  }

  /**
  importObjectWithData:context:

  :param: data ObjectJSONValue
  :param: context NSManagedObjectContext!

  :returns: Command?
  */
  override public class func importObjectWithData(data: ObjectJSONValue, context: NSManagedObjectContext) -> Command? {
    if self === Command.self, let type = importTypeForKeys(data.keys.array) {
      return type.importObjectWithData(data, context: context)
    } else {
      return super.importObjectWithData(data, context: context) as? Command
    }
  }

  var operation: CommandOperation { return CommandOperation(command: self) }

}