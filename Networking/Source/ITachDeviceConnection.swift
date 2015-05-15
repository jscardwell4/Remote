//
//  ITachDeviceConnection.swift
//  Remote
//
//  Created by Jason Cardwell on 5/05/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import class DataModel.ITachDevice
import class DataModel.ITachIRCommand
import class DataModel.DataManager
import MoonKit

/**

 The `ITachDeviceConnection` class handles managing the resources necessary for
 connecting to an iTach device over TCP and the sending/receiving of messages to/from the device.
 Messages to be sent to the device are received from the connection manager and messages received
 from the iTach device are passed up to the connection manager.

 */
@objc class ITachDeviceConnection: GCDAsyncSocketDelegate {

  typealias Callback = ConnectionManager.Callback

  // MARK: - Static properties

  static let TagKey = "tag"
  static let PortKey = "port"
  static let ExpectResponseKey = "expectResponse"

  static let TCPPort: UInt16 = 4998

  typealias Error = ConnectionManager.Error

  static let ITachQueue = dispatch_queue_create("com.moondeerstudios.remote.itach", DISPATCH_QUEUE_CONCURRENT)

  // MARK: - Instance properties

  /** Messages being sent */
  private var messagesSending: OrderedDictionary<Int, MessageQueueEntry<Command>> = [:]

  /** Messages awaiting response */
  private var messagesSent: OrderedDictionary<Int, MessageQueueEntry<Command>> = [:]

  /** Connection in progress */
  private(set) var connecting = false { willSet { if newValue && connecting { MSLogWarn("already connecting") } } }

  /** Model for device */
  let device: ITachDevice

  /** Message send buffer */
  private var messageQueue: Queue<MessageQueueEntry<Command>> = Queue()

  /** Connection to device */
  private let socket: GCDAsyncSocket

  /** Current tag for new messages */
  private var currentTag: Int = 0

  /** Executed on connect */
  private var connectCallback: Callback?

  /** Executed on disconnect */
  private var disconnectCallback: Callback?

  private(set) var connected = false { willSet { if newValue && connected { MSLogWarn("already connected") } } }

  weak var learnerDelegate: ITachLearnerDelegate? {
    willSet {
      if learnerDelegate != nil {
        MSLogDebug("removing existing learner delegate from connection")
      }
    }
    didSet {
      learnerDelegate?.connection = self
      if learnerDelegate != nil {
        MSLogDebug("learner delegate added to connection")
      }
    }
  }

  // MARK: - Initialization

  /**
  initWithDevice:

  :param: device ITachDevice
  */
  init(device d: ITachDevice) {
    device = d
    socket = GCDAsyncSocket()
    socket.setDelegate(self, delegateQueue: ITachDeviceConnection.ITachQueue)
  }

  // MARK: - Sending and Receiving

  /** sendNextMessage */
  func sendNextMessage() {
    if !connected { MSLogError("cannot send messages without a socket connection") }

    else if var entry = messageQueue.dequeue() {

      let tag = currentTag++ // Should be the ONLY place the tag is incremented

      var message = entry.messageData

      switch message {
        case .SendIR(_, let command): message = .SendIR(tag, command)
        default: break
      }

      entry.messageData = message

      // Send the message
      receiveNextMessage(tag: tag)
      socket.writeData(entry.data, withTimeout: -1, tag: tag)
      messagesSending[tag] = entry
    }

    else { receiveNextMessage() }

  }

  /**
  receiveNextMessage:

  :param: tag Int = -1
  */
  func receiveNextMessage(tag: Int = -1) {
    if connected {
      socket.readDataToData(GCDAsyncSocket.CRData(),
                withTimeout: -1,
                     buffer: nil,
               bufferOffset: 0,
                  maxLength: 0,
                        tag: tag)
    }
  }


  /**
  enqueueCommand:completion:

  :param: command ITachIRCommand
  :param: completion Callback? = nil
  */
  func enqueueCommand(command: ITachIRCommand, completion: Callback? = nil) {
    enqueueEntry(MessageQueueEntry(messageData: .SendIR(-1, command),
                                   userInfo: [ITachDeviceConnection.PortKey:Int(command.port)],
                                   completion: completion))
  }

  /**
  enqueueCommand:completion:

  :param: command Command
  :param: completion Callback? = nil
  */
  func enqueueCommand(command: Command, completion: Callback? = nil) {
    enqueueEntry(MessageQueueEntry(messageData: command,
                                   userInfo: [ITachDeviceConnection.ExpectResponseKey: command.expectResponse],
                                   completion: completion))
  }

  /**
  enqueueEntry:completion:

  :param: entry MessageQueueEntry
  */
  private func enqueueEntry(entry: MessageQueueEntry<Command>) {
    if entry.message.isEmpty {
      entry.completion?(false, Error.CommandEmpty.error())
    } else {
      messageQueue.enqueue(entry)
      if (!connected || connecting) { connect() {[unowned self] success, _ in if success { self.sendNextMessage() } } }
      else { sendNextMessage() }
    }
  }

  // MARK: - Connecting

  /**
  connect:

  :param: completion Callback? = nil
  */
  func connect(completion: Callback? = nil) {
    if connecting { completion?(false, Error.ConnectionInProgress.error()) }

    // Or if we are already connected
    else if connected { completion?(false, Error.ConnectionExists.error()) }

    // Otherwise set the flag
    else {
      connecting = true
      connectCallback = completion

      var error: NSError?
      socket.connectToHost(device.configURL, onPort:ITachDeviceConnection.TCPPort, error: &error)
      if error != nil {
        completion?(false, error)
        connectCallback = nil
      }
    }
  }

  /**
  disconnect:

  :param: completion Callback? = nil
  */
  func disconnect(completion: Callback? = nil) {
    if connected {
      disconnectCallback = completion
      socket.disconnectAfterReadingAndWriting()
    } else {
      completion?(true, nil)
    }
  }

  // MARK: - GCGAsyncSocketDelegate

  /**
  socket:didConnectToHost:port:

  :param: sock GCDAsyncSocket
  :param: host String
  :param: port UInt16
  */
  func socket(sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
    MSLogDebug("connected to host '\(host)' over port '\(port)'")
    connecting = false
    connected = true
    connectCallback?(true, nil)
    connectCallback = nil

    sendNextMessage()
  }

  /**
  socket:didReadData:withTag:

  :param: sock GCDAsyncSocket
  :param: data NSData
  :param: tag Int
  */
  func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Int) {
    // TODO: Tag numbers are still getting all out of whack

    let message = NSString(data: data) as String

    let completion: Callback?
    let entry: MessageQueueEntry? = messagesSent[tag]
    let expected = entry?.messageData.expectResponse


    if let expect = expected?.first where expected!.count == 1 && message ~= ~/expect {
      completion = messagesSent.removeValueForKey(tag)?.completion
    } else if let expect = expected?.first where expected!.count == 2 && message ~= ~/expect {
      completion = nil
    } else if let expect = expected?.last where expected!.count == 2 && message ~= ~/expect {
      completion = messagesSent.removeValueForKey(tag)?.completion
    } else {
      completion = nil
      receiveNextMessage(tag: tag)
    }
    
    MSLogDebug("response received '\(message)' with tag '\(tag)'")

    if let response = Response(response: message) {
      switch response {
        case .UnknownCommand (let e):
          completion?(false, Error.NetworkDeviceError.error(userInfo: [NSLocalizedFailureReasonErrorKey:e.reason]))
        case .BusyIR(_, let t) where t == tag:
          messagesSending[t] = entry
          sendNextMessage()
        case .StopIR(let t) where t == tag:
          completion?(false, Error.CommandHalted.error())
        case .CapturedCommand(let c):
          learnerDelegate?.commandCaptured(c)
        case .LearnerEnabled:
          learnerDelegate?.learnerEnabled()
        case .LearnerDisabled:
          learnerDelegate?.learnerDisabled()
        case .LearnerUnavailable:
          learnerDelegate?.learnerUnavailable()
        case .CompleteIR, .Device, .EndListDevices, .Version, .Network, .IRConfig:
          completion?(true, nil)
        default:
          completion?(false, nil)
      }
    } else {
      completion?(false, nil)
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

      MSLogDebug("entry written with message '\(entry.message)' and tag '\(tag)'")

      // Insert it into our delivered collection
      messagesSent[tag] = entry

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
    MSLogDebug("socket disconnected with error: \(toString(descriptionForError(error)))")
    disconnectCallback?(true, error)
    disconnectCallback = nil
  }

  // MARK: - ITachError enumeration
  enum ITachError: String {
    case ERR_01 = "ERR_01"
    case ERR_02 = "ERR_02"
    case ERR_03 = "ERR_03"
    case ERR_04 = "ERR_04"
    case ERR_05 = "ERR_05"
    case ERR_06 = "ERR_06"
    case ERR_07 = "ERR_07"
    case ERR_08 = "ERR_08"
    case ERR_09 = "ERR_09"
    case ERR_10 = "ERR_10"
    case ERR_11 = "ERR_11"
    case ERR_12 = "ERR_12"
    case ERR_13 = "ERR_13"
    case ERR_14 = "ERR_14"
    case ERR_15 = "ERR_15"
    case ERR_16 = "ERR_16"
    case ERR_17 = "ERR_17"
    case ERR_18 = "ERR_18"
    case ERR_19 = "ERR_19"
    case ERR_20 = "ERR_20"
    case ERR_21 = "ERR_21"
    case ERR_22 = "ERR_22"
    case ERR_23 = "ERR_23"
    case ERR_24 = "ERR_24"
    case ERR_25 = "ERR_25"
    case ERR_26 = "ERR_26"
    case ERR_27 = "ERR_27"

    var reason: String {
      switch self {
        case .ERR_01: return "Invalid command. Command not found"
        case .ERR_02: return "Invalid module address (does not exist)"
        case .ERR_03: return "Invalid connector address (does not exist)"
        case .ERR_04: return "Invalid ID value"
        case .ERR_05: return "Invalid frequency value"
        case .ERR_06: return "Invalid repeat value"
        case .ERR_07: return "Invalid offset value"
        case .ERR_08: return "Invalid pulse count"
        case .ERR_09: return "Invalid pulse data"
        case .ERR_10: return "Uneven amount of <on|off> statements"
        case .ERR_11: return "No carriage return found"
        case .ERR_12: return "Repeat count exceeded"
        case .ERR_13: return "IR command sent to input connector"
        case .ERR_14: return "Blaster command sent to non-blaster connector"
        case .ERR_15: return "No carriage return before buffer full"
        case .ERR_16: return "No carriage return"
        case .ERR_17: return "Bad command syntax"
        case .ERR_18: return "Sensor command sent to non-input connector"
        case .ERR_19: return "Repeated IR transmission failure"
        case .ERR_20: return "Above designated IR <on|off> pair limit"
        case .ERR_21: return "Symbol odd boundary"
        case .ERR_22: return "Undefined symbol"
        case .ERR_23: return "Unknown option"
        case .ERR_24: return "Invalid baud rate setting"
        case .ERR_25: return "Invalid flow control setting"
        case .ERR_26: return "Invalid parity setting"
        case .ERR_27: return "Settings are locked"
      }
    }


  }

}