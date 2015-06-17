//
//  BankCollectionDetailAttributedTextCell.swift
//  Remote
//
//  Created by Jason Cardwell on 11/28/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//


import Foundation
import UIKit
import MoonKit

final class BankCollectionDetailAttributedTextCell: BankCollectionDetailCell {

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
      repeat {
        color = parentView?.backgroundColor
        parentView = parentView?.superview
      } while color == nil && parentView != nil

      return color?.isRGBCompatible == true ? color! : UIColor.whiteColor()
    }

    var foregroundColor: UIColor {
      let color = attributedText?.foregroundColor
      return color?.isRGBCompatible == true ? color! : UIColor.blackColor()
    }

    /**
    initWithFrame:

    - parameter frame: CGRect
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

    - parameter autolayout: Bool
    */
    init(autolayout: Bool) {
      super.init(frame: CGRect.zeroRect)
      translatesAutoresizingMaskIntoConstraints = !autolayout
    }

    /**
    init:

    - parameter aDecoder: NSCoder
    */
    required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

    /**
    intrinsicContentSize

    - returns: CGSize
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

    - parameter rect: CGRect
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
          text.enumerateAttribute(NSFontAttributeName, inRange: NSRange(0..<text.length), options: []) {
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
    removeAllConstraints()
    super.updateConstraints()

    if name != nil {
      contentView.constrain(
        𝗛|-nameLabel--attributedTextDisplay-|𝗛,
        𝗩|-nameLabel-|𝗩, 𝗩|-attributedTextDisplay-|𝗩,
        [attributedTextDisplay.width => nameLabel.width, attributedTextDisplay.height => nameLabel.height]
      )
    } else {
      contentView.constrain(𝗛|attributedTextDisplay|𝗛, 𝗩|attributedTextDisplay|𝗩)

    }
  }

  override var name: String? { didSet { setNeedsUpdateConstraints() } }

  override func initializeIVARs() {
    contentView.addSubview(nameLabel)
    contentView.addSubview(attributedTextDisplay)
  }

  private let attributedTextDisplay = AttributedTextDisplay(autolayout: true)

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
