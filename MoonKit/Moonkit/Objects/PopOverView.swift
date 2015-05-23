//
//  PopOverView.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/22/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import UIKit

public class PopOverView: UIView {

  public typealias Action = (PopOverView, String) -> Void

  public enum Location { case Top, Bottom }

  /** Whether the arrow is drawn at the top or the bottom of the view, also affects label offsets and alignment rect */
  public var location: Location = .Bottom

  /** Storage for the color passed through to labels for property of the same name */
  public var font: UIFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline) {
    didSet { apply(labels){[font = font] in $0.font = font} }
  }

  /** Storage for the color passed through to labels for property of the same name */
  public var textColor: UIColor = UIColor.blackColor() {
    didSet { apply(labels){[color = textColor] in $0.textColor = color} }
  }

  /** Storage for the color passed through to labels for property of the same name */
  public var highlightedTextColor: UIColor = UIColor(name: "dodger-blue")! {
    didSet { apply(labels){[color = highlightedTextColor] in $0.highlightedTextColor = color} }
  }

  /** Storage for the `Action` closures associated with each label */
  private var actions: [Action] = []

  /** Overridden to pass through value to/from the shape layer's `fillColor` property */
  public override var backgroundColor: UIColor? {
    get { return UIColor(CGColor: (layer as! CAShapeLayer).fillColor) }
    set { (layer as! CAShapeLayer).fillColor = newValue?.CGColor }
  }

  /** Overridden to use `CAShapeLayer` as the view's backing layer */
  public override class func layerClass() -> AnyClass { return CAShapeLayer.self }

  /** Value used to size the arrow */
  public var offset: CGFloat = 10 { didSet { refreshShape() } }

  /**
  Overridden to account for the top/bottom arrow

  :returns: UIEdgeInsets
  */
  public override func alignmentRectInsets() -> UIEdgeInsets {
    switch location {
      case .Top:    return UIEdgeInsets(top: offset, left: 0, bottom: 0, right: 0)
      case .Bottom: return UIEdgeInsets(top: 0, left: 0, bottom: offset, right: 0)
    }
  }

  /** Method for updating the shape layer's path according to the views `bounds` and `location` */
  private func refreshShape() {
    let (w, h) = bounds.size.unpack()
    if w < 20 || h < 20 { return }
    let path = UIBezierPath()
    switch location {
    case .Top:
      path.moveToPoint(CGPoint(x: 0, y: offset))
      path.addLineToPoint(CGPoint(x: round(w * 0.5) - offset, y: offset))
      path.addLineToPoint(CGPoint(x: round(w * 0.5), y: 0))
      path.addLineToPoint(CGPoint(x: round(w * 0.5) + offset, y: offset))
      path.addLineToPoint(CGPoint(x: w, y: offset))
      path.addLineToPoint(CGPoint(x: w, y: h))
      path.addLineToPoint(CGPoint(x: 0, y: h))
      path.closePath()
    case .Bottom:
      path.moveToPoint(CGPoint.zeroPoint)
      path.addLineToPoint(CGPoint(x: w, y: 0))
      path.addLineToPoint(CGPoint(x: w, y: h - offset))
      path.addLineToPoint(CGPoint(x: round(w * 0.5) + offset, y: h - offset))
      path.addLineToPoint(CGPoint(x: round(w * 0.5), y: h))
      path.addLineToPoint(CGPoint(x: round(w * 0.5) - offset, y: h - offset))
      path.addLineToPoint(CGPoint(x: 0, y: h - offset))
      path.closePath()
    }
    (layer as! CAShapeLayer).path = path.CGPath
  }

  /** updateConstraints */
  public override func updateConstraints() {
    removeAllConstraints()
    super.updateConstraints()
    if let effectView = subviews.first as? UIVisualEffectView { constrain(𝗛|effectView|𝗛, 𝗩|effectView|𝗩) }
    let labels = self.labels
    if labels.count == 0 { return }
    let topOffset: Float
    let bottomOffset: Float
    switch location {
      case .Top:    topOffset = Float(offset + 8); bottomOffset = 8
      case .Bottom: bottomOffset = Float(offset + 8); topOffset = 8
    }
    var prevLabel: UILabel?
    for label in labels {
      constrain(𝗛|--8--label--8--|𝗛)
      if let prev = prevLabel { constrain(label.top => prev.bottom + 8) } else { constrain(𝗩|--topOffset--label) }
      prevLabel = label
    }
    constrain(prevLabel!--bottomOffset--|𝗩)
  }

  /** Convenience accessor for the view's subviews as `UILabel` objects */
  private var labels: [UILabel] { return flattened(contentView.subviews) }

  /** Overridden so we can update our shape's path on bounds changes */
  public override var bounds: CGRect { didSet { refreshShape() } }

  /**
  Callback for tap gestures attached to the labels

  :param: sender UITapGestureRecognizer
  */
  func handleTap(sender: UITapGestureRecognizer) {
    if let label = sender.view as? UILabel where label.tag < actions.count, let string = label.text {
      label.highlighted = true
      delayedDispatchToMain(0.5, {self.actions[label.tag](self, string)})
    }
  }

  /**
  Internal method for creating and decorating a new `UILabel` object

  :param: text String

  :returns: UILabel
  */
  private func newLabelWithText(text: String) -> UILabel {
    let label = UILabel(autolayout: true)
    label.tag = labels.count
    label.font = font
    label.textColor = textColor
    label.text = text
    label.highlightedTextColor = highlightedTextColor
    label.backgroundColor = UIColor.clearColor()
    label.userInteractionEnabled = true
    label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
    return label
  }

  private weak var contentView: UIView!

  private func initializeIVARs() {
    let blur = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
    blur.setTranslatesAutoresizingMaskIntoConstraints(false)
    blur.contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
    blur.constrain(𝗩|blur.contentView|𝗩, 𝗛|blur.contentView|𝗛)
    let vibrancy = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: .Dark)))
    vibrancy.setTranslatesAutoresizingMaskIntoConstraints(false)
    blur.contentView.addSubview(vibrancy)
    blur.contentView.constrain(𝗩|vibrancy|𝗩, 𝗛|vibrancy|𝗛)
    vibrancy.contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
    vibrancy.constrain(𝗩|vibrancy.contentView|𝗩, 𝗛|vibrancy.contentView|𝗛)
    contentView = vibrancy.contentView
    addSubview(blur)
  }

  public override class func requiresConstraintBasedLayout() -> Bool { return true }

  /**
  initWithFrame:

  :param: frame CGRect
  */
  public override init(frame: CGRect) { super.init(frame: frame); initializeIVARs() }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required public init(coder aDecoder: NSCoder) { super.init(coder: aDecoder); initializeIVARs() }



  /**
  Overridden to return a size composed of the stacked `labels`

  :returns: CGSize
  */
  public override func intrinsicContentSize() -> CGSize {
    let labelSizes = labels.map {$0.intrinsicContentSize()}
    let w = min(maxElement(labelSizes.map {$0.width}), UIScreen.mainScreen().bounds.width - 8)
    let h = sum(labelSizes.map {$0.height}) + CGFloat(labelSizes.count + 1) * CGFloat(10)
    return CGSize(width: w, height: h)
  }

  /**
  Method to add a new label with the specified text and action

  :param: string String
  :param: action Action
  */
  public func addLabel(label string: String, withAction action: Action) {
    contentView.addSubview(newLabelWithText(string))
    actions.append(action)
  }

}
