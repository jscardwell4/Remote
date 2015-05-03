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

  // Cached model values

  private(set) public var labelString: NSAttributedString? { didSet { label?.attributedText = labelString } }

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
  override func kvoRegistration() -> [Property:KVOReceptionist.Observation] {
    var registry = super.kvoRegistration()
    registry["label"] = {
      RemoteElementView.dumpObservation($0)
      ($0.observer as? ButtonGroupView)?.labelString = ($0.object as? ButtonGroup)?.label
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
    MSLogVerbose("button group named '\(buttonGroup.name)' with uuid '\(buttonGroup.uuid)' is panel? \(buttonGroup.isPanel)")
  }

  /** updateViewFromModel */
  override func updateViewFromModel() {
    labelString = buttonGroup?.label
    super.updateViewFromModel()
  }

  /** didMoveToSuperview */
  override public func didMoveToSuperview() {
    super.didMoveToSuperview()
    let superIsNil = superview == nil
    let groupIsPanel = buttonGroup.isPanel
    let editing = isEditing
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
  override public func addSubview(view: UIView) {
    if let elementView = view as? RemoteElementView {
      if locked {
        elementView.resizable = false
        elementView.moveable = false
      }
      if let buttonView = elementView as? ButtonView {
        if buttonView.model.role == .Tuck {
          buttonView.tapAction = {self.tuck()}
        }
      }
    }
    super.addSubview(view)
  }

  /** addInternalSubviews */
  override func addInternalSubviews() {
    super.addInternalSubviews()
    let label = UILabel.newForAutolayout()
    label.backgroundColor = UIColor.clearColor()
    addSubview(label)/*addViewToContent(label)*/
    self.label = label
  }

  override public var editingMode: RemoteElement.BaseType {
    didSet {
      resizable = editingMode == .Undefined
      moveable = editingMode == .Undefined
      /*subelementInteractionEnabled = editingMode != .Remote*/
    }
  }

  /**
  intrinsicContentSize

  :returns: CGSize
  */
  override public func intrinsicContentSize() -> CGSize {
    if buttonGroup.role & RemoteElement.Role.Toolbar != nil { return CGSize(width: UIScreen.mainScreen().bounds.width, height: 44.0) }
    else { return CGSize(square: UIViewNoIntrinsicMetric) }
  }

  /**
  buttonViewDidExecute:

  :param: buttonView ButtonView
  */
  func buttonViewDidExecute(buttonView: ButtonView) {
    if buttonGroup.autohide { MSRunAsyncOnMain{self.tuck()} }
  }

  /**
  drawRect:

  :param: rect CGRect
  */
  override public func drawRect(rect: CGRect) {
    if model.shape == .Undefined { return }
    if hasOption(.DrawBackground, model.style) {
      let backgroundAttrs = Painter.Attributes(rect: rect.integerRect, color: backgroundColor ?? Painter.defaultBackgroundColor)
      Painter.drawBackgroundWithShape(model.shape, attributes: backgroundAttrs)
    }

    if let image = backgroundImage {
      let imageAttrs = Painter.Attributes(rect: rect.integerRect, alpha: CGFloat(backgroundImageAlpha))
      Painter.drawImage(image, withAttributes: imageAttrs)
    }

    if hasOption(.ApplyGloss, model.style) {
      let glossAttrs = Painter.Attributes(rect: rect.integerRect, alpha: 0.15, blendMode: kCGBlendModeSoftLight)
      Painter.drawGlossWithShape(model.shape, attributes: glossAttrs)
    }

  }

}
