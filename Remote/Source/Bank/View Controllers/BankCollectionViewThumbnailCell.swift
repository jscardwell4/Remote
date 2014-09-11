//
//  BankCollectionViewThumbnailCell.swift
//  Remote
//
//  Created by Jason Cardwell on 9/10/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit


class BankCollectionViewThumbnailCell: UICollectionViewCell {

  class var identifier: String  { return "BankCollectionThumbnailCellIdentifier" }

  var item: BankableModelObject? {
    didSet {
      if item != nil {
        self.thumbnailImageView.userInteractionEnabled = item!.dynamicType.isPreviewable()
      } else {
        self.thumbnailImageView.userInteractionEnabled = false
        self.thumbnailImageView.image = nil
      }
    }
  }

  private var thumbnailImageView: UIImageView
  var controller: BankCollectionViewController? = nil

  override init(frame: CGRect) {

    thumbnailImageView = UIImageView.newForAutolayout()
    super.init(frame: frame)

    self.addSubview(thumbnailImageView)
    let constraintsFormat = "\n".join(["|[image]|", "V:|[image]|"])

    let views = ["image": thumbnailImageView, "self": self]

    let constraints = NSLayoutConstraint.constraintsByParsingString(constraintsFormat, views:views)

    self.addConstraints(constraints)

  }

  required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }


  override func prepareForReuse() { super.prepareForReuse(); self.item = nil }

  func thumbnailImageViewAction() { self.controller?.detailItem(self.item) }

}
