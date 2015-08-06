//: Playground - noun: a place where people can play
import Foundation
import UIKit
import MoonKit

let message = "NOTIFY * HTTP/1.1\r\nCACHE-CONTROL:max-age=120\r\nLOCATION:http://10.0.0.252/desc\r\nNT:uuid:00:21:b9:01:f2:b6\r\nNTS:ssdp:alive\r\nSERVER:UCoS, UPnP/1.0, UDI/1.0\r\nUSN:uuid:00:21:b9:01:f2:b6"

let match = (~/"\r\nUSN:uuid:([0-9a-f:]{17})").match(message)
//let match = (~/"(\r\n)").match((message as NSString) as String)
print(match)
