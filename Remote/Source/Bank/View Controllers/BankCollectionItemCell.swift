//
//  BankCollectionItemCell.swift
//  Remote
//
//  Created by Jason Cardwell on 9/10/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit


class BankCollectionItemCell: BankCollectionCell {

  weak var item: BankDisplayItemModel? {
    didSet {
      nameLabel.text = item?.name
      previewable = item?.previewable ?? false
    }
  }

  override var exportItem: MSJSONExport? { return item }

  private let thumbnailImageView: UIImageView = {
    let view = UIImageView()
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.contentMode = .ScaleAspectFit
    view.userInteractionEnabled = true
    view.constrainWithFormat("self.width ≤ self.height")
    view.tintColor = UIColor.blackColor()
    return view
    }()

  private let nameLabel: UILabel = {
    let view = UILabel()
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.font = Bank.infoFont
    return view
  }()

  private let chevron: UIImageView = {
    let view = UIImageView()
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.image = UIImage(named: "766-arrow-right")
    view.contentMode = .ScaleAspectFit
    view.constrainWithFormat("self.height = self.width :: self.height = 22")
    return view
    }()

  private let previewGesture: UITapGestureRecognizer = UITapGestureRecognizer()

  private var previewable: Bool = false {
    didSet {
      thumbnailImageView.image = item?.preview
      if let imageSize = thumbnailImageView.image?.size {
        thumbnailImageView.contentMode = CGSizeContainsSize(contentSize, imageSize) ? .Center : .ScaleAspectFit
      }
      thumbnailImageView.hidden = !previewable
      previewGesture.enabled = previewable && viewingMode == .List
    }
  }

  private var viewingMode: BankCollectionAttributes.ViewingMode = .List {
    didSet {
      previewGesture.enabled = (viewingMode == .List && previewable)
      swipeToDelete = (viewingMode == .List)
      setNeedsUpdateConstraints()
    }
  }

  var previewActionHandler: ((Void) -> Void)?

  /**
  applyLayoutAttributes:

  :param: layoutAttributes UICollectionViewLayoutAttributes!
  */
  override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
    super.applyLayoutAttributes(layoutAttributes)
    if let attributes = layoutAttributes as? BankCollectionAttributes { viewingMode = attributes.viewingMode }
  }


  /** updateConstraints */
  override func updateConstraints() {

    let listIdentifier      = createIdentifier(self, ["Internal", "List"])
    let thumbnailIdentifier = createIdentifier(self, ["Internal", "Thumbnail"])

    removeConstraintsWithIdentifier(listIdentifier)
    removeConstraintsWithIdentifier(thumbnailIdentifier)

    super.updateConstraints()

    switch viewingMode {

      case .List:

        var formatStrings = [
          "label.centerY = content.centerY",
          "label.height = content.height",
          "chevron.centerY = content.centerY",
          "chevron.left = label.right + 8",
          "chevron.right = content.right - 20",
          "indicator.centerY = content.centerY",
          "indicator.right = content.left + \(indicatorImage == nil ? 0.0 : 40.0)"
        ]

        if previewable {
          formatStrings += [
            "image.left = indicator.right + 20",
            "image.height = content.height",
            "label.left = image.right + 8"
          ]
        } else {
          formatStrings += ["label.left = indicator.right + 20"]
        }

        let format = "\n".join(formatStrings)

        let views = [ "indicator": indicator,
                      "image"    : thumbnailImageView,
                      "label"    : nameLabel,
                      "chevron"  : chevron,
                      "content"  : contentView]

        constrainWithFormat(format, views: views, identifier: listIdentifier)

        let predicate = NSPredicate(format: "firstItem == %@" +
                                            "AND secondItem == %@ " +
                                            "AND firstAttribute == \(NSLayoutAttribute.Right.rawValue)" +
                                            "AND secondAttribute == \(NSLayoutAttribute.Left.rawValue)" +
                                            "AND relation == \(NSLayoutRelation.Equal.rawValue)", indicator, contentView)
        indicatorConstraint = constraintMatching(predicate)
        indicator.hidden    = false
        nameLabel.hidden    = false
        chevron.hidden      = false


      case .Thumbnail:

        let format = "\n".join(
          "|[image]|",
          "image.height = image.width",
          "indicator.left = content.left + 8",
          "indicator.top = content.top + 8"
          )

        let views = ["image": thumbnailImageView, "content": contentView, "indicator": indicator]
        constrainWithFormat(format, views:views, identifier: thumbnailIdentifier)

        indicator.hidden    = indicatorImage == nil
        chevron.hidden      = true
        nameLabel.hidden    = true

      default: break

    }

  }

  /** initializeSubviews */
  private func initializeSubviews() {
    contentView.addSubview(nameLabel)
    contentView.addSubview(chevron)
    contentView.addSubview(thumbnailImageView)
    previewGesture.addTarget(self, action: "previewAction")
    thumbnailImageView.addGestureRecognizer(previewGesture)
  }

  /**
  initWithFrame:

  :param: frame CGRect
  */
  override init(frame: CGRect) { super.init(frame: frame); initializeSubviews() }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder); initializeSubviews() }

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
  func previewAction() { if let action = previewActionHandler { action() } }

}
