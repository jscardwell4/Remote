//
//  ISYDeviceConnection.swift
//  Remote
//
//  Created by Jason Cardwell on 5/06/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit
import class DataModel.ISYDevice
import class DataModel.ISYDeviceNode
import class DataModel.ISYDeviceGroup
import class DataModel.DataManager

// TODO: Hardcoded user/passwords absolutely need to be replaced with proper implementation

final class ISYDeviceConnection: Equatable, Hashable {

  /** A class to stand in as delegate for `NSURLConnection` requests */
  @objc private class ConnectionDelegate: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate {

    var user: String?
    var password: String?
    var didFail: ((NSError) -> Void)?
    var didReceiveData: ((NSData) -> Void)?
    private var dataReceived = NSMutableData()

    /**
    connection:didFailWithError:

    :param: connection NSURLConnection
    :param: error NSError
    */
    func connection(connection: NSURLConnection, didFailWithError error: NSError) { didFail?(error) }

    /**
    connection:willSendRequestForAuthenticationChallenge:

    :param: connection NSURLConnection
    :param: challenge NSURLAuthenticationChallenge
    */
    func connection(connection: NSURLConnection,
      willSendRequestForAuthenticationChallenge challenge: NSURLAuthenticationChallenge)
    {
      if let user = self.user, password = self.password {
        let credential = NSURLCredential(user: user, password: password, persistence: .ForSession)
        challenge.sender.useCredential(credential, forAuthenticationChallenge: challenge)
      }
    }

    /**
    connection:didReceiveData:

    :param: connection NSURLConnection
    :param: data NSData
    */
    func connection(connection: NSURLConnection, didReceiveData data: NSData) { dataReceived.appendData(data) }

    /**
    connectionDidFinishLoading:

    :param: connection NSURLConnection
    */
    func connectionDidFinishLoading(connection: NSURLConnection) { didReceiveData?(dataReceived) }

  }

  /** Use by class method `connectionWithBaseURL` to keep connection from being deallocated */
  private static var URLConnection: NSURLConnection?

  /** Use by instances to keep connection from being deallocated */
  private var urlConnection: NSURLConnection?

  let device: ISYDevice
  var baseURL: NSURL! { return NSURL(string: device.baseURL)! }

  /**
  init:

  :param: d ISYDevice
  */
  init(device d: ISYDevice) { device = d; updateNodes() }

  /**
  connectionWithBaseURL:

  :param: baseURL NSURL
  :param: completion (ISYDeviceConnection?, NSError?) -> Void

  :returns: ISYDeviceConnection
  */
  class func connectionWithBaseURL(baseURL: NSURL, completion: (ISYDeviceConnection?, NSError?) -> Void) {

    // TODO: Set error objects on failure to create/fetch device

    // Create connection delegate to request the description of device at `baseURL`
    if let requestURL = NSURL(string: "desc", relativeToURL: baseURL) {

      let request = NSURLRequest(URL: requestURL)

      let completionWrapper: (ISYDeviceConnection?, NSError?) -> Void = {
        ISYDeviceConnection.URLConnection = nil
        completion($0, $1)
      }

      let delegate = ConnectionDelegate()
      delegate.user = "moondeer"
      delegate.password = "1bluebear"
      delegate.didFail = { completion(nil, $0) }

      delegate.didReceiveData = {

        let keys = [
          "URLBase",
          "deviceType",
          "manufacturer",
          "manufacturerURL",
          "modelDescription",
          "modelName",
          "modelNumber",
          "friendlyName",
          "UDN"
        ]
        let parsedData = MSDictionary(byParsingXML: $0)
        let attributes = MSDictionary(valuesForKeys: keys, usingBlock: {NSNull.collectionSafeValue(findFirstValueForKeyInContainer($0, parsedData))})
        attributes.compact()
          if attributes.count == keys.count {
            attributes.replaceKey("URLBase", withKey: "baseURL")
            attributes.replaceKey("UDN", withKey: "uniqueIdentifier")
            let services = findValuesForKeyInContainer("serviceType", parsedData) as! [String]
            if contains(services, "urn:udi-com:service:X_Insteon_Lighting_Service:1"),
              let uniqueIdentifier = attributes["uniqueIdentifier"] as? String
            {
              let moc = DataManager.rootContext
              moc.performBlockAndWait {
                let device = ISYDevice.objectWithValue(uniqueIdentifier,
                                          forAttribute: "uniqueIdentifier",
                                               context: moc) ?? ISYDevice(context: moc)
                device.setValuesForKeysWithDictionary(attributes as [NSObject : AnyObject])
                var error: NSError?
                let saved = moc.save(&error)
                if saved { completionWrapper(ISYDeviceConnection(device: device), error) }
                else { completionWrapper(nil, error) }
              }
          } else { completionWrapper(nil, nil) }
        } else { completionWrapper(nil, nil) }
      }

      ISYDeviceConnection.URLConnection = NSURLConnection(request: request, delegate: delegate)

    } else { completion(nil, nil) }

  }

  /** updateNodes */
  private func updateNodes() {

    if let url = NSURL(string: "rest/nodes", relativeToURL: baseURL) {
      let request = NSURLRequest(URL: url)
      let delegate = ConnectionDelegate()
      delegate.user = "moondeer"
      delegate.password = "1bluebear"
      delegate.didReceiveData = { [unowned self] in
        let parsedData = MSDictionary(byParsingXML: $0)
        let moc = DataManager.rootContext

        moc.performBlock { [unowned self] in

          let nodes = findFirstValueForKeyInContainer("node", parsedData) as! [MSDictionary]

          let nodeKeys = ["flag", "address", "type", "enabled", "pnode", "name"]
          let nodeModels = MSDictionary()

          for node in nodes {

            let propertyID        = node["property"]!["id"] as! String
            let propertyValue     = node["property"]!["value"] as! String
            let propertyUOM       = node["property"]!["uom"] as! String
            let propertyFormatted = node["property"]!["formatted"] as! String

            node.filter {key, _ in contains(nodeKeys, key as! String)}

            node["propertyID"]        = propertyID
            node["propertyValue"]     = propertyValue.toInt()
            node["propertyUOM"]       = propertyUOM
            node["propertyFormatted"] = propertyFormatted
            node["device"]            = self.device
            node["enabled"]           = (node["enabled"] as! String) == "true"
            node["flag"]              = (node["flag"] as! String).toInt()

            let nodeModel = ISYDeviceNode(context: moc)
            nodeModel.setValuesForKeysWithDictionary(node as [NSObject:AnyObject])

            nodeModels[nodeModel.address] = nodeModel

          }

          var error: NSError?
          var saved = moc.save(&error)
          assert(!MSHandleError(error))

          let groups = findFirstValueForKeyInContainer("group", parsedData) as! [MSDictionary]
          let groupKeys = ["flag", "address", "name", "family", "members"]

          for group in groups {

            group.filter {key, _ in  contains(groupKeys, key as! String) }
            if let members = group["members"]?["link"] as? [MSDictionary] {
              group["members"] = Set((members as NSArray).mapped {member, _ in nodeModels[member["link"]] } as! [String])
            }

            group["device"] = self.device
            group["flag"] = (group["flag"] as? String)?.toInt()
            group["family"] = (group["family"] as? String)?.toInt()

            let groupModel = ISYDeviceGroup(context: moc)
            groupModel.setValuesForKeysWithDictionary(group as [NSObject:AnyObject])

          }

          saved = moc.save(&error)
          assert(!MSHandleError(error))

        }

      }

      urlConnection = NSURLConnection(request: request, delegate: delegate)
    }
  }

  /**
  sendRestCommand:toNode:parameters:completion:

  :param: command String
  :param: nodeID String
  :param: parameters [String]
  :param: completion ((Bool, NSError?) -> Void)? = nil
  */
  func sendRestCommand(command: String,
                toNode nodeID: String,
            parameters: [String],
            completion: ((Bool, NSError?) -> Void)? = nil)
  {
    let text = "rest/nodes/\(nodeID)/cmd/\(command)" + (parameters.count > 0 ? "/" + "/".join(parameters) : "")
    if let url = NSURL(string: text, relativeToURL: baseURL) {
      let request = NSURLRequest(URL: url)
      let delegate = ConnectionDelegate()
      delegate.user = "moondeer"
      delegate.password = "1bluebear"
      delegate.didFail = { completion?(false, $0) }
      delegate.didReceiveData = {_ in completion?(true, nil) }
      urlConnection = NSURLConnection(request: request, delegate: delegate)
    }
    else { completion?(false, nil) }
  }

  /**
  Send a Soap command over the connection with optional completion callback

  :param: body String The command's content, this must not be empty
  :param: completion ((Bool, NSError?) -> Void)? = nil
  */
  func sendSoapCommandWithBody(body: String, completion: ((Bool, NSError?) -> Void)? = nil) {
    assert(!body.isEmpty)
    if let url = NSURL(string: "services", relativeToURL: baseURL) {

      let request = NSMutableURLRequest(URL: url)
      request.HTTPMethod = "POST"
      request.setValue("text/xml; charset=\"utf-8\"", forHTTPHeaderField: "Content-Type")
      request.setValue("\"urn:udi-com:service:X_Insteon_Lighting_Service:1#UDIService\"",
        forHTTPHeaderField: "SOAPACTION")
      request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)

      let delegate = ConnectionDelegate()
      delegate.user = "moondeer"
      delegate.password = "1bluebear"
      delegate.didFail = { completion?(false, $0) }
      delegate.didReceiveData = { _ in completion?(true, nil) }

      urlConnection = NSURLConnection(request: request, delegate: delegate)

    } else { completion?(false, nil) }

  }

  var hashValue: Int { return baseURL.hashValue }
}

/**
Equatable support

:param: lhs ISYDeviceConnection
:param: rhs ISYDeviceConnection

:returns: Bool
*/
func ==(lhs: ISYDeviceConnection, rhs: ISYDeviceConnection) -> Bool {
  return lhs === rhs || lhs.baseURL == rhs.baseURL
}