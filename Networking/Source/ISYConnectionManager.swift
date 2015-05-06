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

@objc final class ISYConnectionManager: NetworkDeviceConnectionDelegate {

  typealias Callback = ConnectionManager.Callback
  typealias Error = ConnectionManager.Error

  static let MulticastAddress = "239.255.255.250"
  static let MulticastPort = "1900"

  /** Previously discovered devices. */
  static private(set) var networkDevices = Set(ISYDevice.objectsInContext(DataManager.rootContext) as! [ISYDevice])

  /** Currently connected devices. */
  static var connections = Set<ISYDeviceConnection>()

  /** Uuids  from processed beacons. */
  static private var beaconsReceived = Set<String>()

  /** Multicast group connection */
  static let multicastConnection =
    NetworkDeviceMulticastConnection(address:ISYConnectionManager.MulticastAddress,
                                     port: ISYConnectionManager.MulticastPort,
                                     delegate: ISYConnectionManager())

  /** Whether socket is open to receive multicast group broadcast messages */
  static private(set) var detectingNetworkDevices = false

  /**
  Join multicast group and listen for beacons broadcast by iTach devices.

  :param: completion Callback? = nil Block to be executed upon completion of the task.
  */
  class func startDetectingNetworkDevices(completion: Callback? = nil) {
    // Set group active flag
    detectingNetworkDevices = true

    // Check for wifi
    if !ConnectionManager.wifiAvailable {
      MSLogError("cannot detect network devices without a valid wifi connection")
      completion?(false, NSError(domain: Error.domain, code: Error.NoWifi.rawValue, userInfo: nil))
    }

    // Just execute the completion block if we have already joined
    else if multicastConnection.connected { MSLogWarn("multicast socket already exists"); completion?(true, nil) }

    // Otherwise join the multicast group
    else { multicastConnection.connect(completion: completion) }
  }

  /**
  Cease listening for beacon broadcasts and release resources.

  :param: completion Callback? = nil Block to be executed upon completion of the task.
  */
  class func stopDetectingNetworkDevices(completion: Callback? = nil) {
    // Set group active flag
    detectingNetworkDevices = false

    // Leave group if joined to one
    if multicastConnection.connected { multicastConnection.disconnect(completion: completion) }

    // Otherwise just execute completion block
    else { MSLogWarn("not currently joined to a multicast group"); completion?(true, nil) }
  }


  /**
  Sends an IR command to the device identified by the specified `uuid`.

  :param: command HTTPCommand The command to execute
  :param: completion Callback? = nil The block to execute upon task completion
  */
  class func sendCommand(command: HTTPCommand, completion: Callback? = nil) {
    // ???: Not used because `ConnectionManager` sends the `HTTPCommand`?
  }

  /** Suspend active connections */
  class func suspend() { if detectingNetworkDevices { multicastConnection.disconnect() } }

  /** Resume previously active connections */
  class func resume() { if detectingNetworkDevices { multicastConnection.connect() } }

  /**
  Callback executed by a `NetworkDeviceConnection` after disconnecting from its device

  :param: connection NetworkDeviceConnection The connection which has been disconnected
  */
  class func deviceDisconnected(connection: NetworkDeviceConnection) { MSLogInfo("") }

  /**
  Callback executed by a `NetworkDeviceConnection` after connecting to its device

  :param: connection NetworkDeviceConnection The connection which has been established
  */
  class func deviceConnected(connection: NetworkDeviceConnection) { MSLogInfo("") }

  /**
  Callback executed by a `NetworkDeviceConnection` after sending a message

  :param: message The message that has been sent
  :param: connection NetworkDeviceConnection The connection over which the message has been sent
  */
  class func messageSent(message: String, overConnection connection: NetworkDeviceConnection) {
    MSLogInfo("message: \(message)")
  }

  /**
  Processes messages received through `NetworkDeviceConnection` objects.

  :param: message String Contents of the message received by the device connection
  :param: connection NetworkDeviceConnection Device connection which received the message
  */
  class func messageReceived(message: String, overConnection connection: NetworkDeviceConnection) {

    if connection === multicastConnection {

      MSLogInfo("message over multicast connection:\n\(message)\n")

      let entryStrings = message.matchingSubstringsForRegEx("^[A-Z]+:.*(?=\\r)") as! [String]
      MSLogInfo("entryStrings = \(entryStrings)")

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
}