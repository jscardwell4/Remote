//
//  DiscoveryView.swift
//  Remote
//
//  Created by Jason Cardwell on 8/1/15.
//  Copyright © 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit
import class DataModel.NetworkDevice

final class DiscoveryView: UIView {

  let animationView = DiscoveryAnimationView(autolayout: true)
  let statusView = UILabel(autolayout: true)

  /** updateConstraints */
  override func updateConstraints() {
    super.updateConstraints()

    let id = MoonKit.Identifier(self, "Internal")

    guard constraintsWithIdentifier(id).count == 0 else { return }

    constrain([[𝗩|-statusView], 𝗩|animationView-|𝗩, 𝗛|-statusView-|𝗛, 𝗛|-animationView|𝗛] --> id)
  }

  let deviceView = UILabel(autolayout: true)

  enum Status {
    case Idle
    case Searching
    case Discovery (NetworkDevice)
    case Timeout

    var text: NSAttributedString {
      switch self {
        case .Idle:
          return "What are we waiting for?" ¶| [Bank.labelFont, Bank.labelColor]
        case .Searching:
          return "Searching for network devices…" ¶| [Bank.labelFont, Bank.labelColor]
        case .Discovery:
          return "Found something… Is this what you were searching for?" ¶| [Bank.labelFont, Bank.labelColor]
        case .Timeout:
          return "I'm pretty search we have searched everywhere. Shall we call it a day?" ¶| [Bank.labelFont, Bank.labelColor]
      }
    }

  }

  var status = Status.Idle {
    didSet {
      guard status != oldValue else { return }
      statusView.attributedText = status.text
      switch status {
        case .Searching:
          animationView.hidden = false
          animationView.animating = true
        case .Discovery(let device):
          decorateDeviceViewWithDevice(device)
          fallthrough
        default:
          animationView.hidden = true
          animationView.animating = false
      }
    }
  }

  /**
  decorateDeviceViewWithDevice:

  - parameter device: NetworkDevice
  */
  private func decorateDeviceViewWithDevice(device: NetworkDevice) {
    // TODO: Fill out stub
  }

  func initializeIVARs() {
    backgroundColor = UIColor.whiteColor()
    layer.shadowOpacity = 0.75
    layer.shadowRadius = 8
    layer.shadowOffset = CGSize(width: 1, height: 3)

    animationView.hidden = true
    addSubview(animationView)

    statusView.attributedText = status.text
    statusView.numberOfLines = 0
    statusView.backgroundColor = UIColor.clearColor()
    addSubview(statusView)

  }

  /**
  initWithFrame:

  - parameter frame: CGRect
  */
  override init(frame: CGRect) { super.init(frame: frame); initializeIVARs() }

  /**
  init:

  - parameter aDecoder: NSCoder
  */
  required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder); initializeIVARs() }

  /**
  requiresConstraintBasedLayout

  - returns: Bool
  */
  override class func requiresConstraintBasedLayout() -> Bool { return true }
}

extension DiscoveryView.Status: Equatable {}

func ==(lhs: DiscoveryView.Status, rhs: DiscoveryView.Status) -> Bool {
  switch (lhs, rhs) {
    case (.Searching, .Searching), (.Idle, .Idle), (.Discovery, .Discovery), (.Timeout, .Timeout): return true
    default: return false
  }
}
