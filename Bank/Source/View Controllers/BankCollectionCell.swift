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


// TODO: Sliding delete into view follows touch but sliding it back out of view does not?
// TODO: Touching cell while delete is showing should dismiss delete not push controller

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
    button.nametag = "delete"
    button.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.75)
    button.setTitle("Delete", forState: .Normal)
    return button
  }()

  let chevron: UIImageView = {
    let view = UIImageView(autolayout: true)
    view.nametag = "chevron"
    view.image = Bank.chevronImage
    view.contentMode = .ScaleAspectFit
    return view
  }()

  var deleteAction: ((Void) -> Void)?

  var showingDeleteDidChange: ((BankCollectionCell) -> Void)?

  var showingDelete: Bool { return contentView.transform.tx == -100.0 }

  var exportItem: JSONValueConvertible? { return nil }

  private(set) var contentSize = CGSize.zeroSize //{ didSet { removeAllConstraints(); setNeedsUpdateConstraints() } }

  var indicatorImage: UIImage? {
    didSet {
      indicator.image = indicatorImage
      indicator.hidden = indicatorImage == nil
      animateIndicator?()
    }
  }

  var showChevron: Bool = true { didSet { chevron.hidden = !showChevron } }

  var suppressIndicatorConstraints = false
  var suppressChevronConstraints   = false
  var suppressDeleteConstraints    = false

  var animateIndicator: ((Void) -> Void)?

  /**
  showIndicator:selected:

  - parameter show: Bool
  - parameter selected: Bool = false
  */
  func showIndicator(show: Bool, selected: Bool = false) {
    indicatorImage = (show ? (selected ? Bank.indicatorImageSelected : Bank.indicatorImage) : nil)
  }


  /**
  applyLayoutAttributes:

  - parameter layoutAttributes: UICollectionViewLayoutAttributes!
  */
  override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
    contentSize = layoutAttributes.size
  }

  var indicatorConstraint: NSLayoutConstraint?

  /** updateConstraints */
  override func updateConstraints() {

    let identifierBase = createIdentifier(self, "Internal")
  	let identifier = createIdentifierGenerator(identifierBase)

    // Refresh our constraints
    removeAllConstraints()

    super.updateConstraints()

    removeAllConstraints()

    constrain(
      𝗛|contentView|𝗛 --> identifier("ContainContent", "Horizontal"),
      𝗩|contentView|𝗩 --> identifier("ContainContent", "Vertical")
    )
    constrain(
      contentView.width => contentSize.width   --> identifier("Content", "Width"),
      contentView.height => contentSize.height --> identifier("Content", "Height")
    )

    if !suppressDeleteConstraints {
      constrain(
        deleteButton.right => right                                       --> identifier("DeleteButton", "Right"),
        deleteButton.top => top                                           --> identifier("DeleteButton", "Top"),
        deleteButton.width => Float(BankCollectionCell.deleteButtonWidth) --> identifier("DeleteButton", "Width"),
        deleteButton.bottom => bottom                                     --> identifier("DeleteButton", "Bottom")
      )
    }

    if !suppressChevronConstraints {
      constrain(
        chevron.centerY => contentView.centerY --> identifier("Chevron", "Vertical"),
        chevron.right => right - 20            --> identifier("Chevron", "Right"),
        chevron.width ≤ chevron.height         --> identifier("Chevron", "Proportion"),
        chevron.height => 22                   --> identifier("Chevron", "Size")
      )
    }

    if !suppressIndicatorConstraints {
      constrain(
        indicator.width ≤ indicator.height --> identifier("Indicator", "Proportion"),
        indicator.height => 22             --> identifier("Indicator", "Size")
      )
    }

	}

  /** deleteButtonAction */
  func deleteButtonAction() { deleteAction?(); hideDelete() }

  var swipeToDelete: Bool = true { didSet { if oldValue != swipeToDelete { panGesture.enabled = swipeToDelete } } }

  private weak var panGesture: PanGesture!

  /**
  animationDurationForDistance:

  - parameter distance: CGFloat

  - returns: NSTimeInterval
  */
  private func animationDurationForDistance(distance: CGFloat) -> NSTimeInterval {
    return NSTimeInterval(CGFloat(0.25) * distance / BankCollectionCell.deleteButtonWidth)
  }

  /**
  revealDelete:

  - parameter distance: CGFloat
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

  - parameter distance: CGFloat
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

  - returns: Bool
  */
  override class func requiresConstraintBasedLayout() -> Bool { return true }


  /** initializeIVARs */
  private func initializeIVARs() {
    translatesAutoresizingMaskIntoConstraints = false
    nametag = "cell"
    backgroundColor = UIColor.clearColor()
    opaque = false
    contentView.backgroundColor = UIColor.clearColor()
    contentView.opaque = false
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(chevron)
    panGesture = {
      var previousState: UIGestureRecognizerState = .Possible

      let gesture = PanGesture(handler: {
        [unowned self] gesture -> Void in

        let pan = gesture as! PanGesture

        let x = pan.translationInView(self).x

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
              animate(abs(x))
            }

          case .Cancelled, .Failed:
            self.hideDelete(abs(x))

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

  - parameter frame: CGRect
  */
  override init(frame: CGRect) { super.init(frame: frame); initializeIVARs() }

  /**
  init:

  - parameter aDecoder: NSCoder
  */
  required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder); initializeIVARs() }

}
