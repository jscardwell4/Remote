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

@objc(ActivityController)
public final class ActivityController: ModelObject {

  @NSManaged var primitiveCurrentActivity: Activity?
  public var currentActivity: Activity? {
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
  public var currentRemote: Remote {
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
  @NSManaged public var homeRemote: Remote
  @NSManaged public var topToolbar: ButtonGroup

  public var activities: [Activity] { return sortedByName(Activity.objectsInContext(managedObjectContext!) as? [Activity] ?? []) }

  /**
  sharedController:

  :param: context NSManagedObjectContext

  :returns: ActivityController
  */
  public class func sharedController(context: NSManagedObjectContext) -> ActivityController {
    return findFirstInContext(context) ?? ActivityController(context: context)
  }

  override public var jsonValue: JSONValue {
    var dict = super.jsonValue.value as! JSONValue.ObjectValue
    dict["homeRemote.uuid"] = .String(homeRemote.uuid)
    dict["currentRemote.uuid"] = .String(currentRemote.uuid)
    dict["currentActivity.uuid"] = .String(currentActivity?.uuid ?? "")
    dict["top-toolbar"] = topToolbar.jsonValue
    dict["activities"] = .Array(activities.map({$0.jsonValue}))

    return .Object(dict)
  }

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override public func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)

    updateRelationshipFromData(data, forAttribute: "homeRemote")
    updateRelationshipFromData(data, forAttribute: "topToolbar")
  }

}
