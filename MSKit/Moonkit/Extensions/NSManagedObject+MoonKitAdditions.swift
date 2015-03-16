//
//  NSManagedObject+MoonKitAdditions.swift
//  MSKit
//
//  Created by Jason Cardwell on 3/5/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import CoreData
import Swift

extension NSManagedObject {

  /**
  entityDescription:

  :param: context NSManagedObjectContext

  :returns: NSEntityDescription?
  */
  public class func entityDescription(context: NSManagedObjectContext) -> NSEntityDescription? {
    if let modelEntities = context.persistentStoreCoordinator?.managedObjectModel.entitiesByName as? [String:NSEntityDescription] {
      return modelEntities[NSStringFromClass(self)]
    } else { return nil }
  }


}