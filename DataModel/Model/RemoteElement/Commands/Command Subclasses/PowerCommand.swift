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
  @NSManaged var primitiveState: NSNumber
  public var state: State {
    get {
      willAccessValueForKey("state")
      let state = primitiveState
      didAccessValueForKey("state")
      return state.boolValue ? .On : .Off
    }
    set {
      willChangeValueForKey("state")
      primitiveState = newValue == .On ? true : false
      didChangeValueForKey("state")
    }
  }

  @objc public enum State: Int { case On = 1, Off = 0 }

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override public func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)
    if let stateJSON = data["state"] as? String { state = State(JSONValue: stateJSON) }
    updateRelationshipFromData(data, forAttribute: "device")
  }

  /**
  JSONDictionary

  :returns: MSDictionary!
  */
  override public func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    dictionary["class"] = "power"
    dictionary["device.uuid"] = device.commentedUUID
    dictionary["state"] = state.JSONValue

    dictionary.compact()
    dictionary.compress()

    return dictionary
  }

  override var operation: CommandOperation {
    return (state == .On ? device.onCommand?.operation : device.offCommand?.operation)!
  }

}

extension PowerCommand.State: JSONValueConvertible {
  public var JSONValue: String { return rawValue == 1 ? "on" : "off" }
  public init(JSONValue: String) {
    switch JSONValue {
      case "on": self = .On
      default: self = .Off
    }
  }
}