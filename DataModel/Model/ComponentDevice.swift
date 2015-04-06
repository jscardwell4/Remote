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

  /**
  requiresUniqueNaming

  :returns: Bool
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

  :param: data ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)

    if let port = data["port"] as? NSNumber { self.port = port.shortValue }

    updateRelationshipFromData(data, forAttribute: "onCommand")
    updateRelationshipFromData(data, forAttribute: "offCommand")
    updateRelationshipFromData(data, forAttribute: "manufacturer")
    updateRelationshipFromData(data, forAttribute: "networkDevice")
    updateRelationshipFromData(data, forAttribute: "codeSet")

//    if let codeSetData = data["code-set"] as? [String:AnyObject] {
//      if let rawCodeSetIndex = codeSetData["index"] as? String, codeSetIndex = PathIndex(rawValue: rawCodeSetIndex) {
//        if let moc = managedObjectContext, codeSet = IRCodeSet.modelWithIndex(codeSetIndex, context: moc) {
//          self.codeSet = codeSet
//        }
//      }
//    }
  }

  override public var description: String {
    var description = "\(super.description)\n\t" + "\n\t".join(
      "always on = \(alwaysOn)",
      "input powers on = \(inputPowersOn)",
      "inputs = [" + ", ".join(map(inputs, {$0.name})) + "]",
      "port = \(port)",
      "power = \(power)",
      "manufacturer = \(manufacturer.index)",
      "code set = "
    )
    if let codeSet = self.codeSet {
      description += codeSet.index.rawValue
    } else { description += "nil" }
    return description
  }

  /**
  objectWithIndex:context:

  :param: index PathIndex
  :param: context NSManagedObjectContext

  :returns: ComponentDevice?
  */
  @objc(objectWithPathIndex:context:)
  override public class func objectWithIndex(index: PathIndex, context: NSManagedObjectContext) -> ComponentDevice? {
    return modelWithIndex(index, context: context)
  }

  override public var jsonValue: JSONValue {

    var dict = super.jsonValue.value as! JSONValue.ObjectValue

    appendValueForKey("port", toDictionary: &dict)
    appendValueForKey("alwaysOn", toDictionary: &dict)
    appendValueForKey("inputPowersOn", toDictionary: &dict)

    appendValueForKey("onCommand", toDictionary: &dict)
    appendValueForKey("offCommand", toDictionary: &dict)
    appendValueForKeyPath("manufacturer.uuid", toDictionary: &dict)
    appendValueForKeyPath("networkDevice.uuid", toDictionary: &dict)
    appendValueForKeyPath("codeSet.index", toDictionary: &dict)
    return .Object(dict)

  }

}

extension ComponentDevice: PathIndexedModel {
  public var pathIndex: PathIndex { return PathIndex(indexedName)! }
  public static func modelWithIndex(index: PathIndex, context: NSManagedObjectContext) -> ComponentDevice? {
    return objectWithValue(index.rawValue.pathDecoded, forAttribute: "name", context: context)
  }
}

