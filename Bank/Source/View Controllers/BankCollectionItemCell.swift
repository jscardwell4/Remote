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
        if let previewImage = (item as? Previewable)?.thumbnail {
          thumbnailImageView.image = previewImage
        } else {
          thumbnailImageView.image = nil
        }
      }
      thumbnailImageView.hidden = !previewable
      previewGesture.enabled = previewable && viewingMode == .List
    }
  }

  private var viewingMode: Bank.ViewingMode = .List

  /** updateEnabledGestures */
  private func updateEnabledGestures() {
    previewGesture.enabled = !zoomed && (viewingMode == .List && previewable)
    swipeToDelete = !zoomed && (viewingMode == .List)
  }

  /** updateSubviews */
  private func updateSubviews() {
    switch viewingMode {
      case .List where zoomed == false:
        indicator.hidden    = false
        nameLabel.hidden    = false
        chevron.hidden      = !showChevron
        thumbnailImageView.contentMode = .ScaleAspectFit
      case .Thumbnail, .List where zoomed == true:
        indicator.hidden = zoomed || indicatorImage == nil
        chevron.hidden      = true
        nameLabel.hidden    = true
        thumbnailImageView.contentMode = contentSize.contains(thumbnailImageView.image?.size ?? CGSize.zeroSize)
                                           ? .Center
                                           : .ScaleAspectFit
      default:
        break
    }
  }

  private var zoomed = false {
    didSet {
//      removeAllConstraints()
      suppressChevronConstraints   = zoomed
      suppressDeleteConstraints    = zoomed
      suppressIndicatorConstraints = zoomed
    }
  }
  
  var previewActionHandler: ((Void) -> Void)?

  /**
  applyLayoutAttributes:

  :param: layoutAttributes UICollectionViewLayoutAttributes!
  */
  override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
    if let attributes = layoutAttributes as? BankCollectionAttributes {
      zoomed = attributes.zoomed
      viewingMode = attributes.viewingMode
      updateEnabledGestures()
      updateSubviews()
      setNeedsUpdateConstraints()
      MSLogDebug("attributes = \(attributes)")
    }
    super.applyLayoutAttributes(layoutAttributes)
  }


  /** updateConstraints */
  override func updateConstraints() {

    let identifierBase = createIdentifier(self, "Internal")
    let listIdentifier      = createIdentifierGenerator(createIdentifier(self, "Internal", "List"))
    let thumbnailIdentifier = createIdentifierGenerator(createIdentifier(self, "Internal", "Thumbnail"))

    removeConstraintsWithIdentifierPrefix(identifierBase)

    super.updateConstraints()

    switch viewingMode {

      case .List where zoomed == false:

        constrain(
          nameLabel.centerY => contentView.centerY
            --> listIdentifier(suffixes: "Label", "Vertical"),
          nameLabel.height => contentView.height
            --> listIdentifier(suffixes: "Label", "Height"),
          chevron.left => nameLabel.right + 8
            --> listIdentifier(suffixes: "Chevron", "Label", "Spacing", "Horizontal"),
          indicator.centerY => contentView.centerY
            --> listIdentifier(suffixes: "Indicator", "Vertical"),
          indicator.right => contentView.left + (indicatorImage == nil ? 0 : 40)
            --> listIdentifier(suffixes: "Indicator", "Left")
        )

        if previewable {
          constrain(
            thumbnailImageView.left => indicator.right + 20
              --> listIdentifier(suffixes: "Thumbnail", "Indicator", "Spacing", "Horizontal"),
            thumbnailImageView.height => contentView.height - 8
              --> listIdentifier(suffixes: "Thumbnail", "Height"),
            thumbnailImageView.width => thumbnailImageView.height
              --> listIdentifier(suffixes: "Thumbnail", "Width"),
            thumbnailImageView.centerY => contentView.centerY
              --> listIdentifier(suffixes: "Thumbnail", "Vertical"),
            nameLabel.left => thumbnailImageView.right + 8
              --> listIdentifier(suffixes: "Label", "Thumbnail", "Spacing", "Horizontal")
          )
        } else {
          constrain(
            nameLabel.left => indicator.right + 20
              --> listIdentifier(suffixes: "Label", "Indicator", "Spacing", "Horizontal")
          )
        }

        indicatorConstraint = constraintWithIdentifier(listIdentifier(suffixes: "Indicator", "Left"))

      case .Thumbnail, .List where zoomed == true:
        if zoomed, let (w, h) = thumbnailImageView.image?.size.unpack() where w > 0 && h > 0 {
            constrain(
              𝗛|--(≥0)--thumbnailImageView--(≤0)--|𝗛
                --> thumbnailIdentifier(suffixes: "Zoomed", "Thumbnail", "Spacing", "Horizontal"),
              [thumbnailImageView.height => thumbnailImageView.width * Float(Ratio(w, h).inverseValue)
                --> thumbnailIdentifier(suffixes: "Zoomed", "Thumbnail", "Proportion"),
              thumbnailImageView.width => w -!> 500
                --> thumbnailIdentifier(suffixes: "Zoomed", "Thumbnail", "Width"),
              thumbnailImageView.centerX => contentView.centerX
                --> thumbnailIdentifier(suffixes: "Zoomed", "Thumbnail", "Horizontal"),
              thumbnailImageView.centerY => contentView.centerY
                --> thumbnailIdentifier(suffixes: "Zoomed", "Thumbnail", "Vertical")]
            )
        } else if !zoomed {
          constrain(
            𝗛|thumbnailImageView|𝗛
              --> thumbnailIdentifier(suffixes: "Thumbnail", "Spacing", "Horizontal"),
            [thumbnailImageView.height => thumbnailImageView.width
              --> thumbnailIdentifier(suffixes: "Thumbnail", "Proportion"),
             indicator.left => contentView.left + 8
              --> thumbnailIdentifier(suffixes: "Indicator", "Left"),
             indicator.top => contentView.top + 8
              --> thumbnailIdentifier(suffixes: "Indicator", "Top")]
          )
        }

      default:
        break

    }

//    MSLogDebug("viewingMode = \(viewingMode), constraints = {\n\t" +
//               "\n\t".join((constraints() as! [NSLayoutConstraint]).map {$0.prettyDescription}) +
//               "\n}")

  }

  /** initializeIVARs */
  private func initializeIVARs() {
    contentView.addSubview(nameLabel)
    contentView.addSubview(thumbnailImageView)
    previewGesture.addTarget(self, action: "previewAction")
    thumbnailImageView.addGestureRecognizer(previewGesture)
}

  /**
  initWithFrame:

  :param: frame CGRect
  */
  override init(frame: CGRect) { super.init(frame: frame); initializeIVARs() }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder); initializeIVARs() }

  /**

  prepareForReuse

  */
  override func prepareForReuse() { super.prepareForReuse(); item = nil }

  /** previewAction */
  func previewAction() { if let action = previewActionHandler { action() } }

}
