//
//  PowerCommand.swift
//  Remote
//
//  Created by Jason Cardwell on 3/2/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

/**
  `PowerCommand` subclasses `Command` for the sole purpose of telling a `ComponentDevice` to be
  turned on or off.
*/
@objc(PowerCommand)
public final class PowerCommand: Command {

  @NSManaged public var device: ComponentDevice

  public typealias State = Bool
  @NSManaged public var state: State


  /**
  updateWithData:

  - parameter data: ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)
    if let stateJSON = String(data["state"]) { state = stateJSON ~= "on" ? true : false }
    updateRelationshipFromData(data, forAttribute: "device")
  }

  override public var description: String {
    var result = super.description
    result += "\n\tstate = " + (state ? "on" : "off")
    result += "\n\tdevice = \(device.index.rawValue)"
    return result
  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["device.index"] = device.index.jsonValue
    obj["state"] = (state ? "on" : "off").jsonValue
    return obj.jsonValue
  }

  override var operation: CommandOperation { return (state ? device.onCommand?.operation : device.offCommand?.operation)! } 
}
