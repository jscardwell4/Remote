//
//  Activity.swift
//  Remote
//
//  Created by Jason Cardwell on 3/1/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MoonKit

@objc(Activity)
public final class Activity: NamedModelObject {

  @NSManaged public var launchMacro: MacroCommand?
  @NSManaged public var haltMacro: MacroCommand?
  @NSManaged public var remote: Remote?

  /**
  requiresUniqueNaming

  :returns: Bool
  */
  override public class func requiresUniqueNaming() -> Bool { return true }

  public var activityController: ActivityController? {
    return managedObjectContext == nil ? nil : ActivityController.sharedController(managedObjectContext!)
  }

  /**
  Launches the activity by invoking the launch macro and switching to the activity's remote.

  :param: completion Block to execute upon completing the task
  */
  public func launchActivity(completion: ((success: Bool, error: NSError?) -> Void)?) {
    if let controller = activityController where controller.currentActivity != self, let macro = launchMacro {
      macro.execute {[unowned self] (success, error) -> Void in
        if error == nil && success {
          controller.currentActivity = self
          completion?(success: controller.currentRemote == self.remote, error: nil)
        } else {
          completion?(success: false, error: error)
        }
      }
    }
  }

  /**
  Halts the activity by invoking the halt macro and switching to the home remote.

  :param: completion Block to execute upon completing the task
  */
  public func haltActivity(completion: ((success: Bool, error: NSError?) -> Void)?) {
    if let controller = activityController where controller.currentActivity == self, let macro = haltMacro {
      macro.execute {[unowned self] (success, error) -> Void in
        if error == nil && success {
          controller.currentActivity = nil
          completion?(success: controller.currentRemote == controller.homeRemote, error: nil)
        } else {
          completion?(success: false, error: error)
        }
      }
    }
  }

  /**
  If activity is active, this method calls `haltActivity:`, otherwise it calls `launchActvity:`.

  :param: completion The completion block to pass through to the halting or launching method
  */
  public func launchOrHaltActivity(completion: ((success: Bool, error: NSError?) -> Void)?) {
    if let controller = activityController {
      if let currentActivity = controller.currentActivity {
        if currentActivity == self {
          haltActivity(completion)
        } else {
          currentActivity.haltActivity {[unowned self] (success, error) -> Void in self.launchActivity(completion) }
        }
      } else {
        launchActivity(completion)
      }
    }
  }

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override public func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)

    updateRelationshipFromData(data, forKey: "remote")
    updateRelationshipFromData(data, forKey: "launchMacro")
    updateRelationshipFromData(data, forKey: "haltMacro")
  }


  /**
  JSONDictionary

  :returns: MSDictionary!
  */
  override public func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    appendValue(remote?.commentedUUID, forKey: "remote.uuid", toDictionary: dictionary)
    appendValue(launchMacro?.JSONDictionary(), forKey: "launch-macro", toDictionary: dictionary)
    appendValue(haltMacro?.JSONDictionary(), forKey: "halt-macro", toDictionary: dictionary)

    dictionary.compact()
    dictionary.compress()

    return dictionary
  }

  /**
  objectWithIndex:context:

  :param: index PathIndex
  :param: context NSManagedObjectContext

  :returns: Activity?
  */
  @objc(objectWithPathIndex:context:)
  override public class func objectWithIndex(index: PathIndex, context: NSManagedObjectContext) -> Activity? {
    return modelWithIndex(index, context: context)
  }

}

extension Activity: PathIndexedModel {
  public var pathIndex: PathIndex { return PathIndex(indexedName)! }
  public static func modelWithIndex(index: PathIndex, context: NSManagedObjectContext) -> Activity? {
    return objectWithValue(index.rawValue.pathDecoded, forAttribute: "name", context: context)
  }
}
