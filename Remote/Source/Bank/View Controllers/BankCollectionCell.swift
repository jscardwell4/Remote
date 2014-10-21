//
//  BankCollectionCellCollectionViewCell.swift
//  Remote
//
//  Created by Jason Cardwell on 10/7/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankCollectionCell: UICollectionViewCell {

  let indicator: UIImageView = {
    let view = UIImageView.newForAutolayout()
    view.nametag = "indicator"
    view.constrainWithFormat("self.width ≤ self.height :: self.height = 22")
    return view
  }()

  let deleteButton: UIButton = {
    let button = UIButton()
    button.setTranslatesAutoresizingMaskIntoConstraints(false)
    button.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.75)
    button.setTitle("Delete", forState: .Normal)
    button.constrainWithFormat("self.width = 100")
    return button
  }()

  var deleteAction: ((Void) -> Void)?

  var showingDeleteChangeHandler: ((BankCollectionCell) -> Void)?

  var showingDelete: Bool { return contentView.transform.tx == -100.0 }

  private(set) var contentSize = CGSizeZero

  var indicatorImage: UIImage? {
    didSet {
      indicator.image = indicatorImage
      indicator.hidden = indicatorImage == nil
      animateIndicator?()
    }
  }

  var animateIndicator: ((Void) -> Void)?

  /**
  applyLayoutAttributes:

  :param: layoutAttributes UICollectionViewLayoutAttributes!
  */
  override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
    super.applyLayoutAttributes(layoutAttributes)
    contentSize = layoutAttributes.frame.size
  }

  var indicatorConstraint: NSLayoutConstraint?
  var contentConstraint: NSLayoutConstraint?

  /** updateConstraints */
  override func updateConstraints() {

  	let identifier = createIdentifier(self, "Internal")

    // Refresh our constraints
    removeConstraintsWithIdentifier(identifier)
    let format = "\n".join("delete.right = self.right", "delete.top = self.top", "delete.bottom = self.bottom")
    let views = ["delete": deleteButton]
    constrainWithFormat(format, views: views, identifier: identifier)

//    if contentConstraint == nil {
//      contentConstraint = NSLayoutConstraint(item: contentView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
//      addConstraint(contentConstraint!)
//    }

    super.updateConstraints()

	}

  /** deleteButtonAction */
  func deleteButtonAction() {
    println("deleteButtonAction")
    UIView.animateWithDuration(animationDurationForDistance(deleteButton.bounds.size.width)){
      self.contentView.transform.tx = 0.0
    }
  }

  var swipeToDelete: Bool = true {
    didSet {
      if oldValue != swipeToDelete {
        panGesture.enabled = swipeToDelete
      }
    }
  }

  private weak var panGesture: UIPanGestureRecognizer!

  /**
  animationDurationForDistance:

  :param: distance CGFloat

  :returns: NSTimeInterval
  */
  private func animationDurationForDistance(distance: CGFloat) -> NSTimeInterval {
    return NSTimeInterval(CGFloat(0.25) * distance / deleteButton.bounds.size.width)
  }

  /** hideDelete */
  func hideDelete() {
    UIView.animateWithDuration(animationDurationForDistance(abs(contentView.transform.tx)),
      animations: { self.contentView.transform.tx = 0.0 },
      completion: {(completed: Bool) -> Void in _ = self.showingDeleteChangeHandler?(self) })
  }

  /**
  handlePan:

  :param: gesture UIPanGestureRecognizer
  */
  func handlePan(gesture: UIPanGestureRecognizer) {

    let x = gesture.translationInView(self).x
    let duration = animationDurationForDistance(abs(x))

    switch gesture.state {

      case .Began, .Changed:
        if x < 0 { contentView.transform.tx = x }

      case .Ended:
        UIView.animateWithDuration(duration,
          animations: {self.contentView.transform.tx = x <= -100.0 ? -100.0 : 0.0},
          completion: { (completed: Bool) -> Void in _ = self.showingDeleteChangeHandler?(self) })

      case .Possible, .Cancelled, .Failed:
        UIView.animateWithDuration(duration,
          animations: {self.contentView.transform.tx = 0.0},
          completion: { (completed: Bool) -> Void in _ = self.showingDeleteChangeHandler?(self) })

    }

  }

  /**
  requiresConstraintBasedLayout

  :returns: Bool
  */
  override class func requiresConstraintBasedLayout() -> Bool { return true }


  /** initializeSubviews */
  private func initializeSubviews() {
    panGesture = {
      let gesture = UIPanGestureRecognizer(target: self, action: "handlePan:")
      self.addGestureRecognizer(gesture)
      return gesture
      }()
    insertSubview(deleteButton, belowSubview: contentView)
    deleteButton.addTarget(self, action: "deleteButtonAction", forControlEvents: .TouchUpInside)
    contentView.addSubview(indicator)
    contentView.backgroundColor = UIColor.whiteColor()
    contentView.nametag = "content"
    setNeedsUpdateConstraints()
    animateIndicator = {
      UIView.animateWithDuration(5.0, animations: { () -> Void in
        _ = self.indicatorConstraint?.constant = self.indicatorImage == nil ? 0.0 : 40.0
      })
    }
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

}
