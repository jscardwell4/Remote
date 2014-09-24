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

    let identifierPrefix    = "Internal"
    let listIdentifier      = "List"
    let thumbnailIdentifier = "Thumbnail"
    let indicatorIdentifier = "Indicator"

    switch viewingMode {

      case .List:
        precondition(CGSizeEqualToSize(bounds.size, BankCollectionLayout.ListItemCellSize), "Why hasn't our size updated?")

        // Deactivate any thumbnail viewing mode constraints we find
        let thumbnailConstraints = contentView.constraintsWithIdentifierSuffix(thumbnailIdentifier)
        for thumbnailConstraint in thumbnailConstraints as [NSLayoutConstraint] { thumbnailConstraint.active = false }

        // Look for existing list viewing mode constraints
        let listConstraints = contentView.constraintsWithIdentifierSuffix(listIdentifier)

        // Just active them if they exist
        if listConstraints.count > 0 {
          for listConstraint in listConstraints as [NSLayoutConstraint] { listConstraint.active = true }
        }

        // Otherwise we need to create them
        else {

          indicatorConstraint = {[unowned self] in
            let constraint = NSLayoutConstraint(item: self.indicator,
                                                attribute: .Right,
                                                relatedBy: .Equal,
                                                   toItem: self.contentView,
                                                attribute: .Left,
                                               multiplier: 1.0,
                                                 constant: 0.0)
            constraint.identifier = "-".join([identifierPrefix, indicatorIdentifier, listIdentifier])
            self.contentView.addConstraint(constraint)
            return constraint
          }()

          let contentSize = BankCollectionLayout.ListItemCellSize
          let format = "\n".join(
            [ "image.height = content.height",
              "image.width = image.height",
              "[indicator]-20-[image]-8-[label]-8-[detail(44)]-20-|",
              "V:|-8-[label]-8-|",
              "indicator.centerY = label.centerY",
              "detail.centerY = label.centerY",
              "content.width = \(contentSize.width)",
              "content.height = \(contentSize.height)"]
          )

          let views = [ "indicator": indicator,
                        "image"    : thumbnailImageView,
                        "label"    : nameLabel,
                        "detail"   : detailButton,
                        "content"  : contentView]

          contentView.constrainWithFormat(format, views: views, identifier: "-".join([identifierPrefix, listIdentifier]))

        }

        // Finally we must make sure our views are not hidden
        indicator.hidden    = false
        nameLabel.hidden    = false
        detailButton.hidden = false


      case .Thumbnail:
        precondition(CGSizeEqualToSize(bounds.size, BankCollectionLayout.ThumbnailItemCellSize), "Why hasn't our size updated?")

        // Deactivate any list viewing mode constraints we find
        let listConstraints = contentView.constraintsWithIdentifierSuffix(listIdentifier)
        for listConstraint in listConstraints as [NSLayoutConstraint] { listConstraint.active = false }

        // Look for existing thumbnail viewing mode constraints
        let thumbnailConstraints = contentView.constraintsWithIdentifierSuffix(thumbnailIdentifier)

        // Just activate them if they exist
        if thumbnailConstraints.count > 0 {
          for thumbnailConstraint in thumbnailConstraints as [NSLayoutConstraint] { thumbnailConstraint.active = true }
        }

        // Otherwise we must create them
        else {

          let contentSize = BankCollectionLayout.ThumbnailItemCellSize
          let format = "\n".join(["|[image]|",
                                  "image.height = image.width",
                                  "content.width = \(contentSize.width)",
                                  "content.height = \(contentSize.height)"])
          let views = ["image": thumbnailImageView, "content": contentView]
          contentView.constrainWithFormat(format, views:views, identifier: "-".join([identifierPrefix, thumbnailIdentifier]))

        }

        // Finally we must make sure that the views we want hidden are actually hidden
        indicator.hidden    = true
        detailButton.hidden = true
        nameLabel.hidden    = true

      default: break

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

    indicator = { [unowned self] in
      let indicator = UIImageView.newForAutolayout()
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
      self.contentView.addSubview(detailButton)
      return detailButton
      }()

    thumbnailImageView = { [unowned self] in
      let thumbnailImageView = UIImageView.newForAutolayout()
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
  requiresConstraintBasedLayout

  :returns: Bool
  */
  override class func requiresConstraintBasedLayout() -> Bool { return true }
  
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
