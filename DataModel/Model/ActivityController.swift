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
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["homeRemote.uuid"] = homeRemote.uuid.jsonValue
    obj["currentRemote.uuid"] = currentRemote.uuid.jsonValue
    obj["currentActivity.uuid"] = currentActivity?.uuid.jsonValue
    obj["topToolbar"] = topToolbar.jsonValue
    obj["activities"] = Optional(JSONValue(activities))
    return obj.jsonValue
  }

  /**
  updateWithData:

  :param: data ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)

    updateRelationshipFromData(data, forAttribute: "homeRemote")
    updateRelationshipFromData(data, forAttribute: "topToolbar")
  }

}
