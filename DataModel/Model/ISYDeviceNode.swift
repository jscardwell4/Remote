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
    @NSManaged public var enabled: NSNumber
    @NSManaged public var flag: NSNumber
    @NSManaged public var pnode: String
    @NSManaged public var propertyFormatted: String
    @NSManaged public var propertyID: String
    @NSManaged public var propertyUOM: String
    @NSManaged public var propertyValue: NSNumber
    @NSManaged public var type: String
    @NSManaged public var device: ISYDevice
    @NSManaged public var groups: NSSet

  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)
    if let flag              = data.value["flag"]?.value               as? NSNumber { self.flag = flag }
    if let address           = data.value["address"]?.value            as? String   { self.address = address }
    if let type              = data.value["type"]?.value               as? String   { self.type = type }
    if let enabled           = data.value["enabled"]?.value            as? NSNumber { self.enabled = enabled }
    if let pnode             = data.value["pnode"]?.value              as? String   { self.pnode = pnode }
    if let propertyFormatted = data.value["property-formatted"]?.value as? String   { self.propertyFormatted = propertyFormatted }
    if let propertyID        = data.value["property-id"]?.value        as? String   { self.propertyID = propertyID }
    if let propertyUOM       = data.value["property-uom"]?.value       as? String   { self.propertyUOM = propertyUOM }
    if let propertyValue     = data.value["property-value"]?.value     as? NSNumber { self.propertyValue = propertyValue }
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
