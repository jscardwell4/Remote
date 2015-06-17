//
//  MulticastConnection.swift
//  Remote
//
//  Created by Jason Cardwell on 5/7/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit



@objc class MulticastConnection: GCDAsyncUdpSocketDelegate {

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
  joinGroup:

  - parameter error: NSErrorPointer

  - returns: Bool
  */
  func joinGroup() throws {
    var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
    if !joinedGroup {
      var localError: NSError?
      let boundPort: Bool
      do {
        try socket.bindToPort(port)
        boundPort = true
      } catch var error as NSError {
        localError = error
        boundPort = false
      }
      if boundPort && !MSHandleError(localError, message: "failed to bind port \(port)") {
        do {
          try socket.joinMulticastGroup(address)
          joinedGroup = true
        } catch var error as NSError {
          localError = error
          joinedGroup = false
        }
        MSHandleError(localError, message: "failed to join group \(address)")
      }

      if let e = localError { error = e }
    }
    if joinedGroup {
      return
    }
    throw error
  }

  /**
  leaveGroup:

  - parameter error: NSErrorPointer

  - returns: Bool
  */
  func leaveGroup() throws {
    var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
    if joinedGroup && socket.leaveMulticastGroup(address) { joinedGroup = false }
    if !joinedGroup {
      return
    }
    throw error
  }

  /**
  listen:

  - parameter error: NSErrorPointer = nil

  - returns: Bool
  */
  func listen() throws {
    var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
    if !joinedGroup { do {
        try joinGroup()
      } catch var error1 as NSError {
        error = error1
      } }
    if joinedGroup && !listening {
      do {
        try socket.beginReceiving()
        listening = true
      } catch var error1 as NSError {
        error = error1
        listening = false
      }
    }
    if listening {
      return
    }
    throw error
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
  func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!,
    withFilterContext filterContext: AnyObject!)
  {
    if let string = NSString(data: data) as? String { callback?(string) }
  }

}