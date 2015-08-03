//
//  DiscoveryViewController.swift
//  Remote
//
//  Created by Jason Cardwell on 7/29/15.
//  Copyright © 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit
import DataModel

final class DiscoveryViewController: UIViewController {

  // MARK: - Properties

  typealias Status = DiscoveryView.Status

  var status = Status.Idle {
    didSet {
      guard isViewLoaded() && status != oldValue else { return }
      discoveryView.status = status
      let leftButton: UIBarButtonItem
      let rightButton: UIBarButtonItem
      switch status {
        case .Searching, .Idle:
          networkDevice = nil
          leftButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelAction")
          rightButton = UIBarButtonItem.flexibleSpace()
        case .Discovery(let device):
          networkDevice = device
          leftButton = UIBarButtonItem(title: "Keep Searching", style: .Plain, target: self, action: "keepSearching")
          rightButton = UIBarButtonItem(title: "Select", style: .Plain, target: self, action: "submitAction")
        case .Timeout:
          leftButton = UIBarButtonItem(title: "Keep Searching", style: .Plain, target: self, action: "keepSearching")
          rightButton = UIBarButtonItem(title: "Give Up", style: .Plain, target: self, action: "cancelAction")
      }
      toolbar.setItems([
        UIBarButtonItem.fixedSpace(16),
        leftButton,
        UIBarButtonItem.flexibleSpace(),
        rightButton,
        UIBarButtonItem.fixedSpace(16)
      ], animated: true)
    }
  }

  private weak var discoveryView: DiscoveryView!
  private weak var toolbar: UIToolbar! {
    didSet {
      guard let toolbar = toolbar else { return }
      toolbar.nametag = "toolbar"
      toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .Any, barMetrics: .Default)
      toolbar.tintColor = UIColor(white: 0.5, alpha: 1)
      toolbar.items = [
        UIBarButtonItem.fixedSpace(16),
        UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelAction")
      ]
    }
  }

  private var timer: dispatch_source_t?
  private let didCancel: (() -> Void)?
  private let didSubmit: ((ModelObject) -> Void)?

  private var networkDevice: NetworkDevice?


  // MARK: - Actions

  /** Invokes `didCancel` */
  func cancelAction() { didCancel?() }

  /** Invokes `didSubmit` if `networkDevice` is not `nil` */
  func submitAction() { guard let device = networkDevice else { return }; didSubmit?(device) }

  /** Stops the timer and nullifies the variable if the timer was active */
  private func cancelTimer() { guard let t = timer else { return }; dispatch_source_cancel(t); timer = nil }

  /** Restarts the timeout clock */
  private func resetTimer() {
    cancelTimer()
    guard let t = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue()) else { return }
    dispatch_source_set_timer(t, dispatch_walltime(nil, 0), UInt64(120.0 * Double(NSEC_PER_SEC)), 0)
    dispatch_source_set_event_handler(t) { [unowned self] in self.status = .Timeout }
    timer = t
  }

  /** Resets the timer and makes sure `status` is set to `.Searching` */
  func keepSearching() { resetTimer(); status = .Searching }

  // MARK: - Initializers

  /**
  Designated initalizer simply sets the handlers and invokes `super(nibName:bundle:)`

  - parameter cancel: (() -> Void)? = nil
  - parameter submit: ((ModelObject) -> Void)? = nil The `ModelObject` is always an instance of `NetworkDevice`
  */
  init(didCancel cancel: (() -> Void)? = nil, didSubmit submit: ((ModelObject) -> Void)? = nil) {
    didCancel = cancel; didSubmit = submit; super.init(nibName: nil, bundle: nil)
  }

  /**
  init:

  - parameter aDecoder: NSCoder
  */
  required init?(coder aDecoder: NSCoder) {
    fatalError("init?(coder aDecoder: NSCoder) not implemented for DiscoveryViewController")
  }

  // MARK: - View management

  /** loadView */
  override func loadView() {
    view = UIView(autolayout: true)

    let discoveryView = DiscoveryView(autolayout: true)
    discoveryView.status = status
    view.addSubview(discoveryView)
    self.discoveryView = discoveryView

    let toolbar = UIToolbar(autolayout: true)
    view.addSubview(toolbar)
    self.toolbar = toolbar

    view.setNeedsUpdateConstraints()

  }

  /** updateViewConstraints */
  override func updateViewConstraints() {
    super.updateViewConstraints()

    let id = MoonKit.Identifier(self, "Internal")

    guard view.constraintsWithIdentifier(id).count == 0 else { return }

    view.constrain(
      [view.width => 280, view.height => 300] --> id,
      𝗩|discoveryView--toolbar|𝗩 --> id,
      𝗛|discoveryView|𝗛 --> id,
      [toolbar.left => discoveryView.left, toolbar.right => discoveryView.right] --> id
    )
  }

}

