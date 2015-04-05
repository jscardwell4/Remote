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
    updateRelationshipFromData(data, forAttribute: "members")
  }

  override public var jsonValue: JSONValue {
    var dict = super.jsonValue.value as! JSONValue.ObjectValue
    appendValueForKey("flag", toDictionary: &dict)
    appendValueForKey("address", toDictionary: &dict)
    appendValueForKey("family", toDictionary: &dict)
    appendValueForKeyPath("members.uuid", forKey: "members", toDictionary: &dict)
    appendValueForKeyPath("device.index",  forKey: "device", toDictionary: &dict)
    return .Object(dict)
  }

}
