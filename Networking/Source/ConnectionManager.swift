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
import class DataModel.DataManager
import class DataModel.ITachIRCommand
import class DataModel.NetworkDevice
import class DataModel.ITachDevice
import class DataModel.HTTPCommand

/** The `ConnectionManager` class oversee all device-related network activity. */
public final class ConnectionManager {

  public typealias Callback = (Bool, NSError?) -> Void

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

  private static let simulatedCommandDelay = Int64(0.5 * Double(NSEC_PER_SEC))

  public static let ConnectionStatusNotification = "ConnectionManagerConnectionStatusNotification"
  public static let NetworkDeviceDiscoveryNotification = "ConnectionManagerNetworkDeviceDiscoveryNotification"

  public static let WifiAvailableKey = "ConnectionManaagerWifiAvailableKey"
  public static let NetworkDeviceKey = "ConnectionManagerNetworkDeviceKey"
  public static let AutoConnectDeviceKey = "ConnectionManagerAutoConnectDeviceKey"

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

  /** Whether to simulate send operations */
  static let simulateCommandSuccess = NSUserDefaults.standardUserDefaults().boolForKey("simulate")

  /** Handles backgrounded notification */
  private let backgroundReceptionist =
    MSNotificationReceptionist(observer: ConnectionManager.self,
                     forObject: UIApplication.sharedApplication(),
              notificationName: UIApplicationDidEnterBackgroundNotification,
                         queue: NSOperationQueue.mainQueue(),
                       handler: {_ in ITachConnectionManager.suspend(); ISYConnectionManager.suspend()})

  /** Handles foregrounded notification */
  private let foregroundReceptionist =
    MSNotificationReceptionist(observer: ConnectionManager.self,
                     forObject: UIApplication.sharedApplication(),
              notificationName: UIApplicationWillEnterForegroundNotification,
                         queue: NSOperationQueue.mainQueue(),
                       handler: {_ in ITachConnectionManager.resume(); ISYConnectionManager.resume()})


  /**
  Executes the send operation, and, optionally, calls the completion handler with the result.

  :param: commandID NSManagedObjectID ID of the command to send
  :param: completion Callback? = nil Block to be executed upon completion of the send operation
  */
  public class func sendCommandWithID(commandID: NSManagedObjectID, completion: Callback? = nil) {
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

  /**
  Invoked by specializing connection manager classes when a new device is has been detected

  :param: device NetworkDevice
  */
  class func discoveredDevice(device: NetworkDevice) {
    NSNotificationCenter.defaultCenter().postNotificationName(NetworkDeviceDiscoveryNotification,
                                                       object: self,
                                                     userInfo: [NetworkDeviceKey:device.uuid])
  }

  /**
  connectToITachDevice:learnerDelegate:

  :param: device ITachDevice
  :param: learnerDelegate ITachLearnerDelegate
  */
  public class func connectToITachDevice(device: ITachDevice, learnerDelegate: ITachLearnerDelegate?) {
    let connection = ITachConnectionManager.connectionForDevice(device)
    if connection.learnerDelegate != nil && connection.learnerDelegate !== learnerDelegate {
      MSLogWarn("existing learner delegate for connection will be replaced")
    }
    connection.learnerDelegate = learnerDelegate
  }

  /**
  Wraps provided completion block to aggregate multiple calls

  :param: completion Callback

  :returns: Callback
  */
  private class func completionWrapper(completion: Callback?) ->  Callback {
    var completionCount = 0
    var completionSuccess = true
    var completionError: NSError?

    return {
      success, error in
      completionSuccess = success && completionSuccess
      if completionError != nil && error != nil {
        completionError = Error.Aggregate.error(userInfo: [NSUnderlyingErrorKey: [completionError!, error!]])
      }
      else if error != nil { completionError = error }
      
      if ++completionCount == 2 { completion?(completionSuccess, completionError) }
    }
  }

  /** Join multicast group and listen for beacons broadcast by iTach devices. */
  public class func startDetectingNetworkDevices() {
    ITachConnectionManager.startDetectingNetworkDevices()
    ISYConnectionManager.startDetectingNetworkDevices()
    MSLogInfo("listening for network devices…")
  }

  /** Leave multicast group. */
  public class func stopDetectingNetworkDevices() {
    ITachConnectionManager.stopDetectingNetworkDevices()
    ISYConnectionManager.stopDetectingNetworkDevices()
    MSLogInfo("no longer listening for network devices…")
  }

  /** Whether network devices are currently being detected */
  public class var isDetectingNetworkDevices: Bool {
    return ITachConnectionManager.detectingNetworkDevices || ISYConnectionManager.detectingNetworkDevices
  }
}