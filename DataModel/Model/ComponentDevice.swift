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
  @NSManaged public var networkDevice: NetworkDevice?
  @NSManaged public var offCommand: ITachIRCommand?
  @NSManaged public var onCommand: ITachIRCommand?
  @NSManaged public var powerCommands: Set<PowerCommand>

  public var manufacturer: Manufacturer {
    get {
      willAccessValueForKey("manufacturer")
      var manufacturer = primitiveValueForKey("manufacturer") as? Manufacturer
      didAccessValueForKey("manufacturer")
      if manufacturer == nil {
        manufacturer = Manufacturer.defaultCollectionInContext(managedObjectContext!)
        setPrimitiveValue(manufacturer, forKey: "manufacturer")
      }
      return manufacturer!
    }
    set {
      willChangeValueForKey("manufacturer")
      setPrimitiveValue(newValue, forKey: "manufacturer")
      didChangeValueForKey("manufacturer")
    }
  }

  private var ignoreNextPowerCommand = false

  /**
  requiresUniqueNaming

  - returns: Bool
  */
  public override class func requiresUniqueNaming() -> Bool { return true }

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
  updateWithData:

  - parameter data: ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)

    if let port = Int16(data["port"]) { self.port = port }
    if let alwaysOn = Bool(data["alwaysOn"]) { self.alwaysOn = alwaysOn }
    if let inputPowersOn = Bool(data["inputPowersOn"]) { self.inputPowersOn = inputPowersOn }
    updateRelationshipFromData(data, forAttribute: "onCommand")
    updateRelationshipFromData(data, forAttribute: "offCommand")
    updateRelationshipFromData(data, forAttribute: "manufacturer")
    updateRelationshipFromData(data, forAttribute: "networkDevice")

    if let codeSet: IRCodeSet = relatedObjectWithData(data, forAttribute: "codeSet") {
      self.codeSet = codeSet
    }
  }

  override public var description: String {
    let description = "\(super.description)\n\t" + "\n\t".join(
      "always on = \(alwaysOn)",
      "input powers on = \(inputPowersOn)",
      "inputs = [" + ", ".join(inputs.map({$0.name})) + "]",
      "port = \(port)",
      "power = \(power)",
      "manufacturer = \(manufacturer.index)",
      "code set = \(String(codeSet?.index))"
    )
    return description
  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["port"] = port.jsonValue
    obj["alwaysOn"] = alwaysOn.jsonValue
    obj["inputPowersOn"] = inputPowersOn.jsonValue
    obj["onCommand"] = onCommand?.jsonValue
    obj["offCommand"] = offCommand?.jsonValue
    obj["manufacturer.index"] = manufacturer.index.jsonValue
    obj["newtorkDevice.index"] = networkDevice?.index.jsonValue
    obj["codeSet.index"] = codeSet?.index.jsonValue
    return obj.jsonValue

  }

}

