//
//  ITachDeviceConnection.swift
//  Remote
//
//  Created by Jason Cardwell on 5/05/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import class DataModel.ITachDevice
import class DataModel.SendIRCommand
import class DataModel.DataManager
import MoonKit

@objc protocol ITachDeviceConnectionLearnerDelegate {

  optional func learnerEnabledOverConnection(connection: ITachDeviceConnection)
  optional func learnerDisabledOverConnection(connection: ITachDeviceConnection)
  optional func learnerUnavailableOverConnection(connection: ITachDeviceConnection)
  optional func commandCaptured(command: String, overConnection connection: ITachDeviceConnection)

}

/**

 The `ITachDeviceConnection` class handles managing the resources necessary for
 connecting to an iTach device over TCP and the sending/receiving of messages to/from the device.
 Messages to be sent to the device are received from the connection manager and messages received
 from the iTach device are passed up to the connection manager.

 */
@objc class ITachDeviceConnection: GCDAsyncSocketDelegate {

  static let TagKey = "tag"
  static let PortKey = "port"
  static let TCPPort: UInt16 = 4998

  static let ITachQueue = dispatch_queue_create("com.moondeerstudios.remote.itach", DISPATCH_QUEUE_CONCURRENT)
  static let ITachErrorCodes = [ "Reserved error code",  // Inserted to make index match error code
                                 "Invalid command. Command not found",
                                 "Invalid module address (does not exist)",
                                 "Invalid connector address (does not exist)",
                                 "Invalid ID value",
                                 "Invalid frequency value",
                                 "Invalid repeat value",
                                 "Invalid offset value",
                                 "Invalid pulse count",
                                 "Invalid pulse data",
                                 "Uneven amount of <on|off> statements",
                                 "No carriage return found",
                                 "Repeat count exceeded",
                                 "IR command sent to input connector",
                                 "Blaster command sent to non-blaster connector",
                                 "No carriage return before buffer full",
                                 "No carriage return",
                                 "Bad command syntax",
                                 "Sensor command sent to non-input connector",
                                 "Repeated IR transmission failure",
                                 "Above designated IR <on|off> pair limit",
                                 "Symbol odd boundary",
                                 "Undefined symbol",
                                 "Unknown option",
                                 "Invalid baud rate setting",
                                 "Invalid flow control setting",
                                 "Invalid parity setting",
                                 "Settings are locked" ]

  var messagesSending: OrderedDictionary<Int, MessageQueueEntry> = [:] /// Messages being sent
  var messagesSent: OrderedDictionary<Int, MessageQueueEntry> = [:]    /// Messages awaiting response
  var connecting = false                                               /// Connection in progress
  let device: ITachDevice!                                             /// Model for device
  var messageQueue: Queue<MessageQueueEntry> = Queue()                 /// Message send buffer
  var socket: GCDAsyncSocket?                                          /// Connection to device
  var currentTag: Int = 0                                              /// Current tag for new messages

  var connectCallback: ((Bool, NSError?) -> Void)?                     /// Executed on connect
  var disconnectCallback: ((Bool, NSError?) -> Void)?                  /// Executed on disconnect

  var connected: Bool { return socket?.isConnected == true }
  var learnerDelegate: ITachDeviceConnectionLearnerDelegate?

  /**
  initWithDevice:

  :param: device ITachDevice
  */
  init(device d: ITachDevice) { device = d }

  enum BeaconProperty: String {
    case ConfigURL        = "Config-URL"
    case Make             = "Make"
    case Model            = "Model"
    case PCB              = "PCB_PN"
    case SDK              = "SDKClass"
    case Status           = "Status"
    case Revision         = "Revision"
    case Pkg              = "Pkg_Level"
    case UniqueIdentifier = "UUID"

    var deviceProperty: String {
      switch self {
        case .ConfigURL:        return "configURL"
        case .Make:             return "make"
        case .Model:            return "model"
        case .PCB:              return "pcbPN"
        case .SDK:              return "sdkClass"
        case .Status:           return "status"
        case .Revision:         return "revision"
        case .Pkg:              return "pkgLevel"
        case .UniqueIdentifier: return "uniqueIdentifier"
      }
    }
  }

  /**
  init:

  :param: beacon String
  */
  init?(discoveryBeacon beacon: String) {
    let moc = DataManager.rootContext
    var device: ITachDevice?
    moc.performBlockAndWait {
      let entries = beacon.matchingSubstringsForRegEx(~/"(?<=<-)(.*?)(?=>)")
      var attributes: [String:String] = [:]
      apply(entries) {
        let components = "=".split($0)
        if components.count == 2, let prop = BeaconProperty(rawValue: components[0]) {
          attributes[prop.deviceProperty] = components[1]
        }
      }
      if let uniqueIdentifier = attributes[BeaconProperty.UniqueIdentifier.deviceProperty],
        model = attributes[BeaconProperty.Model.deviceProperty] where model ~= ".*IR.*"
      {
        device = ITachDevice.objectWithValue(uniqueIdentifier,
                                forAttribute: BeaconProperty.UniqueIdentifier.deviceProperty,
                                     context: moc) ?? ITachDevice(context: moc)
        device?.setValuesForKeysWithDictionary(attributes)
        var error: NSError?
        let saved = moc.save(&error)
        MSHandleError(error)
      }
    }
    if device != nil { self.device = device! } else { self.device = nil; return nil }
  }

  /** sendNextMessage */
  func sendNextMessage() {
    if !connected { MSLogError("cannot send messages without a socket connection"); return }

    else if var entry = messageQueue.dequeue() {

      let tag = currentTag++ // Should be the ONLY place the tag is incremented

      entry.userInfo[ITachDeviceConnection.TagKey] = tag // Add the tag to the user info

      // Remove placeholder if the entry is for a sendir command
      if entry.message.hasPrefix("sendir") { entry.message = entry.message.sub("<tag>", toString(tag)) }

      MSLogInfo("sending message with tag \(tag)")

      // Send the message
      socket?.writeData(entry.data, withTimeout: -1, tag: tag)

      messagesSending[tag] = entry
    }
  }

  /**
  connect:

  :param: completion ((Bool, NSError?) -> Void)? = nil
  */
  func connect(completion: ((Bool, NSError?) -> Void)? = nil) {
    if connecting {
      MSLogWarn("already trying to establish a connection with device")
/*
      completion?(false, NSError(domain: ConnectionManagerErrorDomain,
                                 code: ConnectionManagerErrorConnectionInProgress,
                                 userInfo: nil))

*/
      return
    }

    // Or if we are already connected
    else if connected {
      MSLogWarn("already connected to device")
/*
      completion?(false, NSError(domain: ConnectionManagerErrorDomain,
                                 code: ConnectionManagerErrorConnectionExists,
                                 userInfo: nil))

*/
      return
    }

    // Otherwise set the flag
    else { connecting = true }

    connectCallback = completion
    if socket == nil { socket = GCDAsyncSocket(delegate: self, delegateQueue: ITachDeviceConnection.ITachQueue) }
    assert(socket != nil)

    var error: NSError?
    socket?.connectToHost(device.configURL, onPort:ITachDeviceConnection.TCPPort, error: &error)
    if error != nil {
      completion?(false, error)
      connectCallback = nil
    }

  }

  /**
  disconnect:

  :param: completion ((Bool, NSError?) -> Void)? = nil
  */
  func disconnect(completion: ((Bool, NSError?) -> Void)? = nil) {
    if connected {
      disconnectCallback = completion
      socket?.disconnectAfterReadingAndWriting()
    } else {
      completion?(true, nil)
    }
  }

  /**
  enqueueCommand:completion:

  :param: command AnyObject
  :param: completion ((Bool, String?, NSError?) -> Void)? = nil
  */
  func enqueueCommand(command: AnyObject, completion: ((Bool, String?, NSError?) -> Void)? = nil) {

    var entry: MessageQueueEntry?

    // Check if we are queueing a sendir command
    if let irCommand = command as? SendIRCommand {
      let message = irCommand.commandString
      if !message.isEmpty {
        entry = MessageQueueEntry(message: message, completion: completion)
        entry?.userInfo[ITachDeviceConnection.PortKey] = command.port
      }
    }

    // Otherwise check for a string
    else if let message = command as? String {
      entry = MessageQueueEntry(message: message, completion: completion)
    }

    if entry != nil {
      messageQueue.enqueue(entry!)
      if !(connected || connecting) { connect() }
    }

  }

  /**
  socket:didConnectToHost:port:

  :param: sock GCDAsyncSocket
  :param: host String
  :param: port UInt16
  */
  func socket(sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
    connecting = false
    connectCallback?(true, nil)
    connectCallback = nil
    sendNextMessage()
  }


  enum DeviceResponse: String {
    case Learner        = "IR Learner"
    case CompleteIR     = "completeir"
    case SendIRCommand  = "sendir"
    case SendIRError    = "ERR"
    case UnknownCommand = "unknowncommand"
    case Device         = "device"
    case EndDevice      = "endlistdevices"
    case Version        = "version"
    case BusyIR         = "busyIR"
    case Network        = "NET"
    case IRConfig       = "IR"
    case StopIR         = "stopir"
  }


  /**
  socket:didReadData:withTag:

  :param: sock GCDAsyncSocket
  :param: data NSData
  :param: tag Int
  */
  func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Int) {
    let message = NSString(data: data) as String
    let entry = messagesSent.removeValueForKey(tag)

    switch message {

      case "\(DeviceResponse.CompleteIR.rawValue).*",
           "\(DeviceResponse.IRConfig.rawValue).*",
           "\(DeviceResponse.Device.rawValue).*",
           "\(DeviceResponse.Network.rawValue).*",
           "\(DeviceResponse.Version.rawValue).*":
        entry?.completion?(true, nil, nil)

      case ".*\(DeviceResponse.SendIRError.rawValue).*":
        if let errorCodeString = message.stringByMatchingFirstOccurrenceOfRegEx("[0-9]+$"),
          errorCode = errorCodeString.toInt() where errorCode < ITachDeviceConnection.ITachErrorCodes.count
        {
          let errorMessage = ITachDeviceConnection.ITachErrorCodes[errorCode]
          // let error = NSError(domain: ConnectionManagerErrorDomain,
          //                     code: ConnectionManagerErrorNetworkDeviceError,
          //                     userInfo: [NSLocalizedFailureReasonErrorKey: errorMessage])
          entry?.completion?(false, nil, nil)//error)
        }

      case "\(DeviceResponse.Learner.rawValue).*":
        if message ~= ".*Enabled.*" { learnerDelegate?.learnerEnabledOverConnection?(self) }
        else if message ~= ".*Disabled.*" { learnerDelegate?.learnerDisabledOverConnection?(self) }
        else { learnerDelegate?.learnerUnavailableOverConnection?(self) }

      case "\(DeviceResponse.StopIR.rawValue).*":
        // let error = NSError(domain: ConnectionManagerErrorDomain,
        //                     code: ConnectionManagerCommandHalted,
        //                     userInfo: nil)
        entry?.completion?(false, nil, nil)//error)

      case "\(DeviceResponse.BusyIR.rawValue).*":
        messagesSending[tag] = entry
        sendNextMessage()

      case "\(DeviceResponse.SendIRCommand.rawValue).*":
        learnerDelegate?.commandCaptured?(message, overConnection: self)

      default: break
    }
  }

  /**
  socket:didWriteDataWithTag:

  :param: sock GCDAsyncSocket
  :param: tag Int
  */
  func socket(sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {

    // Take the message sent out of our pending collection
    if let entry = messagesSending.removeValueForKey(tag) {

      // Insert it into our delivered collection
      messagesSent[tag] = entry

      // Initiate a read to receive the device response
      socket?.readDataToData(GCDAsyncSocket.CRData(),
                 withTimeout: -1,
                      buffer: nil,
                bufferOffset: 0,
                   maxLength: 0,
                         tag: tag)

      // Send next if queue is not empty
      sendNextMessage()
    }

  }

  /**
  socketDidDisconnect:withError:

  :param: sock GCDAsyncSocket
  :param: error NSError?
  */
  func socketDidDisconnect(sock: GCDAsyncSocket, withError error: NSError?) {
    disconnectCallback?(true, error)
    disconnectCallback = nil
  }

}