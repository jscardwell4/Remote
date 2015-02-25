//
//  ISYDeviceGroup.swift
//  Remote
//
//  Created by Jason Cardwell on 10/1/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData

@objc(ISYDeviceGroup)
class ISYDeviceGroup: NamedModelObject {

  @NSManaged var address: String
  @NSManaged var family: NSNumber
  @NSManaged var flag: NSNumber
  @NSManaged var device: ISYDevice
  @NSManaged var members: NSSet

  override func updateWithData(data: [NSObject : AnyObject]!) {
    super.updateWithData(data)
    flag =    data["flag"]    as? NSNumber ?? flag
    address = data["address"] as?   String ?? address
    family =  data["family"]  as? NSNumber ?? family
    if let members = ISYDeviceNode.importObjectsFromData(data["members"], context: managedObjectContext) as? [ISYDeviceNode] {
      mutableSetValueForKey("members").addObjectsFromArray(members)
    }
  }

}

extension ISYDeviceGroup: MSJSONExport {

  override func JSONDictionary() -> MSDictionary! {
    let dictionary = super.JSONDictionary()
    safeSetValue(flag,    forKey: "flag",    inDictionary: dictionary)
    safeSetValue(address, forKey: "address", inDictionary: dictionary)
    safeSetValue(family,  forKey: "family",  inDictionary: dictionary)
    safeSetValueForKeyPath("members.uuid", forKey: "members.uuid", inDictionary: dictionary)
    safeSetValueForKeyPath("device.uuid",  forKey: "device.uuid",  inDictionary: dictionary)
    dictionary.compact()
    dictionary.compress()
    return dictionary
  }

}
