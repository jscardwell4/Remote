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
import Lumberjack

private let LabelHeight : CGFloat  = 21.0
private let ButtonHeight: CGFloat  = 44.0

@objc(BankCollectionZoomViewDelegate)
protocol BankCollectionZoomViewDelegate: NSObjectProtocol {
  func didDismissZoomView(BankCollectionZoomView)
  func didDismissForEditingZoomView(BankCollectionZoomView)
  func didDismissForDetailZoomView(BankCollectionZoomView)
}

@objc(BankCollectionZoomView)
class BankCollectionZoomView: UIView {

	var item: BankableModelObject? {
		didSet {
			nameLabel.text = item?.name
      image = item?.preview
			editButton.enabled = item?.editable ?? false
			detailButton.enabled = item?.dynamicType.isDetailable() ?? false
		}
	}

  var image: UIImage? {
    get { return imageView?.image }
    set {
      imageView?.image = newValue
      if let size = newValue?.size {
        imageView.contentMode = CGSizeGreaterThanOrEqualToSize(size, imageView.bounds.size) ? .ScaleAspectFit : .Center
      }
    }
  }

  var delegate: BankCollectionZoomViewDelegate?

  override init(frame: CGRect) {

    super.init(frame: frame)

    setTranslatesAutoresizingMaskIntoConstraints(false)

    self.backgroundImageView = {
    	let backgroundImageView = UIImageView(forAutoLayoutWithFrame: CGRect(x: 1, y: 1, width: 318, height: 383))
      backgroundImageView.opaque = true
      backgroundImageView.contentMode = .Center
    	self.addSubview(backgroundImageView)
    	return backgroundImageView
    	}()

    self.imageView = {
    	let imageView = UIImageView(forAutoLayoutWithFrame: CGRect(x: 32, y: 75, width: 256, height: 256))
      imageView.contentMode = .ScaleAspectFit
      imageView.constrainWithFormat("self.width = 256\nself.height = self.width")
    	self.addSubview(imageView)
    	return imageView
      }()

    self.nameLabel = {
      let nameLabel = UILabel(forAutoLayoutWithFrame: CGRect(x: 32, y: 10, width: 256, height: LabelHeight))
      nameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
      nameLabel.textAlignment = .Center
      nameLabel.constrainWithFormat("self.height = \(LabelHeight)")
      self.addSubview(nameLabel)
      return nameLabel
    }()

    self.detailButton = {
    	let detailButton = UIButton(forAutoLayoutWithFrame: CGRect(x: 264, y: 31,  width: ButtonHeight,  height: ButtonHeight ))
      detailButton.constrainWithFormat("self.height = \(ButtonHeight)\nself.width = self.height")
      detailButton.setImage(UIImage(named: "724-gray-info"), forState: .Normal)
      detailButton.setImage(UIImage(named: "724-gray-info-selected"), forState: .Highlighted)
      detailButton.addTarget(self, action: "dismiss:", forControlEvents: .TouchUpInside)
    	self.addSubview(detailButton)
    	return detailButton
    	}()

    self.editButton = {
    	let editButton = UIButton(forAutoLayoutWithFrame: CGRect(x: 264, y: 331, width: ButtonHeight,  height: ButtonHeight ))
      editButton.constrainWithFormat("self.height = \(ButtonHeight)\nself.width = self.height")
      editButton.setImage(UIImage(named: "830-gray-pencil"), forState: .Normal)
      editButton.setImage(UIImage(named: "830-gray-pencil-selected"), forState: .Highlighted)
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

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  weak var detailButton:        UIButton!
	weak var editButton:          UIButton!
	weak var nameLabel:           UILabel!
	weak var imageView:           UIImageView!
	weak var backgroundImageView: UIImageView!

	/**
	requiresConstraintBasedLayout

	:returns: Bool
	*/
	override class func requiresConstraintBasedLayout() -> Bool { return true }

  /**
  updateConstraints
  */
  override func updateConstraints() {

    removeConstraints(constraints())

    let format = "\n".join([
      "|-1-[background]-1-|",
      "V:|-1-[background]-1-|",
      "V:|-10-[name][detail][image][edit]-10-|",
      "|-32-[name]-32-|",
      "image.left ≥ self.left + 32",
      "image.right ≤ self.right - 32",
      "image.centerX = self.centerX",
      "edit.right = self.right - 12",
      "detail.right = edit.right"
      ])

    let views = [ "background": backgroundImageView,
                  "image"     : imageView,
                  "name"      : nameLabel,
                  "edit"      : editButton,
                  "detail"    : detailButton ]

    constrainWithFormat(format, views: views)

    super.updateConstraints()

  }

	/**
	intrinsicContentSize

	:returns: CGSize
	*/
/*
	override func intrinsicContentSize() -> CGSize {

		let maxImageSize      = CGSize(width: 200.0, height: 200.0)
		let minImageSize      = CGSize(width: 44.0,  height: 44.0)
		let verticalPadding  : CGFloat  = 10.0
		let horizontalPadding: CGFloat  = 32.0
		let maxContentWidth  : CGFloat  = 256.0

		var intrinsicSize = CGSize(width: UIViewNoIntrinsicMetric, height: UIViewNoIntrinsicMetric)

		if imageView.image != nil {

			var imageSize = CGSizeGreaterThanOrEqualToSize(imageView.image!.size, maxImageSize)
												? CGSizeAspectMappedToSize(imageView.image!.size, minImageSize, true)
												: imageView.image!.size

			imageSize = CGSizeGreaterThanOrEqualToSize(imageSize, minImageSize) ? imageSize : minImageSize
			let contentWidth = min(max(nameLabel.intrinsicContentSize().width, imageSize.width), maxContentWidth)
			intrinsicSize.width  = horizontalPadding * 2.0 + contentWidth
			intrinsicSize.height = verticalPadding * 2.0 + LabelHeight + ButtonHeight * 2.0 + imageSize.height
		}

		return intrinsicSize

	}
*/

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
