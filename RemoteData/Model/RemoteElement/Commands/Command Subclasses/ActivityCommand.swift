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
class ActivityCommand: Command {

  @NSManaged var activity: Activity?

  /**
  JSONDictionary

  :returns: MSDictionary!
  */
  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    dictionary["class"] = "activity"
    appendValue(activity?.commentedUUID, forKey: "activity.uuid", toDictionary: dictionary)

    dictionary.compact()
    dictionary.compress()

    return dictionary
  }

  /** awakeFromInsert */
  override func awakeFromInsert() {
    super.awakeFromInsert()
    indicator = true
  }

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)
    updateRelationshipFromData(data, forKey: "activity")
  }

  override var operation: CommandOperation {
    return ActivityCommandOperation(command: self)
  }
}
