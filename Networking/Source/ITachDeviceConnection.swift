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
final class ITachDeviceConnection {

  typealias Callback = ConnectionManager.Callback
  typealias Error = ConnectionManager.Error

  // MARK: - Static properties
  enum InfoKey: String { case Port, ExpectResponse }

  static let TCPPort: UInt16 = 4998

  // typealias Error = ConnectionManager.Error
  typealias MessageQueue = Queue<MessageQueueEntry<Command>>
  typealias MessageTag = Int
  typealias TaggedMessageIndex = OrderedDictionary<MessageTag, MessageQueueEntry<Command>>

  static let ITachQueue = dispatch_queue_create("com.moondeerstudios.remote.itach", DISPATCH_QUEUE_CONCURRENT)

  // MARK: - Instance properties

  /** Messages being sent */
  private var messagesSending: TaggedMessageIndex = [:]

  /** Messages awaiting response */
  private var messagesSent: TaggedMessageIndex = [:]

  /** Connection in progress */
  private(set) var connecting = false { willSet { if newValue && connecting { MSLogWarn("already connecting") } } }

  /** Model for device */
  let device: ITachDevice

  /** Message send buffer */
  private var messageQueue: MessageQueue = Queue()

  /** Connection to device */
  private let socket: GCDAsyncSocket

  /** Current tag for new messages */
  private var currentTag: MessageTag = 0

  /** Executed on connect */
  private var connectCallback: Callback?

  /** Executed on disconnect */
  private var disconnectCallback: Callback?

  private(set) var connected = false { willSet { if newValue && connected { MSLogWarn("already connected") } } }

  weak var learnerDelegate: ITachLearnerDelegate? { didSet { learnerDelegate?.connection = self } }

  // MARK: - Initialization

  /**
  initWithDevice:

  - parameter device: ITachDevice
  */
  init(device d: ITachDevice) {
    device = d
    socket = GCDAsyncSocket()
    socket.setDelegate(self, delegateQueue: ITachDeviceConnection.ITachQueue)
  }

  // MARK: - Sending and Receiving

  /** 
  sendNextMessage 
  
  - throws: `ITachDeviceConnection.Error.NoSocketConnection`
  */
  func sendNextMessage() throws {

    guard connected else { throw Error.NoSocketConnection }

    guard var entry = messageQueue.dequeue() else { try receiveNextMessage(); return }

    let tag = currentTag++ // Should be the ONLY place the tag is incremented

    var message = entry.messageData

    if case .SendIR(_, let command) = message { message = .SendIR(tag, command) }

    entry.messageData = message

    // Send the message
    try receiveNextMessage(tag)
    socket.writeData(entry.data, withTimeout: -1, tag: tag)
    messagesSending[tag] = entry

  }

  /**
  receiveNextMessage:

  - parameter tag: Int = -1

  - throws: `ITachDeviceConnection.Error.NoSocketConnection`
  */
  func receiveNextMessage(tag: Int = -1) throws {
    guard connected else { throw Error.NoSocketConnection }
    socket.readDataToData(GCDAsyncSocket.CRData(),
              withTimeout: -1,
                   buffer: nil,
             bufferOffset: 0,
                maxLength: 0,
                      tag: tag)
  }


  /**
  enqueueCommand:completion:

  - parameter command: ITachIRCommand
  - parameter completion: Callback? = nil
  */
  func enqueueCommand(command: ITachIRCommand, completion: Callback? = nil) throws {
    let entry = MessageQueueEntry(messageData: Command.SendIR(-1, command),
                                  info: [InfoKey.Port.rawValue:Int(command.port)],
                                  completion: completion)
    try enqueueEntry(entry)
  }

  /**
  enqueueCommand:completion:

  - parameter command: Command
  - parameter completion: Callback? = nil
  */
  func enqueueCommand(command: Command, completion: Callback? = nil) throws {
    let entry = MessageQueueEntry(messageData: command,
                                  info: [InfoKey.ExpectResponse.rawValue: command.expectResponse],
                                  completion: completion)
    try enqueueEntry(entry)
  }

  /**
  enqueueEntry:completion:

  - parameter entry: MessageQueueEntry
  
  - throws: Empty message error or any error attempting to send next message
  */
  private func enqueueEntry(entry: MessageQueueEntry<Command>) throws {
    guard !entry.message.isEmpty else { throw Error.EmptyMessage }

    messageQueue.enqueue(entry)

    guard connected || connecting else {
      try connect {[unowned self] success, _ in if success { try! self.sendNextMessage() } }
      return
    }

    try sendNextMessage()
  }

  // MARK: - Connecting

  /**
  connect:

  - parameter completion: Callback? = nil

  - throws: `ITachDeviceConnection.Error.ConnectionInProgress`, `ITachDeviceConnection.Error.ConnectionExists`, 
            or any error encountered connecting to host
  */
  func connect(completion: Callback? = nil) throws {
    guard !connecting else { throw Error.ConnectionInProgress }
    guard !connected else { throw Error.ConnectionExists }

    try socket.connectToHost(device.configURL, onPort:ITachDeviceConnection.TCPPort)

    connecting = true
    connectCallback = completion
  }

  /**
  disconnect:

  - parameter completion: Callback? = nil
  */
  func disconnect(completion: Callback? = nil) {
    guard connected else { completion?(true, nil); return }
    disconnectCallback = completion
    socket.disconnectAfterReadingAndWriting()
  }

}

// MARK: - GCGAsyncSocketDelegate

extension ITachDeviceConnection: GCDAsyncSocketDelegate {

  /**
  socket:didConnectToHost:port:

  - parameter sock: GCDAsyncSocket
  - parameter host: String
  - parameter port: UInt16
  */
  @objc func socket(sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
    MSLogInfo("connected to host '\(host)' over port '\(port)'")
    connecting = false
    connected = true
    connectCallback?(true, nil)
    connectCallback = nil

    do { try sendNextMessage() } catch { logError(error) }
  }

  /**
  socket:didReadData:withTag:

  - parameter sock: GCDAsyncSocket
  - parameter data: NSData
  - parameter tag: Int
  */
  @objc func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Int) {
    // TODO: Tag numbers are still getting all out of whack (7/30/15 -- Still?)

    guard let message = String(data: data) else { MSLogWarn("failed to turn received data into a string"); return }

    let completion: Callback?
    let entry: MessageQueueEntry? = messagesSent[tag]
    let expected = entry?.messageData.expectResponse

    switch expected?.count {
      case 1 where message ~= expected!.first!: fallthrough
      case 2 where message ~= expected!.first!: completion = messagesSent.removeValueForKey(tag)?.completion
      case 2 where message ~= expected!.first!: do { try receiveNextMessage(tag) } catch { logError(error) }; completion = nil
      default:                                  completion = nil
    }

    MSLogDebug("response received '\(message)' with tag '\(tag)'")


    guard let response = Response(response: message) else { completion?(false, Error.InvalidResponse); return }

    switch response {

      case .UnknownCommand (let e):         completion?(false, Error.DeviceError(e))
      case .BusyIR(_, let t) where t == tag: messagesSending[t] = entry; do { try sendNextMessage() } catch { logError(error) }
      case .StopIR(let t) where t == tag:    completion?(false, Error.CommandHalted)
      case .CapturedCommand(let c):          learnerDelegate?.commandCaptured(c)
      case .LearnerEnabled:                  learnerDelegate?.learnerEnabled()
      case .LearnerDisabled:                 learnerDelegate?.learnerDisabled()
      case .LearnerUnavailable:              learnerDelegate?.learnerUnavailable()
      case .CompleteIR,
           .Device,
           .EndListDevices,
           .Version,
           .Network,
           .IRConfig:                        completion?(true, nil)
      default:                               completion?(false, Error.InvalidResponse)

    }

  }

  /**
  socket:didWriteDataWithTag:

  - parameter sock: GCDAsyncSocket
  - parameter tag: Int
  */
  @objc func socket(sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {

    // Take the message sent out of our pending collection
    guard let entry = messagesSending.removeValueForKey(tag) else { return }

    MSLogDebug("entry written with message '\(entry.message)' and tag '\(tag)'")

    // Insert it into our delivered collection
    messagesSent[tag] = entry

    // Send next if queue is not empty
    do { try sendNextMessage() } catch { logError(error) }

  }

  /**
  socketDidDisconnect:withError:

  - parameter sock: GCDAsyncSocket
  - parameter error: NSError?
  */
  @objc func socketDidDisconnect(sock: GCDAsyncSocket, withError error: NSError?) {
    guard let callback = disconnectCallback else { return }

    let connectionError: Error? = error == nil ? nil : Error.ConnectionError(error!)

    callback(connectionError == nil, connectionError)
    disconnectCallback = nil
  }

}

// MARK: - ITachError enumeration
public enum ITachError: String, ErrorType, CustomStringConvertible {
  case ERR_01, ERR_02, ERR_03, ERR_04, ERR_05, ERR_06, ERR_07, ERR_08, ERR_09, ERR_10, ERR_11, ERR_12, ERR_13, 
       ERR_14, ERR_15, ERR_16, ERR_17, ERR_18, ERR_19, ERR_20, ERR_21, ERR_22, ERR_23, ERR_24, ERR_25, ERR_26, 
       ERR_27

  public var description: String {
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

