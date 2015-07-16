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
    super.updateConstraints()
    let id = MoonKit.Identifier(self, "InfoLabel")
    if constraintsWithIdentifier(id).count == 0 {
      constrain(𝗛|-infoLabel-|𝗛 --> id, [infoLabel.centerY => centerY] --> id)
    }
  }

//  /** prepareForReuse */
//  override func prepareForReuse() {
//    super.prepareForReuse()
//    infoLabel.text = nil
//    infoLabel.attributedText = nil
//  }

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
