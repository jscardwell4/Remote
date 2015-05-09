//
//  NetworkDeviceMulticastConnection.swift
//  Remote
//
//  Created by Jason Cardwell on 5/05/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit

class NetworkDeviceMulticastConnection: NetworkDeviceConnection {

  let address: String
  let port: String

  /**
  init:port:delegate:

  :param: a String
  :param: p String
  :param: delegate NetworkDeviceConnectionDelegate?
  */
  init(address a: String, port p: String, callback: ((String) -> Void)? = nil) {
    address = a; port = p
    super.init(callback: callback)
  }

  private var _sourceFileDescriptor: dispatch_fd_t = -1
  override var sourceFileDescriptor: dispatch_fd_t {

    if _sourceFileDescriptor > -1 { return _sourceFileDescriptor }

    /// Create a UDP socket for receiving the multicast group broadcast
    ////////////////////////////////////////////////////////////////////////////////


    // Get the address info

    var socketAddress: sockaddr? = nil
    var socketAddressLength = socklen_t()
    var error = Int32()
    var socketHints = addrinfo()
    var resolve = UnsafeMutablePointer<addrinfo>()

    socketHints.ai_family = AF_UNSPEC
    socketHints.ai_socktype = SOCK_DGRAM


    self.address.withCString({ (a: UnsafePointer<Int8>) -> Void in
      self.port.withCString({ (p: UnsafePointer<Int8>) -> Void in
        error = getaddrinfo(a, p, &socketHints, &resolve)
      })
    })

    if error != 0 {
      MSLogError("error getting address info for \(address), \(port): \(toString(String.fromCString(gai_strerror(error))))")
      return -1
    }

    // Resolve into a useable socket

    var socketFileDescriptor: dispatch_fd_t = -1

    do {

      socketFileDescriptor = socket(resolve.memory.ai_family, resolve.memory.ai_socktype, resolve.memory.ai_protocol)

      if socketFileDescriptor >= 0 { // success
        socketAddress = resolve.memory.ai_addr.memory
        socketAddressLength = resolve.memory.ai_addrlen
        break
      }

      resolve = resolve.memory.ai_next

    } while resolve != nil

    freeaddrinfo(resolve)

     // Check whether loop broke on nil
    if socketAddress == nil || socketFileDescriptor < 0 {
      MSLogError("error creating multicast socket for \(address), \(port)")
      return -1
    }

    // Bind socket to multicast address info

    if bind(Int32(socketFileDescriptor), &socketAddress!, socketAddressLength) < 0 {

      close(socketFileDescriptor)
      MSLogError("failed to bind multicast socket: \(errno) - \(toString(String.fromCString(strerror(errno))))...closing socket")
      return -1
    }

    /// Join multicast group
    ////////////////////////////////////////////////////////////////////////////////

    switch Int32(socketAddress!.sa_family) {

      case AF_INET:
        let sa = unsafeBitCast(socketAddress!, sockaddr_in.self) //socketAddress as! sockaddr_in
        var mreq = ip_mreq()
        mreq.imr_multiaddr = sa.sin_addr
//        mreq.imr_interface.s_addr = in_addr(s_addr: 0)
        error = setsockopt(socketFileDescriptor, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, socklen_t(sizeofValue(mreq)))

      case AF_INET6:
        let sa = unsafeBitCast(socketAddress!, sockaddr_in6.self)
        var mreq6 = ipv6_mreq()
        mreq6.ipv6mr_multiaddr = sa.sin6_addr
        error = setsockopt(socketFileDescriptor, IPPROTO_IPV6, IPV6_JOIN_GROUP, &mreq6, socklen_t(sizeofValue(mreq6)))

      default: break

    }

    if error < 0 {
      close(socketFileDescriptor)
      MSLogError("failed to join multicast group: \(errno) - \(toString(String.fromCString(strerror(errno))))...closing socket")
      return -1
    }

    _sourceFileDescriptor = socketFileDescriptor
    return _sourceFileDescriptor
  }

}