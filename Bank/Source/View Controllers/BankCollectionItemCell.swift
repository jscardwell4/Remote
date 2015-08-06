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


final class BankCollectionItemCell: BankCollectionCell {

  override class var cellIdentifier: String { return "ItemCell" }

  weak var item: protocol<Named>? { didSet { nameLabel.text = item?.name; previewable = item != nil && item! is Previewable } }

  override var exportItem: JSONValueConvertible? { return item as? JSONValueConvertible }

  private let thumbnailImageView: UIImageView = {
    let view = UIImageView(autolayout: true)
    view.nametag = "thumbnail"
    view.backgroundColor = UIColor.clearColor()
    view.opaque = false
    view.contentMode = .ScaleAspectFit
    view.userInteractionEnabled = true
    view.constrain(view.width ≤ view.height)
    view.tintColor = UIColor.blackColor()
    return view
    }()

  private let nameLabel: UILabel = {
    let view = UILabel(autolayout: true)
    view.nametag = "label"
    view.font = Bank.infoFont
    view.backgroundColor = UIColor.clearColor()
    view.opaque = false
    return view
    }()

  private let previewGesture: UITapGestureRecognizer = UITapGestureRecognizer()

  private var previewable: Bool = false {
    didSet {
      if previewable {
        thumbnailImageView.image = (item as? Previewable)?.thumbnail
      }
      thumbnailImageView.hidden = !previewable
      previewGesture.enabled = previewable && viewingMode == .List
    }
  }

  private var viewingMode: Bank.ViewingMode = .List

  /** updateEnabledGestures */
  private func updateEnabledGestures() {
    previewGesture.enabled = (viewingMode == .List && previewable)
    swipeToDelete = (viewingMode == .List)
  }

  /** updateSubviews */
  private func updateSubviews() {
    switch viewingMode {
      case .List:
        indicator.hidden    = false
        nameLabel.hidden    = false
        chevron.hidden      = !showChevron
        thumbnailImageView.contentMode = .ScaleAspectFit
      case .Thumbnail:
        indicator.hidden = indicatorImage == nil
        chevron.hidden      = true
        nameLabel.hidden    = true
        thumbnailImageView.contentMode = contentSize.contains(thumbnailImageView.image?.size ?? CGSize.zeroSize)
                                           ? .Center
                                           : .ScaleAspectFit
    }
  }

  var previewActionHandler: ((Void) -> Void)?

  /**
  applyLayoutAttributes:

  - parameter layoutAttributes: UICollectionViewLayoutAttributes!
  */
  override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
    if let attributes = layoutAttributes as? BankCollectionAttributes {
      viewingMode = attributes.viewingMode
      updateEnabledGestures()
      updateSubviews()
      setNeedsUpdateConstraints()
    }
    super.applyLayoutAttributes(layoutAttributes)
  }

  /** updateConstraints */
  override func updateConstraints() {

    let identifierBase = MoonKit.Identifier(self, "Internal")
    let listIdentifier = { (tags: [String]) -> MoonKit.Identifier in
      var identifier = MoonKit.Identifier(self, "Internal", "List")
      identifier.extend(tags)
      return identifier
    }
    let thumbnailIdentifier = { (tags: [String]) -> MoonKit.Identifier in
      var identifier = MoonKit.Identifier(self, "Internal", "Thumbnail")
      identifier.extend(tags)
      return identifier
    }

    removeConstraintsWithIdentifierPrefix(identifierBase.string)

    super.updateConstraints()

    switch viewingMode {

      case .List:

        constrain(
          nameLabel.centerY => contentView.centerY
            --> listIdentifier(["Label", "Vertical"]),
          nameLabel.height => contentView.height
            --> listIdentifier(["Label", "Height"]),
          chevron.left => nameLabel.right + 8
            --> listIdentifier(["Chevron", "Label", "Spacing", "Horizontal"]),
          indicator.centerY => contentView.centerY
            --> listIdentifier(["Indicator", "Vertical"]),
          indicator.right => contentView.left + (indicatorImage == nil ? 0 : 40)
            --> listIdentifier(["Indicator", "Left"])
        )

        if previewable {
          constrain(
            thumbnailImageView.left => indicator.right + 20
              --> listIdentifier(["Thumbnail", "Indicator", "Spacing", "Horizontal"]),
            thumbnailImageView.height => contentView.height - 8
              --> listIdentifier(["Thumbnail", "Height"]),
            thumbnailImageView.width => thumbnailImageView.height
              --> listIdentifier(["Thumbnail", "Width"]),
            thumbnailImageView.centerY => contentView.centerY
              --> listIdentifier(["Thumbnail", "Vertical"]),
            nameLabel.left => thumbnailImageView.right + 8
              --> listIdentifier(["Label", "Thumbnail", "Spacing", "Horizontal"])
          )
        } else {
          constrain(
            nameLabel.left => indicator.right + 20
              --> listIdentifier(["Label", "Indicator", "Spacing", "Horizontal"])
          )
        }

        indicatorConstraint = constraintWithIdentifier(listIdentifier(["Indicator", "Left"]).string)

      case .Thumbnail:
        constrain(
          𝗛|thumbnailImageView|𝗛
            --> thumbnailIdentifier(["Thumbnail", "Spacing", "Horizontal"]),
          [thumbnailImageView.height => thumbnailImageView.width
            --> thumbnailIdentifier(["Thumbnail", "Proportion"]),
           indicator.left => contentView.left + 8
            --> thumbnailIdentifier(["Indicator", "Left"]),
           indicator.top => contentView.top + 8
            --> thumbnailIdentifier(["Indicator", "Top"])]
        )

    }

  }

  /** initializeIVARs */
  private func initializeIVARs() {
    contentView.addSubview(nameLabel)
    contentView.addSubview(thumbnailImageView)
    previewGesture.addTarget(self, action: "previewAction")
    thumbnailImageView.addGestureRecognizer(previewGesture)
  }

  override init(frame: CGRect) { super.init(frame: frame); initializeIVARs() }
  required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder); initializeIVARs() }

  override func prepareForReuse() { super.prepareForReuse(); item = nil }

  /** previewAction */
  func previewAction() { if let action = previewActionHandler { action() } }

}
