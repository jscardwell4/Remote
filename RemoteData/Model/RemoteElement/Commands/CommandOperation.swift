//
//  CommandOperation.swift
//  Remote
//
//  Created by Jason Cardwell on 3/19/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit

class CommandOperation: NSOperation {

  private(set) override var executing: Bool {
    get {
      return super.executing
    }
    set {
      self.executing = newValue
    }
  }
  private(set) override var finished: Bool {
    get {
      return super.finished
    }
    set {
      self.finished = newValue
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
      willChangeValueForKey("isFinished")
      finished = true
      didChangeValueForKey("isFinished")
    } else if let dependencies = dependencies as? [CommandOperation],
      unsuccessfulDependency = findFirst(dependencies, {$0.success == false})
    {
      //TODO: wrap error as underlying error
      error = unsuccessfulDependency.error
      willChangeValueForKey("isFinished")
      finished = true
      didChangeValueForKey("isFinished")
    } else {
      willChangeValueForKey("isExecuting")
      NSThread.detachNewThreadSelector("main", toTarget: self, withObject: nil)
      executing = true
      didChangeValueForKey("isExecuting")
    }
  }

  /** main */
  override func main() {
    willChangeValueForKey("isFinished")
    willChangeValueForKey("isExecuting")
    executing = false
    finished = true
    didChangeValueForKey("isExecuting")
    didChangeValueForKey("isFinished")
  }


}


class ActivityCommandOperation: CommandOperation {

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

class SwitchCommandOperation: CommandOperation {

  /** main */
  override func main() {

  }

}

class SendCommandOperation: CommandOperation {

  /** main */
  override func main() {

  }

}

class DelayCommandOperation: CommandOperation {

  /** main */
  override func main() {

  }

}

class MacroCommandOperation: CommandOperation {

  /** main */
  override func main() {

  }

}

class SystemCommandOperation: CommandOperation {

  /** main */
  override func main() {

  }

}
