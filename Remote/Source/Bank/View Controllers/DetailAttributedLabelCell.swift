//
//  DetailAttributedLabelCell.swift
//  Remote
//
//  Created by Jason Cardwell on 11/28/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//


import Foundation
import UIKit
import MoonKit

class DetailAttributedLabelCell: DetailCell {

  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewCellStyle
  :param: reuseIdentifier String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(nameLabel)
    contentView.addSubview(infoLabel)
    let format = "|-[name]-[label]-| :: V:|-[name]-| :: V:|-[label]-|"
    contentView.constrain(format, views: ["name": nameLabel, "label": infoLabel])
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
    infoLabel.attributedText = nil
  }

  override var info: AnyObject? {
    get { return infoLabel.attributedText }
    set {
      if let attributedText = newValue as? NSAttributedString { infoLabel.attributedText = attributedText}
      else { infoLabel.attributedText = nil }
    }
  }

}
