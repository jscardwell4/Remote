//
//  PopoverView.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/22/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
public class PopoverView: UIView {

  public typealias Action = (PopoverView) -> Void

  /** Struct for holding the data associated with a single label in the list */
  public struct LabelData {
    public let text: String
    public let action: Action
    public init(text t: String, action a: Action) { text = t; action = a }
  }

  /** Enumeration to define which edge of the view will have an arrow */
  public enum Location { case Top, Bottom }

  /** Whether the arrow is drawn at the top or the bottom of the view, also affects label offsets and alignment rect */
  public var location: Location = .Bottom

  /** Storage for the color passed through to labels for property of the same name */
  public var font: UIFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline) {
    didSet { labels.apply {[font = font] in $0.font = font} }
  }

  /** Storage for the color passed through to labels for property of the same name */
  public var textColor: UIColor = UIColor.whiteColor() {
    didSet { labels.apply {[color = textColor] in $0.textColor = color} }
  }

  /** Storage for the color passed through to labels for property of the same name */
  public var highlightedTextColor: UIColor = UIColor(name: "dodger-blue")! {
    didSet { labels.apply {[color = highlightedTextColor] in $0.highlightedTextColor = color} }
  }

  /** Value used to size the arrow's width */
  public var arrowWidth: CGFloat = 10  { didSet { refreshShape() } }

  /** Value used to size the arrow's height */
  public var arrowHeight: CGFloat = 10  { didSet { refreshShape() } }

  /** Value used to place arrow */
  public var xOffset: CGFloat = 0 { didSet { refreshShape() } }

  /** The data used to generate `LabelButton` instances */
  private let data: [LabelData]

  /** Optional callback for when popover is dismissed by touching outside it's bounds */
  private let dismissal: ((PopoverView) -> Void)?

  /** Stack view used to arrange the label buttons */
  private weak var stackView: UIStackView!

  /**
  Overridden to account for the top/bottom arrow

  - returns: UIEdgeInsets
  */
  public override func alignmentRectInsets() -> UIEdgeInsets {
    switch location {
      case .Top:    return UIEdgeInsets(top: arrowHeight, left: 0, bottom: 0, right: 0)
      case .Bottom: return UIEdgeInsets(top: 0, left: 0, bottom: arrowHeight, right: 0)
    }
  }

  /** Method for updating the shape layer's path according to the views `bounds` and `location` */
  private func refreshShape() {
    let (w, h) = bounds.size.unpack()
    guard w > arrowWidth && h > arrowHeight else { return }

    let mid = round(half(w) + xOffset)
    let arrowWidth_2 = arrowWidth / 2
    let path = UIBezierPath()

    switch location {
      case .Top:
        path.moveToPoint   (CGPoint(x: 0,                     y: arrowHeight    ))
        path.addLineToPoint(CGPoint(x: mid - arrowWidth_2,    y: arrowHeight    ))
        path.addLineToPoint(CGPoint(x: mid,                   y: 0              ))
        path.addLineToPoint(CGPoint(x: mid + arrowWidth_2,    y: arrowHeight    ))
        path.addLineToPoint(CGPoint(x: w,                     y: arrowHeight    ))
        path.addLineToPoint(CGPoint(x: w,                     y: h              ))
        path.addLineToPoint(CGPoint(x: 0,                     y: h              ))
      case .Bottom:
        path.moveToPoint   (CGPoint(x: 0,                     y: 0              ))
        path.addLineToPoint(CGPoint(x: w,                     y: 0              ))
        path.addLineToPoint(CGPoint(x: w,                     y: h - arrowHeight))
        path.addLineToPoint(CGPoint(x: mid + arrowWidth_2,    y: h - arrowHeight))
        path.addLineToPoint(CGPoint(x: mid,                   y: h              ))
        path.addLineToPoint(CGPoint(x: mid - arrowWidth_2,    y: h - arrowHeight))
        path.addLineToPoint(CGPoint(x: 0,                     y: h - arrowHeight))
    }

    path.closePath()

    maskingLayer.frame = CGRect(size: bounds.size)
    maskingLayer.path = path.CGPath
  }

  /** updateConstraints */
  public override func updateConstraints() {
    super.updateConstraints()

    let id = Identifier(self, "Internal")

    guard constraintsWithIdentifier(id).count == 0 else { return }

    removeConstraints(constraintsWithIdentifier(id))

    var topOffset:    CGFloat = location == .Top    ? arrowHeight : 0
    var bottomOffset: CGFloat = location == .Bottom ? arrowHeight : 0

    guard let effect = contentView?.superview as? UIVisualEffectView else { return }

    constrain(
      𝗛|effect|𝗛 --> id,
      [
        effect.top => top - topOffset,
        effect.bottom => bottom + bottomOffset
      ] --> id
    )

    if location == .Top { bottomOffset += arrowHeight } else { topOffset += bottomOffset }

    constrain(𝗛|--8--stackView--8--|𝗛 --> id, 𝗩|--topOffset--stackView--bottomOffset--|𝗩 --> id)
  }

  /** Convenience accessor for the view's `LabelButton` objects */
  private var labels: [LabelButton] { return stackView.arrangedSubviews as! [LabelButton] }

  /** Overridden so we can update our shape's path on bounds changes */
  public override var bounds: CGRect { didSet { refreshShape() } }

  /** Holds a reference to the effect view's content view */
  private weak var contentView: UIView!

  /** Convenience accessor for the shape layer used to mask root layer */
  private var maskingLayer: CAShapeLayer { return layer.mask as! CAShapeLayer }

  /** initializeIVARs */
  private func initializeIVARs() {
    translatesAutoresizingMaskIntoConstraints = false

    layer.mask = CAShapeLayer()
    refreshShape()

    let blurEffect = UIBlurEffect(style: .Dark)
    let blur = UIVisualEffectView(effect: blurEffect)
    blur.translatesAutoresizingMaskIntoConstraints = false
    blur.contentView.translatesAutoresizingMaskIntoConstraints = false
    blur.constrain(𝗩|blur.contentView|𝗩, 𝗛|blur.contentView|𝗛)

    addSubview(blur)
    contentView = blur.contentView

    let stackView = UIStackView(arrangedSubviews: data.enumerate().map {
      idx, labelData in
      let label = LabelButton(action: { [unowned self] _ in
        self.touchBarrier?.removeFromSuperview()
        self.removeFromSuperview()
        labelData.action(self)
      })
      label.tag = idx
      label.font = self.font
      label.textColor = self.textColor
      label.text = labelData.text
      label.highlightedTextColor = self.highlightedTextColor
      label.backgroundColor = UIColor.clearColor()
      return label
      })
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .Vertical
    stackView.alignment = .Center
    stackView.distribution = .EqualSpacing
    stackView.baselineRelativeArrangement = true
    contentView.addSubview(stackView)
    self.stackView = stackView

  }

  /**
  requiresConstraintBasedLayout

  - returns: Bool
  */
  public override class func requiresConstraintBasedLayout() -> Bool { return true }

  /**
  initWithLabelData:dismissal:

  - parameter labelData: [LabelData]
  - parameter callback: ((PopoverView) -> Void
  */
  public init(labelData: [LabelData], dismissal callback: ((PopoverView) -> Void)?) {
    data = labelData
    dismissal = callback
    super.init(frame: CGRect.zeroRect)
    initializeIVARs()
  }

  /**
  Initialization with coder is unsupported

  - parameter aDecoder: NSCoder
  */
  required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  /**
  Overridden to return a size composed of the stacked `labels`

  - returns: CGSize
  */
  public override func intrinsicContentSize() -> CGSize {
    let labelSizes = labels.map {$0.intrinsicContentSize()}
    let w = min(labelSizes.map {$0.width}.maxElement()! + 16, UIScreen.mainScreen().bounds.width - 16)
    let h = sum(labelSizes.map {$0.height}) + arrowHeight + 16
    return CGSize(width: w, height: h)
  }

  private weak var touchBarrier: ImageButtonView?

  /** didMoveToWindow */
  public override func didMoveToWindow() {
    super.didMoveToWindow()
    guard let window = window where self.touchBarrier == nil else { return }

    let touchBarrier = ImageButtonView(image: window.blurredSnapshot(), highlightedImage: nil) {
      [weak self] (imageView: ImageButtonView) -> Void in

      self?.removeFromSuperview()
      imageView.removeFromSuperview()
      self?.dismissal?(self!)
    }

    touchBarrier.frame = window.bounds
    touchBarrier.alpha = 0.25

    window.insertSubview(touchBarrier, belowSubview: self)
    self.touchBarrier = touchBarrier
  }
}
