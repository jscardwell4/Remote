//
//  NetworkReachability.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/7/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import SystemConfiguration

private let IN_LINKLOCALNETNUM = UInt32(0xA9FE000)

private(set) var contextInfo = UnsafeMutablePointer<Void>.alloc(1)

private let block: @objc_block (SCNetworkReachability!, SCNetworkReachabilityFlags, UnsafeMutablePointer<Void>) -> Void = {
  _, flags, context in

  UnsafeMutablePointer<NetworkReachability>(context).memory.callback(flags)
}
private let imp = imp_implementationWithBlock(unsafeBitCast(block, AnyObject.self))
private let handler = unsafeBitCast(imp, SCNetworkReachabilityCallBack.self)


public class NetworkReachability: NSObject {

  public typealias Callback = (SCNetworkReachabilityFlags) -> Void

  private let callback: Callback

  private static let queue = dispatch_queue_create("com.moondeerstudios.moonkit.reachability", DISPATCH_QUEUE_SERIAL)

  public private(set) var flags = SCNetworkReachabilityFlags()

  public func refreshFlags() {
    var flags = SCNetworkReachabilityFlags()
    SCNetworkReachabilityGetFlags(reachability, &flags)
    self.flags = flags
    callback(flags)
  }

  public init(callout: Callback) {
    callback = callout

    var addrIn = sockaddr_in()
    addrIn.sin_len = UInt8(sizeof(sockaddr_in.self))
    addrIn.sin_family = sa_family_t(AF_INET)
    addrIn.sin_addr.s_addr = IN_LINKLOCALNETNUM

    var addr = unsafeBitCast(addrIn, sockaddr.self)

    reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, &addr).takeRetainedValue()

    super.init()
    var info = self
    var context = SCNetworkReachabilityContext(version: 0, info: &info, retain: nil, release: nil, copyDescription: nil)


    var success = SCNetworkReachabilitySetCallback(reachability, handler, &context)
    assert(success != 0)

    success = SCNetworkReachabilitySetDispatchQueue(reachability, NetworkReachability.queue)
    assert(success != 0)
  }

  private let reachability: SCNetworkReachability
}