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

    updateRelationshipFromData(data, forAttribute: "codes")
    updateRelationshipFromData(data, forAttribute: "devices")
    updateRelationshipFromData(data, forAttribute: "manufacturer")
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

  :param: index PathIndex
  :param: context NSManagedObjectContext

  :returns: Image?
  */
  @objc(objectWithPathIndex:context:)
  public override class func objectWithIndex(index: PathIndex, context: NSManagedObjectContext) -> IRCodeSet? {
    return modelWithIndex(index, context: context)
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
  public var pathIndex: PathIndex { return manufacturer.pathIndex + indexedName }

  /**
  modelWithIndex:context:

  :param: index PathIndex
  :param: context NSManagedObjectContext

  :returns: IRCodeSet?
  */
  public static func modelWithIndex(index: PathIndex, context: NSManagedObjectContext) -> IRCodeSet? {
    if index.count != 2 { return nil }
    else {
      let codeSetName = index.removeLast().pathDecoded
      return findFirst(Manufacturer.modelWithIndex(index, context: context)?.codeSets, {$0.name == codeSetName})
    }
  }

}

extension IRCodeSet: ModelCollection {
  public var items: [NamedModel] { return sortedByName(codes) }
}