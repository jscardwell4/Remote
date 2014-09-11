//
//  BankCollectionViewListCell.swift
//  Remote
//
//  Created by Jason Cardwell on 9/10/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit


class BankCollectionViewListCell: UICollectionViewCell {

  class var identifier: String  { return "BankCollectionListCellIdentifier" }

  var item: BankableModelObject? {
    didSet {
      if item != nil {
        self.thumbnailImageView.userInteractionEnabled = item!.dynamicType.isPreviewable()
        self.detailButton.enabled = item!.dynamicType.isDetailable()
        self.thumbnailImageView.image = item!.thumbnail
        self.nameLabel.text = item!.name
      } else {
        self.thumbnailImageView.userInteractionEnabled = false
        self.detailButton.enabled = false
        self.thumbnailImageView.image = nil
        self.nameLabel.text = nil
      }
    }
  }

  private var thumbnailImageView: UIImageView
  private var nameLabel: UILabel
  private var detailButton: UIButton
  private var deleteButton: UIButton
  private var leadingConstraint: NSLayoutConstraint!
  var controller: BankCollectionViewController? = nil

  override init(frame: CGRect) {

    thumbnailImageView = UIImageView.newForAutolayout()
    nameLabel = UILabel.newForAutolayout()
    detailButton = UIButton.buttonWithType(.DetailDisclosure) as UIButton
    deleteButton = UIButton.buttonWithType(.System) as UIButton
    super.init(frame: frame)

    self.addSubview(thumbnailImageView)
    self.addSubview(nameLabel)
    self.addSubview(detailButton)
    self.addSubview(deleteButton)
    detailButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    detailButton.addTarget(self, action:"detailButtonAction", forControlEvents:.TouchUpInside)
    deleteButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    deleteButton.addTarget(self, action:"deleteButtonAction", forControlEvents:.TouchUpInside)

    let constraintsFormat = "\n".join(["'leading' image.left = self.left + 8",
                                       "[image]-8-[label]-8-[detail]-8-|",
                                       "delete.left = self.right",
                                       "V:|-8-[label]-8-|",
                                       "image.centerY = label.centerY",
                                       "detail.centerY = label.centerY",
                                       "delete.centerY = label.centerY",
                                       "delete.width = 67",
                                       "detail.width = detail.height",
                                       "detail.width = 22",
                                       "image.width = image.height",
                                       "image.width = 32"])

    let views = ["image": thumbnailImageView,
                 "label": nameLabel,
                 "detail": detailButton,
                 "delete": deleteButton,
                 "self": self]

    let constraints = NSLayoutConstraint.constraintsByParsingString(constraintsFormat, views:views)

    for constraint in constraints as [NSLayoutConstraint] {

      if constraint.nametag == "leading" { leadingConstraint = constraint; break }

    }

    self.addConstraints(constraints)

  }

  required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }


  override func prepareForReuse() { super.prepareForReuse(); self.item = nil }

  func thumbnailImageViewAction() { self.controller?.detailItem(self.item) }

  func deleteButtonAction() { self.controller?.deleteItem(self.item) }

  func detailButtonAction() { self.controller?.detailItem(self.item) }


  func swipeToDeleteAnimation(gesture: UISwipeGestureRecognizer) {

    let defaultConstant: CGFloat = 8, shiftedConstant: CGFloat = -58

    if let indexPath: NSIndexPath = self.controller?.collectionView?.indexPathForCell(self) {

      if let collectionView: UICollectionView = self.controller?.collectionView {

        if let collectionViewDelegate = collectionView.delegate {

          let canDelete =  collectionViewDelegate.collectionView!(collectionView,
                                                 canPerformAction: "deleteItemForCell:",
                                               forItemAtIndexPath: indexPath,
                                                       withSender: self)
          if canDelete {

            self.leadingConstraint.constant = (  self.leadingConstraint.constant == defaultConstant
                                               ? shiftedConstant
                                               : defaultConstant)

            UIView.animateWithDuration(0.5) { [unowned self] in self.layoutIfNeeded() }

          }

        }

      }

    }

  }

}
