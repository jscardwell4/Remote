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
public class ISYDeviceGroup: IndexedModelObject {

  @NSManaged public var address: String
  @NSManaged public var family: Int16
  @NSManaged public var flag: Int16
  @NSManaged public var device: ISYDevice!
  @NSManaged public var members: Set<ISYDeviceNode>

  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)
    if let flag = Int16(data["flag"]) { self.flag = flag }
    if let address = String(data["address"]) { self.address = address }
    if let family = Int16(data["family"]) { self.family = family }
//    if let membersJSON = ArrayJSONValue(data["members"]) {
//
//    }
    updateRelationshipFromData(data, forAttribute: "members")
  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["flag"] = flag.jsonValue
    obj["address"] = address.jsonValue
    obj["family"] = family.jsonValue
    obj["device.index"] = device?.index.jsonValue
    obj["members.index"] = JSONValue(members.map({$0.index}))
    return obj.jsonValue
  }

}
