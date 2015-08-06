//
//  ActivityViewController.swift
//  Remote
//
//  Created by Jason Cardwell on 3/1/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit
import DataModel
import Settings

public final class ActivityViewController: UIViewController {

  public static let proximitySensorKey = "RemoteProximitySensorKey"
  override public class func initialize() {
    if self === ActivityViewController.self {
      SettingsManager.registerSettingWithKey(proximitySensorKey,
                            withDefaultValue: true,
                                fromDefaults: {($0 as? NSNumber)?.boolValue == true},
                                  toDefaults: {$0})
    }
  }

  let context = DataManager.mainContext()

  private(set) var activityController: ActivityController
  
  private var remoteReceptionist: MSKVOReceptionist!
  private var settingsReceptionist: MSNotificationReceptionist!
  private weak var topToolbarView: ButtonGroupView!
  private weak var topToolbarConstraint: NSLayoutConstraint!
  private weak var remoteView: RemoteView!

  /** init */
  public init() {
    activityController = ActivityController.sharedController(context)
    super.init(nibName: nil, bundle: nil)
    initializeReceptionists()
  }

  /**
  init:

  - parameter aDecoder: NSCoder
  */
  required public init?(coder aDecoder: NSCoder) {
    activityController = ActivityController.sharedController(context)
    super.init(coder: aDecoder)
    initializeReceptionists()
  }

  /** initializeReceptionists */
  private func initializeReceptionists() {
    remoteReceptionist = MSKVOReceptionist(observer: self,
      forObject: activityController,
      keyPath: "currentRemote",
      options: .New,
      queue: NSOperationQueue.mainQueue(),
      handler: {
        if let remote = $0.change[NSKeyValueChangeNewKey] as? Remote,
          let viewController = $0.observer as? ActivityViewController {
            viewController.insertRemoteView(RemoteView(model: remote))
        }
    })

    settingsReceptionist = MSNotificationReceptionist(
      observer: self,
      forObject: SettingsManager.self,
      notificationName: SettingsManager.NotificationName,
      queue: NSOperationQueue.mainQueue(),
      handler: { _ in
        UIDevice.currentDevice().proximityMonitoringEnabled =
          SettingsManager.valueForSetting(ActivityViewController.proximitySensorKey) ?? false
    })
  }

  /** viewDidLoad */
  override public func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: "handlePinch:"))

    let topToolbarView = ButtonGroupView(model: activityController.topToolbar)
    MSLogVerbose(topToolbarView.model.description)
    view.addSubview(topToolbarView)
    self.topToolbarView = topToolbarView

    insertRemoteView(RemoteView(model: activityController.currentRemote))
  }

  /**
  viewWillAppear:

  - parameter animated: Bool
  */
  override public func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if SettingsManager.valueForSetting(ActivityViewController.proximitySensorKey) == true {
      UIDevice.currentDevice().proximityMonitoringEnabled = true
    }
  }

  /**
  viewWillDisappear:

  - parameter animated: Bool
  */
  override public func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    if SettingsManager.valueForSetting(ActivityViewController.proximitySensorKey) == true {
      UIDevice.currentDevice().proximityMonitoringEnabled = false
    }
  }

  /** updateTopToolbarLocation */
  func updateTopToolbarLocation() {
    if activityController.currentRemote.topBarHidden == (topToolbarConstraint.constant == 0) { toggleTopToolbar(true) }
  }

  /**
  viewDidAppear:

  - parameter animated: Bool
  */
  override public func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    updateTopToolbarLocation()
  }

  /**
  handlePinch:

  - parameter pinch: UIPinchGestureRecognizer
  */
  func handlePinch(pinch: UIPinchGestureRecognizer) { if pinch.state == .Ended { toggleTopToolbar(true)} }

  /**
  toggleTopToolbar:

  - parameter animated: Bool
  */
  func toggleTopToolbar(animated: Bool) {
    let constant = topToolbarConstraint.constant > 0.0 ? 0.0 : -topToolbarView.bounds.height
    if animated { animateToolbar(constant) } else { topToolbarConstraint.constant = constant }
  }

  /**
  animateToolbar:

  - parameter constraintConstant: CGFloat
  */
  func animateToolbar(constraintConstant: CGFloat) {
    UIView.animateWithDuration(0.25,
      delay: 0.0,
      options: .BeginFromCurrentState,
      animations: {self.topToolbarConstraint.constant = constraintConstant; self.view.layoutIfNeeded()},
      completion: nil)
  }

  /**
  showTopToolbar:

  - parameter animated: Bool
  */
  func showTopToolbar(animated: Bool) { if animated { animateToolbar(0.0) } else { topToolbarConstraint.constant = 0.0 } }

  /**
  hideTopToolbar:

  - parameter animated: Bool
  */
  func hideTopToolbar(animated: Bool) {
    if animated { animateToolbar(-topToolbarView.bounds.height) }
    else { topToolbarConstraint.constant = -topToolbarView.bounds.height }
  }

  /**
  insertRemoteView:

  - parameter remoteView: RemoteView
  */
  func insertRemoteView(remoteView: RemoteView) {
    if self.remoteView != nil {
      UIView.animateWithDuration(0.25, animations: {
        self.remoteView.removeFromSuperview()
        self.view.insertSubview(remoteView, belowSubview: self.topToolbarView)
        self.remoteView = remoteView
        self.view.setNeedsUpdateConstraints()
      })
    } else {
      view.insertSubview(remoteView, belowSubview: topToolbarView)
      self.remoteView = remoteView
      view.setNeedsUpdateConstraints()
    }
  }

  /** updateViewConstraints */
  override public func updateViewConstraints() {
    super.updateViewConstraints()

    let identifier = MoonKit.Identifier(self, "Internal")
    view.removeConstraintsWithIdentifier(identifier.string)

    if remoteView != nil && topToolbarView != nil {
      view.constrain(identifier: identifier.string,
        remoteView.centerX => view.centerX,
        remoteView.bottom => view.bottom,
        remoteView.top => view.top,
        topToolbarView.centerX => view.centerX
      )
    }

    let topToolbarConstraint = NSLayoutConstraint(topToolbarView.top => view.top --> identifier)
    view.addConstraint(topToolbarConstraint)
    self.topToolbarConstraint = topToolbarConstraint

    updateTopToolbarLocation()

  }

}
