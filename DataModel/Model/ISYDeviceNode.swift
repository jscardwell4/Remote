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
class ISYDeviceNode: NamedModelObject {

    @NSManaged var address: String
    @NSManaged var enabled: NSNumber
    @NSManaged var flag: NSNumber
    @NSManaged var pnode: String
    @NSManaged var propertyFormatted: String
    @NSManaged var propertyID: String
    @NSManaged var propertyUOM: String
    @NSManaged var propertyValue: NSNumber
    @NSManaged var type: String
    @NSManaged var device: ISYDevice
    @NSManaged var groups: NSSet

  override func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)
    if let flag              = data["flag"]               as? NSNumber { self.flag = flag }
    if let address           = data["address"]            as? String   { self.address = address }
    if let type              = data["type"]               as? String   { self.type = type }
    if let enabled           = data["enabled"]            as? NSNumber { self.enabled = enabled }
    if let pnode             = data["pnode"]              as? String   { self.pnode = pnode }
    if let propertyFormatted = data["property-formatted"] as? String   { self.propertyFormatted = propertyFormatted }
    if let propertyID        = data["property-id"]        as? String   { self.propertyID = propertyID }
    if let propertyUOM       = data["property-uom"]       as? String   { self.propertyUOM = propertyUOM }
    if let propertyValue     = data["property-value"]     as? NSNumber { self.propertyValue = propertyValue }
    updateRelationshipFromData(data, forKey: "groups")
  }

}

extension ISYDeviceNode: MSJSONExport {

  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()
    appendValueForKey("flag", toDictionary: dictionary)
    appendValueForKey("address", toDictionary: dictionary)
    appendValueForKey("type", toDictionary: dictionary)
    appendValueForKey("enabled", toDictionary: dictionary)
    appendValueForKey("pnode", toDictionary: dictionary)
    appendValueForKey("propertyFormatted", toDictionary: dictionary)
    appendValueForKey("propertyID", toDictionary: dictionary)
    appendValueForKey("propertyUOM", toDictionary: dictionary)
    appendValueForKey("propertyValue", toDictionary: dictionary)
    appendValueForKeyPath("groups.uuid", forKey: "groups", toDictionary: dictionary)
    dictionary.compact()
    dictionary.compress()
    return dictionary
  }

}
