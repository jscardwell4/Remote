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
  let deviceView = UIStackView(arrangedSubviews: [])
  let manualView: FormView = {
    let templates: OrderedDictionary<String, FieldTemplate> =
    [ "Type": .Picker(value: "iTach", choices: ["iTach", "ISY"], editable: true),
      "Location": .Text(value: "", placeholder: "http://the.device.url", validation: nil, editable: true) ]
    let form = Form(templates: templates)
    return FormView(form: form)
  }()

  /** updateConstraints */
  override func updateConstraints() {
    super.updateConstraints()

    let id = MoonKit.Identifier(self, "Internal")

    guard constraintsWithIdentifier(id).count == 0 else { return }

    constrain([
      𝗩|-statusView--deviceView-|𝗩,
      𝗩|-statusView--manualView-|𝗩,
      𝗩|animationView-|𝗩,
      𝗛|-statusView-|𝗛,
      𝗛|-animationView|𝗛,
      𝗛|-deviceView-|𝗛,
      𝗛|-manualView-|𝗛
    ] --> id)
  }

  enum Status {
    case Manual (Form.ChangeHandler)
    case Searching
    case Discovery (NetworkDevice)
    case Timeout

    var text: NSAttributedString {
      switch self {
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

      UIView.transitionWithView(self, duration: 0.25, options: [], animations: {
        () -> Void in

          self.statusView.attributedText = self.status.text

          // Configure view for current status
          switch self.status {

            case .Manual(let handler):
              self.manualView.form.changeHandler = handler
              self.manualView.alpha = 1

            case .Searching:
              self.animationView.alpha = 1
              self.animationView.animating = true

            case .Discovery(let device):
              for (_, k, v) in device.summaryItems {
                let label = UILabel(autolayout: true, attributedText: "\(k):" ¶| [Bank.formLabelFont, Bank.formLabelTextColor])
                let value = UILabel(autolayout: true, attributedText: v ¶| [Bank.formControlFont, Bank.formControlTextColor])
                let stack = UIStackView(arrangedSubviews: [label, value])
                self.deviceView.addArrangedSubview(stack)
              }
              self.deviceView.alpha = 1

            default:
              break

          }

          // Remove any leftover effects from previous status
          switch oldValue {

            case .Manual:
              self.manualView.alpha = 0

            case .Searching:
              self.animationView.alpha = 0
              self.animationView.animating = false

            case .Discovery:
              self.deviceView.alpha = 0
              self.deviceView.arrangedSubviews.apply { self.deviceView.removeArrangedSubview($0) }

            default:
              break

          }

        }, completion: nil)
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

    manualView.nametag = "manualView"
    manualView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(manualView)

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
    case (.Searching, .Searching), (.Manual, .Manual), (.Discovery, .Discovery), (.Timeout, .Timeout): return true
    default: return false
  }
}
