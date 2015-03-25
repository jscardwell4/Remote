//
//  DetailListCell.swift
//  Remote
//
//  Created by Jason Cardwell on 10/21/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailListCell: DetailCell {

  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewCellStyle
  :param: reuseIdentifier String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(infoLabel)
    contentView.constrain("|-[label]-| :: V:|-[label]-|", views: ["label": infoLabel])
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    infoLabel.text = nil
    infoLabel.attributedText = nil
  }

  override var info: AnyObject? {
    get { return infoDataType.objectFromText(infoLabel.text, attributedText: infoLabel.attributedText) }
    set {
      switch infoDataType.textualRepresentationForObject(info) {
        case let text as NSAttributedString: infoLabel.attributedText = text
        case let text as String:             infoLabel.text = text
        default:                             infoLabel.text = nil
      }
    }
  }

}
