//: Playground - noun: a place where people can play
import Foundation
import UIKit
import MoonKit
import SystemConfiguration

var addrIn = sockaddr_in()
addrIn.sin_len = UInt8(sizeof(sockaddr_in.self))
addrIn.sin_family = sa_family_t(AF_INET)
addrIn.sin_addr.s_addr = UInt32(0xA9FE000)

var addr = unsafeBitCast(addrIn, sockaddr.self)

let reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, &addr)!

let reachabilityString = String(reflecting: reachability)



