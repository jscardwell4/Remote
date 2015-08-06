//
//  ISYConnectionManager.swift
//  Remote
//
//  Created by Jason Cardwell on 5/06/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit
import Settings
import class DataModel.HTTPCommand
import class DataModel.ISYDevice
import class DataModel.DataManager
import class DataModel.NetworkDevice

final class ISYConnectionManager {

  typealias Callback = ConnectionManager.Callback
  typealias Error = ConnectionManager.Error
  typealias Device = ISYDevice
  typealias DeviceIdentifier = String
  typealias Connection = ISYDeviceConnection

  static let MulticastAddress = "239.255.255.250"
  static let MulticastPort: UInt16 = 1900
  static let MulticastSearchMessage = "M-SEARCH * HTTP/1.1\rHOST:239.255.255.250:1900\rMAN:\"ssdp.discover\"\rMX:1\rST:urn:udi-com:device:X_Insteon_Lighting_Device:1"

  static private var context: NSManagedObjectContext = DataManager.rootContext

  /** Previously discovered devices. */
  static private(set) var networkDevices = Set(ISYDevice.objectsInContext(DataManager.rootContext) as! [ISYDevice])

  /** Current/previous device connections */
  static private var connections: [DeviceIdentifier:Connection] = [:]

  /** Uuids from processed beacons. */
  static private var beaconsReceived: Set<String> = []

  /** Multicast group connection */
  static let multicastConnection = MulticastConnection(address:ISYConnectionManager.MulticastAddress,
                                                       port: ISYConnectionManager.MulticastPort,
                                                       didReceiveMessage: ISYConnectionManager.messageReceived)

  /** Whether socket is open to receive multicast group broadcast messages */
  static private(set) var detectingNetworkDevices = false

  /**
  Join multicast group and listen for beacons broadcast by iTach devices.

  - parameter context: NSManagedObjectContext = DataManager.rootContext
  */
  class func startDetectingNetworkDevices(context: NSManagedObjectContext = DataManager.rootContext) throws {
    guard !detectingNetworkDevices else { return }
    self.context = context
    detectingNetworkDevices = true
    try multicastConnection.listen()
    multicastConnection.sendMessage(MulticastSearchMessage)
    MSLogDebug("listening for ISY devices…")
  }

  /** Cease listening for beacon broadcasts and release resources. */
  class func stopDetectingNetworkDevices() {
    guard detectingNetworkDevices else { return }
    multicastConnection.stopListening()
    detectingNetworkDevices = false
    MSLogDebug("no longer listening for ISY devices")
  }

  /** Suspend active connections */
  class func suspend() { guard detectingNetworkDevices else { return }; multicastConnection.stopListening() }

  /** Resume previously active connections */
  class func resume() throws { guard detectingNetworkDevices else { return };  try multicastConnection.listen() }

  /**
  Processes messages received through `NetworkDeviceConnection` objects.

  - parameter message: String Contents of the message received by the device connection
  */
  class func messageReceived(message: String) {

    MSLogDebug("message received over multicast connection:\n\(message)\n")

    guard let uniqueIdentifier = (~/"USN:(uuid:[0-9a-f:]{17})").firstMatch(message)?.captures[1]?.string
      where beaconsReceived ∌ uniqueIdentifier else { return }

    beaconsReceived.insert(uniqueIdentifier)

    guard let location = (~/"LOCATION:(http://[0-9.]+/desc)").firstMatch(message)?.captures[1]?.string,
      descURL = NSURL(string: location) else { return }

    NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration()).dataTaskWithURL(descURL) {
      (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in

      guard let data = data else { MSHandleError(error); return }
      
      let isUpdate = Device.objectExistsInContext(context, withValue: uniqueIdentifier, forAttribute: "uniqueIdentifier")

      guard let device = Device.deviceFromDesc(data, context: context) else { return }

      let notify = isUpdate ? ConnectionManager.updatedDevice : ConnectionManager.discoveredDevice
      let shouldStopKey: ConnectionManager.SettingKey = isUpdate ? .StopAfterUpdated : .StopAfterDiscovered
      let shouldConnectKey: ConnectionManager.SettingKey = isUpdate ? .AutoConnectExisting : .AutoConnectDiscovery

      notify(device)

      // Stop if appropriate
      if SettingsManager.valueForSetting(shouldStopKey) == true { stopDetectingNetworkDevices() }

      // Connect if appropriate
      if SettingsManager.valueForSetting(shouldConnectKey) == true { connections[uniqueIdentifier] = Connection(device: device) }
    } .resume()

  }

}