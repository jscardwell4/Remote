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
class IRCodeSet: BankCategory {


  @NSManaged var devices: Set<ComponentDevice>?

  var codes: [IRCode] { get { return items as! [IRCode] } set { items = newValue } }
  var manufacturer: Manufacturer { get { return parentCategory as! Manufacturer } set { parentCategory = newValue } }

  override var editableItems: Bool { return true }

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)

//    if let codesData = data["codes"] as? NSArray, let moc = managedObjectContext {
//      if codes == nil { codes = NSSet() }
//      let mutableCodes = mutableSetValueForKey("codes")
//      mutableCodes.addObjectsFromArray(IRCode.importObjectsFromData(codesData, context: moc))
//    }

//    if let manufacturerData = data["manufacturer"] as? [String:AnyObject], let moc = managedObjectContext,
//      let manufacturer = Manufacturer.fetchOrImportObjectWithData(manufacturerData, context: moc) {
//      self.manufacturer = manufacturer
//    }

  }

}
