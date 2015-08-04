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
  static let MulticastSearchMessage = "M-SEARCH * HTTP/1.1\rHOST:239.255.255.250:1900\rMAN:\"ssdp.discover\"\rMX:1\rST:urn:udi-com:device:X_Insteon_Lighting_Device:1"

  /** Previously discovered devices. */
  static private(set) var networkDevices = Set(ISYDevice.objectsInContext(DataManager.rootContext) as! [ISYDevice])

  /** Currently connected devices. */
  static var connections: Set<ISYDeviceConnection> = []

  /** Uuids  from processed beacons. */
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
    detectingNetworkDevices = true
    try multicastConnection.listen()
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

    let entries = Dictionary((~/"(?m)^([A-Z]+):(.*)(?=\\r)").match(message).map { ($0.captures[1]!.string, $0.captures[2]!.string) })
    MSLogDebug("entries = \(entries)")

    if let location = entries["LOCATION"] where location.hasSuffix("/desc") && beaconsReceived ∌ location,
      let baseURL = NSURL(string: location[0 ..< location.characters.count - 5])
    {
      beaconsReceived.insert(location)
      ISYDeviceConnection.connectionWithBaseURL(baseURL) {

        guard let connection = $0  else { MSHandleError($1); return }

        ISYConnectionManager.connections.insert(connection)
        self.networkDevices.insert(connection.device)
        ISYConnectionManager.stopDetectingNetworkDevices()
        
      }

    }

  }
}