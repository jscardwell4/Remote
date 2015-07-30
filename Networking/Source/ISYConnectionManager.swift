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
  class func startDetectingNetworkDevices(context: NSManagedObjectContext = DataManager.rootContext) throws {
    guard !detectingNetworkDevices else { return }
    try multicastConnection.listen()
    detectingNetworkDevices = true
  }

  /** Cease listening for beacon broadcasts and release resources. */
  class func stopDetectingNetworkDevices() {
    guard detectingNetworkDevices else { return }
    multicastConnection.stopListening()
    detectingNetworkDevices = false
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

    let entries: [String:String] = Dictionary((~/"^[A-Z]+:.*(?=\\r)").match(message).flatMap {
      let components = "=".split($0.string); return components.count == 2 ? (components[0], components[1]) : nil
    })

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