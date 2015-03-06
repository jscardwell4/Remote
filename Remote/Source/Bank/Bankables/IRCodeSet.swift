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
class IRCodeSet: BankableModelCategory {

  override class func itemType() -> BankableModelObject.Type { return IRCode.self }

  @NSManaged var devices: NSSet?
  @NSManaged var codes: NSSet?
  @NSManaged var manufacturer: Manufacturer?

  override var items: [BankItemModel] {
    get { return sortedByName((codes?.allObjects as? [IRCode]) ?? []) }
    set { if let newCodes = newValue as? [IRCode] { codes = NSSet(array: newCodes) } }
  }
  override var previewableItems:   Bool { return false }
  override var editableItems:      Bool { return true }

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)

    if let codesData = data["codes"] as? NSArray, let moc = managedObjectContext {
      if codes == nil { codes = NSSet() }
      let mutableCodes = mutableSetValueForKey("codes")
      mutableCodes.addObjectsFromArray(IRCode.importObjectsFromData(codesData, context: moc))
    }

    if let manufacturerData = data["manufacturer"] as? [String:AnyObject], let moc = managedObjectContext,
      let manufacturer = Manufacturer.importObjectFromData(manufacturerData, context: moc) {
      self.manufacturer = manufacturer
    }

  }

}
