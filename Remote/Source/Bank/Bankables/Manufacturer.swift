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
class Manufacturer: BankableModelObject {

  @NSManaged var codes: NSSet?
  @NSManaged var codeSets: NSSet?
  @NSManaged var devices: NSSet?

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

  override func updateWithData(data: [NSObject : AnyObject]!) {
    super.updateWithData(data)

    if let codeSetsData = data["codesets"] as? NSArray {
      if codeSets == nil { codeSets = NSSet() }
      let mutableCodeSets = mutableSetValueForKey("codeSets")
      if let importedCodeSets = IRCodeSet.importObjectsFromData(codeSetsData, context: managedObjectContext) {
        mutableCodeSets.addObjectsFromArray(importedCodeSets)
        if codes == nil { codes = NSSet() }
        let mutableCodes = mutableSetValueForKey("codes")

        if let c = importedCodeSets as? [IRCodeSet] {
          let importedCodes = flattened(c.map({$0.codes?.allObjects ?? []}))
          mutableCodes.addObjectsFromArray(importedCodes)
        }
      }
    }

    if let devicesData = data["devices"] as? NSArray {
      if devices == nil { devices = NSSet() }
      let mutableDevices = mutableSetValueForKey("devices")
      if let importedDevices = ComponentDevice.importObjectsFromData(devicesData, context: managedObjectContext) {
        mutableDevices.addObjectsFromArray(importedDevices)
      }
    }
  }

  class var rootCategory: Bank.RootCategory {
    let manufacturers = findAllSortedBy("name", ascending: true) as? [Manufacturer]
    return Bank.RootCategory(label: "Manufacturers",
                             icon: UIImage(named: "1022-factory")!,
                             items: manufacturers ?? [],
                             editableItems: true)
  }

  override class func isEditable()      -> Bool { return true  }
  override class func isPreviewable()   -> Bool { return false }

  override func detailController() -> UIViewController {
    return ManufacturerDetailController(item: self)!
  }

}

extension Manufacturer: MSJSONExport {

  override func JSONDictionary() -> MSDictionary! {
    let dictionary = super.JSONDictionary()

    safeSetValueForKeyPath("codeSets.JSONDictionary", forKey: "codesets", inDictionary: dictionary)
    safeSetValueForKeyPath("devices.commentedUUID",   forKey: "devices",  inDictionary: dictionary)

    dictionary.compact()
    dictionary.compress()

    return dictionary
  }

}
