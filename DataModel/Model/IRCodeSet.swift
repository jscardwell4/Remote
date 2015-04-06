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

  :param: data ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)

//    MSLogDebug("self.codes before updating codes = \(self.codes)")
    updateRelationshipFromData(data, forAttribute: "codes")
//    MSLogDebug("self.codes after updating codes = \(self.codes)")
    updateRelationshipFromData(data, forAttribute: "devices")
//    updateRelationshipFromData(data, forAttribute: "manufacturer")
  }

  override public var jsonValue: JSONValue {
    var dict = super.jsonValue.value as! JSONValue.ObjectValue

    appendValue(manufacturer.index.rawValue, forKey: "manufacturer.index", ifNotDefault: false, toDictionary: &dict)
    appendValueForKey("codes", toDictionary: &dict)
    appendValueForKeyPath("devices.uuid", forKey: "devices", toDictionary: &dict)
    
    return .Object(dict)
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