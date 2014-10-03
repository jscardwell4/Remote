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

@objc(BankRootCell)
class BankRootCell: UITableViewCell {

  var bankableModelClassName: String? {
    didSet {
      if let name = bankableModelClassName {
        if let modelClass = NSClassFromString(name) as? BankableModelObject.Type {
          bankableModelClass = modelClass
        }
      }
    }
  }

  var bankableModelClass: BankDisplayItem.Protocol? {
    didSet {
//      if let model = bankableModelClass {
//        if let image = model.icon?() {
//          icon.image = image
//        } else { icon.image = nil }
//        if let text = model.label?() {
//          label.text = text
//        } else { label.text = nil }
//      } else {
//        icon.image = nil
//        label.text = nil
//      }
    }
  }

  private let icon: UIImageView = {
    let view = UIImageView.newForAutolayout()
    view.constrainWithFormat("self.width = self.height")
    view.contentMode = .ScaleAspectFit
    return view
  }()

  private let label: UILabel = {
    let view = UILabel.newForAutolayout()
    view.font = Bank.infoFont
    return view
  }()

  private let chevron: UIImageView = {
    let view = UIImageView.newForAutolayout()
    view.constrainWithFormat("self.width = self.height")
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
      constrainWithFormat(format, views: views, identifier: identifier)
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
