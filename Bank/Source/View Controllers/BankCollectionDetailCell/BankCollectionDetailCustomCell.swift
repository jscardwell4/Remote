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
    if customView != nil {
      contentView.constrain(𝗛|--(≥0)--customView!--(≥0)--|𝗛, 𝗩|--(≥0)--customView!--(≥0)--|𝗩)
      contentView.centerSubview(customView!)
    }
  }

  override func initializeIVARs() {
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
