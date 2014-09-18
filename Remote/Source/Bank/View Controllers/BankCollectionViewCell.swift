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
  var imageActionHandler: ((cell: BankCollectionViewCell) -> Void)?
  var detailActionHandler: ((cell: BankCollectionViewCell) -> Void)?

  /**

  willMoveToSuperview:

  :param: newSuperview UIView?

  */
  override func willMoveToSuperview(newSuperview: UIView?) {


    if newSuperview != nil {

      switch reuseIdentifier {

      case self.dynamicType.listIdentifier:
        let nameLabel = UILabel.newForAutolayout()
        contentView.addSubview(nameLabel)
        self.nameLabel = nameLabel

        let detailButton = UIButton.buttonWithType(.DetailDisclosure) as UIButton
        detailButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        detailButton.addTarget(self, action:"detailButtonAction", forControlEvents:.TouchUpInside)
        contentView.addSubview(detailButton)
        self.detailButton = detailButton

        let thumbnailImageView = UIImageView.newForAutolayout()
        contentView.addSubview(thumbnailImageView)
        self.thumbnailImageView = thumbnailImageView

        let constraintsFormat = "\n".join(["image.left = content.left + 20",
                                           "[image]-8-[label]-8-[detail]-20-|",
                                           "V:|-8-[label]-8-|",
                                           "image.centerY = label.centerY",
                                           "detail.centerY = label.centerY",
                                           "detail.width = detail.height",
                                           "detail.width = 22",
                                           "image.width = image.height",
                                           "image.width = 32"])

        let views = [ "image"  : thumbnailImageView,
                      "label"  : nameLabel,
                      "detail" : detailButton,
                      "content": contentView ]

        contentView.addConstraints(NSLayoutConstraint.constraintsByParsingString(constraintsFormat, views:views))

        if (item != nil) {
          self.thumbnailImageView?.userInteractionEnabled = item!.dynamicType.isPreviewable()
          self.thumbnailImageView?.image                  = item!.thumbnail
          self.detailButton?.enabled                      = item!.dynamicType.isDetailable()
          self.nameLabel?.text                            = item!.name
        }
        break

      case self.dynamicType.thumbnailIdentifier:
        contentView.backgroundColor = UIColor.yellowColor()
        let thumbnailImageView = UIImageView.newForAutolayout()
        thumbnailImageView.contentMode = .Center
        contentView.addSubview(thumbnailImageView)
        self.thumbnailImageView = thumbnailImageView

        let constraintsFormat = "\n".join(["|[image]|", "V:|[image]|"])
        let views = [ "image": thumbnailImageView]
        contentView.addConstraints(NSLayoutConstraint.constraintsByParsingString(constraintsFormat, views:views))

        if (item != nil) {
          self.thumbnailImageView?.userInteractionEnabled = item!.dynamicType.isPreviewable()
          self.thumbnailImageView?.image                  = item!.thumbnail
        }

        break

      default: break

      }

    }

  }

  override init(frame: CGRect) { super.init(frame: frame) }

  required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  /**

  prepareForReuse

  */
  override func prepareForReuse() {

    super.prepareForReuse();
    self.item = nil
  }

  /**

  thumbnailImageViewAction

  */
  func thumbnailImageViewAction() { if let action = imageActionHandler { action(cell: self) } }

  /**

  detailButtonAction

  */
  func detailButtonAction() { if let action = detailActionHandler { action(cell: self) } }

}
