//
//  CommandOperation.swift
//  Remote
//
//  Created by Jason Cardwell on 3/19/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit
import class Networking.ConnectionManager

internal class CommandOperation: NSOperation {

  private var _executing = false
  private(set) override var executing: Bool {
    get { return _executing }
    set {
      willChangeValueForKey("isExecuting")
      _executing = newValue
      didChangeValueForKey("isExecuting")
    }
  }

  private var _finished = false
  private(set) override var finished: Bool {
    get { return _finished }
    set {
      willChangeValueForKey("isFinished")
      _finished = newValue
      didChangeValueForKey("isFinished")
    }
  }
  private(set) var success: Bool = false {
    didSet { if success && (error != nil || !finished || cancelled) { success = false } }
  }
  override var concurrent: Bool { return true }
  let command: Command
  private(set) var error: NSError?

  /**
  initWithCommand:

  :param: command Command
  */
  init(command: Command) {
    self.command = command
    super.init()
  }

  /** start */
  override func start() {
    if cancelled {
      finished = true
    } else if let dependencies = dependencies as? [CommandOperation],
      unsuccessfulDependency = findFirst(dependencies, {$0.success == false})
    {
      //TODO: wrap error as underlying error
      error = unsuccessfulDependency.error
      finished = true
    } else {
      NSThread.detachNewThreadSelector("main", toTarget: self, withObject: nil)
      executing = true
    }
  }

  /** main */
  override func main() {
    executing = false
    finished = true
  }

}


final class ActivityCommandOperation: CommandOperation {

  /** main */
  override func main() {
    if let activity = (command as? ActivityCommand)?.activity {
      activity.launchOrHaltActivity {
        (success: Bool, error: NSError?) -> Void in
        self.success = success
        super.main()
      }
    }
  }

}

final class SwitchCommandOperation: CommandOperation {

  /** main */
  override func main() {
    if let moc = command.managedObjectContext, switchCommand = command as? SwitchCommand {
      let activityController = ActivityController.sharedController(moc)
      switch switchCommand.targetType {
        case .Mode:
          let remote = activityController.currentRemote
          let mode: RemoteElement.Mode = switchCommand.target
          remote.currentMode = mode
          success = remote.currentMode == mode
        case .Remote:
          if let uuidIndex = UUIDIndex(switchCommand.target),
            remote = Remote.objectWithUUID(uuidIndex, context: moc)
          {
            activityController.currentRemote = remote
            success = activityController.currentRemote === remote
          } else { success = false }
        default:
          success = true
      }
    }
    super.main()
  }

}

final class SendCommandOperation: CommandOperation {

  /** main */
  override func main() {
    let commandID = command.objectID
    ConnectionManager.sendCommandWithID(commandID) {
      MSLogDebug("command ID:\(commandID)\ncompletion: success? \($0) error - \($1)")
      self.success = $0
      self.error = $1
      super.main()
    }
  }

}

final class DelayCommandOperation: CommandOperation {

  /** main */
  override func main() {
    if let delayCommand = command as? DelayCommand {
      NSThread.sleepForTimeInterval(Double(delayCommand.duration))
      success = true
      super.main()
    } else {
      success = false
      super.main()
    }
  }

}

final class MacroCommandOperation: CommandOperation {

  /** main */
  override func main() {
    // TODO: Make sure execution stops on first unsuccessful command in the macro
    if let macroCommand = command as? MacroCommand {
      if macroCommand.commands.count > 0 {
        let operations = macroCommand.commands.map {$0.operation}
        var precedingOperation: CommandOperation?
        for operation in operations {
          if precedingOperation != nil { operation.addDependency(precedingOperation!) }
          precedingOperation = operation
        }
        precedingOperation?.completionBlock = {
          MSLogDebug("command dispatch complete")
          self.success = findFirst(operations, {$0.finished && !$0.success}) == nil
          let errors = compressedMap(operations, {$0.error})
          if errors.count == 1 { self.error = errors.last }
          else if errors.count > 1 { self.error = NSError(domain: "MacroCommandExecution", code: -1, underlyingErrors: errors) }
          super.main()
        }
        macroCommand.queue.addOperations((operations as NSOrderedSet).array, waitUntilFinished: false)
      } else {
        success = true
        super.main()
      }
    } else {
      success = false
      super.main()
    }
  }

}

final class SystemCommandOperation: CommandOperation {

  /** main */
  override func main() {
    if let systemCommand = command as? SystemCommand {
      switch systemCommand.type {
        case .ProximitySensor:
          let device = UIDevice.currentDevice()
          device.proximityMonitoringEnabled = !device.proximityMonitoringEnabled
          success = true
        case .URLRequest:
          MSLogWarn("SystemCommandType.URLRequest not yet implemented…")
          success = true
        case .LaunchScreen:
          if let url = NSURL(string: "mainmenu") { success = UIApplication.sharedApplication().openURL(url) }
          else { success = false }
        case .OpenSettings:
          if let url = NSURL(string: "settings") { success = UIApplication.sharedApplication().openURL(url) }
          else { success = false }
        case .OpenEditor:
          if let url = NSURL(string: "editor") { success = UIApplication.sharedApplication().openURL(url) }
          else { success = false }
        default:
          success = true
      }
      super.main()
    } else {
      success = false
      super.main()
    }
  }

}
