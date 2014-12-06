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

class DetailLabelCell: DetailCell {

  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewCellStyle
  :param: reuseIdentifier String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(nameLabel)
    contentView.addSubview(infoLabel)
    contentView.constrain("|-[n]-[l]-| :: V:|-[n]-| :: V:|-[l]-|", views: ["n": nameLabel, "l": infoLabel])
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
