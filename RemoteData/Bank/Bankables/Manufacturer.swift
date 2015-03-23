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
      manufacturer = self.objectWithValue(name, forAttribute: "name", context: context)
      if manufacturer == nil {
        manufacturer = self.createInContext(context)
        manufacturer.name = name
      }
    }
    return manufacturer
  }

  /**
  updateWithData:

  :param: data [String AnyObject]
  */
  override func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)
    updateRelationshipFromData(data, forKey: "codeSets", lookupKey: "code-sets")
    updateRelationshipFromData(data, forKey: "devices")
  }

  /**
  rootCategoryNamed:context:

  :param: name String
  :param: context NSManagedObjectContext

  :returns: IndexedBankCategory?
  */
  override class func rootCategoryNamed(name: String, context: NSManagedObjectContext) -> IndexedBankCategory? {
    return objectWithValue(name, forAttribute: "name", context: context)
  }

  class var rootCategory: BankRootCategory<BankCategory,BankModel> {
    let manufacturers = objectsInContext(DataManager.rootContext, sortBy: "name") as? [Manufacturer]
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

    appendValueForKeyPath("devices.commentedUUID",   forKey: "devices", toDictionary: dictionary)
    appendValueForKeyPath("codeSets.JSONDictionary", forKey: "code-sets", toDictionary: dictionary)

    dictionary.compact()
    dictionary.compress()

    return dictionary
  }

}
