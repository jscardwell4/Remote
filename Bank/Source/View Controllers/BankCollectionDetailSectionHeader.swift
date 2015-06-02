//
//  BankCollectionDetailSectionHeader.swift
//  Remote
//
//  Created by Jason Cardwell on 6/02/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankCollectionDetailSectionHeader: UICollectionReusableView {

  /// MARK: Identifiers

  /** A simple string-based enum to establish valid reuse identifiers for use with styling the header */
  enum Identifier: String, EnumerableType {
    case Header           = "BankCollectionDetailSectionHeader"
    case FilteringHeader  = "BankCollectionFilteringDetailSectionHeader"

    static var all: [Identifier] { return [.Header, .FilteringHeader] }

    var headerType: BankCollectionDetailSectionHeader.Type {
      switch self {
        case .Header:          return BankCollectionDetailSectionHeader.self
        case .FilteringHeader: return BankCollectionFilteringDetailSectionHeader.self
      }
    }

    /**
    enumerate:

    :param: block (Identifier) -> Void
    */
    static func enumerate(block: (Identifier) -> Void) { apply(all, block) }

    /**
    registerWithCollectionView:

    :param: collectionView UICollectionView
    */
    func registerWithCollectionView(collectionView: UICollectionView) {
      collectionView.registerClass(headerType, forSupplementaryViewOfKind: "Header", withReuseIdentifier: rawValue)
    }

    /**
    registerAllWithCollectionView:

    :param: collectionView UICollectionView
    */
    static func registerAllWithCollectionView(collectionView: UICollectionView) {
      enumerate { $0.registerWithCollectionView(collectionView) }
   }

  }

  /**
  registerIdentifiersWithCollectionView:

  :param: collectionView UICollectionView
  */
  class func registerIdentifiersWithCollectionView(collectionView: UICollectionView) {
    Identifier.registerAllWithCollectionView(collectionView)
  }

  var title: String? { didSet { setNeedsUpdateConstraints(); setNeedsDisplay() } }

  /** initializeIVARs */
  func initializeIVARs() {
    opaque = false
    backgroundColor = UIColor.clearColor()
  }

  /**
  initWithFrame:

  :param: frame CGRect
  */
  override init(frame: CGRect) { super.init(frame: frame); initializeIVARs() }

  /**
  initWithCoder:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder); initializeIVARs() }

  /** prepareForReuse */
  override func prepareForReuse() { title = nil; super.prepareForReuse() }

  /**
  requiresConstraintBasedLayout

  :returns: Bool
  */
  override class func requiresConstraintBasedLayout() -> Bool { return true }

  /**
  drawRect:

  :param: rect CGRect
  */
  override func drawRect(rect: CGRect) {

    let context = UIGraphicsGetCurrentContext()


    let bgColor = UIColor(red: 0.937, green: 0.937, blue: 0.957, alpha: 1.000)


    let textInnerShadow = NSShadow(color: UIColor.blackColor().colorWithAlphaComponent(0.6),
                                   offset: CGSizeMake(0.1, -0.1),
                                   blurRadius: 4)
    let textOuterShadow = NSShadow(color: UIColor.whiteColor(),
                                   offset: CGSize(width: 0.1, height: 0.6),
                                   blurRadius: 0)


    bgColor.setFill()
    UIRectFill(rect)

    if let titleText = title {


      let textRect = CGRect(x: rect.minX + 20, y: rect.minY + 12, width: rect.width - 84, height: rect.height - 12)

      UIGraphicsPushContext(context)
      CGContextSetShadowWithColor(context,
                                  textOuterShadow.shadowOffset,
                                  textOuterShadow.shadowBlurRadius,
                                  (textOuterShadow.shadowColor as! UIColor).CGColor)

      let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
      textStyle.alignment = NSTextAlignment.Left

      let textFontAttributes = [NSFontAttributeName: Bank.sectionHeaderFont,
                                NSForegroundColorAttributeName: bgColor,
                                NSParagraphStyleAttributeName: textStyle]

      UIGraphicsPushContext(context)

      UIRectClip(textRect)

      titleText.drawInRect(textRect, withAttributes: textFontAttributes)

      UIGraphicsPopContext()


      UIGraphicsPushContext(context)

      UIRectClip(textRect)

      CGContextSetShadow(context, CGSize.zeroSize, 0)
      CGContextSetAlpha(context, CGColorGetAlpha((textInnerShadow.shadowColor as! UIColor).CGColor))

      CGContextBeginTransparencyLayer(context, nil)

      let textOpaqueTextShadow = (textInnerShadow.shadowColor as! UIColor).colorWithAlphaComponent(1)

      CGContextSetShadowWithColor(context,
                                  textInnerShadow.shadowOffset,
                                  textInnerShadow.shadowBlurRadius,
                                  (textOpaqueTextShadow as UIColor).CGColor)

      CGContextSetBlendMode(context, kCGBlendModeSourceOut)

      CGContextBeginTransparencyLayer(context, nil)

      textOpaqueTextShadow.setFill()

      let textInnerShadowFontAttributes = [NSFontAttributeName: Bank.sectionHeaderFont,
                                           NSForegroundColorAttributeName: textInnerShadow.shadowColor!,
                                           NSParagraphStyleAttributeName: textStyle]

      titleText.drawInRect(textRect, withAttributes: textInnerShadowFontAttributes)

      CGContextEndTransparencyLayer(context)
      CGContextEndTransparencyLayer(context)

      UIGraphicsPopContext()


      UIGraphicsPopContext()

    }

  }

}