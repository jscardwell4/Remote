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
  @NSManaged public var family: Int16
  @NSManaged public var flag: Int16
  @NSManaged public var device: ISYDevice
  @NSManaged public var members: NSSet

  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)
    if let flag = Int16(data["flag"]) { self.flag = flag }
    if let address = String(data["address"]) { self.address = address }
    if let family = Int16(data["family"]) { self.family = family }
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
