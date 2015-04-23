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

  public var currentActivity: Activity? {
    get {
      willAccessValueForKey("currentActivity")
      let activity = primitiveValueForKey("currentActivity") as? Activity
      didAccessValueForKey("currentActivity")
      return activity
    }
    set {
      willChangeValueForKey("currentActivity")
      setPrimitiveValue(newValue, forKey: "currentActivity")
      didChangeValueForKey("currentActivity")
      if let remote = newValue?.remote { currentRemote = remote }
    }
  }

  public var currentRemote: Remote {
    get {
      willAccessValueForKey("currentRemote")
      let remote = primitiveValueForKey("currentRemote") as? Remote
      didAccessValueForKey("currentRemote")
      return remote ?? homeRemote
    }
    set {
      willChangeValueForKey("currentRemote")
      setPrimitiveValue(newValue, forKey: "currentRemote")
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
    obj["homeRemote.index"] = homeRemote.index.jsonValue
    obj["currentRemote.index"] = currentRemote.index.jsonValue
    obj["currentActivity.index"] = currentActivity?.index.jsonValue
    obj["topToolbar"] = topToolbar.jsonValue
    obj["activities"] = Optional(JSONValue(activities))
    return obj.jsonValue
  }

  override public var description: String {
    var description = super.description
    description += "\n\t".join(
      "home remote = \(homeRemote.index)",
      "top toolbar = {\(topToolbar.description.indentedBy(4))\n\t}",
      "activities = " + toString(activities.map {$0.name}),
      "current activity = \(toString(currentActivity?.name))"
    )
    return description
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
