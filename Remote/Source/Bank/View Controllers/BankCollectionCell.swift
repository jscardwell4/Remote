//
//  BankCollectionCellCollectionViewCell.swift
//  Remote
//
//  Created by Jason Cardwell on 10/7/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankCollectionCell: UICollectionViewCell {

  override class func load() {
    registerLogLevel(LOG_LEVEL_ERROR)
  }

  let indicator: UIImageView = {
    let view = UIImageView.newForAutolayout()
    view.nametag = "indicator"
    view.constrainWithFormat("self.width ≤ self.height :: self.height = 22")
    return view
  }()

  private var contentSize = CGSizeZero

  var indicatorConstraint: NSLayoutConstraint?

  var indicatorImage: UIImage? {
    didSet {
      indicator.image = indicatorImage
      indicator.hidden = indicatorImage == nil
      animateIndicator?()
    }
  }

  var animateIndicator: ((Void) -> Void)?

  /**
  applyLayoutAttributes:

  :param: layoutAttributes UICollectionViewLayoutAttributes!
  */
  override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
    super.applyLayoutAttributes(layoutAttributes)
    contentSize = layoutAttributes.frame.size
  }

  /** updateConstraints */
  override func updateConstraints() {

    MSLogDebug("before…\n\(prettyConstraintsDescription())\n\(contentView.prettyConstraintsDescription())")

  	let identifier          = createIdentifier(self, "Internal")
    let indicatorIdentifier = createIdentifier(self, ["Internal", "Indicator"])
    let contentIdentifier   = createIdentifier(self, ["Internal", "Content"])


    // Refresh content constraints
    contentView.removeConstraintsWithIdentifier(contentIdentifier)
    contentView.constrainToSize(contentSize, identifier: contentIdentifier)

    // Refresh our constraints
    removeConstraintsWithIdentifier(identifier)
    constrainWithFormat("content.center = self.center", views: ["content": contentView], identifier: identifier)

    // Create and add indicator constraint if needed
/*
    if indicatorConstraint == nil {

      let constraint = NSLayoutConstraint(item: indicator,
                                          attribute: .Right,
                                          relatedBy: .Equal,
                                             toItem: contentView,
                                          attribute: .Left,
                                         multiplier: 1.0,
                                           constant: indicatorImage == nil ? 0.0 : 40.0)
      constraint.identifier = indicatorIdentifier
      indicatorConstraint = constraint
      addConstraint(constraint)

    }
*/

    MSLogDebug("after…\n\(prettyConstraintsDescription())\n\(contentView.prettyConstraintsDescription())")

    super.updateConstraints()

	}

  /**
  requiresConstraintBasedLayout

  :returns: Bool
  */
  override class func requiresConstraintBasedLayout() -> Bool { return true }

  /**
  initWithFrame:

  :param: frame CGRect
  */
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
    contentView.addSubview(indicator)
    contentView.nametag = "content"
    setNeedsUpdateConstraints()
    animateIndicator = {
      UIView.animateWithDuration(5.0, animations: { () -> Void in
        _ = self.indicatorConstraint?.constant = self.indicatorImage == nil ? 0.0 : 40.0
      })
    }
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
    contentView.addSubview(indicator)
    contentView.nametag = "content"
    setNeedsUpdateConstraints()
    animateIndicator = {
      UIView.animateWithDuration(5.0, animations: { () -> Void in
        _ = self.indicatorConstraint?.constant = self.indicatorImage == nil ? 0.0 : 40.0
      })
    }
  }

}
