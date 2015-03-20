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
class IRCodeSet: IndexedBankCategoryObject, BankCategory {


  @NSManaged var devices: Set<ComponentDevice>
  @NSManaged var codes: Set<IRCode>
  @NSManaged var manufacturer: Manufacturer

  override var index: String { return "\(manufacturer.name)/\(name)" }
  var indexedCategory: IndexedBankCategory? { return manufacturer }
  func setIndexedCategory(category: IndexedBankCategory?) {
    if let manufacturer = category as? Manufacturer { self.manufacturer = manufacturer }
  }
  var indexedItems: [IndexedBankCategoryItem] { return sortedByName(codes) }
  func setIndexedItems(items: [IndexedBankCategoryItem]) {
    if let codes = items as? [IRCode] { self.codes = Set(codes) }
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

    safeSetValueForKeyPath("manufacturer.index", forKey: "manufacturer.index", inDictionary: dictionary)
    safeSetValueForKeyPath("codes.JSONDictionary", forKey: "codes", inDictionary: dictionary)
    safeSetValueForKeyPath("devices.commentedUUID", forKey: "devices", inDictionary: dictionary)

    dictionary.compact()
    dictionary.compress()
    
    return dictionary
  }


}
