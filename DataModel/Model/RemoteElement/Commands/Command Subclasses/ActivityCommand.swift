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

  override public var jsonValue: JSONValue {
    var dict = super.jsonValue.value as! JSONValue.ObjectValue

    dict["class"] = .String("activity")
    dict["activity.uuid"] = JSONValue(activity?.uuid)
    return .Object(dict)
  }

  /** awakeFromInsert */
  override public func awakeFromInsert() {
    super.awakeFromInsert()
    indicator = true
  }

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override public func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)
    updateRelationshipFromData(data, forAttribute: "activity")
  }

  override var operation: CommandOperation {
    return ActivityCommandOperation(command: self)
  }
}
