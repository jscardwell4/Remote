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

  :param: font UIFont
  */
  public func setFont(font: UIFont, range: Range<Int>? = nil) {
    if length > 0 { addAttribute(NSFontAttributeName, value: font, range: NSRange(range ?? 0..<length)) }
  }

}

extension NSParagraphStyle {

  /**
  Method of convenience for creating a paragraph style with attributes already set.

  :param: lineSpacing CGFloat = 0
  :param: paragraphSpacing CGFloat = 0
  :param: alignment NSTextAlignment = .Natural
  :param: headIndent CGFloat = 0
  :param: tailIndent CGFloat = 0
  :param: firstLineHeadIndent CGFloat = 0
  :param: minimumLineHeight CGFloat = 0
  :param: maximumLineHeight CGFloat = 0
  :param: lineBreakMode NSLineBreakMode = .ByWordWrapping
  :param: lineHeightMultiple CGFloat = 0
  :param: paragraphSpacingBefore CGFloat = 0
  :param: hyphenationFactor Float = 0
  :param: tabStops [AnyObject]? = nil
  :param: defaultTabInterval CGFloat = 0

  :returns: NSParagraphStyle
  */
  public class func paragraphStyleWithAttributes(
      lineSpacing: CGFloat = 0,
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
      tabStops: [AnyObject]? = nil,
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
