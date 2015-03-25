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
class NetworkDevice: EditableModelObject {

  @NSManaged var uniqueIdentifier: String!
  @NSManaged var componentDevices: NSSet?

  /**
  deviceExistsWithIdentifier:

  :param: identifier String

  :returns: Bool
  */
  class func deviceExistsWithIdentifier(identifier: String) -> Bool {
    return objectWithValue(identifier, forAttribute: "uniqueIdentifier", context: DataManager.rootContext) != nil
  }

  override func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)
    if let uniqueIdentifier = data["unique-identifier"] as? String { self.uniqueIdentifier = uniqueIdentifier }
  }

  /**
  importObjectWithData:context:

  :param: data [String:AnyObject]
  :param: context NSManagedObjectContext

  :returns: NetworkDevice?
  */
//  override class func importObjectWithData(data: [String:AnyObject], context: NSManagedObjectContext) -> NetworkDevice? {
//
//    var device: NetworkDevice?
//
//    // Try getting the type of device to import
//    if let type = data["type"] as? String {
//
//      var entityName: String?
//      var deviceType: NetworkDevice.Type = NetworkDevice.self
//
//      // Import with parameters derived from specified type
//      switch type {
//        case "itach":
//          device = importObjectForEntity("ITachDevice", forType: ITachDevice.self, fromData: data, context: context) as? NetworkDevice
//        case "isy":
//          device = importObjectForEntity("ISYDevice", forType: ISYDevice.self, fromData: data, context: context) as? NetworkDevice
//        default:
//          break
//      }
//    }
//
//    return device
//  }

}

extension NetworkDevice: MSJSONExport {

  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()
      appendValue(uniqueIdentifier, forKey: "unique-identifier", toDictionary: dictionary)
      dictionary.compact()
      dictionary.compress()
      return dictionary
  }

}