//
//  DetailAttributedTextCell.swift
//  Remote
//
//  Created by Jason Cardwell on 11/28/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//


import Foundation
import UIKit
import MoonKit

final class DetailAttributedTextCell: DetailCell {

  private class AttributedTextDisplay: UIView {

    var attributedText: NSAttributedString? {
      didSet {
        if attributedText != oldValue {
          invalidateIntrinsicContentSize()
          setNeedsDisplay()
        }
      }
    }

    var usePerceivedBrightness: Bool = true { didSet { if usePerceivedBrightness != oldValue { setNeedsDisplay() } } }

    var baseColor: UIColor {
      var color: UIColor?
      var parentView = superview
      do {
        color = parentView?.backgroundColor
        parentView = parentView?.superview
      } while color == nil && parentView != nil

      return color?.isRGBCompatible == true ? color! : UIColor.whiteColor()
    }

    var foregroundColor: UIColor {
      let color = attributedText?.foregroundColor
      return color?.isRGBCompatible == true ? color! : UIColor.blackColor()
    }

    /** init */
    override init() { super.init() }

    /**
    initWithFrame:

    :param: frame CGRect
    */
    override init(frame: CGRect) {
      super.init(frame: frame)
      setContentHuggingPriority(1000, forAxis: .Vertical)
      setContentHuggingPriority(1000, forAxis: .Horizontal)
      setContentCompressionResistancePriority(0, forAxis: .Vertical)
      setContentCompressionResistancePriority(0, forAxis: .Horizontal)
    }

    /**
    initWithAutolayout:

    :param: autolayout Bool
    */
    init(autolayout: Bool) {
      super.init(frame: CGRect.zeroRect)
      setTranslatesAutoresizingMaskIntoConstraints(!autolayout)
    }

    /**
    init:

    :param: aDecoder NSCoder
    */
    required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

    /**
    intrinsicContentSize

    :returns: CGSize
    */
    override func intrinsicContentSize() -> CGSize {
      if let text = attributedText {
        return text.boundingRectWithSize(CGSize(square: CGFloat.infinity),
                                 options: .UsesLineFragmentOrigin,
                                 context: nil).size + 8.0
      } else {
        return CGSize(square: UIViewNoIntrinsicMetric)
      }
    }

    /**
    drawRect:

    :param: rect CGRect
    */
    override func drawRect(rect: CGRect) {

      let bgColor = baseColor
      let fgColor = foregroundColor
      let (bgBrightness, fgBrightness) = usePerceivedBrightness
                                           ? (bgColor.perceivedBrightness!, fgColor.perceivedBrightness!)
                                           : (bgColor.brightness!, fgColor.brightness!)
      let offset: CGFloat = abs(bgBrightness - fgBrightness) > 0.5 ? 0 : bgBrightness * 0.75

      let context = UIGraphicsGetCurrentContext()

      baseColor.setFill()
      UIRectFill(rect)

      bgColor.addedWithRed(-offset, green: -offset, blue: -offset, alpha: 0)?.setFill()
      UIRectFill(rect)

      UIGraphicsPushContext(context)
      UIRectClip(rect)
      CGContextSetShadow(context, CGSize.zeroSize, 0)

      let innerShadowColor = UIColor.whiteColor()
      let innerShadow = NSShadow(color: innerShadowColor, offset: CGSize(width: 0.1, height: -0.1), blurRadius: 2)

      CGContextBeginTransparencyLayer(context, nil)
      CGContextSetShadowWithColor(context, innerShadow.shadowOffset, innerShadow.shadowBlurRadius, innerShadowColor.CGColor)
      CGContextSetBlendMode(context, kCGBlendModeSourceOut)
      CGContextBeginTransparencyLayer(context, nil)

      innerShadowColor.setFill()
      UIRectFill(rect)

      CGContextEndTransparencyLayer(context)
      CGContextEndTransparencyLayer(context)
      UIGraphicsPopContext()

      baseColor.setStroke()
      UIRectFrame(rect)

      if let text = attributedText?.mutableCopy() as? NSMutableAttributedString {

        var frame = UIEdgeInsets(inset: 4).insetRect(rect)

        if frame.size.minAxis <= 0 { return }

        let naturalSize = text.size()

        if frame.size.contains(naturalSize) {

          let halfDeltaSize = (frame.size - naturalSize) * 0.5
          frame.inset(dx: halfDeltaSize.width, dy: halfDeltaSize.height)

        } else {

          let multiplier = frame.size.height / naturalSize.height
          text.enumerateAttribute(NSFontAttributeName, inRange: NSRange(0..<text.length), options: nil) {
            (value: AnyObject!, range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in

            if let font = value as? UIFont {
              text.addAttribute(NSFontAttributeName, value: font.fontWithSize(font.pointSize * multiplier), range: range)
            }

          }

        }

        text.drawWithRect(frame, options: .UsesLineFragmentOrigin, context: nil)

      }

    }

  }

  /** updateConstraints */
  override func updateConstraints() {
    super.updateConstraints()

    let id = createIdentifier(self, ["Internal"])
    contentView.removeConstraintsWithIdentifier(id)
    if name != nil {
      let format = "|-[name]-[text(==name)]-| :: V:|-[name]-| :: V:|-[text(==name)]-|"
      contentView.constrain(format, views: ["name": nameLabel, "text": attributedTextDisplay], identifier: id)
    } else {
      let format = "|[text]| :: V:|[text]|"
      contentView.constrain(format, views: ["text": attributedTextDisplay], identifier: id)

    }
  }

  override var name: String? { didSet { setNeedsUpdateConstraints() } }

  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewCellStyle
  :param: reuseIdentifier String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    contentView.addSubview(nameLabel)
    contentView.addSubview(attributedTextDisplay)
  }

  private let attributedTextDisplay = AttributedTextDisplay(autolayout: true)

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    nameLabel.text = nil
    attributedTextDisplay.attributedText = nil
  }

  override var info: AnyObject? {
    get { return attributedTextDisplay.attributedText }
    set { attributedTextDisplay.attributedText = newValue as? NSAttributedString }
  }

}
