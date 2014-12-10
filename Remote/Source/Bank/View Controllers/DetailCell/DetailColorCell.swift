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

class DetailColorCell: DetailCell, UITextFieldDelegate {

  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewCellStyle
  :param: reuseIdentifier String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(nameLabel)
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
    placeholderColor = UIColor.clearColor()
    colorSwatch.color = placeholderColor
  }

  override var info: AnyObject? {
    get { return colorSwatch.color }
    set { if let color = newValue as? UIColor { colorSwatch.color = color } else { colorSwatch.color = placeholderColor } }
  }

  private let colorSwatch: ColorSwatch = ColorSwatch(autolayout: true)

  override var isEditingState: Bool {
    didSet {
      colorSwatch.userInteractionEnabled = isEditingState
       if colorSwatch.isFirstResponder() { colorSwatch.resignFirstResponder() }
    }
  }

  var placeholderColor: UIColor = UIColor.clearColor()

}
