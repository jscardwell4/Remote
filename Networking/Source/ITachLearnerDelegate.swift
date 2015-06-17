//
//  ITachLearnerDelegate.swift
//  Remote
//
//  Created by Jason Cardwell on 5/7/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit
import CoreData
import class DataModel.ITachDevice
import class DataModel.ITachIRCommand
import class DataModel.DataManager

public class ITachLearnerDelegate {

  public typealias Callback = ConnectionManager.Callback

  /**
  Attempt to connect to the specified device. Only succeeds if connection can be established, and did not already exist
  with another learner delegate assigned to it

  - parameter device: ITachDevice

  - returns: Bool
  */
  public func connectToDevice(device: ITachDevice) -> Bool {
    let connection = ITachConnectionManager.connectionForDevice(device)
    if let existingDelegate = connection.learnerDelegate where existingDelegate !== self {
      MSLogWarn("attempt to replace existing learner delegate over connection for device '\(device.uniqueIdentifier)'")
      return false
    } else {
      self.connection = connection
      connection.learnerDelegate = self
      return true
    }
  }

  /** Set in `enableLearner:` and invoked when a response has been received */
  private var learnerEnabledCallback: Callback?

  /** Set in `disableLearner:` and invoked when a response has been received */
  private var learnerDisabledCallback: Callback?

  /**
  Enables IR learning over connection

  - parameter callback: Callback? = nil
  */
  public func enableLearner(callback: Callback? = nil) {
    MSLogDebug("")
    if isLearnerAvailable {
      learnerEnabledCallback = callback
      connection?.enqueueCommand(.GetIRL)
    }
  }

  /**
  Disables IR learning over connection

  - parameter callback: Callback? = nil
  */
  public func disableLearner(callback: Callback? = nil) {
    MSLogDebug("")
    if isLearnerEnabled {
      learnerDisabledCallback = callback
      connection?.enqueueCommand(.StopIRL)
    }
  }

  /** Stores last known state of device IRL */
  public private(set) var isLearnerEnabled = false

  /** Invoked by `ITachDeviceConnection` when an enabled response has been received */
  func learnerEnabled() {
    MSLogDebug("")
    isLearnerEnabled = true
    learnerEnabledCallback?(true, nil)
    learnerEnabledCallback = nil
  }


  /** Invoked by `ITachDeviceConnection` when a disabled response has been received */
  func learnerDisabled() {
    MSLogDebug("")
    isLearnerEnabled = false
    learnerDisabledCallback?(true, nil)
    learnerDisabledCallback = nil
  }

  /** `true` until an unavailable response has been received */
  public private(set) var isLearnerAvailable = true

  /** Invoked by `ITachDeviceConnection` when an unavailable response has been received */
  func learnerUnavailable() {
    MSLogDebug("")
    isLearnerAvailable = false
    if let callback = learnerEnabledCallback { callback(false, nil); learnerEnabledCallback = nil }
    else if let callback = learnerDisabledCallback { callback(false, nil); learnerDisabledCallback = nil }
  }

  /**
  Invoked by `ITachDeviceConnection` when a sendir response has been received

  - parameter command: String
  */
  func commandCaptured(command: String) {
    let chunks = ",".split(command)

    var compressed = ",".join(chunks[0 ... 5])
    let pairs = Array(chunks[6 ..< chunks.count])

    var availableChars = Stack("ONMLKJIHGFEDCBA")

    let p1 = map(stride(from: 0, to: pairs.count, by: 2)) { pairs[$0] }
    let p2 = map(stride(from: 1, to: pairs.count, by: 2)) { pairs[$0] }

    var zippedPairs = Stack(map(zip(p1, p2), {",".join([$0, $1])})).reversed()
    var assignedChars: [String:Character] = [:]

    while var p = zippedPairs.pop() {
      if let x = p.characters.last where x == "\r" { p = String(String(dropLast(p.characters))) }
      if let c = assignedChars[p] {
        compressed.append(c)
      } else {
        assignedChars[p] = availableChars.pop()
        if let lastC = compressed.characters.last where String(lastC) ~= "[0-9]" { compressed += "," }
        compressed += p
      }
    }

    didCaptureCommand?(compressed)
  }

  /** Public facing callback for when a command has been captured */
  public var didCaptureCommand: ((String) -> Void)?

  weak var connection: ITachDeviceConnection?

  /** init */
  public init() {}
}