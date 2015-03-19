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
class ComponentDevice: NamedModelObject, BankModel, Detailable {

  @NSManaged var alwaysOn: Bool
  @NSManaged var inputPowersOn: Bool
  @NSManaged var user: Bool
  @NSManaged var inputs: Set<IRCode>
  @NSManaged var port: Int16
  @NSManaged var power: Bool
  @NSManaged var codeSet: IRCodeSet?
  @NSManaged var manufacturer: Manufacturer
  @NSManaged var networkDevice: NetworkDevice?
  @NSManaged var offCommand: SendIRCommand?
  @NSManaged var onCommand: SendIRCommand?
  @NSManaged var powerCommands: Set<PowerCommand>

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

    if let port = data["port"] as? NSNumber { self.port = port.shortValue }

    updateRelationshipFromData(data, forKey: "onCommand")
    updateRelationshipFromData(data, forKey: "offCommand")
    updateRelationshipFromData(data, forKey: "manufacturer")
    updateRelationshipFromData(data, forKey: "networkDevice")
    updateRelationshipFromData(data, forKey: "codeSet")
  }

  class var rootCategory: BankRootCategory<BankCategory,BankModel> {
    let devices = findAllSortedBy("name", ascending: true, context: DataManager.rootContext) as? [ComponentDevice]
    return BankRootCategory(label: "Component Devices",
                             icon: UIImage(named: "969-television")!,
                             items: devices ?? [],
                             editableItems: true)
  }

  /**
  detailController

  :returns: UIViewController
  */
  func detailController() -> UIViewController { return ComponentDeviceDetailController(model: self) }

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
