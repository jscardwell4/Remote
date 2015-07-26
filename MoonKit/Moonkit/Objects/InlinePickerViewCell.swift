//
//  InlinePickerViewCell.swift
//  MoonKit
//
//  Created by Jason Cardwell on 7/2/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

class InlinePickerViewCell: UICollectionViewCell {

  private let label = UILabel(autolayout: true)

  var text: NSAttributedString? { didSet { if !selected { label.attributedText = text } } }

  var selectedText: NSAttributedString? { didSet { if selected { label.attributedText = selectedText } } }

  override var selected: Bool {
    didSet {
      switch selected {
        case true where selectedText != nil: label.attributedText = selectedText
        default: label.attributedText = text
      }
    }
  }

  /**
  initWithFrame:

  - parameter frame: CGRect
  */
  override init(frame: CGRect) { super.init(frame: frame); initializeIVARs() }

  /**
  init:

  - parameter aDecoder: NSCoder
  */
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    text = aDecoder.decodeObjectForKey("InlinePickerViewCellText") as? NSAttributedString
    selectedText = aDecoder.decodeObjectForKey("InlinePickerViewCellSelectedText") as? NSAttributedString
    initializeIVARs()
  }

  /**
  applyLayoutAttributes:

  - parameter layoutAttributes: UICollectionViewLayoutAttributes
  */
  override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
    super.applyLayoutAttributes(layoutAttributes)

    layer.zPosition = (layoutAttributes as? InlinePickerViewLayout.Attributes)?.zPosition ?? 0.0
  }

  override var description: String {
    var result = String(dropLast(super.description.characters))
    result.extend("; text = " + (text != nil ? "'\(text!.string)'" : "nil") + ">")
    return result
  }

  /** initializeIVARs */
  private func initializeIVARs() {
    layer.doubleSided = false
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.mainScreen().scale

    label.adjustsFontSizeToFitWidth = true
    label.numberOfLines = 1
    label.lineBreakMode = .ByTruncatingTail

    label.attributedText = selected ? selectedText : text

    translatesAutoresizingMaskIntoConstraints = false
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(label)
  }

  /**
  requiresConstraintBasedLayout

  - returns: Bool
  */
  override class func requiresConstraintBasedLayout() -> Bool { return true }

  /** updateConstraints */
  override func updateConstraints() {
    removeAllConstraints()
    super.updateConstraints()
    constrain(𝗛|contentView|𝗛, 𝗩|contentView|𝗩, 𝗛|label|𝗛, 𝗩|label|𝗩)
  }
}

