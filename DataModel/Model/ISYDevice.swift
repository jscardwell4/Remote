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
  initWithEntity:insertIntoManagedObjectContext:

  - parameter entity: NSEntityDescription
  - parameter context: NSManagedObjectContext?
  */
  override public init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
    super.init(entity: entity, insertIntoManagedObjectContext: context)
  }

  /**
  initWithContext:

  - parameter context: NSManagedObjectContext?
  */
  override public init(context: NSManagedObjectContext?) {
    super.init(context: context)
  }

  /**
  initWithData:context:

  - parameter data: ObjectJSONValue
  - parameter context: NSManagedObjectContext
  */
  required public init?(data: ObjectJSONValue, context: NSManagedObjectContext) {
    super.init(data: data, context: context)
  }

  // MARK: - DescProperty enumeration

  enum DescProperty: String {
    case BaseURL = "root.URLBase"
    case DeviceType = "root.device.deviceType"
    case Manufacturer = "root.device.manufacturer"
    case ManufacturerURL = "root.device.manufacturerURL"
    case ModelDescription = "root.device.modelDescription"
    case ModelName  = "root.device.modelName"
    case ModelNumber = "root.device.modelNumber"
    case FriendlyName = "root.device.friendlyName"
    case UniqueIdentifier = "root.device.UDN"

    var deviceProperty: String {
      switch self {
        case .BaseURL:          return "baseURL"
        case .DeviceType:       return "deviceType"
        case .Manufacturer:     return "manufacturer"
        case .ManufacturerURL:  return "manufacturerURL"
        case .ModelDescription: return "modelDescription"
        case .ModelName:        return "modelName"
        case .ModelNumber:      return "modelNumber"
        case .FriendlyName:     return "firendlyName"
        case .UniqueIdentifier: return "uniqueIdentifier"
      }
    }
  }

  /**
  initWithDesc:context:

  - parameter desc: MSDictionary
  - parameter context: NSManagedObjectContext
  */
  public init?(desc: MSDictionary, context: NSManagedObjectContext) {
    guard
      let uniqueIdentifier = desc.valueForKeyPath(DescProperty.UniqueIdentifier.rawValue) as? String
        where !NetworkDevice.objectExistsInContext(context, withValue: uniqueIdentifier, forAttribute: "uniqueIdentifier"),
      let baseURL = desc.valueForKeyPath(DescProperty.BaseURL.rawValue) as? String,
          deviceType = desc.valueForKeyPath(DescProperty.DeviceType.rawValue) as? String,
          manufacturer = desc.valueForKeyPath(DescProperty.Manufacturer.rawValue) as? String,
          manufacturerURL = desc.valueForKeyPath(DescProperty.ManufacturerURL.rawValue) as? String,
          modelDescription = desc.valueForKeyPath(DescProperty.ModelDescription.rawValue) as? String,
          modelName = desc.valueForKeyPath(DescProperty.ModelName.rawValue) as? String,
          modelNumber = desc.valueForKeyPath(DescProperty.ModelNumber.rawValue) as? String,
          friendlyName = desc.valueForKeyPath(DescProperty.FriendlyName.rawValue) as? String

      else { super.init(context: nil); return nil }

    super.init(context: context)

    self.uniqueIdentifier = uniqueIdentifier
    self.baseURL = baseURL
    self.deviceType = deviceType
    self.manufacturer = manufacturer
    self.manufacturerURL = manufacturerURL
    self.modelDescription = modelDescription
    self.modelName = modelName
    self.modelNumber = modelNumber
    self.friendlyName = friendlyName

    updateNodes()
  }

  /**
  deviceFromDesc:context:

  - parameter desc: NSData
  - parameter context: NSManagedObjectContext

  - returns: ISYDevice?
  */
  public class func deviceFromDesc(desc: NSData, context: NSManagedObjectContext) -> ISYDevice? {

    let parsedData = MSDictionary(byParsingXML: desc)
    MSLogDebug("parsedData = \(parsedData)")
    guard let id = parsedData.valueForKeyPath(DescProperty.UniqueIdentifier.rawValue) as? String else { return nil }

    if let device = objectWithValue(id, forAttribute: "uniqueIdentifier", context: context) {
      device.updateWithDesc(parsedData)
      return device
    } else { return ISYDevice(desc: parsedData, context: context) }
  }

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

  /**
  updateWithDesc:

  - parameter desc: MSDictionary
  */
  public func updateWithDesc(desc: MSDictionary) {
    guard
      let uniqueIdentifier = desc.valueForKeyPath(DescProperty.UniqueIdentifier.rawValue) as? String
      where uniqueIdentifier == self.uniqueIdentifier,
      let baseURL = desc.valueForKeyPath(DescProperty.BaseURL.rawValue) as? String,
          deviceType = desc.valueForKeyPath(DescProperty.DeviceType.rawValue) as? String,
          manufacturer = desc.valueForKeyPath(DescProperty.Manufacturer.rawValue) as? String,
          manufacturerURL = desc.valueForKeyPath(DescProperty.ManufacturerURL.rawValue) as? String,
          modelDescription = desc.valueForKeyPath(DescProperty.ModelDescription.rawValue) as? String,
          modelName = desc.valueForKeyPath(DescProperty.ModelName.rawValue) as? String,
          modelNumber = desc.valueForKeyPath(DescProperty.ModelNumber.rawValue) as? String,
          friendlyName = desc.valueForKeyPath(DescProperty.FriendlyName.rawValue) as? String

      else { return }

    self.baseURL = baseURL
    self.deviceType = deviceType
    self.manufacturer = manufacturer
    self.manufacturerURL = manufacturerURL
    self.modelDescription = modelDescription
    self.modelName = modelName
    self.modelNumber = modelNumber
    self.friendlyName = friendlyName

    updateNodes()
  }

  /** updateNodes */
  private func updateNodes() {

    guard let moc = managedObjectContext, url = NSURL(string: "\(baseURL)/rest/nodes") else { return }

    NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()).dataTaskWithURL(url) {
      (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in

      guard let data = data else { MSHandleError(error); return }

      let parsedData = MSDictionary(byParsingXML: data)

      MSLogDebug("parsedData = \(parsedData)")

      moc.performBlock { [unowned self] in

        let nodes = findFirstValueForKeyInContainer("node", parsedData) as! [MSDictionary]

        let nodeKeys = Set(["flag", "address", "type", "enabled", "pnode", "name"])
        let nodeModels = MSDictionary()

        for node in nodes {
          let property = node["property"] as! [String:String]
          let propertyID        = property["id"]!
          let propertyValue     = property["value"]!
          let propertyUOM       = property["uom"]!
          let propertyFormatted = property["formatted"]

          node.filter {key, _ in nodeKeys.contains(key as! String)}

          node["propertyID"]        = propertyID
          node["propertyValue"]     = Int(propertyValue)
          node["propertyUOM"]       = propertyUOM
          node["propertyFormatted"] = propertyFormatted
          node["device"]            = self
          node["enabled"]           = (node["enabled"] as! String) == "true"
          node["flag"]              = Int((node["flag"] as! String))

          let nodeModel = ISYDeviceNode(context: moc)
          nodeModel.setValuesForKeysWithDictionary((node as NSDictionary) as! [String:AnyObject])

          nodeModels[nodeModel.index.stringValue] = nodeModel

        }

        do { try moc.save() } catch { MSHandleError(error as? NSError) }

        let groups = findFirstValueForKeyInContainer("group", parsedData) as! [MSDictionary]
        let groupKeys = Set(["flag", "address", "name", "family", "members"])

        for group in groups {

          group.filter {key, _ in  groupKeys.contains(key as! String) }
          if let members = group["members"] as? [MSDictionary] {
            group["members"] = NSSet(array: compressedMap((members as NSArray).valueForKeyPath("index") as! [String], {nodeModels[$0]}))
          }

          group["device"] = self
          group["flag"] = Int(group["flag"] as! String)
          group["family"] = Int(group["family"] as! String)

          let groupModel = ISYDeviceGroup(context: moc)
          groupModel.setValuesForKeysWithDictionary((group as NSDictionary) as! [String:AnyObject])
          
        }
        
        do { try moc.save() } catch { logError(error) }
        
      }

    } .resume()

  }

  override public var summaryItems: OrderedDictionary<String, String> {
    var items = super.summaryItems
    items["URL"] = baseURL
    items["Friendly Name"] = friendlyName
    items["Device Type"] = deviceType
    items["Manufacturer Name"] = modelName
    items["Manufacturer Number"] = modelNumber
    items["Manufacturer Description"] = modelDescription
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
