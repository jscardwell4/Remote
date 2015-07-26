//
//  ISYConnectionManager.swift
//  Remote
//
//  Created by Jason Cardwell on 5/06/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit
import class DataModel.HTTPCommand
import class DataModel.ISYDevice
import class DataModel.DataManager

final class ISYConnectionManager {

  typealias Callback = ConnectionManager.Callback
  typealias Error = ConnectionManager.Error

  static let MulticastAddress = "239.255.255.250"
  static let MulticastPort: UInt16 = 1900

  /** Previously discovered devices. */
  static private(set) var networkDevices = Set(ISYDevice.objectsInContext(DataManager.rootContext) as! [ISYDevice])

  /** Currently connected devices. */
  static var connections = Set<ISYDeviceConnection>()

  /** Uuids  from processed beacons. */
  static private var beaconsReceived = Set<String>()

  /** Multicast group connection */
  static let multicastConnection = MulticastConnection(address:ISYConnectionManager.MulticastAddress,
                                                       port: ISYConnectionManager.MulticastPort,
                                                       callback: ISYConnectionManager.messageReceived)

  /** Whether socket is open to receive multicast group broadcast messages */
  static private(set) var detectingNetworkDevices = false

  /**
  Join multicast group and listen for beacons broadcast by iTach devices.

  - parameter context: NSManagedObjectContext = DataManager.rootContext
  */
  class func startDetectingNetworkDevices(context: NSManagedObjectContext = DataManager.rootContext) {
    detectingNetworkDevices = true
    do {
      try multicastConnection.listen()
    } catch _ {
    }
  }

  /** Cease listening for beacon broadcasts and release resources. */
  class func stopDetectingNetworkDevices() { detectingNetworkDevices = false; multicastConnection.stopListening() }

  /**
  Sends an IR command to the device identified by the specified `uuid`.

  - parameter command: HTTPCommand The command to execute
  - parameter completion: Callback? = nil The block to execute upon task completion
  */
  class func sendCommand(command: HTTPCommand, completion: Callback? = nil) {
    // ???: Not used because `ConnectionManager` sends the `HTTPCommand`?
  }

  /** Suspend active connections */
  class func suspend() { if detectingNetworkDevices { multicastConnection.stopListening() } }

  /** Resume previously active connections */
  class func resume() { if detectingNetworkDevices { do {
        try multicastConnection.listen()
      } catch _ {
      } } }

  /**
  Processes messages received through `NetworkDeviceConnection` objects.

  - parameter message: String Contents of the message received by the device connection
  */
  class func messageReceived(message: String) {

    MSLogVerbose("message received over multicast connection:\n\(message.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding))\n")

    let entryStrings = message.matchingSubstringsForRegEx("^[A-Z]+:.*(?=\\r)") as! [String]
    MSLogVerbose("entryStrings = \(entryStrings)")

    var entries: [String:String] = [:]
    apply(entryStrings) {
      let components = ":".split($0)
      if components.count == 2 { entries[components[0]] = components[1] }
    }

    if let location = entries["LOCATION"] where location.hasSuffix("/desc") && beaconsReceived ∌ location,
      let baseURL = NSURL(string: location[0..<location.length - 5])
    {
      beaconsReceived.insert(location)
      ISYDeviceConnection.connectionWithBaseURL(baseURL) {
        if let connection = $0 {
          ISYConnectionManager.connections.insert(connection)
          self.networkDevices.insert(connection.device)
          ISYConnectionManager.stopDetectingNetworkDevices()
        } else { MSHandleError($1) }
      }

    }

  }
}