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

  private weak var discoveryView: UIView!
  private weak var toolbar: UIToolbar!

  /** cancelAction */
  func cancelAction() {
    didCancel?()
  }

  /** submitAction */
  func submitAction() {
    MSLogDebug("")
  }

  private let didCancel: (() -> Void)?
  private let didSubmit: ((ModelObject) -> Void)?

  private var networkDevice: NetworkDevice?

  /**
  init:didCancel:didSubmit:

  - parameter cancel: (() -> Void)? = nil
  - parameter submit: (() -> Void)? = nil
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

  /** loadView */
  override func loadView() {
    view = UIView(autolayout: true)

    let discoveryView = UIView(autolayout: true)
    discoveryView.backgroundColor = UIColor.whiteColor()
    discoveryView.layer.shadowOpacity = 0.75
    discoveryView.layer.shadowRadius = 8
    discoveryView.layer.shadowOffset = CGSize(width: 1, height: 3)

    view.addSubview(discoveryView)
    self.discoveryView = discoveryView

    let toolbar = UIToolbar(autolayout: true)
    toolbar.nametag = "toolbar"
    toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .Any, barMetrics: .Default)
    toolbar.tintColor = UIColor(white: 0.5, alpha: 1)
    toolbar.items = [
      UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelAction"),
      UIBarButtonItem.flexibleSpace(),
      UIBarButtonItem(title: "Submit", style: .Done, target: self, action: "submitAction")
    ]
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
      [view.width => 300, view.height => 344] --> id,
      𝗩|discoveryView--toolbar|𝗩 --> id,
      𝗛|discoveryView|𝗛 --> id,
      [toolbar.left => discoveryView.left, toolbar.right => discoveryView.right] --> id
    )
  }
}

