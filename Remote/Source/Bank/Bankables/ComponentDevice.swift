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
  @NSManaged var port: Int16
  @NSManaged var power: Bool
  @NSManaged var codeSet: IRCodeSet?
  @NSManaged var manufacturer: Manufacturer?
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

  :param: data [NSObject AnyObject]!
  */
  override func updateWithData(data: [NSObject : AnyObject]!) {
    super.updateWithData(data)

    port = (data["port"] as? NSNumber)?.shortValue ?? port
    onCommand = SendIRCommand.importObjectFromData(data["on-command"] as? NSDictionary,
                                           context: managedObjectContext!) ?? onCommand
    offCommand = SendIRCommand.importObjectFromData(data["off-command"] as? NSDictionary,
                                            context: managedObjectContext!) ?? offCommand
    manufacturer = Manufacturer.importObjectFromData(data["manufacturer"] as? NSDictionary,
                                             context: managedObjectContext!) ?? manufacturer
    networkDevice = NetworkDevice.importObjectFromData(data["network-device"] as? NSDictionary,
                                               context: managedObjectContext!) ?? networkDevice
    codeSet = IRCodeSet.importObjectFromData(data["code-set"] as? NSDictionary,
                                     context: managedObjectContext) ?? codeSet
  }

  class var rootCategory: Bank.RootCategory {
    let devices = findAllSortedBy("name", ascending: true) as? [ComponentDevice]
    return Bank.RootCategory(label: "Component Devices",
                             icon: UIImage(named: "969-television")!,
                             items: devices ?? [],
                             editableItems: true)
  }

  /**
  isEditable

  :returns: Bool
  */
  override class func isEditable() -> Bool { return true  }

  /**
  isPreviewable

  :returns: Bool
  */
  override class func isPreviewable() -> Bool { return false }

  /**
  detailController

  :returns: UIViewController
  */
  override func detailController() -> UIViewController {
    return ComponentDeviceDetailController(item: self)!
  }

}

extension ComponentDevice: MSJSONExport {

  /**
  JSONDictionary

  :returns: MSDictionary!
  */
  override func JSONDictionary() -> MSDictionary! {

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
