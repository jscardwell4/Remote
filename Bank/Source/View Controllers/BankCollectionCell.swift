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

  class func registerWithCollectionView(collectionView: UICollectionView) {
    collectionView.registerClass(self, forCellWithReuseIdentifier: cellIdentifier)
  }

  class var cellIdentifier: String { return "CollectionCell" }

  static let deleteButtonWidth: CGFloat = 100

  let indicator: UIImageView = {
    let view = UIImageView(autolayout: true)
    view.nametag = "indicator"
    return view
  }()

  let deleteButton: UIButton = {
    let button = UIButton(autolayout: true)
    button.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.75)
    button.setTitle("Delete", forState: .Normal)
    return button
  }()

  let chevron: UIImageView = {
    let view = UIImageView(autolayout: true)
    view.image = Bank.chevronImage
    view.contentMode = .ScaleAspectFit
    view.constrain(view.width => view.height, view.height => 22)
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

  /**
  showIndicator:selected:

  :param: show Bool
  :param: selected Bool = false
  */
  func showIndicator(show: Bool, selected: Bool = false) {
    indicatorImage = (show ? (selected ? Bank.indicatorImageSelected : Bank.indicatorImage) : nil)
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
    constrain(identifier: identifier,
      deleteButton.right => right,
      deleteButton.top => top,
      deleteButton.width => Float(BankCollectionCell.deleteButtonWidth),
      deleteButton.bottom => bottom,
      chevron.centerY => contentView.centerY,
      chevron.right => right - 20,
      chevron.width ≤ chevron.height,
      chevron.height => 22,
      indicator.width ≤ indicator.height,
      indicator.height => 22
    )

    super.updateConstraints()

	}

  /** deleteButtonAction */
  func deleteButtonAction() { deleteAction?(); hideDelete() }

  var swipeToDelete: Bool = true { didSet { if oldValue != swipeToDelete { panGesture.enabled = swipeToDelete } } }

  private weak var panGesture: PanGesture!

  /**
  animationDurationForDistance:

  :param: distance CGFloat

  :returns: NSTimeInterval
  */
  private func animationDurationForDistance(distance: CGFloat) -> NSTimeInterval {
    return NSTimeInterval(CGFloat(0.25) * distance / BankCollectionCell.deleteButtonWidth)
  }

  /**
  revealDelete:

  :param: distance CGFloat
  */
  func revealDelete(distance: CGFloat = deleteButtonWidth) {
    contentView.backgroundColor = Bank.backgroundColor
    deleteButton.hidden = false
    UIView.animateWithDuration(animationDurationForDistance(distance),
                    animations: { self.contentView.transform.tx = -BankCollectionCell.deleteButtonWidth },
                    completion: {_ in _ = self.showingDeleteDidChange?(self) })
  }

  /**
  hideDelete:

  :param: distance CGFloat
  */
  func hideDelete(distance: CGFloat = deleteButtonWidth) {
    UIView.animateWithDuration(animationDurationForDistance(distance),
                    animations: { self.contentView.transform.tx = 0 },
                    completion: {_ in
                      self.contentView.backgroundColor = UIColor.clearColor()
                      self.deleteButton.hidden = true
                      self.showingDeleteDidChange?(self)
    })
  }

  /**
  requiresConstraintBasedLayout

  :returns: Bool
  */
  override class func requiresConstraintBasedLayout() -> Bool { return true }


  /** initializeIVARs */
  private func initializeIVARs() {
    backgroundColor = UIColor.clearColor()
    opaque = false
    contentView.backgroundColor = UIColor.clearColor()
    contentView.opaque = false

    contentView.addSubview(chevron)
    panGesture = {
      var previousState: UIGestureRecognizerState = .Possible

      let gesture = PanGesture(handler: {
        [unowned self] gesture -> Void in

        let pan = gesture as! PanGesture

        let x = pan.translationInView(view: self).x

        switch pan.state {

          case .Began:
            self.contentView.backgroundColor = Bank.backgroundColor
            self.deleteButton.hidden = false
            fallthrough
          case .Changed:
            if x < 0 { self.contentView.transform.tx = x }

          case .Ended:
            if previousState == .Changed {
              let animate = x <= -BankCollectionCell.deleteButtonWidth ? self.revealDelete : self.hideDelete
              animate(distance: abs(x))
            }

          case .Cancelled, .Failed:
            self.hideDelete(distance: abs(x))

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
    deleteButton.hidden = true
    contentView.addSubview(indicator)
    contentView.backgroundColor = UIColor.clearColor()
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
  override init(frame: CGRect) { super.init(frame: frame); initializeIVARs() }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder); initializeIVARs() }

}
