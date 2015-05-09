//
//  ITachDeviceConnection.Command.swift
//  Remote
//
//  Created by Jason Cardwell on 5/8/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import class DataModel.IRCode
import class DataModel.ITachIRCommand

extension ITachDeviceConnection {
  enum Command: MessageData {
    /**
    Sent from each iTach module in response to `getdevices`: `device,<moduleaddress>,<moduletype>` where <moduleaddress> is
    |0|1| and `<moduletype>` is |WIFI|ETHERNET|3 RELAY|3 IR|1 SERIAL|
    All modules are included in the response followed by `endlistdevices↵`

    The following are the possible iTachIR responses to a `getdevices` command:

    `device,0,0 WIFI↵device,1,3 IR↵endlistdevices↵` for WiFi to three infrared

    `device,0,0 WIFI↵device,1,1 SERIAL↵endlistdevices↵` for WiFi to one serial

    `device,0,0 WIFI↵device,1,3 RELAY↵endlistdevices↵` for WiFi to three relays

    `device,0,0 ETHERNET↵device,1,3 IR↵endlistdevices↵` for IP to three infrared

    `device,0,0 ETHERNET↵device,1,1 SERIAL↵endlistdevices↵` for IP to one serial

    `device,0,0 ETHERNET↵device,1,3 RELAY↵endlistdevices↵` for IP to three relays

    */
    case GetDevices

    /**
    Sent from iTach in response to `get_NET` command:


    `NET,0:1,<configlock>,<ipsettings>,<ipaddress>,<subnet>,<gateway>`

    where <configlock> = |LOCKED|UNLOCKED|, <ipsettings> = |DHCP|STATIC|, <ipaddress> is the assigned network IP,  <subnet>
    is the network subnet mask and <gateway> is the default network gateway
    */
    case GetNET

    /**
    Sent from iTach in response to `get_IRL`: `IR Learner Enabled↵`

    Sent from iTach in response to `get_IRL` when configured with an LED_LIGHTING connector: `IR Learner Unavailable↵`
    */
    case GetIRL

    /** Sent from iTach in response to `stop_IRL`: `IR Learner Disabled↵` */
    case StopIRL

    /**
    `sendir`,<connectoraddress>,<ID>,<frequency>,<repeat>,<offset>,<on1>,<off1>,<on2>,<off2>,....,<onN>,<offN>↵
    (where N is less than 260 or a total of 520 numbers)

    :<connectoraddress>: <module>:<port> where <module> is always 1 and <port> is any number between 1 and 3
    :<ID>: Any number between 0 and 65535
    :<frequency>: Any number between 15000 and 500000 representing frequency in hertz
    :<repeat>: Any number between 1 and 50 (the IR command is sent <repeat> times)
    :<offset>: Any odd number between 1 and 383 (used if <repeat> is greater than 1)
    :<on1>: Any number between 1 and 65635 (number of pulses)
    :<off1>: Any number between 1 and 65635 (absence of pulse periods of the carrier frequency)

    Sent in response when `sendir` command completes successfully:
    `completeir`,<connectoraddress>,<ID>

    Associated values represent port, id, frequency, repeat, offset and on-off-pattern
    */
    case SendIR (Int, ITachIRCommand)

    var expectResponse: [String] {
      switch self {
      case .GetDevices:
        return ["^device[^\\r]+\\r$", "endlistdevices\\r$"]
      case .GetNET:
        return ["^NET[^\\r]+\\r$"]
      case .GetIRL:
        return ["^IR Learner (?:Enabled|Unavailable)\\r$"]
      case .StopIRL:
        return ["^IR Learner Disabled\\r$"]
      case let .SendIR(id, command):
        return ["^(?:complete|busy)ir,1:\(command.port),\(id)\\r$"]
      }
    }

    var msg: String {
      switch self {
        case .GetDevices: return "getdevices\r"
        case .GetNET:     return "get_NET,0:1\r"
        case .GetIRL:     return "get_IRL\r"
        case .StopIRL:    return "stop_IRL\r"
        case let .SendIR(id, command):
          let port = command.port
          let frequency = command.code.frequency
          let repeat = command.code.repeatCount
          let offset = command.code.offset
          let pattern = command.code.onOffPattern
          return "sendir,1:\(port),\(id),\(frequency),\(repeat),\(offset),\(pattern)\\r"
      }
    }

    var data: NSData { return msg.dataUsingEncoding(NSUTF8StringEncoding)! }
  }

}