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
    view.contentMode = .ScaleAspectFit
    view.userInteractionEnabled = true
    view.constrain(view.width ≤ view.height)
    view.tintColor = UIColor.blackColor()
    return view
    }()

  private let nameLabel: UILabel = { let view = UILabel(autolayout: true); view.font = Bank.infoFont; return view }()

  private let previewGesture: UITapGestureRecognizer = UITapGestureRecognizer()

  private var previewable: Bool = false {
    didSet {
      if previewable {
        if let previewImage = (item as? Previewable)?.thumbnail {
          thumbnailImageView.image = previewImage
          thumbnailImageView.contentMode = contentSize.contains(previewImage.size) ? .Center : .ScaleAspectFit
        } else {
          thumbnailImageView.image = nil
        }
      }
      thumbnailImageView.hidden = !previewable
      previewGesture.enabled = previewable && viewingMode == .List
    }
  }

  private var viewingMode: Bank.ViewingMode = .List {
    didSet {
      if oldValue != viewingMode {
        updateEnabledGestures()
        setNeedsUpdateConstraints()
      }
    }
  }

  private func updateEnabledGestures() {
    previewGesture.enabled = !zoomed && (viewingMode == .List && previewable)
    swipeToDelete = !zoomed && (viewingMode == .List)
  }

  private var zoomed = false { didSet { if oldValue != zoomed { updateEnabledGestures(); setNeedsUpdateConstraints() } } }

  var previewActionHandler: ((Void) -> Void)?

  /**
  applyLayoutAttributes:

  :param: layoutAttributes UICollectionViewLayoutAttributes!
  */
  override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
    super.applyLayoutAttributes(layoutAttributes)
    if let attributes = layoutAttributes as? BankCollectionAttributes {
      zoomed = attributes.zoomed
      viewingMode = attributes.viewingMode
    }
    if let previewImage = thumbnailImageView.image {
      thumbnailImageView.contentMode = contentSize.contains(previewImage.size) ? .Center : .ScaleAspectFit
    }
  }


  /** updateConstraints */
  override func updateConstraints() {

    let listIdentifier      = createIdentifier(self, ["Internal", "List"])
    let thumbnailIdentifier = createIdentifier(self, ["Internal", "Thumbnail"])

    removeConstraintsWithIdentifier(listIdentifier)
    removeConstraintsWithIdentifier(thumbnailIdentifier)

    super.updateConstraints()

    switch viewingMode {

      case .List where zoomed == false:

        constrain(identifier: listIdentifier,
          nameLabel.centerY => contentView.centerY,
          nameLabel.height => contentView.height,
          chevron.left => nameLabel.right + 8,
          indicator.centerY => contentView.centerY,
          indicator.right => contentView.left + (indicatorImage == nil ? 0 : 40)
        )

        if previewable {
          constrain(identifier: listIdentifier,
            thumbnailImageView.left => indicator.right + 20,
            thumbnailImageView.height => contentView.height,
            nameLabel.left => thumbnailImageView.right + 8
          )
        } else {
          constrain(identifier: listIdentifier, nameLabel.left => indicator.right + 20)
        }

        let predicate = NSPredicate(format: "firstItem == %@" +
                                            "AND secondItem == %@ " +
                                            "AND firstAttribute == \(NSLayoutAttribute.Right.rawValue)" +
                                            "AND secondAttribute == \(NSLayoutAttribute.Left.rawValue)" +
                                            "AND relation == \(NSLayoutRelation.Equal.rawValue)", indicator, contentView)
        indicatorConstraint = constraintMatching(predicate)
        indicator.hidden    = false
        nameLabel.hidden    = false
        chevron.hidden      = !showChevron


      case .Thumbnail, .List where zoomed == true:

        constrain(identifier: thumbnailIdentifier,
          𝗛|thumbnailImageView|𝗛,
          [ thumbnailImageView.height => thumbnailImageView.width,
            indicator.left => contentView.left + 8,
            indicator.top => contentView.top + 8]
        )

        indicator.hidden    = indicatorImage == nil
        chevron.hidden      = true
        nameLabel.hidden    = true

      default: break

    }

  }

  /** initializeSubviews */
  private func initializeSubviews() {
    contentView.addSubview(nameLabel)
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
  override func prepareForReuse() { super.prepareForReuse(); item = nil }

  /** previewAction */
  func previewAction() { if let action = previewActionHandler { action() } }

}
