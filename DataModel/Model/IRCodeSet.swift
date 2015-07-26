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
final public class IRCodeSet: EditableModelObject, CollectedModel {


  @NSManaged public var devices: Set<ComponentDevice>
  @NSManaged public var codes: Set<IRCode>

  public var manufacturer: Manufacturer {
    get {
      willAccessValueForKey("manufacturer")
      var manufacturer = primitiveValueForKey("manufacturer") as? Manufacturer
      didAccessValueForKey("manufacturer")
      if manufacturer == nil {
        manufacturer = Manufacturer.defaultCollectionInContext(managedObjectContext!)
        setPrimitiveValue(manufacturer, forKey: "manufacturer")
      }
      return manufacturer!
    }
    set {
      willChangeValueForKey("manufacturer")
      setPrimitiveValue(newValue, forKey: "manufacturer")
      didChangeValueForKey("manufacturer")
    }
  }

  public var collection: ModelCollection? { return manufacturer }

  /**
  updateWithData:

  - parameter data: ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)

    updateRelationshipFromData(data, forAttribute: "codes")
    updateRelationshipFromData(data, forAttribute: "devices")
  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["manufacturer.index"] = manufacturer.index.jsonValue
    obj["codes"] = JSONValue(codes)
    obj["devices.uuid"] = .Array(devices.map({$0.uuid.jsonValue}))
    return obj.jsonValue
  }

  override public var description: String {
    return "\(super.description)\n\t" + "\n\t".join(
      "manufacturer = \(manufacturer.index)",
      "code count = \(codes.count)",
      "devices = [" + ", ".join(devices.map({$0.name})) + "]"
    )
  }

  public override var pathIndex: PathIndex { return manufacturer.pathIndex + indexedName }

  /**
  modelWithIndex:context:

  - parameter index: PathIndex
  - parameter context: NSManagedObjectContext

  - returns: IRCodeSet?
  */
  public override static func modelWithIndex(var index: PathIndex, context: NSManagedObjectContext) -> IRCodeSet? {
    if index.count != 2 { return nil }
    else {
      let codeSetName = index.removeLast().pathDecoded
      return findFirst(Manufacturer.modelWithIndex(index, context: context)?.codeSets, {$0.name == codeSetName})
    }
  }

}

extension IRCodeSet: ModelCollection {
  public var items: [CollectedModel] { return codes.sortByName() }
}

extension IRCodeSet: DefaultingModelCollection {
  public static func defaultCollectionInContext(context: NSManagedObjectContext) -> IRCodeSet {
    let name = "Unspecified"
    if let codeSet = modelWithIndex(PathIndex("\(name)/\(name)"), context: context) {
      return codeSet
    } else {
      let codeSet = self.init(context: context)
      codeSet.name = name
      return codeSet
    }
  }
}
