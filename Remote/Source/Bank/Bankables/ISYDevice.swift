//
//  ISYDevice.swift
//  Remote
//
//  Created by Jason Cardwell on 10/1/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

/**

SOAP:

To turn off a light:

POST /services HTTP/1.1
HOST: 192.168.1.9
Content-Length: 239
Authorization: Basic bW9vbmRlZXI6MWJsdWViZWFy
Content-Type: text/xml; charset="utf-8"
SOAPACTION:"urn:udi-com:service:X_Insteon_Lighting_Service:1#UDIService"

<s:Envelope>
<s:Body>
<u:UDIService xmlns:u="urn:udi-com:service:X_Insteon_Lighting_Service:1">
<control>DOF</control>
<action></action>
<flag>65531</flag>
<node>1B 6E B2 1</node>
</u:UDIService>
</s:Body>
</s:Envelope>

To rename a node:

POST /services HTTP/1.1
HOST: 192.168.1.9
Content-Length: 239
Authorization: Basic bW9vbmRlZXI6MWJsdWViZWFy
Content-Type: text/xml; charset="utf-8"
SOAPACTION:"urn:udi-com:service:X_Insteon_Lighting_Service:1#UDIService"

<s:Envelope>
<s:Body>
<u:RenameNode xmlns:u="urn:udi-com:service:X_Insteon_Lighting_Service:1">
<id>1B 6E B2 1</id>
<name>Front Door Table Lamp</name>
</u:RenameNode>
</s:Body>
</s:Envelope>


REST:

To turn on a light:

http://192.168.1.9/rest/nodes/1B%206E%20B2%201/cmd/DON



*/
@objc(ISYDevice)
class ISYDevice: NetworkDevice {

    @NSManaged var baseURL: String
    @NSManaged var deviceType: String
    @NSManaged var friendlyName: String
    @NSManaged var manufacturer: String
    @NSManaged var manufacturerURL: String
    @NSManaged var modelDescription: String
    @NSManaged var modelName: String
    @NSManaged var modelNumber: String
    @NSManaged var groups: NSSet
    @NSManaged var nodes: NSSet

  override func updateWithData(data: [NSObject : AnyObject]!) {
    super.updateWithData(data)
    modelNumber       = data["model-number"]      as? NSString ?? modelNumber
    modelName         = data["model-name"]        as? NSString ?? modelName
    modelDescription  = data["model-description"] as? NSString ?? modelDescription
    manufacturerURL   = data["manufacturer-url"]  as? NSString ?? manufacturerURL
    manufacturer      = data["manufacturer"]      as? NSString ?? manufacturer
    friendlyName      = data["friendly-name"]     as? NSString ?? friendlyName
    deviceType        = data["device-type"]       as? NSString ?? deviceType
    baseURL           = data["base-url"]          as? NSString ?? baseURL

    if let nodes = ISYDeviceNode.importObjectsFromData(data["nodes"], context: managedObjectContext) as? [ISYDeviceNode] {
      mutableSetValueForKey("nodes").addObjectsFromArray(nodes)
    }

    if let groups = ISYDeviceGroup.importObjectsFromData(data["groups"], context: managedObjectContext) as? [ISYDeviceGroup] {
      mutableSetValueForKey("groups").addObjectsFromArray(groups)
    }
  }

//  override class func detailControllerType() -> BankDetailController.Protocol { return ISYDeviceDetailController.self }

}

extension ISYDevice: MSJSONExport {

  override func JSONDictionary() -> MSDictionary! {
    let dictionary = super.JSONDictionary()
      safeSetValue(modelNumber,      forKey: "model-number",      inDictionary: dictionary)
      safeSetValue(modelName,        forKey: "model-name",        inDictionary: dictionary)
      safeSetValue(modelDescription, forKey: "model-description", inDictionary: dictionary)
      safeSetValue(manufacturerURL,  forKey: "manufacturer-url",  inDictionary: dictionary)
      safeSetValue(manufacturer,     forKey: "manufacturer",      inDictionary: dictionary)
      safeSetValue(friendlyName,     forKey: "friendly-name",     inDictionary: dictionary)
      safeSetValue(deviceType,       forKey: "device-type",       inDictionary: dictionary)
      safeSetValue(baseURL,          forKey: "base-url",          inDictionary: dictionary)
      safeSetValueForKeyPath("nodes.JSONDictionary",  forKey: "nodes",  inDictionary: dictionary)
      safeSetValueForKeyPath("groups.JSONDictionary", forKey: "groups", inDictionary: dictionary)
      dictionary.compact()
      dictionary.compress()
      return dictionary
  }

}
