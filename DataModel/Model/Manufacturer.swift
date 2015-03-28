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

//  public typealias NestedType = IRCodeSet
//  public var subcategories: [NestedType] { get { return Array(codeSets) } set { codeSets = Set(newValue) } }
//  public func subcategoryWithIndex(index: PathModelIndex) -> IRCodeSet? { return findByIndex(codeSets, index) }

//  public typealias ItemType = IRCode
//  public var items: [ItemType] { get { return [] } set {} }
//  public func itemWithIndex(index: PathModelIndex) -> ItemType? { return nil }

  /**
  itemWithIndex:context:

  :param: index String
  :param: context NSManagedObjectContext

  :returns: T?
  */
//  public class func itemWithIndex<T:PathIndexedModel>(var index: PathModelIndex, context: NSManagedObjectContext) -> T? {
//    if index.isEmpty || index.count > 3 { return nil }
//
//    let manufacturerIndex = index.removeAtIndex(0)
//    if let manufacturer = rootItemWithIndex(PathModelIndex(manufacturerIndex), context: context) {
//      if index.isEmpty { return manufacturer as? T }
//      let codeSetIndex = index.removeAtIndex(0)
//      if let codeSet = manufacturer.subcategoryWithIndex("\(manufacturerIndex)/\(codeSetIndex)") {
//        if index.isEmpty { return codeSet as? T }
//        let codeIndex = index.removeLast()
//        return codeSet.itemWithIndex("\(manufacturerIndex)/\(codeSetIndex)/\(codeIndex)") as? T
//      }
//    }
//    return nil
//  }

  /**
  rootItemWithIndex:context:

  :param: index String
  :param: context NSManagedObjectContext

  :returns: Self?
  */
//  public class func rootItemWithIndex(index: PathModelIndex, context: NSManagedObjectContext) -> Self? {
//    return objectWithValue(index.rawValue, forAttribute: "name", context: context)
//  }

  /**
  updateWithData:

  :param: data [String AnyObject]
  */
  override public func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)
    updateRelationshipFromData(data, forKey: "codeSets", lookupKey: "code-sets")
    updateRelationshipFromData(data, forKey: "devices")
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

  :param: index PathModelIndex
  :param: context NSManagedObjectContext

  :returns: Image?
  */
  @objc(objectWithPathIndex:context:)
  public override class func objectWithIndex(index: PathModelIndex, context: NSManagedObjectContext) -> Manufacturer? {
    if let object = modelWithIndex(index, context: context) {
      MSLogDebug("located manufacter with name '\(object.name)'")
      return object
    } else { return nil }
  }

}

extension Manufacturer: PathIndexedModel {
  public var pathIndex: PathModelIndex { return "\(name)" }

  /**
  modelWithIndex:context:

  :param: index PathModelIndex
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  public static func modelWithIndex(index: PathModelIndex, context: NSManagedObjectContext) -> Self? {
    return index.count == 1 ? objectWithValue(index.rawValue, forAttribute: "name", context: context) : nil
  }
  
}

extension Manufacturer: NestingModelCollection {
  public var collections: [ModelCollection] { return sortedByName(codeSets) }
}

