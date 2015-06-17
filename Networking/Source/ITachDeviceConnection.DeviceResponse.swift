//
//  ITachDeviceConnection.DeviceResponse.swift
//  Remote
//
//  Created by Jason Cardwell on 5/8/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit

extension ITachDeviceConnection {
  // TODO: Add response for (set|get)_SERIAL, (get|set)state
  enum Response {
    enum IRMode: String {
      case IR            = "IR"
      case Sensor        = "SENSOR"
      case SensorNotify = "SENSOR_NOTIFY"
      case IRBlaster    = "IR_BLASTER"
      case LedLighting  = "LED_LIGHTING"
    }

    enum ModuleType: String {
      case Wifi       = "WIFI"
      case Ethernet   = "ETHERNET"
      case ThreeRelay = "3 RELAY"
      case ThreeIR    = "3 IR"
      case OneSerial  = "1 SERIAL"
    }

    case LearnerEnabled
    case LearnerDisabled
    case LearnerUnavailable
    case CompleteIR (Int, Int)
    case CapturedCommand (String)
    case UnknownCommand (ITachError)
    case Device (Int, Int, ModuleType)
    case EndListDevices
    case Version (Int?, String)
    case BusyIR (Int, Int)
    case Network (Bool, String, String, String, String)
    case IRConfig (Int, IRMode)
    case StopIR (Int)

    init?(response: String) {
      switch response {
        case ~/"^unknowncommand,ERR_[0-9]{2}\\r$":
          if let err = ITachError(rawValue: response[15...20]) { self = .UnknownCommand(err) }
          else { return nil }
        case ~/"^IR Learner Enabled\\r$":
          self = .LearnerEnabled
        case ~/"^IR Learner Disabled\\r$":
          self = .LearnerDisabled
        case ~/"^IR Learner Unavailabler":
          self = .LearnerUnavailable
        case ~/"^completeir,1:[1-3],[0-9]+\\r$":
          if let port = Int(response[13...13]), tag = Int(",".split(response).last?) {
            self = .CompleteIR(port, tag)
          } else { return nil }
        case ~/"^busyIR,1:[1-3],[0-9]+\\r$":
          if let port = Int(response[13...13]), tag = Int(",".split(response).last?) {
            self = .BusyIR(port, tag)
          } else { return nil }
        case ~/"^IR,1:[1-3],[A-Z_]+\\r$":
          if let port = Int(response[5...5]), raw = ",".split(response).last, mode = IRMode(rawValue: raw) {
            self = .IRConfig(port, mode)
          } else { return nil }
        case ~/"^stopir,1:[1-3]\r":
          if let port = Int(response[9...9]) { self = StopIR(port) } else { return nil }
        case ~/"^version,(?:[0-1],)?[0-9.]+\\r$":
          let components = ",".split(response)
          if components.count == 3, let module = Int(components[1]) {
            self = .Version(module, components[2][0 ..< components[2].length - 2])
          }
          else if components.count == 2 { self = .Version(nil, response[8 ..< response.length - 2]) }
          else { return nil}
        case ~/"^endlistdevices\\r$":
          self = .EndListDevices
        case ~/"^device,[0-1],[0-3],[A-Z 13]+\\r$":
          let components = ",".split(response)
          if let module = Int(components[1]),
            port = Int(components[2]),
            type = ModuleType(rawValue: components[3][0 ..< components[3].length - 2])
          {
            self = .Device(module, port, type)
          } else { return nil }
        case ~/"^NET,0:1,(?:UN)?LOCKED,(?:DHCP|STATIC),[0-9.]+,[0-9.]+,[0-9]+\\r$":
          let components = ",".split(response[0 ..< response.length - 2])
          self = .Network(components[2] == "LOCKED", components[3], components[4], components[5], components[6])
        case ~/"^sendir.*\\r$":
          self = .CapturedCommand(response)
        default:
          return nil
      }
    }

  }

}