//
//  ButtonGroupView.swift
//  Remote
//
//  Created by Jason Cardwell on 11/07/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit
import DataModel

public class ButtonGroupView: RemoteElementView {

  var label: UILabel!

  weak var tuckedConstraint: NSLayoutConstraint?
  weak var untuckedConstraint: NSLayoutConstraint?
  weak var tuckGesture: MSSwipeGestureRecognizer?
  weak var untuckGesture: MSSwipeGestureRecognizer?
  var tuckDirection: UISwipeGestureRecognizerDirection = .Right
  var untuckDirection: UISwipeGestureRecognizerDirection = .Left
  var quadrant: MSSwipeGestureRecognizerQuadrant = .Up

  var buttonGroup: ButtonGroup! { return model as! ButtonGroup }

  /** init */
//  override init() { super.init() }

  /**
  initWithFrame:

  :param: frame CGRect
  */
  override init(frame: CGRect) { super.init(frame: frame) }

  /**
  Overridden properties prevent synthesized initializers

  :param: model RemoteElement
  */
  required public init(model: RemoteElement) {
    super.init(model: model)
  }

  /**
  Overridden properties prevent synthesized initializers

  :param: aDecoder NSCoder
  */
  required public init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  /** tuck */
  func tuck() {
    if buttonGroup.isPanel && tuckedConstraint != nil && untuckedConstraint != nil {
      UIView.animateWithDuration(0.25, animations: {
        self.untuckedConstraint?.priority = 1
        self.tuckedConstraint?.priority = 999
        self.window?.setNeedsUpdateConstraints()
        self.setNeedsLayout()
        self.layoutIfNeeded()
        },
        completion: {
          (finished: Bool) -> Void in
            self.tuckGesture?.enabled = false
            self.untuckGesture?.enabled = true
        })
    }
  }

  /** untuck */
  func untuck() {
    if buttonGroup.isPanel && tuckedConstraint != nil && untuckedConstraint != nil {
      UIView.animateWithDuration(0.25, animations: {
        self.untuckedConstraint?.priority = 999
        self.tuckedConstraint?.priority = 1
        self.window?.setNeedsUpdateConstraints()
        self.setNeedsLayout()
        self.layoutIfNeeded()
        },
        completion: {
          (finished: Bool) -> Void in
            self.tuckGesture?.enabled = true
            self.untuckGesture?.enabled = false
        })
    }
  }

  /** updateConstraints */
  override public func updateConstraints() {
    removeAllConstraints()
    super.updateConstraints()
    stretchSubview(label)
  }

  /**
  handleSwipe:

  :param: gesture UISwipeGestureRecognizer
  */
  func handleSwipe(gesture: UISwipeGestureRecognizer) {
    if gesture.state == .Ended {
      if gesture === tuckGesture { tuck() }
      else if gesture === untuckGesture { untuck() }
    }
  }

  /** attachTuckGestures */
  func attachTuckGestures() {
    let tuckGesture = MSSwipeGestureRecognizer(target: self, action: "handleSwipe:")
    tuckGesture.nametag = "'\(model.name)'-tuck"
    tuckGesture.enabled = false
    tuckGesture.direction = tuckDirection
    tuckGesture.quadrant = quadrant
    window?.addGestureRecognizer(tuckGesture)
    self.tuckGesture = tuckGesture

    let untuckGesture = MSSwipeGestureRecognizer(target: self, action: "handleSwipe:")
    untuckGesture.nametag = "'\(model.name)'-untuck"
    untuckGesture.enabled = false
    untuckGesture.direction = untuckDirection
    untuckGesture.quadrant = quadrant
    window?.addGestureRecognizer(untuckGesture)
    self.untuckGesture = untuckGesture
  }

  /** didMoveToWindow */
  override public func didMoveToWindow() {
    if buttonGroup.isPanel && !isEditing && window != nil { attachTuckGestures() }
    super.didMoveToWindow()
  }

  /**
  kvoRegistration

  :returns: [String:(MSKVOReceptionist) -> Void]
  */
  override func kvoRegistration() -> [String:(MSKVOReceptionist!) -> Void] {
    var registry = super.kvoRegistration()
    registry["label"] = {
      (receptionist: MSKVOReceptionist!) -> Void in
        if let v = receptionist.observer as? ButtonGroupView {
          if let text = receptionist.change[NSKeyValueChangeNewKey] as? NSAttributedString { v.label.attributedText = text }
          else { v.label.attributedText = nil }
        }
    }
    return registry
  }

  /** initializeIVARs */
  override func initializeIVARs() {
    super.initializeIVARs()
    shrinkwrap = true
    resizable = true
    moveable = true
    if buttonGroup.role & RemoteElement.Role.Toolbar != nil {
      setContentCompressionResistancePriority(1000.0, forAxis: .Horizontal)
      setContentCompressionResistancePriority(1000.0, forAxis: .Vertical)
    }
  }

  /** didMoveToSuperview */
  override public func didMoveToSuperview() {
    super.didMoveToSuperview()
    if superview != nil && buttonGroup.isPanel && !isEditing {
      var attribute1 = NSLayoutAttribute.NotAnAttribute
      var attribute2 = attribute1
      switch buttonGroup.panelLocation {
        case .Top:
          attribute1 = .Bottom
          attribute2 = .Top
          tuckDirection = .Up
          untuckDirection = .Down
          quadrant = .Up

        case .Bottom:
          attribute1 = .Top
          attribute2 = .Bottom
          tuckDirection = .Down
          untuckDirection = .Up
          quadrant = .Down

        case .Left:
          attribute1 = .Right
          attribute2 = .Left
          tuckDirection = .Left
          untuckDirection = .Right
          quadrant = .Left

        case .Right:
          attribute1 = .Left
          attribute2 = .Right
          tuckDirection = .Right
          untuckDirection = .Left
          quadrant = .Right

        default:
          break
      }

      let tuckedConstraint = NSLayoutConstraint(item: self,
                                                attribute: attribute1,
                                                relatedBy: .Equal,
                                                toItem: superview,
                                                attribute: attribute2,
                                                multiplier: 1.0,
                                                constant: 0.0)
      tuckedConstraint.priority = 999
      self.tuckedConstraint = tuckedConstraint

      let untuckedConstraint = NSLayoutConstraint(item: self,
                                                attribute: attribute2,
                                                relatedBy: .Equal,
                                                toItem: superview,
                                                attribute: attribute1,
                                                multiplier: 1.0,
                                                constant: 0.0)
      untuckedConstraint.priority = 1
      self.untuckedConstraint = untuckedConstraint

      superview?.addConstraints([tuckedConstraint, untuckedConstraint])
    }
  }

  /**
  addSubelementView:

  :param: view RemoteElementView
  */
  override public func addSubelementView(view: RemoteElementView) {
    if locked {
      view.resizable = false
      view.moveable = false
    }
    if let buttonView = view as? ButtonView {
      if buttonView.model.role == .Tuck {
        buttonView.tapAction = {self.tuck()}
      }
    }
    super.addSubelementView(view)
  }

  /** addInternalSubviews */
  override func addInternalSubviews() {
    super.addInternalSubviews()
    let label = UILabel.newForAutolayout()
    label.backgroundColor = UIColor.clearColor()
    addViewToContent(label)
    self.label = label
  }

  override public var editingMode: RemoteElement.BaseType {
    didSet {
      resizable = editingMode == .Undefined
      moveable = editingMode == .Undefined
      subelementInteractionEnabled = editingMode != .Remote
    }
  }

  /**
  intrinsicContentSize

  :returns: CGSize
  */
  override public func intrinsicContentSize() -> CGSize {
    if buttonGroup.role == RemoteElement.Role.Toolbar { return CGSize(width: UIScreen.mainScreen().bounds.width, height: 44.0) }
    else { return CGSize(square: UIViewNoIntrinsicMetric) }
  }

  /**
  buttonViewDidExecute:

  :param: buttonView ButtonView
  */
  func buttonViewDidExecute(buttonView: ButtonView) {
    if buttonGroup.autohide { MSRunAsyncOnMain{self.tuck()} }
  }

}
