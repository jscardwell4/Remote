//
//  MulticastConnection.swift
//  Remote
//
//  Created by Jason Cardwell on 5/7/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit



class MulticastConnection: GCDAsyncUdpSocketDelegate {

  let address: String
  let port: UInt16
  let callback: ((String) -> Void)?

  private var listening = false
  private var joinedGroup = false

  private let socket: GCDAsyncUdpSocket
  private static let queue = dispatch_queue_create("com.moondeerstudios.networking.multicast", DISPATCH_QUEUE_SERIAL)

  enum Error: WrappedErrorType { 
    
    case JoinGroup (ErrorType)
    case LeaveGroup (ErrorType)
    case BindPort (ErrorType)
    case BeginReceiving (ErrorType)

    var underlyingError: ErrorType? {
      switch self { 
        case .JoinGroup(let error): return error
        case .BindPort(let error):  return error
        case .LeaveGroup(let error): return error
        case .BeginReceiving(let error):  return error
      }
    }
  }

  /**
  init:port:

  - parameter a: String
  - parameter p: UInt16
  */
  init(address: String, port: UInt16, callback: ((String) -> Void)? = nil) {
    self.address = address; self.port = port; self.callback = callback
    socket = GCDAsyncUdpSocket()
    socket.setDelegate(self)
    socket.setDelegateQueue(MulticastConnection.queue)
  }


  /**
  Open socket connection to multicast group

  - throws: `MulticastConnection.Error.BindPort` or `MulticastConnection.Error.JoinGroup`
  */
  func joinGroup() throws {

    guard !joinedGroup else { return }
    
    do { try socket.bindToPort(port) }            catch { throw Error.BindPort(error) }
    do { try socket.joinMulticastGroup(address) } catch { throw Error.JoinGroup(error) }
    
    joinedGroup = true
  }

  /**
  Close socket connection to multicast group

  - throws: `MulticastConnection.Error.LeaveGroup`
  */
  func leaveGroup() throws {
    guard joinedGroup else { return }
    do { try socket.leaveMulticastGroup(address) } catch { throw Error.LeaveGroup(error) }
    joinedGroup = false
  }

  /**
  Begin receiving over socket, joining group first if necessary

  - throws: `MulticastConnection.Error.JoinGroup`, `MulticastConnection.Error.BindPort`, 
             or `MulticastConnection.Error.BeginReceiving`
  */
  func listen() throws {
    guard !listening else { return }
    if !joinedGroup { try joinGroup() }
    do { try socket.beginReceiving() } catch { throw Error.BeginReceiving(error) }
    listening = true
  }

  /** Pauses the receiving of packets if socket is listening */
  func stopListening() { guard listening else { return };  socket.pauseReceiving(); listening = false }

  // MARK: - GCDAsyncUdpSocketDelegate

  /**
  udpSocket:didReceiveData:fromAddress:withFilterContext:

  - parameter sock: GCDAsyncUdpSocket!
  - parameter data: NSData!
  - parameter address: NSData!
  - parameter filterContext: AnyObject!
  */
  @objc func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!,
    withFilterContext filterContext: AnyObject!)
  {
    guard let dataString = String(data: data) else { return }
    callback?(dataString)
  }

}