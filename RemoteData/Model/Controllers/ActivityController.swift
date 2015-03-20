//
//  ActivityController.swift
//  Remote
//
//  Created by Jason Cardwell on 3/1/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MoonKit

class ActivityController: ModelObject {

  @NSManaged var primitiveCurrentActivity: Activity?
  var currentActivity: Activity? {
    get {
      willAccessValueForKey("currentActivity")
      let activity = primitiveCurrentActivity
      didAccessValueForKey("currentActivity")
      return activity
    }
    set {
      willChangeValueForKey("currentActivity")
      primitiveCurrentActivity = newValue
      didChangeValueForKey("currentActivity")
      if let remote = newValue?.remote { currentRemote = remote }
    }
  }

  @NSManaged var primitiveCurrentRemote: Remote?
  var currentRemote: Remote {
    get {
      willAccessValueForKey("currentRemote")
      let remote = primitiveCurrentRemote
      didAccessValueForKey("currentRemote")
      return remote ?? homeRemote
    }
    set {
      willChangeValueForKey("currentRemote")
      primitiveCurrentRemote = newValue
      didChangeValueForKey("currentRemote")
    }
  }
  @NSManaged var homeRemote: Remote
  @NSManaged var topToolbar: ButtonGroup

  var activities: [Activity] { return sortedByName(Activity.findAllInContext(managedObjectContext!) as? [Activity] ?? []) }

  /**
  sharedController:

  :param: context NSManagedObjectContext

  :returns: ActivityController
  */
  class func sharedController(context: NSManagedObjectContext) -> ActivityController {
    return findFirstInContext(context) ?? ActivityController(context: context)
  }

  /**
  JSONDictionary

  :returns: MSDictionary
  */
  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    safeSetValue(homeRemote.commentedUUID, forKey: "homeRemote.uuid", inDictionary: dictionary)
    safeSetValue(currentRemote.commentedUUID, forKey: "currentRemote.uuid", inDictionary: dictionary)
    safeSetValue(currentActivity?.commentedUUID, forKey: "currentActivity.uuid", inDictionary: dictionary)
    safeSetValue(topToolbar.JSONDictionary(), forKey: "top-toolbar", inDictionary: dictionary)
    safeSetValue(activities, forKey: "activities", inDictionary: dictionary)

    dictionary.compact()
    dictionary.compress()

    return dictionary
  }

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)

    updateRelationshipFromData(data, forKey: "homeRemote")
    updateRelationshipFromData(data, forKey: "topToolbar")
  }

}
