//
//  IndexedModelObject.swift
//  Remote
//
//  Created by Jason Cardwell on 4/16/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

public class IndexedModelObject: NamedModelObject, PathIndexedModel {

  public var pathIndex: PathIndex { return PathIndex(indexedName) }
  public override var index: ModelIndex { return ModelIndex(pathIndex) }

  public var indexedName: String { return name.urlUserEncoded }


  /**
  modelWithIndex:context:

  :param: index PathIndex
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  public class func modelWithIndex(index: PathIndex, context: NSManagedObjectContext) -> Self? {
    return objectWithValue(index.rawValue.pathDecoded, forAttribute: "name", context: context)
  }

  /**
  objectWithIndex:context:

  :param: index ModelIndex
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  public override class func objectWithIndex(index: ModelIndex, context: NSManagedObjectContext) -> Self? {
    if let pathIndex = index.pathIndex { return modelWithIndex(pathIndex, context: context) }
    else if let uuidIndex = index.uuidIndex { return objectWithUUID(uuidIndex.rawValue, context: context) }
    else { return nil }
  }

}