//
//  DetailCustomCell.swift
//  Remote
//
//  Created by Jason Cardwell on 12/16/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailCustomCell: DetailCell {

  private(set) var customView: UIView? { didSet { setNeedsUpdateConstraints() } }

  var generateCustomView: ((Void) -> UIView)? {
    didSet {
      if customView != nil { customView!.removeFromSuperview() }
      if let newCustomView = generateCustomView?() {
        newCustomView.setTranslatesAutoresizingMaskIntoConstraints(false)
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
      contentView.constrain("|-(>=0)-[custom]-(>=0)-| :: V:|-(>=0)-[custom]-(>=0)-|", views: ["custom": customView!])
      contentView.centerSubview(customView!)
    }
  }

  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewCellStyle
  :param: reuseIdentifier String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.opaque = false
    opaque = false
    backgroundColor = UIColor.clearColor()
    contentView.backgroundColor = UIColor.clearColor()
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    generateCustomView = nil
    backgroundColor = UIColor.clearColor()
    contentView.backgroundColor = UIColor.clearColor()
  }

}
