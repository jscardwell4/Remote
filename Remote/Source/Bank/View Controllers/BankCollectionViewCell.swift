//
//  BankCollectionViewCell.swift
//  Remote
//
//  Created by Jason Cardwell on 9/10/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit

private let BankCollectionViewCellInternalConstraintNametag = "BankCollectionViewCellInternalConstraintNametag"

@objc(BankCollectionViewCell)
class BankCollectionViewCell: UICollectionViewCell {

  var item: BankableModelObject? {
    didSet {
      if item != nil {
        thumbnailImageView.userInteractionEnabled = item!.dynamicType.isPreviewable()
        detailButton.enabled = item!.dynamicType.isDetailable()
        thumbnailImageView.image = item!.thumbnail
        nameLabel.text = item!.name
        detailable = item!.dynamicType.isDetailable()
      } else {
        thumbnailImageView.userInteractionEnabled = false
        detailButton.enabled = false
        thumbnailImageView.image = nil
        nameLabel.text = nil
        detailable = false
      }
    }
  }

  private weak var thumbnailImageView: UIImageView!
  private weak var nameLabel: UILabel!
  private weak var detailButton: UIButton!
  private weak var indicator: UIImageView!
  private weak var previewGesture: UITapGestureRecognizer!
  private weak var indicatorConstraint: NSLayoutConstraint?

  private var detailable: Bool = false { didSet { detailButton.enabled = detailable } }
  private var previewable: Bool = false { didSet { previewGesture.enabled = previewable } }
  private var viewingMode: BankCollectionLayoutAttributes.ViewingMode = .None { didSet { setNeedsUpdateConstraints() } }

  var previewActionHandler: ((cell: BankCollectionViewCell) -> Void)?
  var detailActionHandler: ((cell: BankCollectionViewCell) -> Void)?
  var indicatorImage: UIImage? {
    didSet {
      indicator?.image = indicatorImage
      let constant: CGFloat = indicatorImage == nil ? 0.0 : 40.0
      if let constraint = indicatorConstraint { UIView.animateWithDuration(0.25) { constraint.constant = constant } }
    }
  }

  /**
  applyLayoutAttributes:

  :param: layoutAttributes UICollectionViewLayoutAttributes!
  */
  override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
    super.applyLayoutAttributes(layoutAttributes)
    if let attributes = layoutAttributes as? BankCollectionLayoutAttributes { viewingMode = attributes.viewingMode }
  }

  /**
  updateConstraints
  */
  override func updateConstraints() {

    super.updateConstraints()

    removeConstraints(constraintsWithNametag(BankCollectionViewCellInternalConstraintNametag))

    switch viewingMode {

      case .List:
        precondition(CGSizeEqualToSize(bounds.size, BankCollectionLayout.ListItemCellSize), "Why hasn't our size updated?")
        indicatorConstraint = {[unowned self] in
          let constraint = NSLayoutConstraint(item: self.indicator,
                                              attribute: .Right,
                                              relatedBy: .Equal,
                                                 toItem: self.contentView,
                                              attribute: .Left,
                                             multiplier: 1.0,
                                               constant: 0.0)
          constraint.nametag = BankCollectionViewCellInternalConstraintNametag
          self.addConstraint(constraint)
          return constraint
        }()

        let format = "\n".join(
          ["image.left = indicator.right + 20",
            "image.height = content.height",
            "[image]-8-[label]",
            "label.right = content.right - 64",
            "[detail]-20-|",
            "V:|-8-[label]-8-|",
            "indicator.centerY = label.centerY",
            "detail.centerY = label.centerY" ]
        )

        let views = [ "indicator": indicator,
                      "image"    : thumbnailImageView,
                      "label"    : nameLabel,
                      "detail"   : detailButton,
                      "content"  : contentView]

        constrainWithFormat(format, views: views, nametag: BankCollectionViewCellInternalConstraintNametag)
        indicator.hidden = false
        nameLabel.hidden = false
        detailButton.hidden = false

      case .Thumbnail:
        precondition(CGSizeEqualToSize(bounds.size, BankCollectionLayout.ThumbnailItemCellSize), "Why hasn't our size updated?")
        indicator.hidden = true
        detailButton.hidden = true
        nameLabel.hidden = true
        let format = "|[image]| :: V:|[image]|"
        let views = ["image": thumbnailImageView]
        constrainWithFormat(format, views:views, nametag: BankCollectionViewCellInternalConstraintNametag)

      default: break

    }

  }

  /**
  initWithFrame:

  :param: frame CGRect
  */
  override init(frame: CGRect) {
    super.init(frame: frame)

    indicator = { [unowned self] in
      let indicator = UIImageView.newForAutolayout()
      indicator.constrainWithFormat("self.height = self.width")
      self.contentView.addSubview(indicator)
      return indicator
      }()

    nameLabel = { [unowned self] in
      let nameLabel = UILabel.newForAutolayout()
      nameLabel.text = self.item?.name
      self.contentView.addSubview(nameLabel)
      return nameLabel
      }()

    detailButton = { [unowned self] in
      let detailButton = UIButton.newForAutolayout()
      detailButton.setImage(UIImage(named: "724-gray-info"), forState: .Normal)
      detailButton.setImage(UIImage(named: "724-gray-info-selected"), forState: .Highlighted)
      detailButton.setTranslatesAutoresizingMaskIntoConstraints(false)
      detailButton.addTarget(self, action:"detailAction", forControlEvents:.TouchUpInside)
      detailButton.constrainWithFormat("self.height = self.width")
      self.contentView.addSubview(detailButton)
      return detailButton
      }()

    thumbnailImageView = { [unowned self] in
      let thumbnailImageView = UIImageView.newForAutolayout()
      thumbnailImageView.constrainWithFormat("self.width ≤ self.height @999")
      self.previewGesture = { [unowned self, thumbnailImageView] in
        let previewGesture = UITapGestureRecognizer(target: self, action: "previewAction")
        thumbnailImageView.addGestureRecognizer(previewGesture)
        return previewGesture
        }()
      thumbnailImageView.image = self.item?.thumbnail
      self.contentView.addSubview(thumbnailImageView)
      return thumbnailImageView
      }()
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /**

  prepareForReuse

  */
  override func prepareForReuse() { super.prepareForReuse(); self.item = nil }

  /**

  thumbnailImageViewAction

  */
  func previewAction() { if let action = previewActionHandler { action(cell: self) } }

  /**

  detailButtonAction

  */
  func detailAction() { if let action = detailActionHandler { action(cell: self) } }

}
