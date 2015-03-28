//
//  IRCodeSet.swift
//  Remote
//
//  Created by Jason Cardwell on 9/27/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(IRCodeSet)
final public class IRCodeSet: EditableModelObject {


  @NSManaged public var devices: Set<ComponentDevice>
  @NSManaged public var codes: Set<IRCode>
  @NSManaged public var manufacturer: Manufacturer

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override public func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)

    updateRelationshipFromData(data, forKey: "codes")
    updateRelationshipFromData(data, forKey: "devices")
    updateRelationshipFromData(data, forKey: "manufacturer")
  }

  /**
  JSONDictionary

  :returns: MSDictionary
  */
  override public func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    appendValue(manufacturer.index.rawValue, forKey: "manufacturer.index", ifNotDefault: false, toDictionary: dictionary)
    appendValueForKeyPath("codes.JSONDictionary", forKey: "codes", toDictionary: dictionary)
    appendValueForKeyPath("devices.commentedUUID", forKey: "devices", toDictionary: dictionary)

    dictionary.compact()
    dictionary.compress()
    
    return dictionary
  }

  /**
  objectWithIndex:context:

  :param: index PathModelIndex
  :param: context NSManagedObjectContext

  :returns: Image?
  */
  @objc(objectWithPathIndex:context:)
  public override class func objectWithIndex(index: PathModelIndex, context: NSManagedObjectContext) -> IRCodeSet? {
    if let object = modelWithIndex(index, context: context) {
      MSLogDebug("located code set with name '\(object.name)'")
      return object
    } else { return nil }
  }

  override public var description: String {
    return "\(super.description)\n\t" + "\n\t".join(
      "manufacturer = \(manufacturer.index)",
      "code count = \(codes.count)",
      "devices = [" + ", ".join(map(devices, {$0.name})) + "]"
    )
  }

}

extension IRCodeSet: PathIndexedModel {
  public var pathIndex: PathModelIndex { return manufacturer.pathIndex + "\(name)" }

  /**
  modelWithIndex:context:

  :param: index PathModelIndex
  :param: context NSManagedObjectContext

  :returns: IRCodeSet?
  */
  public static func modelWithIndex(index: PathModelIndex, context: NSManagedObjectContext) -> IRCodeSet? {
    if let manufacturerName = index.first, codeSetName = index.last where index.count == 2,
      let manufacturer = Manufacturer.modelWithIndex("\(manufacturerName)", context: context)
    {
      return findFirst(manufacturer.codeSets, {$0.name == codeSetName})
    } else { return nil }
  }

}

extension IRCodeSet: ModelCollection {
  public var items: [NamedModel] { return sortedByName(codes) }
}