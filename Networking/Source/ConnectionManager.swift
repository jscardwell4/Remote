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
import class DataModel.SendIRCommand
import class DataModel.HTTPCommand

/** The `ConnectionManager` class oversee all device-related network activity. */
public final class ConnectionManager {

  public typealias Callback = (Bool, NSError?) -> Void

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
  }

  private static let simulatedCommandDelay = Int64(0.5 * Double(NSEC_PER_SEC))

  static let ConnectionStatusNotification = "ConnectionManagerConnectionStatusNotification"
  static let NetworkDeviceDiscoveryNotification = "ConnectionManagerNetworkDeviceDiscoveryNotification"

  static let WifiAvailableKey = "ConnectionManaagerWifiAvailableKey"
  static let NetworkDeviceKey = "ConnectionManagerNetworkDeviceKey"
  static let AutoConnectDeviceKey = "ConnectionManagerAutoConnectDeviceKey"

  /** Monitors changes in connectivity */
  private static let reachability = MSNetworkReachability(callback: {
    (flags: SCNetworkReachabilityFlags) -> Void in
      let wifi = (   ((flags & UInt32(kSCNetworkReachabilityFlagsIsDirect)) != 0)
                  && ((flags & UInt32(kSCNetworkReachabilityFlagsReachable)) != 0))
      if wifi != ConnectionManager.wifiAvailable {
        ConnectionManager.wifiAvailable = wifi
        NSNotificationCenter.defaultCenter().postNotificationName(ConnectionManager.ConnectionStatusNotification,
                                                           object: ConnectionManager.self,
                                                         userInfo: [ConnectionManager.WifiAvailableKey: wifi])
      }

    })


  /** Indicates wifi availability */
  private(set) public static var wifiAvailable = false

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
    if !(wifiAvailable || simulateCommandSuccess) {
      MSLogWarn("wifi not available")
      completion?(false, NSError(domain: Error.domain, code: Error.NoWifi.rawValue, userInfo: nil))
    }

    // Otherwise continue sending command
    else {
      var error: NSError?
      let command = DataManager.rootContext.existingObjectWithID(commandID, error: &error)
      if error != nil {
        completion?(false, NSError(domain: Error.domain,
                                   code: Error.InvalidID.rawValue,
                                   userInfo: [NSUnderlyingErrorKey: error!]))
      } else if let irCommand = command as? SendIRCommand {
        if simulateCommandSuccess { simulateSuccess() }
        else { ITachConnectionManager.sendCommand(irCommand, completion: completion) }
      } else if let httpCommand = command as? HTTPCommand {
        if httpCommand.url.absoluteString!.isEmpty {
          MSLogError("cannot send command with an empty url")
          completion?(false, NSError(domain: Error.domain, code: Error.CommandEmpty.rawValue, userInfo: nil))
        }
        else if simulateCommandSuccess { simulateSuccess() }
        else {
          let request = NSURLRequest(URL: httpCommand.url)
          NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
            (response: NSURLResponse!, data: NSData!, connectionError: NSError!) in

            MSLogDebug("response: \(response)\ndata: \(data)")

            // TODO: Determine what constitutes success here.

            completion?(true, connectionError)
          }
        }
      }
    }
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
        completionError = NSError(domain: Error.domain,
                                    code: Error.Aggregate.rawValue,
                                userInfo: [NSUnderlyingErrorKey: [completionError!, error!]])
      } else if error != nil {
        completionError = error
      }
      if ++completionCount == 2 { completion?(completionSuccess, completionError) }
    }
  }

  /**
  Join multicast group and listen for beacons broadcast by iTach devices.

  :param: completion Callback? = nil Block to be executed upon completion of the task.
  */
  public class func startDetectingNetworkDevices(completion: Callback? = nil) {
    let callback = completionWrapper(completion)
    ITachConnectionManager.startDetectingNetworkDevices(completion: callback)
    ISYConnectionManager.startDetectingNetworkDevices(completion: callback)
    MSLogInfo("listening for network devices…")
  }

  /**
  Leave multicast group.

  :param: completion Callback? = nil Block to be executed upon completion of the task.
  */
  public class func stopDetectingNetworkDevices(completion: Callback? = nil) {
    let callback = completionWrapper(completion)
    ITachConnectionManager.stopDetectingNetworkDevices(completion: callback)
    ISYConnectionManager.stopDetectingNetworkDevices(completion: callback)
    MSLogInfo("no logner listening for network devices…")
  }

  /** Whether network devices are currently being detected */
  public class var isDetectingNetworkDevices: Bool {
    return ITachConnectionManager.detectingNetworkDevices || ISYConnectionManager.detectingNetworkDevices
  }
}