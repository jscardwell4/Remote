//
//  DetailColorCell.swift
//  Remote
//
//  Created by Jason Cardwell on 11/28/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailColorCell: DetailCell {

  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewCellStyle
  :param: reuseIdentifier String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    contentView.addSubview(nameLabel)

    colorSwatch.delegate = self
    contentView.addSubview(colorSwatch)

    let format = "|-[name]-[color]-| :: V:|-[color]-| :: V:|-[name]-|"
    contentView.constrain(format, views: ["name": nameLabel, "color": colorSwatch])
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    nameLabel.text = nil
    placeholderColor = nil
    colorSwatch.color = nil
  }

  override var info: AnyObject? {
    get { return colorSwatch.color }
    set { colorSwatch.color =  newValue as? UIColor ?? placeholderColor }
  }

  private let colorSwatch: ColorSwatch = ColorSwatch(autolayout: true)

  override var isEditingState: Bool {
    didSet {
      colorSwatch.userInteractionEnabled = isEditingState
       if colorSwatch.isFirstResponder() { colorSwatch.resignFirstResponder() }
    }
  }

  var placeholderColor: UIColor?

}

extension DetailColorCell: ColorSwatchDelegate {
  /**
  colorSwatchDidEndEditing:

  :param: colorSwatch ColorSwatch
  */
  func colorSwatchDidEndEditing(colorSwatch: ColorSwatch) {
    valueDidChange?(colorSwatch.color)
  }
}
