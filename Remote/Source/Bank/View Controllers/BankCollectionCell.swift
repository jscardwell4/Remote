//
//  BankCollectionCell.swift
//  Remote
//
//  Created by Jason Cardwell on 9/10/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit

// FIXME: ivar_destroyer crash
@objc(BankCollectionCell)
class BankCollectionCell: UICollectionViewCell {

  weak var item: BankableModelObject? {
    didSet {
      if let newItem = item {
        nameLabel.text = newItem.name
        detailable = newItem.dynamicType.isDetailable()
        previewable = newItem.dynamicType.isPreviewable()
        thumbnailable = newItem.dynamicType.isThumbnailable()
      } else {
        nameLabel.text = nil
        previewable = false
        detailable = false
        thumbnailable = false
      }
    }
  }

  private let thumbnailImageView: UIImageView = {
    let view = UIImageView.newForAutolayout()
    view.constrainWithFormat("self.width = self.height")
    return view
    }()

  private let nameLabel: UILabel = {
    let label = UILabel.newForAutolayout()
    label.font = Bank.infoFont
    label.constrainWithFormat("self.height = 38")
    return label
  }()

  private let detailButton: UIButton = {
    let button = UIButton.newForAutolayout()
    button.setImage(UIImage(named: "766-arrow-right"),          forState: .Normal)
    button.setImage(UIImage(named: "766-arrow-right-selected"), forState: .Highlighted)
    button.constrainWithFormat("self.width = self.height :: self.height = 22")
    return button
    }()

  private let indicator: UIImageView = {
    let view = UIImageView.newForAutolayout()
    view.constrainWithFormat("self.width = self.height :: self.height = 22")
    return view
  }()

  private let previewGesture: UITapGestureRecognizer = UITapGestureRecognizer()
  private var indicatorConstraint: NSLayoutConstraint?

  private var detailable: Bool = false {
    didSet {
      detailButton.enabled = detailable
      detailButton.hidden = !detailable || viewingMode != .List
    }
  }

  private var previewable: Bool = false {
    didSet {
      previewGesture.enabled = previewable && viewingMode == .List
    }
  }

  private var thumbnailable: Bool = false {
    didSet {
      thumbnailImageView.image = item?.thumbnail
      thumbnailImageView.hidden = !thumbnailable
    }
  }

  private var viewingMode: BankCollectionAttributes.ViewingMode = .None {
    didSet {
      previewGesture.enabled = (viewingMode == BankCollectionAttributes.ViewingMode.List && previewable)
      setNeedsUpdateConstraints()
    }
  }

  var previewActionHandler: ((cell: BankCollectionCell) -> Void)?
  var detailActionHandler: ((cell: BankCollectionCell) -> Void)?

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
  applyLayoutAttributes:

  :param: layoutAttributes UICollectionViewLayoutAttributes!
  */
  override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
    super.applyLayoutAttributes(layoutAttributes)
    if let attributes = layoutAttributes as? BankCollectionAttributes { viewingMode = attributes.viewingMode }
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

        // Deactivate any thumbnail viewing mode constraints we find
        let thumbnailConstraints = contentView.constraintsWithIdentifierSuffix(thumbnailIdentifier)
        for thumbnailConstraint in thumbnailConstraints as [NSLayoutConstraint] { thumbnailConstraint.active = false }

        // Look for existing list viewing mode constraints
        let listConstraints = contentView.constraintsWithIdentifierSuffix(listIdentifier)

        // Just active them if they exist
        if listConstraints.count > 0 { for c in listConstraints as [NSLayoutConstraint] { c.active = true } }

        // Otherwise we need to create them
        else {

          indicatorConstraint = {[unowned self] in
            let constraint = NSLayoutConstraint(item: self.indicator,
                                                attribute: .Right,
                                                relatedBy: .Equal,
                                                   toItem: self.contentView,
                                                attribute: .Left,
                                               multiplier: 1.0,
                                                 constant: self.indicatorImage == nil ? 0.0 : 40.0)
            constraint.identifier = "-".join([identifierPrefix, indicatorIdentifier, listIdentifier])
            self.contentView.addConstraint(constraint)
            return constraint
          }()

          let size = BankCollectionLayout.ListItemCellSize
          var formatStrings = [
            "label.centerY = content.centerY",
            "detail.centerY = content.centerY",
            "indicator.centerY = content.centerY",
            "content.width = \(size.width)",
            "content.height = \(size.height)"
          ]

          if thumbnailable {
            formatStrings += [
              "image.left = indicator.right + 20",
              "image.height = content.height",
              "label.left = image.right + 8"
            ]
          } else {
            formatStrings += [
              "label.left = indicator.right + 20"
            ]
          }

          if detailable {
            formatStrings += [
              "detail.left = label.right + 8",
              "detail.right = content.right - 20"
            ]
          } else {
            formatStrings += [
              "label.right = content.right - 20"
            ]
          }

          let format = "\n".join(formatStrings)

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
          let format = "\n".join([
            "|[image]|",
            "image.height = image.width",
            "content.width = \(contentSize.width)",
            "content.height = \(contentSize.height)",
            "indicator.left = content.left + 8",
            "indicator.top = content.top + 8",
            "indicator.width = indicator.height",
            "indicator.height = 22"
            ])
          let views = ["image": thumbnailImageView, "content": contentView, "indicator": indicator]
          contentView.constrainWithFormat(format, views:views, identifier: "-".join([identifierPrefix, thumbnailIdentifier]))

        }

        // Finally we must make sure that the views we want hidden are actually hidden
        indicator.hidden    = indicatorImage == nil
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

    contentView.addSubview(indicator)
    contentView.addSubview(nameLabel)

    contentView.addSubview(detailButton)
    detailButton.addTarget(self, action:"detailAction", forControlEvents:.TouchUpInside)

    contentView.addSubview(thumbnailImageView)
    previewGesture.addTarget(self, action: "previewAction")
    thumbnailImageView.addGestureRecognizer(previewGesture)
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    contentView.setTranslatesAutoresizingMaskIntoConstraints(false)

    contentView.addSubview(indicator)
    contentView.addSubview(nameLabel)

    contentView.addSubview(detailButton)
    detailButton.addTarget(self, action:"detailAction", forControlEvents:.TouchUpInside)

    contentView.addSubview(thumbnailImageView)
    previewGesture.addTarget(self, action: "previewAction")
    thumbnailImageView.addGestureRecognizer(previewGesture)
  }

  /**
  requiresConstraintBasedLayout

  :returns: Bool
  */
  override class func requiresConstraintBasedLayout() -> Bool { return true }

  /**

  prepareForReuse

  */
  override func prepareForReuse() {
    super.prepareForReuse()
    item = nil
  }

  /**

  thumbnailImageViewAction

  */
  func previewAction() { if let action = previewActionHandler { action(cell: self) } }

  /**

  detailButtonAction

  */
  func detailAction() { if let action = detailActionHandler { action(cell: self) } }

}
