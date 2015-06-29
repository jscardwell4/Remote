//
//  DetailSectionHeader.swift
//  Remote
//
//  Created by Jason Cardwell on 12/9/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailSectionHeader: UITableViewHeaderFooterView {

  /// MARK: Identifiers

  private let identifier: Identifier

  /** A simple string-based enum to establish valid reuse identifiers for use with styling the header */
  enum Identifier: String, EnumerableType {
    case Header           = "DetailSectionHeader"
    case FilteringHeader  = "FilteringDetailSectionHeader"

    static var all: [Identifier] { return [.Header, .FilteringHeader] }

    var headerType: DetailSectionHeader.Type {
      switch self {
        case .Header:          return DetailSectionHeader.self
        case .FilteringHeader: return FilteringDetailSectionHeader.self
      }
    }

    /**
    enumerate:

    - parameter block: (Identifier) -> Void
    */
    static func enumerate(block: (Identifier) -> Void) { apply(all, block) }

    /**
    registerWithTableView:

    - parameter tableView: UITableView
    */
    func registerWithTableView(tableView: UITableView) {
      tableView.registerClass(headerType, forHeaderFooterViewReuseIdentifier: rawValue)
    }

    /**
    registerAllWithTableView:

    - parameter tableView: UITableView
    */
    static func registerAllWithTableView(tableView: UITableView) { enumerate { $0.registerWithTableView(tableView) } }
  }

  /**
  registerIdentifiersWithTableView:

  - parameter tableView: UITableView
  */
  class func registerIdentifiersWithTableView(tableView: UITableView) { Identifier.registerAllWithTableView(tableView) }

  var title: String? { didSet { setNeedsUpdateConstraints(); setNeedsDisplay() } }

  /**
  init:

  - parameter reuseIdentifier: String?
  */
  override init(reuseIdentifier: String?) {
    identifier = Identifier(rawValue: reuseIdentifier ?? "") ?? .Header
    super.init(reuseIdentifier: reuseIdentifier)
    opaque = false
    contentView.opaque = false
    contentView.backgroundColor = UIColor.clearColor()
  }

  override func updateConstraints() {
    removeAllConstraints()
    contentView.removeAllConstraints()
    super.updateConstraints()

    constrain(𝗩|contentView|𝗩 -!> 999, 𝗛|contentView|𝗛 -!> 999)
    if title != nil { contentView.constrain(contentView.height ≥ 44 -!> 999) }
    else { contentView.constrain(contentView.height => 10 -!> 999) }
  }

  /**
  initWithFrame:

  - parameter frame: CGRect
  */
//  override init(frame: CGRect) { identifier = .Header; super.init(frame: frame) }

  /**
  initWithCoder:

  - parameter aDecoder: NSCoder
  */
  required init(coder aDecoder: NSCoder) { identifier = .Header; super.init(coder: aDecoder) }

  /** prepareForReuse */
  override func prepareForReuse() { title = nil; super.prepareForReuse() }

  /**
  requiresConstraintBasedLayout

  - returns: Bool
  */
  override class func requiresConstraintBasedLayout() -> Bool { return true }

  /**
  drawRect:

  - parameter rect: CGRect
  */
  override func drawRect(rect: CGRect) {

    let context = UIGraphicsGetCurrentContext()


    let tableBackgroundColor = UIColor(red: 0.937, green: 0.937, blue: 0.957, alpha: 1.000)


    let textInnerShadow = NSShadow(color: UIColor.blackColor().colorWithAlphaComponent(0.6),
                                   offset: CGSizeMake(0.1, -0.1),
                                   blurRadius: 4)
    let textOuterShadow = NSShadow(color: UIColor.whiteColor(),
                                   offset: CGSize(width: 0.1, height: 0.6),
                                   blurRadius: 0)


    tableBackgroundColor.setFill()
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
                                NSForegroundColorAttributeName: tableBackgroundColor,
                                NSParagraphStyleAttributeName: textStyle]

      // let textTextHeight: CGFloat = titleText.boundingRectWithSize(CGSize(width: textRect.width, height: CGFloat.infinity),
      //                                                      options: .UsesLineFragmentOrigin,
      //                                                   attributes: textFontAttributes,
      //                                                      context: nil).height

      // let textTextRect = CGRect(x: textRect.minX,
      //                           y: textRect.minY + textRect.height - textTextHeight,
      //                           width: textRect.width,
      //                           height: textTextHeight)

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

      CGContextSetBlendMode(context, .SourceOut)

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
