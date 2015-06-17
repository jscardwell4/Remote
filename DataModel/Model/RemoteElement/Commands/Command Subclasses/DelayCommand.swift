//
//  DelayCommand.swift
//  Remote
//
//  Created by Jason Cardwell on 3/2/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

/**
  `DelayCommand` subclasses `Command` to provide a delay, usually in a chain of other commands.
*/
@objc(DelayCommand)
public final class DelayCommand: Command {

  @NSManaged public var duration: Float

  /**
  updateWithData:

  - parameter data: ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)
    if let duration = Float(data["duration"]) { self.duration = duration }
  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["duration"] = duration.jsonValue
    return obj.jsonValue
  }

  override public var description: String {
    var result = super.description
    result += "\n\tduration = \(duration)"
    return result
  }

  override var operation: CommandOperation { return DelayCommandOperation(command: self) }
  
}
