//
//  ISYDeviceNode.swift
//  Remote
//
//  Created by Jason Cardwell on 10/1/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(ISYDeviceNode)
public class ISYDeviceNode: NamedModelObject {

    @NSManaged public var address: String
    @NSManaged public var enabled: Bool
    @NSManaged public var flag: Int16
    @NSManaged public var pnode: String
    @NSManaged public var propertyFormatted: String
    @NSManaged public var propertyID: String
    @NSManaged public var propertyUOM: String
    @NSManaged public var propertyValue: Int16
    @NSManaged public var type: String
    @NSManaged public var device: ISYDevice
    @NSManaged public var groups: Set<ISYDeviceGroup>

  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)
    if let flag = Int16(data["flag"]) { self.flag = flag }
    if let address = String(data["address"]) { self.address = address }
    if let type = String(data["type"]) { self.type = type }
    if let enabled = Bool(data["enabled"]) { self.enabled = enabled }
    if let pnode = String(data["pnode"]) { self.pnode = pnode }
    if let propertyFormatted = String(data["property-formatted"]) { self.propertyFormatted = propertyFormatted }
    if let propertyID = String(data["property-id"]) { self.propertyID = propertyID }
    if let propertyUOM = String(data["property-uom"]) { self.propertyUOM = propertyUOM }
    if let propertyValue = Int16(data["property-value"]) { self.propertyValue = propertyValue }
    updateRelationshipFromData(data, forAttribute: "groups")
  }

  override public var jsonValue: JSONValue {
    var dict = super.jsonValue.value as! JSONValue.ObjectValue
    appendValueForKey("flag", toDictionary: &dict)
    appendValueForKey("address", toDictionary: &dict)
    appendValueForKey("type", toDictionary: &dict)
    appendValueForKey("enabled", toDictionary: &dict)
    appendValueForKey("pnode", toDictionary: &dict)
    appendValueForKey("propertyFormatted", toDictionary: &dict)
    appendValueForKey("propertyID", toDictionary: &dict)
    appendValueForKey("propertyUOM", toDictionary: &dict)
    appendValueForKey("propertyValue", toDictionary: &dict)
    appendValueForKeyPath("groups.uuid", forKey: "groups", toDictionary: &dict)
    return .Object(dict)
  }

}
