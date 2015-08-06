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
import Networking

final class DiscoveryViewController: UIViewController {

  // MARK: - Properties

  typealias Status = DiscoveryView.Status
  typealias DeviceType = NetworkDevice.DeviceType

  /** Attempt to connect to the device specified by `manualEntries` value */
  private func checkManual() {
    do {
      let detector = try NSDataDetector(types: NSTextCheckingType.Link.rawValue)
      let locationRange = manualEntries.location.range

      guard let result = detector.firstMatchInString(manualEntries.location, options: [.Anchored], range: locationRange)
        where result.range.length == locationRange.length else { return }

      ConnectionManager.connectToDeviceOfType(manualEntries.type, location: manualEntries.location)
    } catch {
      logError(error)
    }

  }

  /**
  Updates for changes to the form fields when mode of operation is manual

  - parameter form: Form
  - parameter field: Field
  - parameter name: String
  */
  private func manualFormDidChange(form: Form, field: Field, name: String) {
    switch (name, field.value) {

      case ("Type", let type as String):
        guard let type = DeviceType(rawValue: type) else { return }
        manualEntries.type = type

      case ("Location", let location as String):
        manualEntries.location = location

      default:
        break

    }

    checkManual()
  }

  private var manualEntries: (type: DeviceType, location: String) = (.iTach, "")

  /** Adjusts timer and views for the current `status` */
  private func updateForStatus(fromStatus oldValue: Status? = nil) {

    guard let discoveryView = discoveryView, toolbar = toolbar else { return }

    discoveryView.status = status

    let fixed = UIBarButtonItem.fixedSpace(16)
    let flex = UIBarButtonItem.flexibleSpace()
    let leftButton: UIBarButtonItem
    let rightButton: UIBarButtonItem

    let search: () -> Void = { [unowned self] in
      self.status = .Searching
    }

    let cancel: () -> Void = { [unowned self] in
      self.timer.stop()
      self.didCancel?()
    }

    let manual: () -> Void = { [unowned self] in
      self.status = .Manual(self.manualFormDidChange)
    }

    let submit: () -> Void = { [unowned self] in
      guard let device = self.networkDevice else { return }
      self.timer.stop()
      self.didSubmit?(device)
    }

    switch status {

      case .Idle:
        leftButton = flex
        rightButton = flex

      case .Searching:
        networkDevice = nil
        timer.start()

        leftButton = BlockBarButtonItem(title: "Cancel", style: .Plain, action: cancel)
        rightButton = BlockBarButtonItem(title: "Manual", style: .Plain, action: manual)

        guard token == nil else { break }

        do {
          token = try ConnectionManager.startDetectingNetworkDevices(context: context) {
            [weak self] (networkDevice: NetworkDevice?, _) -> Void in
            dispatchToMain { if let device = networkDevice { self?.status = .Discovery(device) } }
          }
        } catch { logError(error) }

      case .Manual(_):
        leftButton = BlockBarButtonItem(title: "Cancel", style: .Plain, action: cancel)
        rightButton = BlockBarButtonItem(title: "Listen", style: .Plain, action: search)

      case .Discovery(let device):
        timer.stop()
        networkDevice = device
        leftButton = BlockBarButtonItem(title: "Keep Searching", style: .Plain, action: search)
        rightButton = BlockBarButtonItem(title: "Select", style: .Done, action: submit)

      case .Timeout:
        timer.stop()
        leftButton = BlockBarButtonItem(title: "Keep Searching", style: .Plain, action: search)
        rightButton = BlockBarButtonItem(title: "Give Up", style: .Done, action: cancel)

    }

    toolbar.setItems([ fixed, leftButton, flex, rightButton, fixed ], animated: true)

    guard let oldValue = oldValue, case .Searching = oldValue where status != .Searching, let token = token else { return }

    ConnectionManager.stopDetectingNetworkDevices(token)
    timer.stop()
    self.token = nil
  }

  var status = Status.Idle {
    didSet {
      // ???: Should we make sure we don't receive a device while waiting for response to timeout message?
      guard isViewLoaded() else { return }
      updateForStatus(fromStatus: oldValue)
    }
  }

  private var token: ConnectionManager.DiscoveryCallbackToken?

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
  private let context: NSManagedObjectContext
  private var networkDevice: NetworkDevice?

  // MARK: - Initializers

  /**
  Designated initalizer simply sets the handlers and invokes `super(nibName:bundle:)`

  - parameter cancel: (() -> Void)? = nil
  - parameter submit: ((ModelObject) -> Void)? = nil The `ModelObject` is always an instance of `NetworkDevice`
  */
  init(context ctx: NSManagedObjectContext,
       didCancel cancel: (() -> Void)? = nil,
       didSubmit submit: ((ModelObject) -> Void)? = nil)
  {
    context = ctx
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

    if case .Idle = status where ConnectionManager.wifiAvailable { status = .Searching } else { updateForStatus() }

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

