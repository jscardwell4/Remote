//
//  BankCollectionDetailCustomCell.swift
//  Remote
//
//  Created by Jason Cardwell on 12/16/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankCollectionDetailCustomCell: BankCollectionDetailCell {

  private(set) var customView: UIView? { didSet { setNeedsUpdateConstraints() } }

  var generateCustomView: ((Void) -> UIView)? {
    didSet {
      if customView != nil { customView!.removeFromSuperview() }
      if let newCustomView = generateCustomView?() {
        newCustomView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(newCustomView)
        customView = newCustomView
      } else {
        customView = nil
      }
    }
  }

  /** updateConstraints */
  override func updateConstraints() {
    super.updateConstraints()
    guard let customView = customView else { return }
    let id = MoonKit.Identifier(self, "Internal")
    if constraintsWithIdentifier(id).count == 0 {
      constrain(𝗛|--(≥0)--customView--(≥0)--|𝗛 --> id, 𝗩|--(≥0)--customView--(≥0)--|𝗩 --> id)
    }
  }

  override func initializeIVARs() {
    super.initializeIVARs()
    contentView.opaque = false
    opaque = false
    backgroundColor = UIColor.clearColor()
    contentView.backgroundColor = UIColor.clearColor()
  }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    generateCustomView = nil
    backgroundColor = UIColor.clearColor()
    contentView.backgroundColor = UIColor.clearColor()
  }

}
