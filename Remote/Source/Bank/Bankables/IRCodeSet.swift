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
class IRCodeSet: BankCategoryObject, BankCategory {


  @NSManaged var devices: Set<ComponentDevice>
  @NSManaged var codes: Set<IRCode>
  @NSManaged var manufacturer: Manufacturer

  override var index: String { return "\(manufacturer.name)/\(name)" }
  var category: BankCategory? { return manufacturer }
  func setCategory(category: BankCategory?) {
    if let manufacturer = category as? Manufacturer { self.manufacturer = manufacturer }
  }
  var items: [BankCategoryItem] { return sortedByName(codes) }
  func setItems(items: [BankCategoryItem]) {
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


}
