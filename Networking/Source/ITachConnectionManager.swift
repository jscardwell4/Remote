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
import class DataModel.NetworkDevice

final class ITachConnectionManager {

  // MARK: - Typealiases and address, port property declarations

  typealias Callback = ConnectionManager.Callback
  typealias Connection = ITachDeviceConnection

  typealias Error = ConnectionManager.Error

  typealias Device = ITachDevice
  typealias DeviceIdentifier = String

  static let MulticastAddress = "239.255.250.250"
  static let MulticastPort: UInt16 = 9131

  // MARK: - Private cache, flag, and connection properties

  static private var context: NSManagedObjectContext = DataManager.rootContext

  /** Current/previous device connections */
  static private var connections: [DeviceIdentifier:Connection] = [:]

  /** Active device connections */
  static private var activeConnections: Set<DeviceIdentifier> = []

  /** UUIDs from processed beacons. */
  static private var beaconsReceived: Set<DeviceIdentifier> = []

  /** Whether socket is (or should be) open to receive multicast group broadcast messages. */
  static private(set) var detectingNetworkDevices = false

  /** Multicast group connection */
  static private var multicastConnection = MulticastConnection(address: ITachConnectionManager.MulticastAddress,
                                                               port: ITachConnectionManager.MulticastPort,
                                                               didReceiveMessage: ITachConnectionManager.messageReceived)

  // MARK: - Network device detection

  /**
  Join multicast group and listen for beacons broadcast by iTach devices.

  - parameter context: NSManagedObjectContext = DataManager.rootContext
  
  - throws: `MulticastConnection.Error`
  */
  class func startDetectingNetworkDevices(context: NSManagedObjectContext = DataManager.rootContext) throws {
    guard !detectingNetworkDevices else { return }
    self.context = context
    detectingNetworkDevices = true
    try multicastConnection.listen()
    MSLogDebug("listening for iTach devices…")
  }

  /** Cease listening for beacon broadcasts and release resources. */
  class func stopDetectingNetworkDevices() {
    guard detectingNetworkDevices else { return }
    multicastConnection.stopListening()
    detectingNetworkDevices = false
    MSLogDebug("no longer listening for iTach devices")
  }

  // MARK: - Device connections

  /**
  connectionForDevice:

  - parameter device: Device

  - returns: Connection
  */
  class func connectionForDevice(device: Device) -> Connection {
    return connections[device.uniqueIdentifier] ?? {
      let connection = Connection(device: device); connections[device.uniqueIdentifier] = connection; return connection
    }()
  }

  /** Suspend active connections */
  class func suspend() {
    if detectingNetworkDevices { multicastConnection.stopListening() }
    activeConnections.apply { self.connections[$0]?.disconnect() }
    activeConnections.removeAll(keepCapacity: true)
  }

  /** 
  Resume multicast connection and any device connections that were active on suspension 
  
  - throws: `MulticastConnection.Error` and any error encountered reconnecting previously active connections
  */
  class func resume() throws {
    guard detectingNetworkDevices else { return }
    try multicastConnection.listen()

    for (_, connection) in connections.filter({ id, _ in self.activeConnections ∋ id}) { try connection.connect() }
  }

  // MARK: - Sending and receiving messages

  /**
  Processes messages received through `NetworkDeviceConnection` objects.

  - parameter message: String Contents of the message received by the device connection
  */
  class func messageReceived(message: String) {

    MSLogDebug("message received over multicast connection:\n\(message)\n")

    guard let uniqueIdentifier = (~/"UUID=([a-zA-Z_0-9]+)").firstMatch(message)?.captures[1]?.string
      where beaconsReceived ∌ uniqueIdentifier else { return }

    beaconsReceived.insert(uniqueIdentifier)

    let isUpdate = Device.objectExistsInContext(context, withValue: uniqueIdentifier, forAttribute: "uniqueIdentifier")

    guard let device = Device.deviceFromBeacon(message, context: context) else { return }

    let notify = isUpdate ? ConnectionManager.updatedDevice : ConnectionManager.discoveredDevice
    let shouldStopKey: ConnectionManager.SettingKey = isUpdate ? .StopAfterUpdated : .StopAfterDiscovered
    let shouldConnectKey: ConnectionManager.SettingKey = isUpdate ? .AutoConnectExisting : .AutoConnectDiscovery

    notify(device)

    // Stop if appropriate
    if SettingsManager.valueForSetting(shouldStopKey) == true { stopDetectingNetworkDevices() }

    // Connect if appropriate
    if SettingsManager.valueForSetting(shouldConnectKey) == true { connections[uniqueIdentifier] = Connection(device: device) }
    
  }

  /**
  connectWithDeviceAtLocation:

  - parameter location: String
  */
  class func connectWithDeviceAtLocation(location: String) {
    MSLogDebug("location = \(location)")
  }

 /**

  Sends an IR command to the device identified by the specified `uuid`.

  - parameter command: ITachIRCommand The command to execute
  - parameter completion: The block to execute upon task completion

  - throws: `ConnectionManager.Error.EmptyCommand`
  */
  class func sendCommand(command: ITachIRCommand, completion: Callback? = nil) throws {
    guard !command.commandString.isEmpty else { MSLogError("cannot send empty or nil command"); throw Error.EmptyCommand }

    guard  let device = command.networkDevice as? Device  else { return }

    try connectionForDevice(device).enqueueCommand(command, completion: completion)
  }

}
