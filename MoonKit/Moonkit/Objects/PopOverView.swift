//
//  PopOverView.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/22/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import UIKit

public class PopOverView: UIView {

  /** Enumeration to define which edge of the view will have an arrow */
  public enum Location { case Top, Bottom }

  /** Whether the arrow is drawn at the top or the bottom of the view, also affects label offsets and alignment rect */
  public var location: Location = .Bottom

  /** Storage for the color passed through to labels for property of the same name */
  public var font: UIFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline) {
    didSet { apply(labels){[font = font] in $0.font = font} }
  }

  /** Storage for the color passed through to labels for property of the same name */
  public var textColor: UIColor = UIColor.whiteColor() {
    didSet { apply(labels){[color = textColor] in $0.textColor = color} }
  }

  /** Storage for the color passed through to labels for property of the same name */
  public var highlightedTextColor: UIColor = UIColor(name: "dodger-blue")! {
    didSet { apply(labels){[color = highlightedTextColor] in $0.highlightedTextColor = color} }
  }

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
    if w < offset || h < offset { return }

    let path = UIBezierPath()
    switch location {
    case .Top:
      path.moveToPoint   (CGPoint(x: 0,                       y: offset    ))
      path.addLineToPoint(CGPoint(x: round(half(w)) - offset, y: offset    ))
      path.addLineToPoint(CGPoint(x: round(half(w)),          y: 0         ))
      path.addLineToPoint(CGPoint(x: round(half(w)) + offset, y: offset    ))
      path.addLineToPoint(CGPoint(x: w,                       y: offset    ))
      path.addLineToPoint(CGPoint(x: w,                       y: h         ))
      path.addLineToPoint(CGPoint(x: 0,                       y: h         ))
    case .Bottom:
      path.moveToPoint   (CGPoint(x: 0,                       y: 0         ))
      path.addLineToPoint(CGPoint(x: w,                       y: 0         ))
      path.addLineToPoint(CGPoint(x: w,                       y: h - offset))
      path.addLineToPoint(CGPoint(x: round(half(w)) + offset, y: h - offset))
      path.addLineToPoint(CGPoint(x: round(half(w)),          y: h         ))
      path.addLineToPoint(CGPoint(x: round(half(w)) - offset, y: h - offset))
      path.addLineToPoint(CGPoint(x: 0,                       y: h - offset))
    }
    path.closePath()
    maskingLayer.frame = CGRect(size: bounds.size)
    maskingLayer.path = path.CGPath
  }

  /** updateConstraints */
  public override func updateConstraints() {
    removeAllConstraints()
    super.updateConstraints()

    var topOffset:    Float = location == .Top    ? Float(offset) : 0
    var bottomOffset: Float = location == .Bottom ? Float(offset) : 0

    if let effect = subviews.first as? UIVisualEffectView {
      constrain(𝗛|effect|𝗛, [effect.top => self.top - topOffset, effect.bottom => self.bottom + bottomOffset])
    }


    let labels = self.labels
    if labels.count == 0 { return }

    topOffset += 8; bottomOffset += 8

    var prevLabel: UILabel?

    for label in labels {
      constrain(𝗛|--8--label--8--|𝗛)
      if let prev = prevLabel { constrain(label.top => prev.bottom + 8) } else { constrain(𝗩|--topOffset--label) }
      prevLabel = label
    }

    constrain(prevLabel!--bottomOffset--|𝗩)
  }

  /** Convenience accessor for the view's subviews as `UILabel` objects */
  private var labels: [LabelButton] { return flattened(contentView.subviews) }

  /** Overridden so we can update our shape's path on bounds changes */
  public override var bounds: CGRect { didSet { refreshShape() } }

  private weak var contentView: UIView!
  private weak var maskingLayer: CAShapeLayer!

  private func initializeIVARs() {
    let maskingLayer = CAShapeLayer()
    layer.mask = maskingLayer
    self.maskingLayer = maskingLayer
    refreshShape()

    let blurEffect = UIBlurEffect(style: .Dark)
    let blur = UIVisualEffectView(effect: blurEffect)
    blur.setTranslatesAutoresizingMaskIntoConstraints(false)
    blur.contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
    blur.constrain(𝗩|blur.contentView|𝗩, 𝗛|blur.contentView|𝗛)

    addSubview(blur)
    contentView = blur.contentView
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
  :param: action (PopOverView, String) -> Void
  */
  public func addLabel(label string: String, withAction action: (PopOverView) -> Void) {
    let label = LabelButton(autolayout: true)
    label.tag = labels.count
    label.font = font
    label.textColor = textColor
    label.text = string
    label.highlightedTextColor = highlightedTextColor
    label.backgroundColor = UIColor.clearColor()
    label.userInteractionEnabled = true
    label.actions.append {_ in action(self)}
    contentView.addSubview(label)
  }

}
