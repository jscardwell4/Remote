//
//  NSAttributedString+MoonKitAdditions.swift
//  Remote
//
//  Created by Jason Cardwell on 12/11/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

import UIKit

extension NSAttributedString {
  public var font: UIFont? { return attribute(NSFontAttributeName, atIndex: 0, effectiveRange: nil) as? UIFont }

  public var foregroundColor: UIColor? {
    return length > 0 ? attribute(NSForegroundColorAttributeName, atIndex: 0, effectiveRange: nil) as? UIColor : nil
  }

  public var backgroundColor: UIColor? {
    return length > 0 ? attribute(NSBackgroundColorAttributeName, atIndex: 0, effectiveRange: nil) as? UIColor : nil
  }

}

extension NSMutableAttributedString {

  public override var font: UIFont? {
    get { return length > 0 ? attribute(NSFontAttributeName, atIndex: 0, effectiveRange: nil) as? UIFont : nil }
    set {
      if length > 0 {
        if newValue != nil { addAttribute(NSFontAttributeName, value: newValue!, range: NSRange(0..<length)) }
        else { removeAttribute(NSFontAttributeName, range: NSRange(0..<length)) }
      }
    }
  }

  /**
  setFont:

  - parameter font: UIFont
  */
  public func setFont(font: UIFont, range: Range<Int>? = nil) {
    if length > 0 { addAttribute(NSFontAttributeName, value: font, range: NSRange(range ?? 0..<length)) }
  }

}

extension NSParagraphStyle {

  /**
  Method of convenience for creating a paragraph style with attributes already set.

  - parameter lineSpacing: CGFloat = 0
  - parameter paragraphSpacing: CGFloat = 0
  - parameter alignment: NSTextAlignment = .Natural
  - parameter headIndent: CGFloat = 0
  - parameter tailIndent: CGFloat = 0
  - parameter firstLineHeadIndent: CGFloat = 0
  - parameter minimumLineHeight: CGFloat = 0
  - parameter maximumLineHeight: CGFloat = 0
  - parameter lineBreakMode: NSLineBreakMode = .ByWordWrapping
  - parameter lineHeightMultiple: CGFloat = 0
  - parameter paragraphSpacingBefore: CGFloat = 0
  - parameter hyphenationFactor: Float = 0
  - parameter tabStops: [AnyObject]? = nil
  - parameter defaultTabInterval: CGFloat = 0

  - returns: NSParagraphStyle
  */
  public class func paragraphStyleWithAttributes(
      lineSpacing lineSpacing: CGFloat = 0,
      paragraphSpacing: CGFloat = 0,
      alignment: NSTextAlignment = .Natural,
      headIndent: CGFloat = 0,
      tailIndent: CGFloat = 0,
      firstLineHeadIndent: CGFloat = 0,
      minimumLineHeight: CGFloat = 0,
      maximumLineHeight: CGFloat = 0,
      lineBreakMode: NSLineBreakMode = .ByWordWrapping,
      lineHeightMultiple: CGFloat = 0,
      paragraphSpacingBefore: CGFloat = 0,
      hyphenationFactor: Float = 0,
      tabStops: [NSTextTab]? = nil,
      defaultTabInterval: CGFloat = 0
    ) -> NSParagraphStyle
  {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = lineSpacing
    paragraphStyle.paragraphSpacing = paragraphSpacing
    paragraphStyle.alignment = alignment
    paragraphStyle.headIndent = headIndent
    paragraphStyle.tailIndent = tailIndent
    paragraphStyle.firstLineHeadIndent = firstLineHeadIndent
    paragraphStyle.minimumLineHeight = minimumLineHeight
    paragraphStyle.maximumLineHeight = maximumLineHeight
    paragraphStyle.lineBreakMode = lineBreakMode
    paragraphStyle.lineHeightMultiple = lineHeightMultiple
    paragraphStyle.paragraphSpacingBefore = paragraphSpacingBefore
    paragraphStyle.hyphenationFactor = hyphenationFactor
    paragraphStyle.tabStops = tabStops
    paragraphStyle.defaultTabInterval = defaultTabInterval
    return paragraphStyle
  }


}
