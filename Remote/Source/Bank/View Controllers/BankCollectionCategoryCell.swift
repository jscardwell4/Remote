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

class BankCollectionCategoryCell: BankCollectionCell {

  // var labelText: String? { get { return label.text } set { label.text = newValue } }

  private let label: UILabel! = {
    let view = UILabel.newForAutolayout()
    view.font = Bank.infoFont
    return view
  }()

  var category: BankDisplayItemCategory? {
    didSet {
      label.text = category?.title
    }
  }

  private let chevron: UIImageView! = {
    let view = UIImageView.newForAutolayout()
    view.constrainWithFormat("self.width = self.height :: self.height = 22")
    view.image = UIImage(named: "766-arrow-right")
    view.contentMode = .ScaleAspectFit
    return view
    }()

  /** updateConstraints */
  override func updateConstraints() {

    let identifier = createIdentifier(self, "Internal")
    removeConstraintsWithIdentifier(identifier)

    super.updateConstraints()

    let format = "\n".join([
      "[indicator]-20-[label]-8-[chevron]-20-|",
      "label.centerY = content.centerY",
      "chevron.centerY = content.centerY",
      "indicator.centerY = content.centerY",
      "indicator.right = content.left + \(indicatorImage == nil ? 0.0 : 40.0)"
      ])
    let views = ["label": label, "indicator": indicator, "chevron": chevron, "content": contentView]
    constrainWithFormat(format, views: views, identifier: identifier)

    let predicate = NSPredicate(format: "firstItem == %@" +
      "AND secondItem == %@ " +
      "AND firstAttribute == \(NSLayoutAttribute.Right.rawValue)" +
      "AND secondAttribute == \(NSLayoutAttribute.Left.rawValue)" +
      "AND relation == \(NSLayoutRelation.Equal.rawValue)", indicator, contentView)
    indicatorConstraint = constraintMatching(predicate)


  }

  /**
  initWithFrame:

  :param: frame CGRect
  */
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(label)
    contentView.addSubview(chevron)
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    contentView.addSubview(label)
    contentView.addSubview(chevron)
  }

}
