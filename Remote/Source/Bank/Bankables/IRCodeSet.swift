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

  @NSManaged var codes: NSSet?
  @NSManaged var manufacturer: Manufacturer?
  override var items: [BankDisplayItemModel] { return (codes?.allObjects ?? []) as [IRCode] }
  override var thumbnailableItems: Bool { return IRCode.isThumbnailable() }
  override var previewableItems:   Bool { return IRCode.isPreviewable()   }
  override var detailableItems:    Bool { return IRCode.isDetailable()    }
  override var editableItems:      Bool { return IRCode.isEditable()      }

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
