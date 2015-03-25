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
class ISYDeviceGroup: NamedModelObject {

  @NSManaged var address: String
  @NSManaged var family: NSNumber
  @NSManaged var flag: NSNumber
  @NSManaged var device: ISYDevice
  @NSManaged var members: NSSet

  override func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)
    if let flag = data["flag"] as? NSNumber { self.flag = flag }
    if let address = data["address"] as? String { self.address = address }
    if let family = data["family"] as? NSNumber { self.family = family }
    updateRelationshipFromData(data, forKey: "members")
  }

}

extension ISYDeviceGroup: MSJSONExport {

  override func JSONDictionary() -> MSDictionary {
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
