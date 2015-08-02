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
public class ISYDevice: NetworkDevice {

  @NSManaged public var baseURL: String
  @NSManaged public var deviceType: String
  @NSManaged public var friendlyName: String
  @NSManaged public var manufacturer: String
  @NSManaged public var manufacturerURL: String
  @NSManaged public var modelDescription: String
  @NSManaged public var modelName: String
  @NSManaged public var modelNumber: String
  @NSManaged public var groups: Set<ISYDeviceGroup>
  @NSManaged public var nodes: Set<ISYDeviceNode>

  /**
  updateWithData:

  - parameter data: ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)
    if let modelNumber       = String(data["modelNumber"]) { self.modelNumber = modelNumber }
    if let modelName         = String(data["modelName"]) { self.modelName = modelName }
    if let modelDescription  = String(data["modelDescription"]) { self.modelDescription = modelDescription }
    if let manufacturerURL   = String(data["manufacturerURL"]) { self.manufacturerURL = manufacturerURL }
    if let manufacturer      = String(data["manufacturer"]) { self.manufacturer = manufacturer }
    if let friendlyName      = String(data["friendlyName"]) { self.friendlyName = friendlyName }
    if let deviceType        = String(data["deviceType"]) { self.deviceType = deviceType }
    if let baseURL           = String(data["baseURL"]) { self.baseURL = baseURL }

    updateRelationshipFromData(data, forAttribute: "nodes")
    updateRelationshipFromData(data, forAttribute: "groups")
  }

  override public var summaryItems: OrderedDictionary<String, String> {
    var items = super.summaryItems
    items["URL"] = baseURL
    items["Friendly Name"] = friendlyName
    items["Device Type"] = deviceType
    items["Model Name"] = modelName
    items["Model Number"] = modelNumber
    items["Model Description"] = modelDescription
    items["Manufacturer"] = manufacturer
    items["Manufacturer URL"] = manufacturerURL

    return items
  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["modelNumber"] = modelNumber.jsonValue
    obj["modelName"] = modelName.jsonValue
    obj["modelDescription"] = modelDescription.jsonValue
    obj["manufacturerURL"] = manufacturerURL.jsonValue
    obj["manufacturer"] = manufacturer.jsonValue
    obj["friendlyName"] = friendlyName.jsonValue
    obj["deviceType"] = deviceType.jsonValue
    obj["baseURL"] = baseURL.jsonValue
    obj["nodes"] = JSONValue(nodes)
    obj["groups"] = JSONValue(groups)
    obj["type"] = "isy"
    return obj.jsonValue
  }
  
}
