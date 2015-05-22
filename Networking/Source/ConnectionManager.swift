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
@objc public final class ConnectionManager {

  class func initialize() {
    SettingsManager.registerBoolSettingWithKey(AutoConnectExistingKey, withDefaultValue: true)
    SettingsManager.registerBoolSettingWithKey(AutoConnectDiscoveredKey, withDefaultValue: false)
    SettingsManager.registerBoolSettingWithKey(StopAfterUpdatedDeviceKey, withDefaultValue: true)
    SettingsManager.registerBoolSettingWithKey(StopAfterUpdatedDeviceKey, withDefaultValue: false)
  }

  public typealias Callback = (Bool, NSError?) -> Void

  // MARK: - Connection manager error type

  /** Enumeration to encapsulate connection errors */
  public enum Error: Int {
    case NoWifi
    case InvalidID
    case CommandEmpty
    case CommandHalted
    case ConnectionExists
    case InvalidNetworkDevice
    case ConnectionInProgress
    case NetworkDeviceError
    case Aggregate

    static let domain = "ConnectionManagerErrorDomain"

    /**
    error:

    :param: userInfo [NSObject AnyObject]? = nil

    :returns: NSError
    */
    func error(userInfo: [NSObject:AnyObject]? = nil) -> NSError {
      return NSError(domain: Error.domain, code: rawValue, userInfo: userInfo)
    }
  }

  // MARK: - Flag, notification, and key property declarations

  /** Whether to simulate send operations */
  static let simulateCommandSuccess = NSUserDefaults.standardUserDefaults().boolForKey("simulate")

  private static let simulatedCommandDelay = Int64(0.5 * Double(NSEC_PER_SEC))

  public static let ConnectionStatusNotification = "ConnectionManagerConnectionStatusNotification"
  public static let NetworkDeviceDiscoveryNotification = "ConnectionManagerNetworkDeviceDiscoveryNotification"
  public static let NetworkDeviceUpdatedNotification = "ConnectionManagerNetworkDeviceUpdatedNotification"

  public static let AutoConnectExistingKey = "ConnectionManagerAutoConnectExistingKey"
  public static let AutoConnectDiscoveredKey = "ConnectionManagerAutoConnectDiscoveredKey"
  public static let StopAfterUpdatedDeviceKey = "StopAfterUpdatedDeviceKey"
  public static let StopAfterDiscoveredDeviceKey = "StopAfterDiscoveredDeviceKey"

  public static let WifiAvailableKey = "ConnectionManaagerWifiAvailableKey"
  public static let NetworkDeviceKey = "ConnectionManagerNetworkDeviceKey"
  public static let AutoConnectDeviceKey = "ConnectionManagerAutoConnectDeviceKey"


  // MARK: - Wifi availability

  /** Monitors changes in connectivity */
  private static let reachability = MSNetworkReachability(callback: {[cm = ConnectionManager.self]
    (flags: SCNetworkReachabilityFlags) -> Void in
      let name = cm.ConnectionStatusNotification
      let userInfo: [NSObject:AnyObject] = [cm.WifiAvailableKey: cm.flagsIndicateWifiAvailable(flags)]
      NSNotificationCenter.defaultCenter().postNotificationName(name, object: cm, userInfo: userInfo)
      MSLogDebug("posted notification for changes in reachability")
    })

  /**
  flagsIndicateWifiAvailable:

  :param: flags SCNetworkReachabilityFlags

  :returns: Bool
  */
  private static func flagsIndicateWifiAvailable(flags: SCNetworkReachabilityFlags) -> Bool {
    return (((flags & UInt32(kSCNetworkReachabilityFlagsIsDirect)) != 0)
         && ((flags & UInt32(kSCNetworkReachabilityFlagsReachable)) != 0))
  }

  /** Indicates wifi availability */
  public static var wifiAvailable: Bool {
    reachability.refreshFlags()
    return flagsIndicateWifiAvailable(reachability.flags)
  }

  // MARK: - Background, foreground receptionists

  /** Handles backgrounded notification */
  private static let backgroundReceptionist =
    MSNotificationReceptionist(observer: ConnectionManager.self,
                     forObject: UIApplication.sharedApplication(),
              notificationName: UIApplicationDidEnterBackgroundNotification,
                         queue: NSOperationQueue.mainQueue(),
                       handler: {_ in ITachConnectionManager.suspend(); ISYConnectionManager.suspend()})

  /** Handles foregrounded notification */
  private static let foregroundReceptionist =
    MSNotificationReceptionist(observer: ConnectionManager.self,
                     forObject: UIApplication.sharedApplication(),
              notificationName: UIApplicationWillEnterForegroundNotification,
                         queue: NSOperationQueue.mainQueue(),
                       handler: {_ in ITachConnectionManager.resume(); ISYConnectionManager.resume()})


  // MARK: - Sending commands

  /**
  Executes the send operation, and, optionally, calls the completion handler with the result.

  :param: commandID NSManagedObjectID ID of the command to send
  :param: completion Callback? = nil Block to be executed upon completion of the send operation
  */
  public static func sendCommandWithID(commandID: NSManagedObjectID, completion: Callback? = nil) {
    MSLogInfo("sending command…")

    let simulateSuccess: () -> Void = {
      let time = dispatch_time(DISPATCH_TIME_NOW, self.simulatedCommandDelay)
      let queue = dispatch_get_main_queue()
      dispatch_after(time, queue, {completion?(true, nil)})
    }

    // Check for wifi or a simulated environment flag
    if !(wifiAvailable || simulateCommandSuccess) { MSLogWarn("wifi not available"); completion?(false, Error.NoWifi.error()) }

    // Otherwise continue sending command
    else {
      var error: NSError?
      let command = DataManager.rootContext.existingObjectWithID(commandID, error: &error)
      if error != nil { completion?(false, Error.InvalidID.error(userInfo: [NSUnderlyingErrorKey: error!])) }
      else if let irCommand = command as? ITachIRCommand {
        if simulateCommandSuccess { simulateSuccess() }
        else { ITachConnectionManager.sendCommand(irCommand, completion: completion) }
      } else if let httpCommand = command as? HTTPCommand {
        if httpCommand.url.absoluteString!.isEmpty {
          MSLogError("cannot send command with an empty url")
          completion?(false, Error.CommandEmpty.error())
        }
        else if simulateCommandSuccess { simulateSuccess() }
        else {
          let request = NSURLRequest(URL: httpCommand.url)
          NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
            (response: NSURLResponse!, data: NSData!, connectionError: NSError!) in
            MSLogDebug("response: \(response)\ndata: \(data)")
            completion?(true, connectionError)
          }
        }
      }
    }
  }

  // MARK: - Network device discovery

  public typealias DiscoveryCallback = (NetworkDevice) -> Void
  public typealias DiscoveryCallbackToken = Int

  private static var discoveryCallbacks: [DiscoveryCallback] = []

  /**
  Join multicast group and listen for beacons broadcast by supported network devices, optionally providing a callback in the
  event a new device is detected.

  :param: context NSManagedObjectContext = DataManager.rootContext
  :param: discovery ((NetworkDevice) -> Void)? = nil
  */
  public static func startDetectingNetworkDevices(context: NSManagedObjectContext = DataManager.rootContext,
                                        discovery: DiscoveryCallback? = nil) -> DiscoveryCallbackToken
  {
    var token = -1
    if let discovery = discovery {
      token = discoveryCallbacks.count; discoveryCallbacks.append(discovery)
      MSLogDebug("discovery appended to discoveryCallbacks, token = \(token)")
    }
    ITachConnectionManager.startDetectingNetworkDevices(context: context)
    ISYConnectionManager.startDetectingNetworkDevices(context: context)
    MSLogInfo("listening for network devices…")
    return token
  }

  /** Leave multicast group. */
  public static func stopDetectingNetworkDevices(discoveryCallbackToken: DiscoveryCallbackToken = -1) {
    if 0 ..< discoveryCallbacks.count ∋ discoveryCallbackToken {
      MSLogDebug("removing discovery callback for token \(discoveryCallbackToken)")
      _ = discoveryCallbacks.removeAtIndex(discoveryCallbackToken)
    }
    if discoveryCallbacks.count == 0 {
      MSLogDebug("discoveryCallbacks is empty, stopping device detection…")
      ITachConnectionManager.stopDetectingNetworkDevices()
      ISYConnectionManager.stopDetectingNetworkDevices()
      MSLogInfo("no longer listening for network devices…")
    }
  }

  /** Whether network devices are currently being detected */
  public static var isDetectingNetworkDevices: Bool {
    return ITachConnectionManager.detectingNetworkDevices || ISYConnectionManager.detectingNetworkDevices
  }

  /**
  Invoked by specializing connection manager classes when an existing device has been updated

  :param: device NetworkDevice
  */
  static func updatedDevice(device: NetworkDevice) {
    NSNotificationCenter.defaultCenter().postNotificationName(NetworkDeviceUpdatedNotification,
                                                       object: self,
                                                     userInfo: [NetworkDeviceKey:device.uuid])
  }

  /**
  Invoked by specializing connection manager classes when a new device is has been detected

  :param: device NetworkDevice
  */
  static func discoveredDevice(device: NetworkDevice) {
    var i = 0
    apply(discoveryCallbacks) {
      MSLogDebug("invoking discovery callback \(i++)")
      $0(device)
    }
    MSLogDebug("removing discovery callbacks and posting notification…")
    discoveryCallbacks.removeAll()
    NSNotificationCenter.defaultCenter().postNotificationName(NetworkDeviceDiscoveryNotification,
                                                       object: self,
                                                     userInfo: [NetworkDeviceKey:device.uuid])
  }

}