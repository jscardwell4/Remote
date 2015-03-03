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
    safeSetValue(activity?.commentedUUID, forKey: "activity.uuid", inDictionary: dictionary)

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

  :param: data [NSObject:AnyObject]!
  */
  override func updateWithData(data: [NSObject:AnyObject]!) {
    super.updateWithData(data)
    if let activityData = data["activity"] as? [NSObject:AnyObject], let moc = managedObjectContext,
      let activity = Activity.importObjectFromData(activityData, context: moc) {
        self.activity = activity
    }
  }

  override var operation: CommandOperation {
    return ActivityCommandOperation(forCommand: self)
  }
}
