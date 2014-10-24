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

  @NSManaged var devices: NSSet?
  @NSManaged var primitiveCodes: NSSet?
  var codes: [IRCode] {
    get {
      willAccessValueForKey("codes")
      let codes = primitiveCodes?.allObjects as? [IRCode]
      didAccessValueForKey("codes")
      return codes ?? []
    }
    set {
      willChangeValueForKey("codes")
      primitiveCodes = NSSet(array: newValue)
      didChangeValueForKey("codes")
    }
  }
  @NSManaged var manufacturer: Manufacturer?

  override var items: [BankDisplayItemModel] {
    get { return sortedByName(codes) }
    set { if let newCodes = newValue as? [IRCode] { codes = newCodes } }
  }
  override var previewableItems:   Bool { return IRCode.isPreviewable()   }
  override var editableItems:      Bool { return IRCode.isEditable()      }

  /**
  updateWithData:

  :param: data [NSObject AnyObject]!
  */
  override func updateWithData(data: [NSObject : AnyObject]!) {
    super.updateWithData(data)

    if let codesData = data["codes"] as? NSArray {
      if primitiveCodes == nil { primitiveCodes = NSSet() }
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
