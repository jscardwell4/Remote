//
//  ITachConnectionManager.swift
//  Remote
//
//  Created by Jason Cardwell on 5/06/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit
import Settings
import class DataModel.ITachIRCommand
import class DataModel.ITachDevice
import class DataModel.DataManager

@objc final class ITachConnectionManager {

  // MARK: - Typealiases and address, port property declarations

  typealias Callback = ConnectionManager.Callback
  typealias Error = ConnectionManager.Error
  typealias Connection = ITachDeviceConnection

  typealias Device = ITachDevice
  typealias DeviceIdentifier = String

  static let MulticastAddress = "239.255.250.250"
  static let MulticastPort: UInt16 = 9131

  // MARK: - Private cache, flag, and connection properties

  /** Current/previous device connections */
  static private var connections: [DeviceIdentifier:Connection] = [:]

  /** Active device connections */
  static private var activeConnections: Set<DeviceIdentifier> = []

  /** UUIDs from processed beacons. */
  static private var beaconsReceived: Set<DeviceIdentifier> = []

  /** Previously discovered devices. */
  static private(set) var networkDevices = Set(Device.objectsInContext(DataManager.rootContext) as! [Device])

  /** Whether socket is (or should be) open to receive multicast group broadcast messages. */
  static private(set) var detectingNetworkDevices = false

  /** Multicast group connection */
  static private var multicastConnection = MulticastConnection(address: ITachConnectionManager.MulticastAddress,
                                                               port: ITachConnectionManager.MulticastPort,
                                                               callback: ITachConnectionManager.messageReceived)

  // MARK: - Network device detection

  /** Join multicast group and listen for beacons broadcast by iTach devices. */
  class func startDetectingNetworkDevices() {
    detectingNetworkDevices = true
    multicastConnection.listen()
    MSLogDebug("listening for iTach devices…")
  }

  /** Cease listening for beacon broadcasts and release resources. */
  class func stopDetectingNetworkDevices() {
    detectingNetworkDevices = false
    multicastConnection.stopListening()
    MSLogDebug("no longer listening for iTach devices")
  }

  // MARK: - Device connections

  /**
  connectionForDevice:

  :param: device Device

  :returns: Connection
  */
  class func connectionForDevice(device: Device) -> Connection {
    let result: Connection
    if let connection = connections[device.uniqueIdentifier] { result = connection }
    else { result = Connection(device: device); connections[device.uniqueIdentifier] = result }
    return result
  }

  /** Suspend active connections */
  class func suspend() {
    if detectingNetworkDevices { multicastConnection.stopListening() }
    activeConnections.removeAll(keepCapacity: true)
    apply(connections) { if $1.connected { ITachConnectionManager.activeConnections.insert($0); $1.disconnect() } }
  }

  /** Resume multicast connection and any device connections that were active on suspension */
  class func resume() {
    if detectingNetworkDevices { multicastConnection.listen() }
    apply(connections) { if ITachConnectionManager.activeConnections ∋ $0 { $1.connect() } }
  }

  // MARK: - Sending and receiving messages

  /**
  Processes messages received through `NetworkDeviceConnection` objects.

  :param: message String Contents of the message received by the device connection
  */
  class func messageReceived(message: String) {

    MSLogDebug("message received over multicast connection:\n\(message)\n")

    if let uniqueIdentifier = message.stringByMatchingFirstOccurrenceOfRegEx("(?<=UUID=)[^<]+(?=>)")
     where beaconsReceived ∌ uniqueIdentifier
    {
      assert(connections[uniqueIdentifier] == nil)
      beaconsReceived.insert(uniqueIdentifier)

      let device = Device.objectWithValue(uniqueIdentifier,
                             forAttribute: "uniqueIdentifier",
                                  context: DataManager.rootContext) ?? Device(context: DataManager.rootContext)
      device.updateWithBeacon(message)

      let shouldStop: Bool
      let shouldConnect: Bool

      // If `networkDevices` already contains `device`, send update notification
      if networkDevices ∋ device {
        ConnectionManager.updatedDevice(device)
        shouldStop = SettingsManager.valueForSetting(ConnectionManager.StopAfterUpdatedDeviceKey) == true
        shouldConnect = SettingsManager.valueForSetting(ConnectionManager.AutoConnectExistingKey) == true
      }

      // otherwise add `device` and send discovery notification
      else {
        networkDevices.insert(device); ConnectionManager.discoveredDevice(device)
        shouldStop = SettingsManager.valueForSetting(ConnectionManager.StopAfterDiscoveredDeviceKey) == true
        shouldConnect = SettingsManager.valueForSetting(ConnectionManager.AutoConnectDiscoveredKey) == true
      }

      // Stop if appropriate
      if shouldStop { stopDetectingNetworkDevices() }

      // Connect if appropriate
      if shouldConnect { connections[uniqueIdentifier] = Connection(device: device) }
    }

  }

 /**

  Sends an IR command to the device identified by the specified `uuid`.

  :param: command ITachIRCommand The command to execute

  :param: completion The block to execute upon task completion

  */
  class func sendCommand(command: ITachIRCommand, completion: Callback? = nil) {
    if command.commandString.isEmpty {
      MSLogError("cannot send empty or nil command")
      completion?(false, NSError(domain: Error.domain, code: Error.CommandEmpty.rawValue, userInfo: nil))
    } else if let device = command.networkDevice as? Device {
      connectionForDevice(device).enqueueCommand(command, completion: completion)
    }
  }

}
