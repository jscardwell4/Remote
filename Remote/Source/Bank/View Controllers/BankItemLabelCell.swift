//
//  BankItemLabelCell.swift
//  Remote
//
//  Created by Jason Cardwell on 10/21/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankItemLabelCell: BankItemCell {

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
    contentView.constrainWithFormat(format, views: ["name": nameLabel, "label": infoLabel])
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
  }

  override var info: AnyObject? {
    get { return infoLabel.text }
    set { infoLabel.text = textFromObject(newValue) }
  }

}
