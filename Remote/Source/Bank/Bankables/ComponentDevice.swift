//
//  ComponentDevice.swift
//  Remote
//
//  Created by Jason Cardwell on 9/30/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(ComponentDevice)
class ComponentDevice: BankableModelObject {

  @NSManaged var alwaysOn: Bool
  @NSManaged var inputPowersOn: Bool
  @NSManaged var primitiveInputs: NSSet
  var inputs: [IRCode] {
    get {
      willAccessValueForKey("inputs")
      let inputs = primitiveInputs.allObjects as? [IRCode]
      didAccessValueForKey("inputs")
      return inputs ?? []
    }
    set {
      willChangeValueForKey("inputs")
      primitiveInputs = NSSet(array: newValue)
      didChangeValueForKey("inputs")
    }
  }
  @NSManaged var port: Int16
  @NSManaged var power: Bool
  @NSManaged var primitiveCodeSet: IRCodeSet?
  var codeSet: IRCodeSet? {
    get {
      willAccessValueForKey("codeSet")
      let codeSet = primitiveCodeSet
      didAccessValueForKey("codeSet")
      return codeSet
    }
    set {
      willChangeValueForKey("codeSet")
      primitiveCodeSet = newValue
      didChangeValueForKey("codeSet")
      if let codeSet = primitiveCodeSet {
        if let manufacturer = primitiveManufacturer {
          if manufacturer != codeSet.manufacturer {
            self.manufacturer = nil
          }
        }
      }
    }
  }
//  @NSManaged var manufacturer: Manufacturer
  @NSManaged var primitiveManufacturer: Manufacturer?
  var manufacturer: Manufacturer? {
    get {
      willAccessValueForKey("manufacturer")
      let manufacturer = primitiveManufacturer
      didAccessValueForKey("manufacturer")
      return manufacturer
    }
    set {
      willChangeValueForKey("manufacturer")
      primitiveManufacturer = newValue ?? nil
      didChangeValueForKey("manufacturer")
      if let manufacturer = primitiveManufacturer {
        if let codeSet = primitiveCodeSet {
          if codeSet.manufacturer != manufacturer {
            self.codeSet = nil
          }
        }
      } else { primitiveCodeSet = nil }
    }
  }
  @NSManaged var networkDevice: NetworkDevice?
  @NSManaged var offCommand: SendIRCommand?
  @NSManaged var onCommand: SendIRCommand?
  @NSManaged var powerCommands: NSSet

  private var ignoreNextPowerCommand = false

  func ignorePowerCommand(completion: ((Bool, NSError?) -> Void)?) -> Bool {
    if ignoreNextPowerCommand {
      ignoreNextPowerCommand = false
      completion?(true, nil)
      return true
    } else { return false }
  }


  func powerOn(completion: ((Bool, NSError?) -> Void)?) {
    if !ignorePowerCommand(completion) {
      offCommand?.execute{[unowned self] (success: Bool, error: NSError?) in
        if success { self.power = true }
        completion?(success, error)
      }
    }
  }

  func powerOff(completion: ((Bool, NSError?) -> Void)?) {
    if !ignorePowerCommand(completion) {
      offCommand?.execute{[unowned self] (success: Bool, error: NSError?) in
        if success { self.power = false }
        completion?(success, error)
      }
    }
  }

  /**
  objectForKeyedSubscript:

  :param: name String!

  :returns: AnyObject!
  */
//  subscript(name: String) -> AnyObject! { return (codes.allObjects as [IRCode]).filter{$0.name == name}.first }

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)

    if let moc = managedObjectContext {

      port = (data["port"] as? NSNumber)?.shortValue ?? port
      if let onCommandData = data["on-command"] as? [String:AnyObject],
        let onCommand = SendIRCommand.fetchOrImportObjectWithData(onCommandData, context: moc) as? SendIRCommand {
          self.onCommand = onCommand
      }
      if let offCommandData = data["off-command"] as? [String:AnyObject],
        let offCommand = SendIRCommand.fetchOrImportObjectWithData(offCommandData, context: moc) as? SendIRCommand {
          self.offCommand = offCommand
      }
      if let manufacturerData = data["manufacturer"] as? [String:AnyObject],
        let manufacturer = Manufacturer.fetchOrImportObjectWithData(manufacturerData, context: moc) {
          self.manufacturer = manufacturer
      }
      if let networkDeviceData = data["network-device"] as? [String:AnyObject],
        let networkDevice = NetworkDevice.fetchOrImportObjectWithData(networkDeviceData, context: moc) {
          self.networkDevice = networkDevice
      }
      if let codeSetData = data["code-set"] as? [String:AnyObject],
        let codeSet = IRCodeSet.fetchOrImportObjectWithData(codeSetData, context: moc) {
          self.codeSet = codeSet
      }
    }
  }

  class var rootCategory: Bank.RootCategory {
    let devices = findAllSortedBy("name", ascending: true, context: DataManager.rootContext) as? [ComponentDevice]
    return Bank.RootCategory(label: "Component Devices",
                             icon: UIImage(named: "969-television")!,
                             items: devices ?? [],
                             editableItems: true)
  }

  /**
  detailController

  :returns: UIViewController
  */
  override func detailController() -> UIViewController { return ComponentDeviceDetailController(model: self) }

}

extension ComponentDevice: MSJSONExport {

  /**
  JSONDictionary

  :returns: MSDictionary!
  */
  override func JSONDictionary() -> MSDictionary {

    let dictionary = super.JSONDictionary()

    setIfNotDefault("port",          inDictionary: dictionary)
    setIfNotDefault("alwaysOn",      inDictionary: dictionary)
    setIfNotDefault("inputPowersOn", inDictionary: dictionary)

    safeSetValueForKeyPath("onCommand.JSONDictionary",    forKey: "on-command",          inDictionary: dictionary)
    safeSetValueForKeyPath("offCommand.JSONDictionary",   forKey: "off-command",         inDictionary: dictionary)
    safeSetValueForKeyPath("manufacturer.commentedUUID",  forKey: "manufacturer.uuid",   inDictionary: dictionary)
    safeSetValueForKeyPath("networkDevice.commentedUUID", forKey: "network-device.uuid", inDictionary: dictionary)
    safeSetValueForKeyPath("codeSet.commentedUUID",       forKey: "code-set",            inDictionary: dictionary)

    dictionary.compact()
    dictionary.compress()

    return dictionary

  }

}
