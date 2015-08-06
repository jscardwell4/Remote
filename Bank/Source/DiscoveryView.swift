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

  private weak var animationView: DiscoveryAnimationView?
  private weak var statusView: UILabel!
  private weak var deviceView: UIStackView?
  private weak var manualView: FormView?

  /** updateConstraints */
  override func updateConstraints() {
    super.updateConstraints()

    var id = MoonKit.Identifier(self, "Status")

    if constraintsWithIdentifier(id).count == 0 {
      constrain([[𝗩|-statusView], 𝗛|-statusView-|𝗛] --> id)
    }

    id[1] = "Content"

    NSLayoutConstraint.deactivateConstraints(constraintsWithIdentifier(id))

    switch status {

      case .Manual where manualView != nil:
        constrain([𝗩|-statusView--manualView!, 𝗛|-manualView!-|𝗛] --> id)

      case .Searching where animationView != nil:
        constrain([𝗩|animationView!-|𝗩, 𝗛|-animationView!|𝗛] --> id)

      case .Discovery where deviceView != nil:
        constrain([𝗩|-statusView--deviceView!-|𝗩, 𝗛|-deviceView!-|𝗛] --> id)

      default:
        break

    }

  }

  enum Status {
    case Idle
    case Manual (Form.ChangeHandler)
    case Searching
    case Discovery (NetworkDevice)
    case Timeout

    var text: NSAttributedString {
      switch self {
        case .Idle:
          return "What are we waiting for?" ¶| [Bank.labelFont, Bank.labelColor]
        case .Manual:
          return "Enter the type and location of the device to connect" ¶| [Bank.labelFont, Bank.labelColor]
        case .Searching:
          return "Searching for network devices…" ¶| [Bank.labelFont, Bank.labelColor]
        case .Discovery:
          return "Found something… Is this what you were looking for?" ¶| [Bank.labelFont, Bank.labelColor]
        case .Timeout:
          return "I'm pretty search we have searched everywhere. Shall we call it a day?" ¶| [Bank.labelFont, Bank.labelColor]
      }
    }

  }

  var status = Status.Searching {
    didSet {
      guard status != oldValue else { return }

//      UIView.transitionWithView(self, duration: 0.25, options: [], animations: {
//        () -> Void in

          self.statusView.attributedText = self.status.text

          // Configure view for current status
          switch self.status {

            case .Manual(let handler):
              let choices = [NetworkDevice.DeviceType.iTach.rawValue, NetworkDevice.DeviceType.ISY.rawValue]
              let form = Form(templates: [
                "Type": .Picker(value: "iTach", choices: choices, editable: true),
                "Location": .Text(value: "", placeholder: "http://the.device.url", validation: nil, editable: true)
              ])
              let manualView = FormView(form: form)
              manualView.nametag = "manualView"
              manualView.translatesAutoresizingMaskIntoConstraints = false
              Bank.decorateForm(manualView)
              manualView.form.changeHandler = handler
              self.addSubview(manualView)
              self.manualView = manualView

            case .Searching:
              let animationView = DiscoveryAnimationView(autolayout: true)
              animationView.nametag = "animationView"
              animationView.animating = true
              self.addSubview(animationView)
              self.animationView = animationView

            case .Discovery(let device):
              let deviceView = UIStackView(arrangedSubviews: [])
              deviceView.translatesAutoresizingMaskIntoConstraints = false
              deviceView.axis = .Vertical
              deviceView.nametag = "deviceView"
              deviceView.baselineRelativeArrangement = true
              for (_, k, v) in device.summaryItems {
                let label = UILabel(autolayout: true, attributedText: "\(k):" ¶| [Bank.formLabelFont, Bank.formLabelTextColor])
                let value = UILabel(autolayout: true, attributedText: v ¶| [Bank.formControlFont, Bank.formControlTextColor])
                let stack = UIStackView(arrangedSubviews: [label, value])
                deviceView.addArrangedSubview(stack)
              }
              self.addSubview(deviceView)
              self.deviceView = deviceView

            default:
              break

          }

          // Remove any leftover effects from previous status
          switch oldValue {

            case .Manual:
              self.manualView?.removeFromSuperview()

            case .Searching:
              self.animationView?.removeFromSuperview()

            case .Discovery:
              self.deviceView?.removeFromSuperview()

            default:
              break

          }

          self.setNeedsUpdateConstraints()

//        }, completion: nil)
    }
  }

  /** initializeIVARs */
  func initializeIVARs() {
    backgroundColor = UIColor.whiteColor()
    layer.shadowOpacity = 0.75
    layer.shadowRadius = 8
    layer.shadowOffset = CGSize(width: 1, height: 3)

    let statusView = UILabel(autolayout: true)
    statusView.nametag = "statusView"
    statusView.attributedText = status.text
    statusView.numberOfLines = 0
    statusView.setContentHuggingPriority(750, forAxis: .Vertical)
    statusView.backgroundColor = UIColor.clearColor()
    addSubview(statusView)
    self.statusView = statusView

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
    case (.Searching, .Searching), (.Manual, .Manual), (.Discovery, .Discovery), (.Timeout, .Timeout): return true
    default: return false
  }
}
