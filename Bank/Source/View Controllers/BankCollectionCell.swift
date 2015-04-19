//
//  BankCollectionCell.swift
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
    view.constrain("self.width ≤ self.height :: self.height = 22")
    return view
  }()

  let deleteButton: UIButton = {
    let button = UIButton()
    button.setTranslatesAutoresizingMaskIntoConstraints(false)
    button.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.75)
    button.setTitle("Delete", forState: .Normal)
    button.constrain("self.width = 100")
    return button
  }()

  let chevron: UIImageView = {
    let view = UIImageView()
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.image = UIImage(named: "766-arrow-right")
    view.contentMode = .ScaleAspectFit
    view.constrain("self.width = self.height :: self.height = 22")
    return view
  }()

  var deleteAction: ((Void) -> Void)?

  var showingDeleteDidChange: ((BankCollectionCell) -> Void)?

  var showingDelete: Bool { return contentView.transform.tx == -100.0 }

  var exportItem: JSONValueConvertible? { return nil }

  private(set) var contentSize = CGSize.zeroSize

  var indicatorImage: UIImage? {
    didSet {
      indicator.image = indicatorImage
      indicator.hidden = indicatorImage == nil
      animateIndicator?()
    }
  }

  var showChevron: Bool = true { didSet { chevron.hidden = !showChevron } }

  var animateIndicator: ((Void) -> Void)?

  private let indicatorImageNormal = Bank.bankImageNamed("1040-checkmark-toolbar")
  private let indicatorImageSelected = Bank.bankImageNamed("1040-checkmark-toolbar-selected")

  /**
  showIndicator:selected:

  :param: show Bool
  :param: selected Bool = false
  */
  func showIndicator(show: Bool, selected: Bool = false) {
    indicatorImage = (show ? (selected ? indicatorImageSelected : indicatorImageNormal) : nil)
  }


  /**
  applyLayoutAttributes:

  :param: layoutAttributes UICollectionViewLayoutAttributes!
  */
  override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
    super.applyLayoutAttributes(layoutAttributes)
    contentSize = layoutAttributes.frame.size
  }

  var indicatorConstraint: NSLayoutConstraint?

  /** updateConstraints */
  override func updateConstraints() {

  	let identifier = createIdentifier(self, "Internal")

    // Refresh our constraints
    removeConstraintsWithIdentifier(identifier)
    let format = "\n".join("delete.right = self.right",
                           "delete.top = self.top",
                           "delete.bottom = self.bottom",
                           "chevron.centerY = content.centerY",
                           "H:[chevron]-20-|")
    let views = ["delete": deleteButton, "chevron": chevron, "content": contentView]
    constrain(format, views: views, identifier: identifier)

    super.updateConstraints()

	}

  /** deleteButtonAction */
  func deleteButtonAction() {
    deleteAction?()
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

  private weak var panGesture: PanGesture!

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
      completion: {(completed: Bool) -> Void in _ = self.showingDeleteDidChange?(self) })
  }

  /**
  handlePan:

  :param: gesture PanGesture
  */
  func handlePan(gesture: PanGesture) {

    let x = gesture.translationInView(view: self).x
    let duration = animationDurationForDistance(abs(x))

    switch gesture.state {

      case .Began, .Changed:
        if x < 0 { contentView.transform.tx = x }

      case .Ended:
        UIView.animateWithDuration(duration,
          animations: {self.contentView.transform.tx = x <= -100.0 ? -100.0 : 0.0},
          completion: { (completed: Bool) -> Void in _ = self.showingDeleteDidChange?(self) })

      case .Cancelled, .Failed:
        UIView.animateWithDuration(duration,
          animations: {self.contentView.transform.tx = 0.0},
          completion: { (completed: Bool) -> Void in _ = self.showingDeleteDidChange?(self) })

      default: break
    }

  }

  /**
  requiresConstraintBasedLayout

  :returns: Bool
  */
  override class func requiresConstraintBasedLayout() -> Bool { return true }


  /** initializeSubviews */
  private func initializeSubviews() {
    contentView.addSubview(chevron)
    panGesture = {
      var previousState: UIGestureRecognizerState = .Possible

      let gesture = PanGesture(handler: {
        [unowned self] gesture -> Void in

        let pan = gesture as! PanGesture

        let x = pan.translationInView(view: self).x

        switch pan.state {

          case .Began, .Changed:
            if x < 0 { self.contentView.transform.tx = x }

          case .Ended:
            if previousState == .Changed {
              UIView.animateWithDuration(self.animationDurationForDistance(abs(x)),
                animations: {self.contentView.transform.tx = x <= -100.0 ? -100.0 : 0.0},
                completion: { (completed: Bool) -> Void in _ = self.showingDeleteDidChange?(self) })
            }

          case .Cancelled, .Failed:
            UIView.animateWithDuration(self.animationDurationForDistance(abs(x)),
              animations: {self.contentView.transform.tx = 0.0},
              completion: { (completed: Bool) -> Void in _ = self.showingDeleteDidChange?(self) })
            
          default: break

        }

        previousState = pan.state
      })
      gesture.confineToView = true
      self.addGestureRecognizer(gesture)
      return gesture
      }()
    insertSubview(deleteButton, belowSubview: contentView)
    deleteButton.addTarget(self, action: "deleteButtonAction", forControlEvents: .TouchUpInside)
    contentView.addSubview(indicator)
    contentView.backgroundColor = Bank.backgroundColor
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
