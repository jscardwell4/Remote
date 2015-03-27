//
//  BankCollectionZoomView.swift
//  Remote
//
//  Created by Jason Cardwell on 9/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit
import DataModel

protocol BankCollectionZoomViewDelegate {
  func didDismissZoomView(BankCollectionZoomView)
  func didDismissForEditingZoomView(BankCollectionZoomView)
  func didDismissForDetailZoomView(BankCollectionZoomView)

}

class BankCollectionZoomView: UIView {

  class var LabelHeight: CGFloat { return 21.0 }
  class var ButtonSize: CGSize { return CGSize(width: 44.0, height: 44.0) }

  var item: Previewable? {
    didSet {
      if let namedItem = item as? Named { nameLabel.text = namedItem.name }
      image = item?.preview
      if let editableItem = item as? Editable { editButton.enabled = editableItem.editable }
      else { editButton.enabled = false }
      detailButton.enabled = item != nil
    }
  }

  var image: UIImage? {
    get { return imageView?.image }
    set {
      imageView?.image = newValue
      if let actualSize = newValue?.size {
        let maxImageSize = CGSize(width: maxImageWidth, height: maxImageHeight)
        if CGSizeContainsSize(maxImageSize, actualSize) { imageSize = actualSize }
        else { imageSize = CGSizeIntegralRoundingDown(CGSizeAspectMappedToSize(actualSize, maxImageSize, true)) }
        setNeedsUpdateConstraints()
      }
    }
  }

  var backgroundImage: UIImage? {
    get { return backgroundImageView?.image }
    set { backgroundImageView?.image = newValue }
  }

  var maxImageWidth: CGFloat { return width - BankCollectionZoomView.ButtonSize.width * 3.0 }

  var maxImageHeight: CGFloat {
    return height - BankCollectionZoomView.ButtonSize.height * 3.0 - BankCollectionZoomView.LabelHeight
  }
  var imageSize: CGSize = CGSize.zeroSize

  var delegate: BankCollectionZoomViewDelegate?

  var showEditButton: Bool { get {  return !editButton.hidden } set { editButton.hidden = !newValue } }

  var showDetailButton: Bool { get {  return !detailButton.hidden } set { detailButton.hidden = !newValue } }

  /**
  initWithFrame:

  :param: frame CGRect
  */
  override init(frame: CGRect) {

    super.init(frame: frame)

    setTranslatesAutoresizingMaskIntoConstraints(false)

    backgroundImageView = {
      let backgroundImageView = UIImageView.newForAutolayout()
      backgroundImageView.opaque = true
      backgroundImageView.contentMode = .Center
      self.addSubview(backgroundImageView)
      return backgroundImageView
      }()

    imageView = {
      let imageView = UIImageView.newForAutolayout()
      imageView.contentMode = .ScaleAspectFit
      self.addSubview(imageView)
      return imageView
      }()

    nameLabel = {
      let nameLabel = UILabel.newForAutolayout()
      nameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
      nameLabel.textAlignment = .Center
      self.addSubview(nameLabel)
      return nameLabel
    }()

    detailButton = {
      let detailButton = UIButton.newForAutolayout()
      detailButton.setImage(UIImage(named: "724-info"), forState: .Normal)
      detailButton.setImage(UIImage(named: "724-info-selected"), forState: .Highlighted)
      detailButton.addTarget(self, action: "dismiss:", forControlEvents: .TouchUpInside)
      self.addSubview(detailButton)
      return detailButton
      }()

    editButton = {
      let editButton = UIButton.newForAutolayout()
      editButton.setImage(UIImage(named: "830-pencil"), forState: .Normal)
      editButton.setImage(UIImage(named: "830-pencil-selected"), forState: .Highlighted)
      editButton.addTarget(self, action: "dismiss:", forControlEvents: .TouchUpInside)
      self.addSubview(editButton)
      return editButton
      }()

    addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismiss:"))

  }

  /**
  initWithFrame:delegate:

  :param: frame CGRect
  :param: delegate BankCollectionZoomViewDelegate
  */
  convenience init(frame: CGRect, delegate: BankCollectionZoomViewDelegate) {
    self.init(frame: frame)
    self.delegate = delegate
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  private weak var detailButton:          UIButton!
  private weak var editButton:            UIButton!
  private weak var nameLabel:             UILabel!
  private weak var imageView:             UIImageView!
  private weak var backgroundImageView:   UIImageView!
  private weak var imageWidthConstraint:  NSLayoutConstraint!
  private weak var imageHeightConstraint: NSLayoutConstraint!

  /**
  requiresConstraintBasedLayout

  :returns: Bool
  */
  override class func requiresConstraintBasedLayout() -> Bool { return true }

  /**
  updateConstraints
  */
  override func updateConstraints() {

    let identifierPrefix = "Internal"

    // Check for our internal constraints
    if constraintsWithIdentifierPrefix(identifierPrefix).count == 0 {

      // Double check that our name label doesn't have our constraint
      if nameLabel.constraintWithIdentifier(identifierPrefix) == nil {
        nameLabel.constrain("self.height = \(BankCollectionZoomView.LabelHeight)", identifier: identifierPrefix)
      }

      // Double check that our detail button doesn't have our constraint
      if detailButton.constraintWithIdentifier(identifierPrefix) == nil {
        detailButton.constrain("self.width = self.height", identifier: identifierPrefix)
      }

      // Double check that our edit button doesn't have our constraint
      if editButton.constraintWithIdentifier(identifierPrefix) == nil {
        editButton.constrain("self.width = self.height", identifier: identifierPrefix)
      }

      // Create the format string for our constraints
      let format = "\n".join([
        "|[background]|",                             // Make the background as wide as us
        "V:|[background]|",                           // Make the background as tall as us
        "image.center = self.center",                 // Center the image
        "detail.centerY = image.top - 33",            // Align detail with the top of image
        "detail.left = name.right + 8",               // Align detail with the right of the name
        "name.bottom = image.top - 8",                // Place the name above the image
        "name.width ≥ image.width",                   // Make the name at least as wide as the image
        "name.width ≤ \(maxImageWidth)",              // Make sure the name isn't too wide
        "name.centerX = self.centerX",                // Center the name
        "edit.centerY = image.bottom + 33",           // Align edit with the bottom of image
        "edit.right = detail.right"                   // Align the right edge of edit and detail
        ])

      // Create the dictionary of views for our constraints
      let views = [ "background": backgroundImageView,
                    "image"     : imageView,
                    "name"      : nameLabel,
                    "edit"      : editButton,
                    "detail"    : detailButton ]

      // Create and add our constraints
      constrain(format, views: views, identifier: identifierPrefix)
    }

    // Check if we have a size set for displaying our image
    if !CGSizeEqualToSize(imageSize, CGSize.zeroSize) {

      // Check if we need to create the image sizing constraints
      if imageWidthConstraint == nil && imageHeightConstraint == nil {

        imageWidthConstraint = {[unowned self] in
          let imageWidthConstraint = NSLayoutConstraint(item: self.imageView,
                                              attribute: .Width,
                                              relatedBy: .Equal,
                                                 toItem: nil,
                                              attribute: .NotAnAttribute,
                                             multiplier: 1.0,
                                               constant: self.imageSize.width)
          imageWidthConstraint.identifier = identifierPrefix
          self.imageView.addConstraint(imageWidthConstraint)
          return imageWidthConstraint
        }()

        imageHeightConstraint = {[unowned self] in
          let imageHeightConstraint = NSLayoutConstraint(item: self.imageView,
                                               attribute: .Height,
                                               relatedBy: .Equal,
                                                  toItem: nil,
                                               attribute: .NotAnAttribute,
                                              multiplier: 1.0,
                                                constant: self.imageSize.height)
          imageHeightConstraint.identifier = identifierPrefix
          self.imageView.addConstraint(imageHeightConstraint)
          return imageHeightConstraint
        }()

      }

      // Otherwise we just need to check that the constraint constants are in sync with our display size
      else {

        precondition(imageWidthConstraint != nil && imageHeightConstraint != nil, "we should have image constraints")

        imageWidthConstraint.constant  = imageSize.width
        imageHeightConstraint.constant = imageSize.height

      }

    }

    super.updateConstraints()

  }

  /**
  dismiss:

  :param: sender AnyObject
  */
  func dismiss(sender: AnyObject) {
    if delegate != nil {
      if sender === editButton { delegate!.didDismissForEditingZoomView(self) }
      else if sender === detailButton { delegate!.didDismissForDetailZoomView(self) }
      else { delegate!.didDismissZoomView(self) }
    }
  }

}
