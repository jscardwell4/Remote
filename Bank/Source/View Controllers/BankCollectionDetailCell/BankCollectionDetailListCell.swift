//
//  BankCollectionDetailListCell.swift
//  Remote
//
//  Created by Jason Cardwell on 10/21/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankCollectionDetailListCell: BankCollectionDetailCell {

  override func initializeIVARs() {
    super.initializeIVARs()
    contentView.addSubview(infoLabel)
  }

  override func updateConstraints() {
    removeAllConstraints()
    super.updateConstraints()
    constrain(𝗛|-infoLabel-|𝗛, [infoLabel.centerY => centerY])
  }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
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
