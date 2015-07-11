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

final class BankRootCell: UITableViewCell {

  var iconImage: UIImage? {
    get { return icon.image }
    set { icon.image = newValue }
  }

  var labelText: String? {
    get { return label.text }
    set { label.text = newValue }
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
      constrain(identifier: identifier,
        icon.left => contentView.left + 20,
        label.left => icon.right + 20,
        chevron.left => label.right + 8,
        chevron.right => contentView.right - 20,
        icon.top => contentView.top + 8,
        icon.bottom => contentView.bottom - 8,
        label.top => contentView.top,
        label.bottom => contentView.bottom,
        chevron.top => contentView.top + 8,
        chevron.bottom => contentView.bottom - 8,
        contentView.left => self.left,
        contentView.right => self.right,
        contentView.top => self.top,
        contentView.bottom => self.bottom
      )
    }
    super.updateConstraints()
  }

  /**
  initWithStyle:reuseIdentifier:

  - parameter style: UITableViewCellStyle
  - parameter reuseIdentifier: String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(icon)
    contentView.addSubview(label)
    contentView.addSubview(chevron)
    setNeedsUpdateConstraints()
  }

  /**
  init:

  - parameter aDecoder: NSCoder
  */
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(icon)
    contentView.addSubview(label)
    contentView.addSubview(chevron)
    setNeedsUpdateConstraints()
  }

}
