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

    obj["class"] = "activity".jsonValue
    obj["activity.uuid"] = activity?.uuid.jsonValue
    return obj.jsonValue
  }

  /**
  updateWithData:

  :param: data ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)
    updateRelationshipFromData(data, forAttribute: "activity")
  }

  override var operation: CommandOperation {
    return ActivityCommandOperation(command: self)
  }
}
