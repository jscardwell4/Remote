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

    constrain([
      𝗩|-statusView--deviceView-|𝗩,
      𝗩|animationView-|𝗩,
      𝗛|-statusView-|𝗛,
      𝗛|-animationView|𝗛,
      𝗛|-deviceView-|𝗛
    ] --> id)
  }

  let deviceView = UIStackView(arrangedSubviews: [])

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
          animationView.alpha = 1
          animationView.animating = true
        case .Discovery(let device):
          for (_, k, v) in device.summaryItems {
            let label = UILabel(autolayout: true)
            label.attributedText = "\(k):" ¶| [Bank.formLabelFont, Bank.formLabelTextColor]
            let value = UILabel(autolayout: true)
            value.attributedText = v ¶| [Bank.formControlFont, Bank.formControlTextColor]
            let stack = UIStackView(arrangedSubviews: [label, value])
            deviceView.addArrangedSubview(stack)
          }
          deviceView.alpha = 1
        default:
          break
      }

      switch oldValue {
        case .Searching:
          animationView.alpha = 0
          animationView.animating = false
        case .Discovery:
          deviceView.alpha = 0
          deviceView.arrangedSubviews.apply { self.deviceView.removeArrangedSubview($0) }
        default: break
      }
    }
  }

  /** initializeIVARs */
  func initializeIVARs() {
    backgroundColor = UIColor.whiteColor()
    layer.shadowOpacity = 0.75
    layer.shadowRadius = 8
    layer.shadowOffset = CGSize(width: 1, height: 3)

    animationView.nametag = "animationView"
    addSubview(animationView)

    statusView.nametag = "statusView"
    statusView.attributedText = status.text
    statusView.numberOfLines = 0
    statusView.backgroundColor = UIColor.clearColor()
    addSubview(statusView)

    deviceView.translatesAutoresizingMaskIntoConstraints = false
    deviceView.axis = .Vertical
    deviceView.nametag = "deviceView"
    deviceView.baselineRelativeArrangement = true
    addSubview(deviceView)

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
