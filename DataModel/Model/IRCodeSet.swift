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
final class IRCodeSet: IndexedEditableModelObject, ModelCategory, ModelCategoryItem {


  @NSManaged var devices: Set<ComponentDevice>
  @NSManaged var codes: Set<IRCode>
  @NSManaged var manufacturer: Manufacturer

  typealias ItemType = IRCode
  var items: [ItemType] { get { return Array(codes) } set { codes = Set(newValue) } }
  func itemWithIndex(index: ModelIndex) -> ItemType? { return findByIndex(codes, index) }

  typealias CategoryType = Manufacturer
  var category: CategoryType? { get { return manufacturer } set { if newValue != nil { manufacturer = newValue! } } }

  override var index: ModelIndex { return manufacturer.index + "\(name)" }

  /**
  modelWithIndex:context:

  :param: index ModelIndex
  :param: context NSManagedObjectContext

  :returns: IRCodeSet?
  */
  override class func modelWithIndex(index: ModelIndex, context: NSManagedObjectContext) -> IRCodeSet? {
    return Manufacturer.itemWithIndex(index, context: context)
  }


  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)

    updateRelationshipFromData(data, forKey: "codes")
    updateRelationshipFromData(data, forKey: "devices")
    updateRelationshipFromData(data, forKey: "manufacturer")
  }

  /**
  JSONDictionary

  :returns: MSDictionary
  */
  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    appendValue(manufacturer.index.description, forKey: "manufacturer.index", ifNotDefault: false, toDictionary: dictionary)
    appendValueForKeyPath("codes.JSONDictionary", forKey: "codes", toDictionary: dictionary)
    appendValueForKeyPath("devices.commentedUUID", forKey: "devices", toDictionary: dictionary)

    dictionary.compact()
    dictionary.compress()
    
    return dictionary
  }


}
