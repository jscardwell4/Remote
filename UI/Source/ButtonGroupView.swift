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
  var buttonGroup: ButtonGroup! { return model as! ButtonGroup }
  var tuckAction: (() -> Void)?

  // Cached model values

  private(set) public var labelString: NSAttributedString? { didSet { label?.attributedText = labelString } }

  /** updateConstraints */
  override public func updateConstraints() {
    super.updateConstraints()

    let identifier = createIdentifier(self, "Internal", "Label")
    removeConstraintsWithIdentifier(identifier)
    constrain(identifier: identifier,
              label.left => self.left,
              label.right => self.right,
              label.top => self.top,
              label.bottom => self.bottom)
  }

  /**
  kvoRegistration

  - returns: [String:(MSKVOReceptionist) -> Void]
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
    if buttonGroup.role & .Toolbar == RemoteElement.Role.Toolbar {
      setContentCompressionResistancePriority(1000.0, forAxis: .Horizontal)
      setContentCompressionResistancePriority(1000.0, forAxis: .Vertical)
    }
  }

  /** updateViewFromModel */
  override func updateViewFromModel() {
    labelString = buttonGroup?.label
    super.updateViewFromModel()
  }

  /**
  addSubelementView:

  - parameter view: RemoteElementView
  */
  override public func addSubelementView(view: RemoteElementView) {
    if let buttonView = view as? ButtonView {
      if locked { buttonView.resizable = false; buttonView.moveable = false }
      if buttonView.model.role == .Tuck { buttonView.tapAction = {self.tuckAction?()} }
      super.addSubelementView(view)
    }
  }

  /** addInternalSubviews */
  override func addInternalSubviews() {
    super.addInternalSubviews()
    let label = UILabel.newForAutolayout()
    label.backgroundColor = UIColor.clearColor()
    addSubview(label)
    self.label = label
  }

  override public var editingMode: RemoteElement.BaseType {
    didSet {
      resizable = editingMode == .Undefined
      moveable = editingMode == .Undefined
      // TODO: determine when/how to adjust user interaction
      /*subelementInteractionEnabled = editingMode != .Remote*/
    }
  }

  /**
  intrinsicContentSize

  - returns: CGSize
  */
  override public func intrinsicContentSize() -> CGSize {
    if buttonGroup.role & .Toolbar == RemoteElement.Role.Toolbar {
      return CGSize(width: UIScreen.mainScreen().bounds.width, height: 44.0)
    } else {
      return CGSize(square: UIViewNoIntrinsicMetric)
    }
  }

  /**
  buttonViewDidExecute:

  - parameter buttonView: ButtonView
  */
  func buttonViewDidExecute(buttonView: ButtonView) { if buttonGroup.autohide { MSRunAsyncOnMain{self.tuckAction?()} } }

  /**
  drawRect:

  - parameter rect: CGRect
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
