//
//  BankItemImageCell.swift
//  Remote
//
//  Created by Jason Cardwell on 10/21/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankItemImageCell: BankItemCell {

  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewCellStyle
  :param: reuseIdentifier String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(imageℹ)
    backgroundView = nil
    backgroundColor = UIColor.clearColor()
    contentView.backgroundColor = UIColor.clearColor()
    contentView.constrainWithFormat("|-[image]-| :: V:|-[image]-|", views: ["image": imageℹ])
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    imageℹ.image = nil
    imageℹ.contentMode = .ScaleAspectFit
  }

  override var info: AnyObject? {
    get { return imageℹ.image }
    set {
      imageℹ.image = newValue as? UIImage
      if let imageSize = (newValue as? UIImage)?.size {
        imageℹ.contentMode = CGSizeContainsSize(bounds.size, imageSize) ? .Center : .ScaleAspectFit
      }
    }
  }

  private let imageℹ: UIImageView = {
    let view = UIImageView()
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.userInteractionEnabled = false
    view.contentMode = .ScaleAspectFit
    view.tintColor = UIColor.blackColor()
    view.backgroundColor = UIColor.clearColor()
    return view

  }()


}
