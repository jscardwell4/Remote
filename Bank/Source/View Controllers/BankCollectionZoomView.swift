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

final class BankCollectionZoomView: UIView {

  let labelHeight: Float = 21
  let buttonWidth: Float = 44
  let buttonHeight: Float = 44

  var item: Previewable? {
    didSet {
      nameLabel.text = (item as? Named)?.name
      image = item?.preview
      editButton.enabled = (item as? Editable)?.editable == true
      detailButton.enabled = (item as? Detailable) != nil
    }
  }

  var image: UIImage? {
    get { return imageView?.image }
    set {
      imageView?.image = newValue
      if let actualSize = newValue?.size {
        if maxImageSize.contains(actualSize) { imageSize = actualSize }
        else { imageSize = actualSize.aspectMappedToSize(maxImageSize, binding: true).integralSizeRoundingDown }
      }
    }
  }

  var maxImageWidth: Float { return Float(w) - buttonWidth * 3.0 }
  var maxImageHeight: Float { return Float(h) - buttonHeight * 3.0 - labelHeight }
  var maxImageSize: CGSize { return CGSize(width: CGFloat(maxImageWidth), height: CGFloat(maxImageHeight)) }
  private var imageSize: CGSize = CGSize.zeroSize { didSet { setNeedsUpdateConstraints() } }

  var delegate: BankCollectionZoomViewDelegate?

  var showEditButton:   Bool { get {  return !editButton.hidden   } set { editButton.hidden = !newValue   } }
  var showDetailButton: Bool { get {  return !detailButton.hidden } set { detailButton.hidden = !newValue } }

  /**
  initWithFrame:

  :param: frame CGRect
  */
  override init(frame: CGRect) {

    super.init(frame: frame)

    MSLogDebug("frame: \(frame)")
    setTranslatesAutoresizingMaskIntoConstraints(false)

    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
    blurView.frame = bounds
//    blurView.setTranslatesAutoresizingMaskIntoConstraints(false)
//    blurView.contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
    addSubview(blurView)
    self.blurView = blurView
    contentView = blurView.contentView

    let imageView = UIImageView(autolayout: true)
    imageView.contentMode = .ScaleAspectFit
    imageView.tintColor = UIColor.blackColor()
    contentView.addSubview(imageView)
    self.imageView = imageView

    let nameLabel = UILabel(autolayout: true)
    nameLabel.font = Bank.boldLabelFont
    nameLabel.textAlignment = .Center
    nameLabel.constrain(nameLabel.height => labelHeight)
    contentView.addSubview(nameLabel)
    self.nameLabel = nameLabel

    let detailButton = UIButton(autolayout: true)
    detailButton.constrain(detailButton.width => detailButton.height)
    detailButton.setImage(Bank.infoImage, forState: .Normal)
    detailButton.setImage(Bank.infoImageSelected, forState: .Highlighted)
    detailButton.addTarget(self, action: "dismiss:", forControlEvents: .TouchUpInside)
    contentView.addSubview(detailButton)
    self.detailButton = detailButton

    let editButton = UIButton(autolayout: true)
    editButton.constrain(editButton.width => editButton.height)
    editButton.setImage(Bank.editImage, forState: .Normal)
    editButton.setImage(Bank.editImageSelected, forState: .Highlighted)
    editButton.addTarget(self, action: "dismiss:", forControlEvents: .TouchUpInside)
    contentView.addSubview(editButton)
    self.editButton = editButton

    addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismiss:"))

  }

  /**
  initWithFrame:delegate:

  :param: frame CGRect
  :param: delegate BankCollectionZoomViewDelegate
  */
  convenience init(frame: CGRect, delegate d: BankCollectionZoomViewDelegate) { self.init(frame: frame); delegate = d }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  private weak var contentView:           UIView!
  private weak var blurView:              UIVisualEffectView!
  private weak var detailButton:          UIButton!
  private weak var editButton:            UIButton!
  private weak var nameLabel:             UILabel!
  private weak var imageView:             UIImageView!

  /**
  requiresConstraintBasedLayout

  :returns: Bool
  */
  override class func requiresConstraintBasedLayout() -> Bool { return true }

  /** updateConstraints */
  override func updateConstraints() {
    MSLogDebug("before update… constraints = {\n\t" + "\n\t".join(constraints()) + "\n}")
    removeAllConstraints()
//    blurView.removeAllConstraints()
//    contentView.removeAllConstraints()
    super.updateConstraints()

    constrain(𝗩|blurView|𝗩, 𝗛|blurView|𝗛)
    constrain(𝗩|contentView|𝗩, 𝗛|contentView|𝗛)
//    blurView.constrain(𝗩|contentView|𝗩, 𝗛|contentView|𝗛)
    contentView.constrain(
      imageView.centerX => contentView.centerX,     // Horizontally center the image
      imageView.centerY => contentView.centerY,     // Vertically center the image
      detailButton.centerY => imageView.top - 33,   // Align detail with the top of image
      detailButton.left => nameLabel.right + 8,     // Align detail with the right of the name
      nameLabel.bottom => imageView.top - 8,        // Place the name above the image
      nameLabel.width ≥ imageView.width,            // Make the name at least as wide as the image
      nameLabel.width ≤ maxImageWidth,              // Make sure the name isn't too wide
      nameLabel.centerX => contentView.centerX,     // Center the name
      editButton.centerY => imageView.bottom + 33,  // Align edit with the bottom of image
      editButton.right => detailButton.right        // Align the right edge of edit and detail
    )

    // Create the image sizing constraints if we have a non-zero size
    if imageSize != CGSize.zeroSize {
      imageView.removeAllConstraints()
      imageView.constrain(imageView.width => Float(imageSize.width), imageView.height => Float(imageSize.height))
    }

    MSLogDebug("after update… constraints = {\n\t" + "\n\t".join(constraints()) + "\n}")

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
