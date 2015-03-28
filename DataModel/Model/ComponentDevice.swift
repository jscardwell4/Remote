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
public final class ComponentDevice: EditableModelObject {

  @NSManaged public var alwaysOn: Bool
  @NSManaged public var inputPowersOn: Bool
  @NSManaged public var inputs: Set<IRCode>
  @NSManaged public var port: Int16
  @NSManaged public var power: Bool
  @NSManaged public var codeSet: IRCodeSet?
  @NSManaged public var manufacturer: Manufacturer
  @NSManaged public var networkDevice: NetworkDevice?
  @NSManaged public var offCommand: SendIRCommand?
  @NSManaged public var onCommand: SendIRCommand?
  @NSManaged public var powerCommands: Set<PowerCommand>

  private var ignoreNextPowerCommand = false

  func ignorePowerCommand(completion: ((Bool, NSError?) -> Void)?) -> Bool {
    if ignoreNextPowerCommand {
      ignoreNextPowerCommand = false
      completion?(true, nil)
      return true
    } else { return false }
  }


  public func powerOn(completion: ((Bool, NSError?) -> Void)?) {
    if !ignorePowerCommand(completion) {
      offCommand?.execute{[unowned self] (success: Bool, error: NSError?) in
        if success { self.power = true }
        completion?(success, error)
      }
    }
  }

  public func powerOff(completion: ((Bool, NSError?) -> Void)?) {
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
  override public func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)

    if let port = data["port"] as? NSNumber { self.port = port.shortValue }

    updateRelationshipFromData(data, forKey: "onCommand")
    updateRelationshipFromData(data, forKey: "offCommand")
    updateRelationshipFromData(data, forKey: "manufacturer")
    updateRelationshipFromData(data, forKey: "networkDevice")
//    updateRelationshipFromData(data, forKey: "codeSet")
  }

}

extension ComponentDevice: MSJSONExport {

  /**
  JSONDictionary

  :returns: MSDictionary!
  */
  override public func JSONDictionary() -> MSDictionary {

    let dictionary = super.JSONDictionary()

    appendValueForKey("port", toDictionary: dictionary)
    appendValueForKey("alwaysOn", toDictionary: dictionary)
    appendValueForKey("inputPowersOn", toDictionary: dictionary)

    appendValueForKeyPath("onCommand.JSONDictionary", forKey: "on-command", toDictionary: dictionary)
    appendValueForKeyPath("offCommand.JSONDictionary", forKey: "off-command", toDictionary: dictionary)
    appendValueForKeyPath("manufacturer.commentedUUID", forKey: "manufacturer.uuid", toDictionary: dictionary)
    appendValueForKeyPath("networkDevice.commentedUUID", forKey: "network-device.uuid", toDictionary: dictionary)
    appendValueForKeyPath("codeSet.commentedUUID", forKey: "code-set", toDictionary: dictionary)

    dictionary.compact()
    dictionary.compress()

    return dictionary

  }

}
