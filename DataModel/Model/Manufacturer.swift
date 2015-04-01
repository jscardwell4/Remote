//
//  Manufacturer.swift
//  Remote
//
//  Created by Jason Cardwell on 9/30/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(Manufacturer)
final public class Manufacturer: EditableModelObject {

  @NSManaged public var codeSets: Set<IRCodeSet>
  @NSManaged public var devices: Set<ComponentDevice>

  /**
  requiresUniqueNaming

  :returns: Bool
  */
  public override class func requiresUniqueNaming() -> Bool { return true }

  /**
  updateWithData:

  :param: data [String AnyObject]
  */
  override public func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)

    updateRelationshipFromData(data, forAttribute: "codeSets")
    updateRelationshipFromData(data, forAttribute: "devices")
  }

  override public func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    appendValueForKeyPath("devices.commentedUUID",   forKey: "devices", toDictionary: dictionary)
    appendValueForKeyPath("codeSets.JSONDictionary", forKey: "code-sets", toDictionary: dictionary)

    dictionary.compact()
    dictionary.compress()

    return dictionary
  }

  /**
  objectWithIndex:context:

  :param: index PathIndex
  :param: context NSManagedObjectContext

  :returns: Image?
  */
  @objc(objectWithPathIndex:context:)
  public override class func objectWithIndex(index: PathIndex, context: NSManagedObjectContext) -> Manufacturer? {
    return modelWithIndex(index, context: context)
  }

  override public var description: String {
    return "\(super.description)\n\t" + "\n\t".join(
      "code sets = [" + ", ".join(map(codeSets, {$0.name})) + "]",
      "devices = [" + ", ".join(map(devices, {$0.name})) + "]"
    )
  }

}

extension Manufacturer: PathIndexedModel {
  public var pathIndex: PathIndex { return PathIndex(indexedName)! }

  /**
  modelWithIndex:context:

  :param: index PathIndex
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  public static func modelWithIndex(index: PathIndex, context: NSManagedObjectContext) -> Self? {
    return index.count == 1 ? objectWithValue(index.rawValue.pathDecoded, forAttribute: "name", context: context) : nil
  }
  
}

extension Manufacturer: NestingModelCollection {
  public var collections: [ModelCollection] { return sortedByName(codeSets) }
}

