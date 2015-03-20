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
class Manufacturer: IndexedBankCategoryObject, Detailable {


  @NSManaged var codeSets: Set<IRCodeSet>
  @NSManaged var devices: Set<ComponentDevice>

  var indexedSubcategories: [IndexedBankCategory] { return Array(codeSets) }
  func setIndexedSubcategories(subcategories: [IndexedBankCategory]) {
    if let codeSets = subcategories as? [IRCodeSet] { self.codeSets = Set(codeSets) }
  }

  /**
  manufacturerWithName:context:

  :param: name String
  :param: context NSManagedObjectContext

  :returns: Manufacturer
  */
  class func manufacturerWithName(name: String, context: NSManagedObjectContext) -> Manufacturer {
    var manufacturer: Manufacturer!
    context.performBlockAndWait { () -> Void in
      manufacturer = self.findFirstByAttribute("name", withValue: name, context: context)
      if manufacturer == nil {
        manufacturer = self.createInContext(context)
        manufacturer.name = name
      }
    }
    return manufacturer
  }

  override func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)
    updateRelationshipFromData(data, forKey: "codeSets")
    updateRelationshipFromData(data, forKey: "devices")
  }

  class var rootCategory: BankRootCategory<BankCategory,BankModel> {
    let manufacturers = findAllSortedBy("name", ascending: true, context: DataManager.rootContext) as? [Manufacturer]
    return BankRootCategory(label: "Manufacturers",
                             icon: UIImage(named: "1022-factory")!,
                             items: manufacturers ?? [],
                             editableItems: true)
  }

  /**
  detailController

  :returns: UIViewController
  */
  func detailController() -> UIViewController { return ManufacturerDetailController(model: self) }

}

extension Manufacturer: MSJSONExport {

  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    safeSetValueForKeyPath("devices.commentedUUID",   forKey: "devices",  inDictionary: dictionary)

    dictionary.compact()
    dictionary.compress()

    return dictionary
  }

}
