//
//  ItachConnectionManager.swift
//  Remote
//
//  Created by Jason Cardwell on 5/06/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit
import class DataModel.SendIRCommand
import class DataModel.ITachDevice

@objc final class ITachConnectionManager: NetworkDeviceConnectionDelegate {

  typealias Callback = ConnectionManager.Callback
  typealias Error = ConnectionManager.Error

  static let MulticastAddress = "239.255.250.250"
  static let MulticastPort = "9131"

  static let LearnerStatusDidChangeNotification = "ITachConnectionManagerLearnerStatusDidChangeNotification"
  static let CommandCapturedNotification = "ItachConnectionManagerCommandCapturedNotification"

  /** Currently connected devices */
  static private var connections: [String:ITachDeviceConnection] = [:]

  /** UUIDs from processed beacons. */
  static private var beaconsReceived: Set<String> = []

  /** Whether socket is (or should be) open to receive multicast group broadcast messages. */
  static private(set) var detectingNetworkDevices = false

  /** Multicast group connection */
  static private var multicastConnection =
    NetworkDeviceMulticastConnection(address: ITachConnectionManager.MulticastAddress,
                                     port: ITachConnectionManager.MulticastPort,
                                     delegate: ITachConnectionManager())

  /**

  Join multicast group and listen for beacons broadcast by iTach devices.

  :param: completion Callback Block to be executed upon completion of the task.

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

  :param: completion Callback Block to be executed upon completion of the task.

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

  :param: command SendIRCommand The command to execute

  :param: completion The block to execute upon task completion

  */
  class func sendCommand(command: SendIRCommand, completion: Callback? = nil) {
    if command.commandString.isEmpty {
      MSLogError("cannot send empty or nil command")
      completion?(false, NSError(domain: Error.domain, code: Error.CommandEmpty.rawValue, userInfo: nil))
    } else if let device = command.networkDevice as? ITachDevice{
      let id = device.uniqueIdentifier
      let connection: ITachDeviceConnection

      if let c = connections[id] { connection = c }
      else { connection = ITachDeviceConnection(device: device); connections[id] = connection }

      connection.enqueueCommand(command) { completion?($0, $2) }
    }
  }

  /** Suspend active connections */
  class func suspend() {
    if detectingNetworkDevices { multicastConnection.disconnect() }
    apply(connections.values.array) { if $0.connected { $0.disconnect() } }
  }

  /** Resume multicast connection, device connections should re-connect as needed when commands are enqueued */
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

      if let uniqueIdentifier = message.stringByMatchingFirstOccurrenceOfRegEx("(?<=UUID=)[^<]+(?=>)")
       where beaconsReceived ∌ uniqueIdentifier
      {
        beaconsReceived.insert(uniqueIdentifier)
        if let deviceConnection = ITachDeviceConnection(discoveryBeacon: message) {
          connections[uniqueIdentifier] = deviceConnection
          stopDetectingNetworkDevices()
        }
      }

    }

  }

}
