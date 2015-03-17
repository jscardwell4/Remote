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

  var codes: Set<IRCode> {
    get {
      willAccessValueForKey("codes")
      let codes = primitiveValueForKey("codes") as! Set<IRCode>
      didAccessValueForKey("codes")
      return codes
    }
    set {
      willChangeValueForKey("codes")
      setPrimitiveValue(newValue, forKey: "codes")
      didChangeValueForKey("codes")
    }
  }

  var codeSets: Set<IRCodeSet> {
    get {
      willAccessValueForKey("codeSets")
      let codeSets = primitiveValueForKey("codeSets") as! Set<IRCodeSet>
      didAccessValueForKey("codeSets")
      return codeSets
    }
    set {
      willChangeValueForKey("codeSets")
      setPrimitiveValue(newValue, forKey: "codeSets")
      didChangeValueForKey("codeSets")
    }
  }

  var devices: Set<ComponentDevice> {
    get {
      willAccessValueForKey("devices")
      let devices = primitiveValueForKey("devices") as! Set<ComponentDevice>
      didAccessValueForKey("devices")
      return devices
    }
    set {
      willChangeValueForKey("devices")
      setPrimitiveValue(newValue, forKey: "devices")
      didChangeValueForKey("devices")
    }
  }

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

//    if let codeSetsData = data["codesets"] as? NSArray, let moc = managedObjectContext {
//      if codeSets == nil { codeSets = NSSet() }
//      let mutableCodeSets = mutableSetValueForKey("codeSets")
//      let importedCodeSets = IRCodeSet.importObjectsFromData(codeSetsData, context: moc)
//      mutableCodeSets.addObjectsFromArray(importedCodeSets)
//      if codes == nil { codes = NSSet() }
//      let mutableCodes = mutableSetValueForKey("codes")
//
//      if let c = importedCodeSets as? [IRCodeSet] {
//        let importedCodes = flattened(c.map({$0.codes?.allObjects ?? []}))
//        mutableCodes.addObjectsFromArray(importedCodes)
//      }
//    }
//
//    if let devicesData = data["devices"] as? NSArray, let moc = managedObjectContext {
//      if devices == nil { devices = NSSet() }
//      let mutableDevices = mutableSetValueForKey("devices")
//      let importedDevices = ComponentDevice.importObjectsFromData(devicesData, context: moc)
//      mutableDevices.addObjectsFromArray(importedDevices)
//    }
  }

  class var rootCategory: Bank.RootCategory {
    let manufacturers = findAllSortedBy("name", ascending: true, context: DataManager.rootContext) as? [Manufacturer]
    return Bank.RootCategory(label: "Manufacturers",
                             icon: UIImage(named: "1022-factory")!,
                             items: manufacturers ?? [],
                             editableItems: true)
  }

  /**
  detailController

  :returns: UIViewController
  */
  override func detailController() -> UIViewController { return ManufacturerDetailController(model: self) }

}

extension Manufacturer: MSJSONExport {

  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    safeSetValueForKeyPath("codeSets.JSONDictionary", forKey: "codesets", inDictionary: dictionary)
    safeSetValueForKeyPath("devices.commentedUUID",   forKey: "devices",  inDictionary: dictionary)

    dictionary.compact()
    dictionary.compress()

    return dictionary
  }

}
