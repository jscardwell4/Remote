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

  private enum LabelStyle {
    case Default, List

    /**
    initWithIdentifier:

    :param: identifier Identifier
    */
    init(identifier: Identifier) {
      switch identifier {
        case .List:  self = .List
        default: self = .Default
      }
    }

   }

  private var labelStyle: LabelStyle = .Default

  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewCellStyle
  :param: reuseIdentifier String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    labelStyle = LabelStyle(identifier: Identifier(rawValue: reuseIdentifier ?? "") ?? .Label)
    switch labelStyle {
      case .Default:
        contentView.addSubview(nameLabel)
        contentView.addSubview(infoLabel)
        contentView.constrain("|-[n]-[l]-| :: V:|-[n]-| :: V:|-[l]-|", views: ["n": nameLabel, "l": infoLabel])
      case .List:
        contentView.addSubview(infoLabel)
        contentView.constrain("|-[label]-| :: V:|-[label]-|", views: ["label": infoLabel])
    }

  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    switch labelStyle {
      case .Default:
        nameLabel.text = nil
        fallthrough
      case .List:
        infoLabel.text = nil
        infoLabel.attributedText = nil
    }
  }

  override var info: AnyObject? {
    get { return infoDataType.objectFromText(infoLabel.text, attributedText: infoLabel.attributedText) }
    set {
      switch infoDataType.textualRepresentationForObject(newValue) {
        case let text as NSAttributedString:
          infoLabel.attributedText = text
        case let text as String:
          infoLabel.text = text
        default:
          infoLabel.text = nil
      }
    }
  }

}
