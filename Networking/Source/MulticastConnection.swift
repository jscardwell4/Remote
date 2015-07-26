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
  joinGroup
  */
  func joinGroup() throws {
    if !joinedGroup {
      var errorMessage: String?
      do {
        try socket.bindToPort(port)
        do {
          try socket.joinMulticastGroup(address)
          joinedGroup = true
        } catch {
          errorMessage = "failed to join group \(address)"
          throw error
        }
      } catch {
        if errorMessage == nil { errorMessage = "failed to bind port \(port)" }
        MSHandleError(error as NSError, message: errorMessage)
        throw error
      }
    }
  }

  /**
  leaveGroup:

  - parameter error: NSErrorPointer

  - returns: Bool
  */
  func leaveGroup() throws {
    if joinedGroup {
      try socket.leaveMulticastGroup(address)
      joinedGroup = false
    }
  }

  /**
  listen:

  - parameter error: NSErrorPointer = nil

  - returns: Bool
  */
  func listen() throws {
    if !joinedGroup { try joinGroup() }

    if joinedGroup && !listening {
      try socket.beginReceiving()
      listening = true
    }
  }

  /** Pauses the receiving of packets if socket is listening */
  func stopListening() { if listening { socket.pauseReceiving(); listening = false } }

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
    callback?(NSString(data: data) as String)
  }

}