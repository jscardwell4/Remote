//
//  DetailLabelCell.swift
//  Remote
//
//  Created by Jason Cardwell on 10/21/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankCollectionDetailLabelCell: BankCollectionDetailCell {

  override func initializeIVARs() {
    contentView.addSubview(nameLabel)
    contentView.addSubview(infoLabel)
    contentView.constrain(𝗛|-nameLabel--infoLabel-|𝗛, 𝗩|-nameLabel-|𝗩, 𝗩|-infoLabel-|𝗩)
  }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    nameLabel.text = nil
    infoLabel.text = nil
    infoLabel.attributedText = nil
  }

  override var info: AnyObject? {
    get { return infoDataType.objectFromText(infoLabel.text, attributedText: infoLabel.attributedText) }
    set {
      switch infoDataType.textualRepresentationForObject(newValue) {
        case let text as NSAttributedString: infoLabel.attributedText = text
        case let text as String:             infoLabel.text = text
        default:                             infoLabel.text = nil
      }
    }
  }

}
