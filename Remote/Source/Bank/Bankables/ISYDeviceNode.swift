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

  override func updateWithData(data: [NSObject : AnyObject]!) {
    super.updateWithData(data)
    flag              = data["flag"]               as? NSNumber ?? flag
    address           = data["address"]            as? String   ?? address
    type              = data["type"]               as? String   ?? type
    enabled           = data["enabled"]            as? NSNumber ?? enabled
    pnode             = data["pnode"]              as? String   ?? pnode
    propertyFormatted = data["property-formatted"] as? String   ?? propertyFormatted
    propertyID        = data["property-id"]        as? String   ?? propertyID
    propertyUOM       = data["property-uom"]       as? String   ?? propertyUOM
    propertyValue     = data["property-value"]     as? NSNumber ?? propertyValue
    if let groups = ISYDeviceGroup.importObjectsFromData(data["groups"], context: managedObjectContext) as? [ISYDeviceGroup] {
      mutableSetValueForKey("groups").addObjectsFromArray(groups)
    }
  }

}

extension ISYDeviceNode: MSJSONExport {

  override func JSONDictionary() -> MSDictionary! {
    let dictionary = super.JSONDictionary()
    safeSetValue(flag,              forKey: "flag",               inDictionary: dictionary)
    safeSetValue(address,           forKey: "address",            inDictionary: dictionary)
    safeSetValue(type,              forKey: "type",               inDictionary: dictionary)
    safeSetValue(enabled,           forKey: "enabled",            inDictionary: dictionary)
    safeSetValue(pnode,             forKey: "pnode",              inDictionary: dictionary)
    safeSetValue(propertyFormatted, forKey: "property-formatted", inDictionary: dictionary)
    safeSetValue(propertyID,        forKey: "property-id",        inDictionary: dictionary)
    safeSetValue(propertyUOM,       forKey: "property-uom",       inDictionary: dictionary)
    safeSetValue(propertyValue,     forKey: "property-value",     inDictionary: dictionary)
    safeSetValueForKeyPath("groups.uuid", forKey: "groups", inDictionary: dictionary)
    dictionary.compact()
    dictionary.compress()
    return dictionary
  }

}
