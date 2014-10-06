//
//  BankCollectionCategoryCell.swift
//  Remote
//
//  Created by Jason Cardwell on 9/27/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//
import Foundation
import UIKit
import MoonKit

class BankCollectionCategoryCell: UICollectionViewCell {

  var labelText: String? { get { return label.text } set { label.text = newValue } }

  private let label: UILabel! = {
    let view = UILabel.newForAutolayout()
    view.font = Bank.infoFont
    return view
  }()

  private let chevron: UIImageView! = {
    let view = UIImageView.newForAutolayout()
    view.constrainWithFormat("self.width = self.height :: self.height = 22")
    view.image = UIImage(named: "766-arrow-right")
    view.contentMode = .ScaleAspectFit
    return view
    }()

  private let indicator: UIImageView = {
    let view = UIImageView.newForAutolayout()
    view.constrainWithFormat("self.width = self.height :: self.height = 22")
    return view
    }()

  private var indicatorConstraint: NSLayoutConstraint?
  var indicatorImage: UIImage? {
    didSet {
      indicator.image = indicatorImage
      indicator.hidden = indicatorImage == nil
      if let c = indicatorConstraint {
        UIView.animateWithDuration(1.0) { c.constant = self.indicatorImage == nil ? 0.0 : 40.0 }
      }
    }
  }

  /**
  updateConstraints
  */
  override func updateConstraints() {
    let identifier = "Internal"
    let indicatorIdentifier = "Indicator"
    if constraintsWithIdentifier(identifier).count == 0 {
      indicatorConstraint = {[unowned self] in
        let constraint = NSLayoutConstraint(item: self.indicator,
          attribute: .Right,
          relatedBy: .Equal,
          toItem: self.contentView,
          attribute: .Left,
          multiplier: 1.0,
          constant: self.indicatorImage == nil ? 0.0 : 40.0)
        constraint.identifier = "-".join([identifier, indicatorIdentifier])
        self.contentView.addConstraint(constraint)
        return constraint
        }()

      let size = BankCollectionLayout.listItemCellSize
      let format = "\n".join([
        "|-20-[label]-8-[chevron]-20-|",
        "label.centerY = content.centerY",
        "chevron.centerY = content.centerY",
        "content.width = \(size.width)",
        "content.height = \(size.height)"
        ])
      let views = ["label": label, "chevron": chevron, "content": contentView]
      constrainWithFormat(format, views: views, identifier: identifier)
    }
    super.updateConstraints()
  }

  /**
  initWithFrame:

  :param: frame CGRect
  */
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
    contentView.addSubview(indicator)
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
    contentView.addSubview(label)
    contentView.addSubview(chevron)
    contentView.addSubview(indicator)
    setNeedsUpdateConstraints()
  }

  /**
  requiresConstraintBasedLayout

  :returns: Bool
  */
  override class func requiresConstraintBasedLayout() -> Bool { return true }

}
