//
//  BankCollectionDetailColorCell.swift
//  Remote
//
//  Created by Jason Cardwell on 11/28/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankCollectionDetailColorCell: BankCollectionDetailCell {

  override func initializeIVARs() {
    super.initializeIVARs()
    contentView.addSubview(nameLabel)
    colorSwatch.delegate = self
    contentView.addSubview(colorSwatch)
  }

  override func updateConstraints() {
    removeAllConstraints()
    super.updateConstraints()
    constrain(𝗛|-nameLabel--colorSwatch-|𝗛, [nameLabel.centerY => centerY, colorSwatch.centerY => centerY])
  }

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

  override var editing: Bool {
    didSet {
      colorSwatch.userInteractionEnabled = editing
       if colorSwatch.isFirstResponder() { colorSwatch.resignFirstResponder() }
    }
  }

  var placeholderColor: UIColor?

}

extension BankCollectionDetailColorCell: ColorSwatchDelegate {
  /**
  colorSwatchDidEndEditing:

  - parameter colorSwatch: ColorSwatch
  */
  func colorSwatchDidEndEditing(colorSwatch: ColorSwatch) {
    valueDidChange?(colorSwatch.color)
  }
}
