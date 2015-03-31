//
//  ISYDeviceGroup.swift
//  Remote
//
//  Created by Jason Cardwell on 10/1/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(ISYDeviceGroup)
public class ISYDeviceGroup: NamedModelObject {

  @NSManaged public var address: String
  @NSManaged public var family: NSNumber
  @NSManaged public var flag: NSNumber
  @NSManaged public var device: ISYDevice
  @NSManaged public var members: NSSet

  override public func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)
    if let flag = data["flag"] as? NSNumber { self.flag = flag }
    if let address = data["address"] as? String { self.address = address }
    if let family = data["family"] as? NSNumber { self.family = family }
    updateRelationshipFromData(data, forKey: "members")
  }

}

extension ISYDeviceGroup: JSONExport {

  override public func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()
    appendValueForKey("flag", toDictionary: dictionary)
    appendValueForKey("address", toDictionary: dictionary)
    appendValueForKey("family", toDictionary: dictionary)
    appendValueForKeyPath("members.uuid", forKey: "members.uuid", toDictionary: dictionary)
    appendValueForKeyPath("device.uuid",  forKey: "device.uuid", toDictionary: dictionary)
    dictionary.compact()
    dictionary.compress()
    return dictionary
  }

}
