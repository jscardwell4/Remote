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
// TODO: Replace use of deprecated NSURLSession

final class ISYDeviceConnection: Equatable, Hashable {

  /** A class to stand in as delegate for `NSURLSession` requests */
  @objc private class ConnectionDelegate: NSObject, NSURLSessionDelegate, NSURLSessionDataDelegate {

    var user: String?
    var password: String?
    var didFail: ((NSError?) -> Void)?
    var didReceiveData: ((NSData) -> Void)?
    private var dataReceived = NSMutableData()

    /**
    URLSession:didBecomeInvalidWithError:

    - parameter session: NSURLSession
    - parameter error: NSError?
    */
    @objc private func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
      MSLogDebug("")
      didFail?(error)
    }

    /**
    URLSession:didReceiveChallenge:completionHandler:

    - parameter session: NSURLSession
    - parameter challenge: NSURLAuthenticationChallenge
    - parameter completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void
    */
    @objc private func URLSession(session: NSURLSession,
              didReceiveChallenge challenge: NSURLAuthenticationChallenge,
                completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void)
    {
      MSLogDebug("")
      if let user = self.user, password = self.password {
        let credential = NSURLCredential(user: user, password: password, persistence: .ForSession)
        challenge.sender?.useCredential(credential, forAuthenticationChallenge: challenge)
      }
    }

    /**
    URLSession:dataTask:didReceiveData:

    - parameter session: NSURLSession
    - parameter dataTask: NSURLSessionDataTask
    - parameter data: NSData
    */
    @objc private func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
      MSLogDebug("")
      dataReceived.appendData(data)
    }

    /**
    URLSession:task:didCompleteWithError:

    - parameter session: NSURLSession
    - parameter task: NSURLSessionTask
    - parameter error: NSError?
    */
    @objc private func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
      MSLogDebug("")
      didReceiveData?(dataReceived)
    }


    /**
    URLSession:dataTask:didBecomeDownloadTask:

    - parameter session: NSURLSession
    - parameter dataTask: NSURLSessionDataTask
    - parameter downloadTask: NSURLSessionDownloadTask
    */
    @objc private func URLSession(session: NSURLSession,
                         dataTask: NSURLSessionDataTask,
            didBecomeDownloadTask downloadTask: NSURLSessionDownloadTask)
    {
      MSLogDebug("")
    }

    /**
    URLSession:dataTask:didBecomeStreamTask:

    - parameter session: NSURLSession
    - parameter dataTask: NSURLSessionDataTask
    - parameter streamTask: NSURLSessionStreamTask
    */
    @objc private func URLSession(session: NSURLSession,
                         dataTask: NSURLSessionDataTask,
              didBecomeStreamTask streamTask: NSURLSessionStreamTask)
    {
      MSLogDebug("")
    }

    /**
    URLSession:dataTask:didReceiveResponse:completionHandler:

    - parameter session: NSURLSession
    - parameter dataTask: NSURLSessionDataTask
    - parameter response: NSURLResponse
    - parameter completionHandler: (NSURLSessionResponseDisposition) -> Void
    */
    @objc private func URLSession(session: NSURLSession,
                         dataTask: NSURLSessionDataTask,
               didReceiveResponse response: NSURLResponse,
                completionHandler: (NSURLSessionResponseDisposition) -> Void)
    {
      MSLogDebug("")
    }

    /**
    URLSession:dataTask:willCacheResponse:completionHandler:

    - parameter session: NSURLSession
    - parameter dataTask: NSURLSessionDataTask
    - parameter proposedResponse: NSCachedURLResponse
    - parameter completionHandler: (NSCachedURLResponse?) -> Void
    */
    @objc private func URLSession(session: NSURLSession,
                         dataTask: NSURLSessionDataTask,
                willCacheResponse proposedResponse: NSCachedURLResponse,
                completionHandler: (NSCachedURLResponse?) -> Void)
    {
      MSLogDebug("")
    }

    /**
    URLSession:task:didReceiveChallenge:completionHandler:

    - parameter session: NSURLSession
    - parameter task: NSURLSessionTask
    - parameter challenge: NSURLAuthenticationChallenge
    - parameter completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void
    */
    @objc private func URLSession(session: NSURLSession,
                             task: NSURLSessionTask,
              didReceiveChallenge challenge: NSURLAuthenticationChallenge,
                completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void)
    {
      MSLogDebug("")
    }

    /**
    URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:

    - parameter session: NSURLSession
    - parameter task: NSURLSessionTask
    - parameter bytesSent: Int64
    - parameter totalBytesSent: Int64
    - parameter totalBytesExpectedToSend: Int64
    */
    @objc private func URLSession(session: NSURLSession,
                             task: NSURLSessionTask,
                  didSendBodyData bytesSent: Int64,
                   totalBytesSent: Int64,
         totalBytesExpectedToSend: Int64)
    {
      MSLogDebug("")
    }

    /**
    URLSession:task:needNewBodyStream:

    - parameter session: NSURLSession
    - parameter task: NSURLSessionTask
    - parameter completionHandler: (NSInputStream?) -> Void
    */
    @objc private func URLSession(session: NSURLSession,
                             task: NSURLSessionTask,
                needNewBodyStream completionHandler: (NSInputStream?) -> Void)
    {
      MSLogDebug("")
    }

    /**
    URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:

    - parameter session: NSURLSession
    - parameter task: NSURLSessionTask
    - parameter response: NSHTTPURLResponse
    - parameter request: NSURLRequest
    - parameter completionHandler: (NSURLRequest?) -> Void
    */
    @objc private func URLSession(session: NSURLSession,
                             task: NSURLSessionTask,
       willPerformHTTPRedirection response: NSHTTPURLResponse,
                       newRequest request: NSURLRequest,
                completionHandler: (NSURLRequest?) -> Void)
    {
      MSLogDebug("")
    }

    /**
    URLSessionDidFinishEventsForBackgroundURLSession:

    - parameter session: NSURLSession
    */
    @objc private func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
      MSLogDebug("")
    }
  }

  /** Use by class method `connectionWithBaseURL` to keep connection from being deallocated */
  private static var URLSession: NSURLSession?

  private static var deviceQueries: Set<NSURL> = []

  /** Use by instances to keep connection from being deallocated */
  private var urlSession: NSURLSession?

  let device: ISYDevice
  var baseURL: NSURL! { return NSURL(string: device.baseURL)! }

  /**
  init:

  - parameter d: ISYDevice
  */
  init(device d: ISYDevice) { device = d/*; updateNodes()*/ }

  /**
  connectionWithBaseURL:

  - parameter baseURL: NSURL
  - parameter completion: (ISYDeviceConnection?, NSError?) -> Void

  - returns: ISYDeviceConnection
  */
//  class func connectionWithBaseURL(baseURL: NSURL, completion: (ISYDeviceConnection?, NSError?) -> Void) {
//
//    // TODO: Set error objects on failure to create/fetch device
//
//    // TODO: Cache devices already queried?
//
////    defer { URLSession = nil }
//
//    // Create connection delegate to request the description of device at `baseURL`
//    guard let requestURL = NSURL(string: "desc", relativeToURL: baseURL) else { completion(nil, nil); return }
//
//    let request = NSURLRequest(URL: requestURL)
//
//    let delegate = ConnectionDelegate()
//    delegate.user = "moondeer"
//    delegate.password = "1bluebear"
//    delegate.didFail = { completion(nil, $0) }
//
//    delegate.didReceiveData = {
//
//      let keys = [
//        "URLBase",
//        "deviceType",
//        "manufacturer",
//        "manufacturerURL",
//        "modelDescription",
//        "modelName",
//        "modelNumber",
//        "friendlyName",
//        "UDN"
//      ]
//      
//      let parsedData = MSDictionary(byParsingXML: $0)
//      let attributes = MSDictionary(valuesForKeys: keys) {
//        NSNull.collectionSafeValue(findFirstValueForKeyInContainer($0, parsedData))
//      }
//      attributes.compact()
//
//      guard attributes.count == keys.count else { completion(nil, nil); return }
//      attributes.replaceKey("URLBase", withKey: "baseURL")
//      attributes.replaceKey("UDN", withKey: "uniqueIdentifier")
//
//      let services = findValuesForKeyInContainer("serviceType", parsedData) as! [String]
//
//      guard services.contains("urn:udi-com:service:X_Insteon_Lighting_Service:1"),
//        let uniqueIdentifier = attributes["uniqueIdentifier"] as? String else { completion(nil, nil); return }
//
//      let moc = DataManager.rootContext
//      moc.performBlockAndWait {
//        let device = ISYDevice.objectWithValue(uniqueIdentifier,
//                                  forAttribute: "uniqueIdentifier",
//                                       context: moc) ?? ISYDevice(context: moc)
//        device.setValuesForKeysWithDictionary((attributes as NSDictionary) as! [String:AnyObject])
//
//        do { try moc.save(); completion(ISYDeviceConnection(device: device), nil) }
//        catch { completion(nil, error as? NSError) }
//      }
//
//    }
//
//    // ???: Do we need to keep the data task alive as well?
//    URLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
//                              delegate: delegate,
//                              delegateQueue: nil)
//    let dataTask = URLSession?.dataTaskWithRequest(request)
//    dataTask?.resume()
//  }

  /** updateNodes */
//  private func updateNodes() {
//
//    guard let url = NSURL(string: "rest/nodes", relativeToURL: baseURL) else { return }
//
//    let request = NSURLRequest(URL: url)
//    let delegate = ConnectionDelegate()
//    delegate.user = "moondeer"
//    delegate.password = "1bluebear"
//    delegate.didReceiveData = { [unowned self] in
//      let parsedData = MSDictionary(byParsingXML: $0)
//      let moc = DataManager.rootContext
//
//      moc.performBlock { [unowned self] in
//
//        let nodes = findFirstValueForKeyInContainer("node", parsedData) as! [MSDictionary]
//
//        let nodeKeys = Set(["flag", "address", "type", "enabled", "pnode", "name"])
//        let nodeModels = MSDictionary()
//
//        for node in nodes {
//          let property = node["property"] as! [String:String]
//          let propertyID        = property["id"]!
//          let propertyValue     = property["value"]!
//          let propertyUOM       = property["uom"]!
//          let propertyFormatted = property["formatted"]
//
//          node.filter {key, _ in nodeKeys.contains(key as! String)}
//
//          node["propertyID"]        = propertyID
//          node["propertyValue"]     = Int(propertyValue)
//          node["propertyUOM"]       = propertyUOM
//          node["propertyFormatted"] = propertyFormatted
//          node["device"]            = self.device
//          node["enabled"]           = (node["enabled"] as! String) == "true"
//          node["flag"]              = Int((node["flag"] as! String))
//
//          let nodeModel = ISYDeviceNode(context: moc)
//          nodeModel.setValuesForKeysWithDictionary((node as NSDictionary) as! [String:AnyObject])
//
//          nodeModels[nodeModel.index.stringValue] = nodeModel
//
//        }
//
//        do { try moc.save() } catch { MSHandleError(error as? NSError) }
//
//        let groups = findFirstValueForKeyInContainer("group", parsedData) as! [MSDictionary]
//        let groupKeys = Set(["flag", "address", "name", "family", "members"])
//
//        for group in groups {
//
//          group.filter {key, _ in  groupKeys.contains(key as! String) }
//          if let members = group["members"] as? [MSDictionary] {
//            group["members"] = NSSet(array: compressedMap((members as NSArray).valueForKeyPath("index") as! [String], {nodeModels[$0]}))
//          }
//
//          group["device"] = self.device
//          group["flag"] = Int(group["flag"] as! String)
//          group["family"] = Int(group["family"] as! String)
//
//          let groupModel = ISYDeviceGroup(context: moc)
//          groupModel.setValuesForKeysWithDictionary((group as NSDictionary) as! [String:AnyObject])
//
//        }
//
//        do { try moc.save() } catch { MSHandleError(error as? NSError) }
//
//      }
//
//    }
//
//    urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
//                              delegate: delegate,
//                              delegateQueue: nil)
//    let dataTask = urlSession?.dataTaskWithRequest(request)
//    dataTask?.resume()
//  }

  /**
  sendRestCommand:toNode:parameters:completion:

  - parameter command: String
  - parameter nodeID: String
  - parameter parameters: [String]
  - parameter completion: ((Bool, NSError?) -> Void)? = nil
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
      urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                                delegate: delegate,
                                delegateQueue: nil)
      let dataTask = urlSession?.dataTaskWithRequest(request)
      dataTask?.resume()
    }
    else { completion?(false, nil) }
  }

  /**
  Send a Soap command over the connection with optional completion callback

  - parameter body: String The command's content, this must not be empty
  - parameter completion: ((Bool, NSError?) -> Void)? = nil
  */
  func sendSoapCommandWithBody(body: String, completion: ((Bool, NSError?) -> Void)? = nil) {
    assert(!body.isEmpty)
    if let url = NSURL(string: "services", relativeToURL: baseURL) {

      let request = NSMutableURLRequest(URL: url)
      request.HTTPMethod = "POST"
      request.setValue("text/xml; charset=\"utf-8\"", forHTTPHeaderField: "Content-Type")
      request.setValue("\"urn:udi-com:service:X_Insteon_Lighting_Service:1#UDIService\"", forHTTPHeaderField: "SOAPACTION")
      request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)

      let delegate = ConnectionDelegate()
      delegate.user = "moondeer"
      delegate.password = "1bluebear"
      delegate.didFail = { completion?(false, $0) }
      delegate.didReceiveData = { _ in completion?(true, nil) }

      urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                                delegate: delegate,
                                delegateQueue: nil)
      let dataTask = urlSession?.dataTaskWithRequest(request)
      dataTask?.resume()

    } else { completion?(false, nil) }

  }

  var hashValue: Int { return baseURL.hashValue }
}

/**
Equatable support

- parameter lhs: ISYDeviceConnection
- parameter rhs: ISYDeviceConnection

- returns: Bool
*/
func ==(lhs: ISYDeviceConnection, rhs: ISYDeviceConnection) -> Bool {
  return lhs === rhs || lhs.baseURL == rhs.baseURL
}