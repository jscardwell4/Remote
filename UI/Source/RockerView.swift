//
//  RockerView.swift
//  Remote
//
//  Created by Jason Cardwell on 11/08/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit
import DataModel

public final class RockerView: ButtonGroupView {

  private weak var labelContainerLeftConstraint: NSLayoutConstraint!
  private weak var labelContainer: UIView!
  private weak var labelPanGesture: UIPanGestureRecognizer!
  private var prevPanAmount: CGFloat = 0.0
  private var labelCount = 0
  private var labelIndex = -1
  private var panLength: CGFloat = 0.0
  private var blockPan = false

  static let ConstraintIdentifier = createIdentifier(self, ["Internal"])

  /** updateConstraints */
  override public func updateConstraints() {
    super.updateConstraints()

    let identifier = createIdentifier(self, ["Internal"])
    if constraintsWithIdentifier(identifier).count == 0 {
      let format = "\n".join("labelContainer.centerY = self.centerY",
                             "labelContainer.height = self.height * 0.34",
                             "labelContainer.left = self.left")
      constrain(format, views: ["labelContainer": labelContainer], identifier: identifier)
      let predicate = NSPredicate(format: "firstItem == %@" +
                                          "AND secondItem == %@ " +
                                          "AND firstAttribute == \(NSLayoutAttribute.Left.rawValue)" +
                                          "AND secondAttribute == \(NSLayoutAttribute.Left.rawValue)" +
                                          "AND relation == \(NSLayoutRelation.Equal.rawValue)", labelContainer, self)
      labelContainerLeftConstraint = constraintMatching(predicate)
    }

    labelContainer.removeAllConstraints()

    let labels = labelContainer.subviewsOfKind(UILabel.self)
    labelContainer.constrain("self.width = \(bounds.width * CGFloat(labels.count))")
    apply(labels){$0.removeAllConstraints()}
    if var prevLabel = labels.first {
      labelContainer.verticallyStretchSubview(prevLabel)
      labelContainer.leftAlignSubview(prevLabel)
      prevLabel.constrain(prevLabel.width => Float(bounds.width))
      for label in labels[1..<labels.count] {
        labelContainer.alignSubview(prevLabel, besideSubview: label, offset: 0.0)
        label.constrainWidth(Float(bounds.width))
        prevLabel = label
      }
      labelContainer.rightAlignSubview(prevLabel)
    }
  }

  /**
  addSubelementView:

  :param: view RemoteElementView
  */
  override public func addSubelementView(view: RemoteElementView) {
    super.addSubelementView(view)
    apply(view.gestureRecognizers as! [UIGestureRecognizer]){$0.requireGestureRecognizerToFail(self.labelPanGesture)}
  }

  /**
  kvoRegistration

  :returns: [Property:KVOReceptionist.Observation]
  */
  override func kvoRegistration() -> [Property:KVOReceptionist.Observation] {
    var registry = super.kvoRegistration()
    registry["commandContainer"] = {
      RemoteElementView.dumpObservation($0)
      ($0.observer as? RockerView)?.buildLabels()
    }
    return registry
  }

  /** addInternalSubviews */
  override func addInternalSubviews() {
    super.addInternalSubviews()
    /*overlayClipsToBounds = true*/
    let labelContainer = UIView.newForAutolayout()
    labelContainer.backgroundColor = UIColor.clearColor()
    self.labelContainer = labelContainer
    addSubview(labelContainer)/*addViewToContent(labelContainer)*/
  }

  /** initializeViewFromModel */
  override func updateViewFromModel() {
    super.updateViewFromModel()
    buildLabels()
    buttonGroup.commandSetIndex = labelIndex
  }

  /** attachGestureRecognizers */
  override func attachGestureRecognizers() {
    super.attachGestureRecognizers()
    let labelPanGesture = UIPanGestureRecognizer(target: self, action: "handlePan:")
    labelPanGesture.maximumNumberOfTouches = 1
    apply(subelementViews) {
      apply($0.gestureRecognizers as! [UIGestureRecognizer]) {
        $0.requireGestureRecognizerToFail(labelPanGesture)}
    }
    self.labelPanGesture = labelPanGesture
    addGestureRecognizer(labelPanGesture)
  }

  /**
  This method animates the label "paged" to via the panning gesture and calls `updateCommandSet` upon completion

  :param: idx Int The label index for the destination label.
  :param: duration CGFloat The time in seconds it should take the animation to complete.
  */
  func animateLabelContainerToIndex(idx: Int, withDuration duration: CGFloat) {
    let constant = -bounds.size.width * CGFloat(idx)
    setNeedsLayout()
    UIView.animateWithDuration(NSTimeInterval(duration),
      delay: 0.0,
      usingSpringWithDamping: 0.3,
      initialSpringVelocity: 0.5,
      options: nil,
      animations: {
        () -> Void in
          self.labelContainerLeftConstraint.constant = constant
          self.layoutIfNeeded()
      },
      completion: {
        (finished: Bool) -> Void in
          if finished {
            self.buttonGroup.commandSetIndex = idx
          }
      })
  }

  /**
  Generate `UILabels` for each label in the model's set and attach to `scrollingLabels`. Any labels attached already
  to the `scrollingLabels` are removed first.
  */
  func buildLabels() {
    labelIndex = 0
    buttonGroup.commandSetIndex = 0
    apply(labelContainer.subviews as! [UIView]){$0.removeFromSuperview()}
    if let collection = buttonGroup.commandSetCollection where collection.count > 0 {
      for i in 0 ..< collection.count {
        if let title = buttonGroup.labelForCommandSetAtIndex(i) {
          let label = UILabel.newForAutolayout()
          label.attributedText = title
          label.backgroundColor = UIColor.clearColor()
          labelContainer.addSubview(label)
        }
      }
    }
    setNeedsUpdateConstraints()
  }

  /**
  Handler for pan gesture attached to `labelContainer` that behaves similar to a scroll view for selecting among the
  labels attached.

  :param: gestureRecognizer UIPanGestureRecognizer The gesture that responded to a pan event in the view.
  */
  func handlePan(gestureRecognizer: UIPanGestureRecognizer) {

    switch gestureRecognizer.state {

      case .Began:
        blockPan = false
        panLength = 0.0
        prevPanAmount = 0.0

      case .Changed:
        if !blockPan {
          var velocity = fabs(gestureRecognizer.velocityInView(self).x)
          var duration = 0.5
          while duration > 0.1 && velocity > 1 { velocity /= 3.0; if velocity > 1 { duration -= 0.1 } }
          let panAmount = gestureRecognizer.translationInView(self).x
          panLength += fabs(panAmount)
          if prevPanAmount != 0 && (   (panAmount < 0 && panAmount > prevPanAmount)
                                    || (panAmount > 0 && panAmount < prevPanAmount))
          {
            blockPan = true
            if prevPanAmount > 0 { labelIndex = max(labelIndex - 1, 0) }
            else { labelIndex = min(labelIndex + 1, labelCount - 1) }
            animateLabelContainerToIndex(labelIndex, withDuration: CGFloat(duration))
            break
          }

          let labelWidth = bounds.width

          if panLength >= labelWidth {
            blockPan = true
            if panAmount > 0 { labelIndex-- }
            else { labelIndex++ }
            animateLabelContainerToIndex(labelIndex, withDuration: CGFloat(duration))
            break
          }

          let currentOffset = labelContainerLeftConstraint.constant
          let newOffset = currentOffset + panAmount
          let containerWidth = labelContainer.bounds.width
          let minOffset = -containerWidth + labelWidth

          if newOffset < minOffset {
            blockPan = true
            labelIndex = labelCount - 1
            animateLabelContainerToIndex(labelIndex, withDuration: CGFloat(duration))
          } else if newOffset > 0 {
            blockPan = true
            labelIndex = 0
            animateLabelContainerToIndex(labelIndex, withDuration: CGFloat(duration))
          } else {
            prevPanAmount = panAmount
            setNeedsLayout()
            UIView.animateWithDuration(0.0) {
              self.labelContainerLeftConstraint.constant = newOffset
              self.layoutIfNeeded()
            }
          }
        }

      case .Ended:
        animateLabelContainerToIndex(labelIndex, withDuration: 0.5)

      default:
        break
    }

  }

}
