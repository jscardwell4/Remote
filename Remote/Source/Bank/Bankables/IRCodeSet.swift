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

  override var path: String { return "\(manufacturer.name)/\(name)" }
  override var category: BankCategory? {
    get { return manufacturer }
    set { if let m = newValue as? Manufacturer { manufacturer = m } }
  }
  override var subcategories: [BankCategory] { get { return [] } set {} }
  override var items: [BankCategoryItem] {
    get { return sortedByName(codes) }
    set { if let c = newValue as? [IRCode] { codes = Set(c) } }
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
