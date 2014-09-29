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
class IRCodeSet: NamedModelObject, BankableCategory {

  @NSManaged var codes: NSSet?
  @NSManaged var manufacturer: Manufacturer?

  var allItems: NSSet? { return codes }

  /**
  updateWithData:

  :param: data [NSObject AnyObject]!
  */
  override func updateWithData(data: [NSObject : AnyObject]!) {
    super.updateWithData(data)

    if let codesData = data["codes"] as? NSArray {
      if codes == nil { codes = NSSet() }
      let mutableCodes = mutableSetValueForKey("codes")
      if let importedCodes = IRCode.importObjectsFromData(codesData, context: managedObjectContext) {
        mutableCodes.addObjectsFromArray(importedCodes)
      }
    }

    if let manufacturerData = data["manufacturer"] as? NSDictionary {
      manufacturer = Manufacturer.importObjectFromData(manufacturerData, context: managedObjectContext) ?? manufacturer
    }

  }

}
