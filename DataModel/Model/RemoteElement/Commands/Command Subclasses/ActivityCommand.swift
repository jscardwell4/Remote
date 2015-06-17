//
//  ActivityCommand.swift
//  Remote
//
//  Created by Jason Cardwell on 3/2/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(ActivityCommand)
public final class ActivityCommand: Command {

  @NSManaged public var activity: Activity?

  override public var indicator: Bool { return true }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["activity.index"] = activity?.index.jsonValue
    return obj.jsonValue
  }

  override public var description: String {
    var result = super.description
    result += "\n\tactivity = \(String(activity?.index.rawValue))"
    return result
  }

  /**
  updateWithData:

  - parameter data: ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)
    updateRelationshipFromData(data, forAttribute: "activity")
  }

  override var operation: CommandOperation {
    return ActivityCommandOperation(command: self)
  }
}
