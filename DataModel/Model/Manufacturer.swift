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
final class Manufacturer: IndexedEditableModelObject, NestingModelCategory, RootedEditableModel {

  @NSManaged var codeSets: Set<IRCodeSet>
  @NSManaged var devices: Set<ComponentDevice>

  typealias NestedType = IRCodeSet
  var subcategories: [NestedType] { get { return Array(codeSets) } set { codeSets = Set(newValue) } }
  func subcategoryWithIndex(index: ModelIndex) -> IRCodeSet? { return findByIndex(codeSets, index) }

  typealias ItemType = IRCode
  var items: [ItemType] { get { return [] } set {} }
  func itemWithIndex(index: ModelIndex) -> ItemType? { return nil }

  /**
  itemWithIndex:context:

  :param: index String
  :param: context NSManagedObjectContext

  :returns: T?
  */
  class func itemWithIndex<T:IndexedEditableModel>(var index: ModelIndex, context: NSManagedObjectContext) -> T? {
    if index.isEmpty || index.count > 3 { return nil }

    let manufacturerIndex = index.removeAtIndex(0)
    if let manufacturer = rootItemWithIndex(ModelIndex(manufacturerIndex), context: context) {
      if index.isEmpty { return manufacturer as? T }
      let codeSetIndex = index.removeAtIndex(0)
      if let codeSet = manufacturer.subcategoryWithIndex("\(manufacturerIndex)/\(codeSetIndex)") {
        if index.isEmpty { return codeSet as? T }
        let codeIndex = index.removeLast()
        return codeSet.itemWithIndex("\(manufacturerIndex)/\(codeSetIndex)/\(codeIndex)") as? T
      }
    }
    return nil
  }

  /**
  rootItemWithIndex:context:

  :param: index String
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  class func rootItemWithIndex(index: ModelIndex, context: NSManagedObjectContext) -> Self? {
    return objectWithValue(index.rawValue, forAttribute: "name", context: context)
  }

  /**
  updateWithData:

  :param: data [String AnyObject]
  */
  override func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)
    updateRelationshipFromData(data, forKey: "codeSets", lookupKey: "code-sets")
    updateRelationshipFromData(data, forKey: "devices")
  }

  /**
  rootCategoryNamed:context:

  :param: name String
  :param: context NSManagedObjectContext

  :returns: IndexedModelCategory?
  */
  class func rootCategoryNamed(name: String, context: NSManagedObjectContext) -> Manufacturer? {
    return objectWithValue(name, forAttribute: "name", context: context)
  }

  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    appendValueForKeyPath("devices.commentedUUID",   forKey: "devices", toDictionary: dictionary)
    appendValueForKeyPath("codeSets.JSONDictionary", forKey: "code-sets", toDictionary: dictionary)

    dictionary.compact()
    dictionary.compress()

    return dictionary
  }

}

