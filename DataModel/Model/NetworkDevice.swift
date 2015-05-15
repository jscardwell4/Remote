//
//  NetworkDevice.swift
//  Remote
//
//  Created by Jason Cardwell on 9/30/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(NetworkDevice)
public class NetworkDevice: EditableModelObject {

  @NSManaged public var uniqueIdentifier: String!
  @NSManaged public var componentDevices: Set<ComponentDevice>

  /**
  deviceExistsWithIdentifier:

  :param: identifier String

  :returns: Bool
  */
  public class func deviceExistsWithIdentifier(identifier: String,
                                        context: NSManagedObjectContext = DataManager.rootContext) -> Bool
  {
    return objectWithValue(identifier, forAttribute: "uniqueIdentifier", context: context) != nil
  }

  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)
    if let uniqueIdentifier = String(data["uniqueIdentifier"]) { self.uniqueIdentifier = uniqueIdentifier }
  }

  override public var description: String {
    return "\(super.description)\n\t" + "\n\t".join(
      "unique identifier = \(uniqueIdentifier)",
      "component devices = [" + ", ".join(map(componentDevices, {$0.name})) + "]"
    )
  }

  /**
  importObjectWithData:context:

  :param: data ObjectJSONValue
  :param: context NSManagedObjectContext

  :returns: NetworkDevice?
  */
  override public class func importObjectWithData(data: ObjectJSONValue, context: NSManagedObjectContext) -> NetworkDevice? {

    if self !== NetworkDevice.self {
      return typeCast(super.importObjectWithData(data, context: context), self)
    }

    var device: NetworkDevice?

    // Try getting the type of device to import
    if let type = String(data["type"]) {

      // Import with parameters derived from specified type
      switch type {
        case "itach":
          device = ITachDevice.importObjectWithData(data, context: context)
        case "isy":
          device = ISYDevice.importObjectWithData(data, context: context)
        default:
          break
      }
    }

    return device
  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["uniqueIdentifier"] = uniqueIdentifier.jsonValue
    return obj.jsonValue
  }

}
