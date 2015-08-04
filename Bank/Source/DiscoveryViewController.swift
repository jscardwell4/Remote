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

  /** Attempt to connect to the device specified by `manualEntries` value */
  private func checkManual() {
    do {
      let detector = try NSDataDetector(types: NSTextCheckingType.Link.rawValue)
      let locationRange = manualEntries.location.range

      guard let result = detector.firstMatchInString(manualEntries.location, options: [.Anchored], range: locationRange)
        where result.range.length == locationRange.length else { return }

      // TODO: Attempt connections
    } catch {
      logError(error)
    }

  }

  /**
  Updates for changes to the form fields when mode of operation is manual

  - parameter form: Form
  - parameter field: Field
  - parameter value: String
  */
  private func manualFormDidChange(form: Form, field: Field, value: String) {
    switch field.type {
      case .Picker: manualEntries.type = value
      case .Text: manualEntries.location = value
      default: break
    }
    checkManual()
  }

  private var manualEntries: (type: String, location: String) = ("iTach", "")

  /** Adjusts timer and views for the current `status` */
  private func updateForStatus() {

    guard isViewLoaded() else { return }

    discoveryView.status = status

    let fixed = UIBarButtonItem.fixedSpace(16)
    let flex = UIBarButtonItem.flexibleSpace()
    let leftButton: UIBarButtonItem
    let rightButton: UIBarButtonItem

    let listen = BlockBarButtonItem(title: "Listen", style: .Plain) {
      [unowned self] in self.status = .Searching
    }

    let manual = BlockBarButtonItem(title: "Manual", style: .Plain) {
      [unowned self] in self.status = .Manual(self.manualFormDidChange)
    }

    let keepSearching = BlockBarButtonItem(title: "Keep Searching", style: .Plain) {
      [unowned self] in self.status = .Searching
    }

    let cancel = BlockBarButtonItem(title: "Cancel", style: .Plain) {
      [unowned self] in self.timer.stop(); self.didCancel?()
    }

    let submit = BlockBarButtonItem(title: "Select", style: .Done) {
      [unowned self] in  guard let device = self.networkDevice else { return }; self.timer.stop(); self.didSubmit?(device)
    }

    let giveUp = BlockBarButtonItem(title: "GiveUp", style: .Done) {
      [unowned self] in self.timer.stop(); self.didCancel?()
    }

    switch status {

      case .Searching:
        networkDevice = nil
        timer.start()
        leftButton = cancel
        rightButton = manual

      case .Manual(_):
        leftButton = cancel
        rightButton = listen

      case .Discovery(let device):
        timer.stop()
        networkDevice = device
        leftButton = keepSearching
        rightButton = submit

      case .Timeout:
        timer.stop()
        leftButton = keepSearching
        rightButton = giveUp

    }

    toolbar.setItems([ fixed, leftButton, flex, rightButton, fixed ], animated: true)
  }

  var status = Status.Searching {
    didSet {
      // ???: Should we make sure we don't receive a device while waiting for response to timeout message?
      guard isViewLoaded() else { return }
      updateForStatus()
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

  private let timer = Timer(interval: 120.0, leeway: 0)
  private let didCancel: (() -> Void)?
  private let didSubmit: ((ModelObject) -> Void)?

  private var networkDevice: NetworkDevice?


  // MARK: - Actions

  /** Invokes `didCancel` */
  func cancelAction() { timer.stop(); didCancel?() }

  /** Invokes `didSubmit` if `networkDevice` is not `nil` */
  func submitAction() { guard let device = networkDevice else { return }; timer.stop(); didSubmit?(device) }

  /** Resets the timer and makes sure `status` is set to `.Searching` */
  func keepSearching() { status = .Searching }

  // MARK: - Initializers

  /**
  Designated initalizer simply sets the handlers and invokes `super(nibName:bundle:)`

  - parameter cancel: (() -> Void)? = nil
  - parameter submit: ((ModelObject) -> Void)? = nil The `ModelObject` is always an instance of `NetworkDevice`
  */
  init(didCancel cancel: (() -> Void)? = nil, didSubmit submit: ((ModelObject) -> Void)? = nil) {
    didCancel = cancel
    didSubmit = submit
    super.init(nibName: nil, bundle: nil)
    timer.handler = { [weak self] _ in self?.status = .Timeout }
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

    updateForStatus()
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

