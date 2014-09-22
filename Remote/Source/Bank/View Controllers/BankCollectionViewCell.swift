//
//  BankCollectionViewCell.swift
//  Remote
//
//  Created by Jason Cardwell on 9/10/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit

class BankCollectionViewCell: UICollectionViewCell {

  class var listIdentifier: String  { return "BankCollectionListCellIdentifier" }
  class var thumbnailIdentifier: String  { return "BankCollectionThumbnailCellIdentifier" }

  var item: BankableModelObject? {
    didSet {
      if item != nil {
        self.thumbnailImageView?.userInteractionEnabled = item!.dynamicType.isPreviewable()
        self.detailButton?.enabled = item!.dynamicType.isDetailable()
        self.thumbnailImageView?.image = item!.thumbnail
        self.nameLabel?.text = item!.name
      } else {
        self.thumbnailImageView?.userInteractionEnabled = false
        self.detailButton?.enabled = false
        self.thumbnailImageView?.image = nil
        self.nameLabel?.text = nil
      }
    }
  }

  private weak var thumbnailImageView: UIImageView?
  private weak var nameLabel: UILabel?
  private weak var detailButton: UIButton?
  private weak var indicator: UIImageView?

  var imageActionHandler: ((cell: BankCollectionViewCell) -> Void)?
  var detailActionHandler: ((cell: BankCollectionViewCell) -> Void)?
  var indicatorImage: UIImage? {
    didSet {
      var constant: CGFloat = 0.0
      if let image = indicatorImage {
        indicator?.image = image
        constant = 60.0
      } else {
        indicator?.image = nil
      }
      let constraint = contentView.constraintWithNametag("indicator")
      precondition(constraint != nil, "we should have been able to retrieve a constraint with nametag 'indicator'")
      UIView.animateWithDuration(0.25) { constraint!.constant = constant }
    }
  }

  private func configureCellForListViewWithoutThumbnails() {

    precondition(item != nil, "we cannot configure the cell properly if we don't have an item")

    let indicator = UIImageView.newForAutolayout()
    indicator.addConstraints(
      NSLayoutConstraint.constraintsByParsingString("indicator.width = 22\nindicator.height = indicator.width",
                                              views: ["indicator": indicator]))
    contentView.addSubview(indicator)
    self.indicator = indicator

    let nameLabel = UILabel.newForAutolayout()
    nameLabel.text = item?.name
    contentView.addSubview(nameLabel)
    self.nameLabel = nameLabel

    let detailButton = UIButton.buttonWithType(.DetailDisclosure) as UIButton
    detailButton.enabled = item!.dynamicType.isDetailable()
    detailButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    detailButton.addTarget(self, action:"detailButtonAction", forControlEvents:.TouchUpInside)
    detailButton.addConstraints(
      NSLayoutConstraint.constraintsByParsingString("detail.width = 22\ndetail.height = detail.width",
                                              views: ["detail": detailButton]))
    contentView.addSubview(detailButton)
    self.detailButton = detailButton

    let constraintsFormat = "\n".join(
      [ "'indicator' indicator.right = content.left",
        "[indicator]-20-[label]-8-[detail]-20-|",
        "V:|-8-[label]-8-|",
        "indicator.centerY = label.centerY",
        "detail.centerY = label.centerY" ]
    )

    let views = [ "indicator": indicator,
                  "label"    : nameLabel,
                  "detail"   : detailButton,
                  "content"  : contentView ]

    contentView.addConstraints(NSLayoutConstraint.constraintsByParsingString(constraintsFormat, views:views))

  }

  private func configureCellForListViewWithThumbnails() {

    precondition(item != nil, "we cannot configure the cell properly if we don't have an item")

    let indicator = UIImageView.newForAutolayout()
    indicator.addConstraints(
      NSLayoutConstraint.constraintsByParsingString("indicator.width = 22\nindicator.height = indicator.width",
                                              views: ["indicator": indicator]))
    contentView.addSubview(indicator)
    self.indicator = indicator

    let nameLabel = UILabel.newForAutolayout()
    nameLabel.text = item!.name
    contentView.addSubview(nameLabel)
    self.nameLabel = nameLabel

    let detailButton = UIButton.buttonWithType(.DetailDisclosure) as UIButton
    detailButton.enabled = item!.dynamicType.isDetailable()
    detailButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    detailButton.addTarget(self, action:"detailButtonAction", forControlEvents:.TouchUpInside)
    detailButton.addConstraints(
      NSLayoutConstraint.constraintsByParsingString("detail.width = 22\ndetail.height = detail.width",
                                              views: ["detail": detailButton]))
    contentView.addSubview(detailButton)
    self.detailButton = detailButton

    let thumbnailImageView = UIImageView.newForAutolayout()
    thumbnailImageView.userInteractionEnabled = item!.dynamicType.isPreviewable()
    thumbnailImageView.image = item!.thumbnail
    thumbnailImageView.addConstraints(
      NSLayoutConstraint.constraintsByParsingString("image.width = 32\nimage.height = image.width",
                                              views: ["image": thumbnailImageView]))
    contentView.addSubview(thumbnailImageView)
    self.thumbnailImageView = thumbnailImageView

    let constraintsFormat = "\n".join(
      [ "'indicator' indicator.right = content.left",
        "image.left = indicator.right + 20",
        "[image]-8-[label]-8-[detail]-20-|",
        "V:|-8-[label]-8-|",
        "indicator.centerY = label.centerY",
        "image.centerY = label.centerY",
        "detail.centerY = label.centerY" ]
    )

    let views = [ "indicator": indicator,
                  "image"    : thumbnailImageView,
                  "label"    : nameLabel,
                  "detail"   : detailButton,
                  "content"  : contentView ]

    contentView.addConstraints(NSLayoutConstraint.constraintsByParsingString(constraintsFormat, views:views))

  }


  private func configureCellForThumbnailView() {

    precondition(item != nil, "we cannot configure the cell properly if we don't have an item")

    let thumbnailImageView = UIImageView.newForAutolayout()
    thumbnailImageView.userInteractionEnabled = item!.dynamicType.isPreviewable()
    thumbnailImageView.image = item!.thumbnail
    thumbnailImageView.contentMode = .Center
    contentView.addSubview(thumbnailImageView)
    self.thumbnailImageView = thumbnailImageView

    let constraintsFormat = "\n".join(["|[image]|", "V:|[image]|"])
    let views = [ "image": thumbnailImageView]
    contentView.addConstraints(NSLayoutConstraint.constraintsByParsingString(constraintsFormat, views:views))

  }

  /**

  willMoveToSuperview:

  :param: newSuperview UIView?

  */
  override func willMoveToSuperview(newSuperview: UIView?) {


    if newSuperview != nil {

      precondition(item != nil, "we cannot configure the cell properly if we don't have an item")

      switch reuseIdentifier {

        case BankCollectionViewCell.listIdentifier:
          if item!.dynamicType.isThumbnailable() { configureCellForListViewWithThumbnails()    }
          else                                   { configureCellForListViewWithoutThumbnails() }


        case BankCollectionViewCell.thumbnailIdentifier:
          // TODO: Add indicator to thumbnail view
          configureCellForThumbnailView()

        default: break

      }

    }

  }

  /**
  initWithFrame:

  :param: frame CGRect
  */
  override init(frame: CGRect) { super.init(frame: frame) }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  /**

  prepareForReuse

  */
  override func prepareForReuse() { super.prepareForReuse(); self.item = nil }

  /**

  thumbnailImageViewAction

  */
  func thumbnailImageViewAction() { if let action = imageActionHandler { action(cell: self) } }

  /**

  detailButtonAction

  */
  func detailButtonAction() { if let action = detailActionHandler { action(cell: self) } }

}
