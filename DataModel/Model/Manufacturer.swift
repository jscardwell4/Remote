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

  - returns: Bool
  */
  public override class func requiresUniqueNaming() -> Bool { return true }

  /**
  updateWithData:

  - parameter data: ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)

    updateRelationshipFromData(data, forAttribute: "codeSets")
    updateRelationshipFromData(data, forAttribute: "devices")
  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["devices.index"] = .Array(devices.map({$0.index.jsonValue}))
    obj["codeSets"] = JSONValue(codeSets)
    return obj.jsonValue
  }

  override public var description: String {
    return "\(super.description)\n\t" + "\n\t".join(
      "code sets = [" + ", ".join(codeSets.map({$0.name})) + "]",
      "devices = [" + ", ".join(devices.map({$0.name})) + "]"
    )
  }
  
}

extension Manufacturer: NestingModelCollection {
  public var collections: [ModelCollection] { return codeSets.sortByName() }
}

extension Manufacturer: ModelCollection, DefaultingModelCollection {
  public static func defaultCollectionInContext(context: NSManagedObjectContext) -> Manufacturer {
    let name = "Unspecified"
    if let manufacturer = modelWithIndex(PathIndex(name), context: context) {
      return manufacturer
    } else {
      let manufacturer = self.init(context: context)
      manufacturer.name = name
      return manufacturer
    }
  }
}

