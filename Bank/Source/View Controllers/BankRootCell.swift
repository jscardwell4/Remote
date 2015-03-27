//
//  BankRootCell.swift
//  Remote
//
//  Created by Jason Cardwell on 9/25/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//
import Foundation
import UIKit
import MoonKit

class BankRootCell: UITableViewCell {

  var rootCategory: Bank.RootCategory? {
    didSet {
      if let category = rootCategory {
        icon.image = category.icon
        label.text = category.label
      }
    }
  }

  private let icon: UIImageView = {
    let view = UIImageView.newForAutolayout()
    view.constrainAspect(1.0)
    view.contentMode = .ScaleAspectFit
    return view
  }()

  private let label: UILabel = {
    let view = UILabel.newForAutolayout()
    view.font = Bank.infoFont
    return view
  }()

  private let chevron: UIImageView! = {
    let view = UIImageView.newForAutolayout()
    view.constrainAspect(1.0)
    view.image = UIImage(named: "766-arrow-right")
    view.contentMode = .ScaleAspectFit
    return view
    }()

  /**
  updateConstraints
  */
  override func updateConstraints() {
    let identifier = "Internal"
    if constraintsWithIdentifier(identifier).count == 0 {
      let format = "|-20-[icon]-20-[label]-8-[chevron]-20-| :: V:|-8-[icon]-8-| :: V:|[label]| :: V:|-8-[chevron]-8-|"
      let views = ["icon": icon, "label": label, "chevron": chevron, "content": contentView]
      constrain(format, views: views, identifier: identifier)
    }
    super.updateConstraints()
  }

  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewCellStyle
  :param: reuseIdentifier String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setTranslatesAutoresizingMaskIntoConstraints(false)
    contentView.addSubview(icon)
    contentView.addSubview(label)
    contentView.addSubview(chevron)
    setNeedsUpdateConstraints()
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setTranslatesAutoresizingMaskIntoConstraints(false)
    contentView.addSubview(icon)
    contentView.addSubview(label)
    contentView.addSubview(chevron)
    setNeedsUpdateConstraints()
  }

}
