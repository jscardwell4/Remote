//
//  ConnectionManager.swift
//  Remote
//
//  Created by Jason Cardwell on 5/06/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit
import CoreData
import Settings
import class DataModel.DataManager
import class DataModel.ITachIRCommand
import class DataModel.NetworkDevice
import class DataModel.ITachDevice
import class DataModel.HTTPCommand

/** The `ConnectionManager` class oversee all device-related network activity. */
public final class ConnectionManager {

  class func initialize() {
    SettingsManager.registerBoolSettingWithKey(SettingKey.AutoConnectExisting,  withDefaultValue: true)
    SettingsManager.registerBoolSettingWithKey(SettingKey.AutoConnectDiscovery, withDefaultValue: false)
    SettingsManager.registerBoolSettingWithKey(SettingKey.StopAfterDiscovered,  withDefaultValue: true)
    SettingsManager.registerBoolSettingWithKey(SettingKey.StopAfterUpdated,     withDefaultValue: false)
  }

  public typealias Callback = (Bool, ErrorType?) -> Void

  // MARK: - Connection manager error type

  /** Enumeration to encapsulate connection errors */
  public enum Error: ErrorType {
    case NoWifi
//    case InvalidID
    case CommandEmpty
//    case CommandHalted
    case InvalidCommand
    case Response (NSError)
//    case ConnectionExists
//    case InvalidNetworkDevice
//    case ConnectionInProgress
//    case NetworkDeviceError
//    case Aggregate

  }

  // MARK: - Flag, notification, and key property declarations

  /** Whether to simulate send operations */
  static let simulate = NSUserDefaults.standardUserDefaults().boolForKey("simulate")

  private static let simulatedCommandDelay = 0.5

  public enum Notification {
    case ConnectionStatus (wifiAvailable: Bool)
    case NetworkDeviceDiscovery (uuid: String)
    case NetworkDeviceUpdated (uuid: String)

    public enum NotificationName: String { case ConnectionStatus, NetworkDeviceDiscovery, NetworkDeviceUpdated }

    public enum InfoKey: String { case WifiAvailable, NetworkDevice, AutoConnectDevice }

    public var name: NotificationName {
      switch self {
        case .ConnectionStatus: return .ConnectionStatus
        case .NetworkDeviceDiscovery: return .NetworkDeviceDiscovery
        case .NetworkDeviceUpdated: return .NetworkDeviceUpdated
      }
    }

    private func post() {
      let userInfo: [NSObject:AnyObject]?
      switch self {
        case .ConnectionStatus(let wifi):       userInfo = [InfoKey.WifiAvailable.rawValue: wifi]
        case .NetworkDeviceDiscovery(let uuid): userInfo = [InfoKey.NetworkDevice.rawValue: uuid]
        case .NetworkDeviceUpdated(let uuid):   userInfo = [InfoKey.NetworkDevice.rawValue: uuid]
      }
      NSNotificationCenter.defaultCenter().postNotificationName(name.rawValue, object: ConnectionManager.self, userInfo: userInfo)
    }
  }

  public enum NotificationKey: String {
    case WifiAvailable
    case NetworkDevice
    case AutoConnectDevice
  }

  public enum SettingKey: String { case AutoConnectExisting, AutoConnectDiscovery, StopAfterUpdated, StopAfterDiscovered  }


  // MARK: - Wifi availability

  /** Monitors changes in connectivity */
  private static let reachability = NetworkReachability {
    Notification.ConnectionStatus(wifiAvailable: $0.isSupersetOf([.IsDirect, .Reachable])).post()
  }

  /** Indicates wifi availability */
  public static var wifiAvailable: Bool { reachability.refreshFlags(); return reachability.wifiAvailable }

  private static let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()

  // MARK: - Background, foreground receptionists

  /** Handles backgrounded and foregrounded application notification */
  private static let notifcationReceptionist = NotificationReceptionist(
    callbacks: [
      UIApplicationDidEnterBackgroundNotification :
        .Block(nil, { _ in ITachConnectionManager.suspend(); ISYConnectionManager.suspend() }),
      UIApplicationWillEnterForegroundNotification :
        .Block(nil, { _ in do { try ITachConnectionManager.resume(); try ISYConnectionManager.resume() } catch { logError(error) } })
    ],
    object: UIApplication.sharedApplication()
  )

  // MARK: - Sending commands

  /**
  Executes the send operation, and, optionally, calls the completion handler with the result.

  - parameter commandID: NSManagedObjectID ID of the command to send
  - parameter completion: Callback? = nil Block to be executed upon completion of the send operation
  - throws: ConnectionManager.Error
  */
  public static func sendCommandWithID(commandID: NSManagedObjectID, completion: Callback? = nil) throws {

    // Check if we should simulate the command instead of executing it
    guard !simulate else { delayedDispatchToMain(ConnectionManager.simulatedCommandDelay) { completion?(true, nil) }; return }

    // Make sure we have wifi
    guard wifiAvailable else { throw Error.NoWifi }

    switch try DataManager.rootContext.existingObjectWithID(commandID) {

      case let command as ITachIRCommand:
        try ITachConnectionManager.sendCommand(command, completion: completion)

      case let command as HTTPCommand where command.url.absoluteString.isEmpty:
        throw Error.CommandEmpty

      case let command as HTTPCommand:
        NSURLSession(configuration: sessionConfiguration).dataTaskWithURL(command.url, completionHandler: {
          let success = (200 ..< 300).contains(($1 as? NSHTTPURLResponse)?.statusCode ?? -1)
          let error: Error? = $2 != nil ? .Response($2!) : nil
          completion?(success, error)
        }).resume()

      default:
        throw Error.InvalidCommand

    }

  }

  // MARK: - Network device discovery

  public typealias DiscoveryCallback = (device: NetworkDevice?, cancelled: Bool) -> Void
  public typealias DiscoveryCallbackToken = Int

  private static var discoveryCallbacks: [DiscoveryCallbackToken:DiscoveryCallback] = [:]

  /**
  Join multicast group and listen for beacons broadcast by supported network devices, optionally providing a callback in the
  event a new device is detected.

  - parameter context: NSManagedObjectContext = DataManager.rootContext
  - parameter discovery: ((NetworkDevice) -> Void)? = nil
  - throws: `ItachConnectionManager.Error`
  */
  public static func startDetectingNetworkDevices(context context: NSManagedObjectContext = DataManager.rootContext,
                                         callback: DiscoveryCallback? = nil) throws -> DiscoveryCallbackToken
  {
    if let callback = callback { discoveryCallbacks[discoveryCallbacks.count] = callback }

    try ITachConnectionManager.startDetectingNetworkDevices(context)
    try ISYConnectionManager.startDetectingNetworkDevices(context)

    MSLogInfo("listening for network devices…")

    return discoveryCallbacks.count - 1
  }

  /**
  Leave multicast groups

  - parameter token: DiscoveryCallbackToken = -1
  */
  public static func stopDetectingNetworkDevices(token: DiscoveryCallbackToken = -1) {

    if (0 ..< discoveryCallbacks.count).contains(token) {
      discoveryCallbacks.removeValueForKey(token)?(device: nil, cancelled: true)
    }

    guard discoveryCallbacks.count == 0 else { return }

    ITachConnectionManager.stopDetectingNetworkDevices()
    ISYConnectionManager.stopDetectingNetworkDevices()

    MSLogInfo("no longer listening for network devices…")

  }

  /** Whether network devices are currently being detected */
  public static var isDetectingNetworkDevices: Bool {
    return ITachConnectionManager.detectingNetworkDevices || ISYConnectionManager.detectingNetworkDevices
  }

  /**
  Invoked by specializing connection manager classes when an existing device has been updated

  - parameter device: NetworkDevice
  */
  static func updatedDevice(device: NetworkDevice) { Notification.NetworkDeviceUpdated(uuid: device.uuid).post() }

  /**
  Invoked by specializing connection manager classes when a new device is has been detected

  - parameter device: NetworkDevice
  */
  static func discoveredDevice(device: NetworkDevice) {
    discoveryCallbacks.keys.apply { self.discoveryCallbacks.removeValueForKey($0)?(device: device, cancelled: false) }
    Notification.NetworkDeviceDiscovery(uuid: device.uuid).post()
  }

}