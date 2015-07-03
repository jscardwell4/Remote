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

  var font: UIFont { get { return label.font } set { label.font = newValue } }
  var text: String? { get { return label.text } set { label.text = newValue } }
  var textColor: UIColor { get { return label.textColor } set { label.textColor = newValue } }

  override var selected: Bool {
    didSet {
      label.enabled = selected
      backgroundColor = selected ? UIColor.redColor() : UIColor.clearColor()
    }
  }

  override init(frame: CGRect) { super.init(frame: frame); initializeIVARs() }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    label.text = aDecoder.decodeObjectForKey("InlinePickerViewCellText") as? String
    initializeIVARs()
  }

  private func initializeIVARs() {
    layer.doubleSided = false
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.mainScreen().scale

    label.enabled = false
    label.numberOfLines = 1
    label.lineBreakMode = .ByTruncatingTail

    translatesAutoresizingMaskIntoConstraints = false
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(label)
  }

  override class func requiresConstraintBasedLayout() -> Bool { return true }

  override func updateConstraints() {
    removeAllConstraints()
    super.updateConstraints()
    constrain(𝗛|contentView|𝗛, 𝗩|contentView|𝗩, 𝗛|label|𝗛, 𝗩|label|𝗩)
  }
}

