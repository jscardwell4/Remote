//
//  InlinePickerView.swift
//  MSKit
//
//  Created by Jason Cardwell on 10/14/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit


public class InlinePickerView: UIView {


  /**
  initWithFrame:

  - parameter frame: CGRect
  */
  override public init(frame: CGRect) { super.init(frame: frame); initializeIVARs() }

  /**
  init:

  - parameter aDecoder: NSCoder
  */
  required public init(coder aDecoder: NSCoder) { super.init(coder: aDecoder); initializeIVARs() }

  /** initializeIVARs */
  private func initializeIVARs() {
    addSubview(collectionView)
    (collectionView.collectionViewLayout as! InlinePickerViewLayout).delegate = self
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.backgroundColor = UIColor.clearColor()
    collectionView.decelerationRate = UIScrollViewDecelerationRateFast
    collectionView.registerClass(InlinePickerViewCell.self, forCellWithReuseIdentifier: "Cell")
  }

  override public func updateConstraints() {
    removeAllConstraints()
    super.updateConstraints()
    constrain(𝗛|collectionView|𝗛, 𝗩|collectionView|𝗩)
  }

  private let collectionView = UICollectionView(frame: CGRect.zeroRect, collectionViewLayout: InlinePickerViewLayout())

  override public class func requiresConstraintBasedLayout() -> Bool { return true }
  override public func intrinsicContentSize() -> CGSize {
    return CGSize(width: UIViewNoIntrinsicMetric, height: cellHeight)
  }

  /**
  selectItem:animated:

  - parameter row: Int
  - parameter animated: Bool
  */
  public func selectItem(item: Int, animated: Bool) {
    collectionView.selectItemAtIndexPath(NSIndexPath(forItem: item, inSection: 0),
                                animated: animated,
                          scrollPosition: [.CenteredHorizontally, .CenteredVertically])
  }

  public var labels: [String] = [] {
    didSet {
      collectionView.collectionViewLayout.invalidateLayout()
      collectionView.reloadData()
    }
  }
  public var didSelectItem: ((InlinePickerView, Int) -> Void)?
  public var font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody) {
    didSet {
      (collectionView.visibleCells() as? [InlinePickerViewCell])?.apply { $0.font = self.font }
    }
  }

  public var textColor = UIColor.darkTextColor() {
    didSet {
      (collectionView.visibleCells() as? [InlinePickerViewCell])?.apply { $0.textColor = self.textColor }
    }
  }

  public func reloadData() {
    collectionView.reloadData()
  }

  public var cellHeight: CGFloat = 44.0
  public var cellPadding: CGFloat = 8.0

  var cellSizes: [CGSize] {
    var result: [CGSize] = []
    let labelAttributes = [NSFontAttributeName: font]
    for label in labels {
      let size = label.sizeWithAttributes(labelAttributes)
      result.append(CGSize(width: ceil(size.width), height: ceil(size.height)))
    }
    return result
  }

}

// MARK: - UICollectionViewDataSource
extension InlinePickerView: UICollectionViewDataSource {


  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return labels.count
  }

  public func collectionView(collectionView: UICollectionView,
      cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
  {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! InlinePickerViewCell
    cell.text = labels[indexPath.row]
    cell.font = font
    cell.textColor = textColor
    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension InlinePickerView: UICollectionViewDelegate {
  public func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }
  public func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }
  public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    didSelectItem?(self, indexPath.row)
  }
}