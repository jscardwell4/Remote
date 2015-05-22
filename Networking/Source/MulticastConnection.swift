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

  :param: a String
  :param: p UInt16
  */
  init(address: String, port: UInt16, callback: ((String) -> Void)? = nil) {
    self.address = address; self.port = port; self.callback = callback
    socket = GCDAsyncUdpSocket()
    socket.setDelegate(self)
    socket.setDelegateQueue(MulticastConnection.queue)
  }


  /**
  joinGroup:

  :param: error NSErrorPointer

  :returns: Bool
  */
  func joinGroup(error: NSErrorPointer) -> Bool {
    if !joinedGroup {
      var localError: NSError?
      let boundPort = socket.bindToPort(port, error: &localError)
      if boundPort && !MSHandleError(localError, message: "failed to bind port \(port)") {
        joinedGroup = socket.joinMulticastGroup(address, error: &localError)
        MSHandleError(localError, message: "failed to join group \(address)")
      }

      if let e = localError { error.memory = e }
    }
    return joinedGroup
  }

  /**
  leaveGroup:

  :param: error NSErrorPointer

  :returns: Bool
  */
  func leaveGroup(error: NSErrorPointer) -> Bool {
    if joinedGroup && socket.leaveMulticastGroup(address, error: error) { joinedGroup = false }
    return !joinedGroup
  }

  /**
  listen:

  :param: error NSErrorPointer = nil

  :returns: Bool
  */
  func listen(error: NSErrorPointer = nil) -> Bool {
    if !joinedGroup { joinGroup(error) }
    if joinedGroup && !listening {
      listening = socket.beginReceiving(error)
    }
    return listening
  }

  /** Pauses the receiving of packets if socket is listening */
  func stopListening() { if listening { socket.pauseReceiving(); listening = false } }

  // MARK: - GCDAsyncUdpSocketDelegate

  /**
  udpSocket:didReceiveData:fromAddress:withFilterContext:

  :param: sock GCDAsyncUdpSocket!
  :param: data NSData!
  :param: address NSData!
  :param: filterContext AnyObject!
  */
  func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!,
    withFilterContext filterContext: AnyObject!)
  {
    if let string = NSString(data: data) as? String { callback?(string) }
  }

}