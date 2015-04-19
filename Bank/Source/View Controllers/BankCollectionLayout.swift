//
//  BankCollectionLayout.swift
//  Remote
//
//  Created by Jason Cardwell on 9/15/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

final class BankCollectionLayout: UICollectionViewLayout {

  /// Default cell sizes
  ////////////////////////////////////////////////////////////////////////////////

  static let ListItemCellSize = CGSize(width: 320.0, height: 38.0)
  static let ThumbnailItemCellSize = CGSize(width: 100.0, height: 100.0)

  /// Customizable cell sizes, spacing, and viewing mode
  ////////////////////////////////////////////////////////////////////////////////

  var itemListSize      = BankCollectionLayout.ListItemCellSize
  var itemThumbnailSize = BankCollectionLayout.ThumbnailItemCellSize
  var categorySize      = BankCollectionLayout.ListItemCellSize

  var verticalSpacing:   CGFloat = 10.0
  var horizontalSpacing: CGFloat = 10.0

  var viewingMode: BankCollectionAttributes.ViewingMode = .List {
    didSet {
      switch viewingMode {
        case .List:      itemSize = itemListSize
        case .Thumbnail: itemSize = itemThumbnailSize
        default: break
      }
      if oldValue != viewingMode { invalidateLayout() }
    }
  }

  /// Private variables to hold calculations
  ////////////////////////////////////////////////////////////////////////////////

  private(set) var itemSize  = BankCollectionLayout.ListItemCellSize

  private var categoryCount = 0
  private var itemCount     = 0

  private var categorySectionHeight: CGFloat = 0
  private var itemSectionHeight:     CGFloat = 0

  private var categoryAttributes: [BankCollectionAttributes] = []
  private var itemAttributes:     [BankCollectionAttributes] = []

  /** prepareLayout */
  override func prepareLayout() {
    precondition(collectionView!.numberOfSections() == 2, "should only be a catgories section and an items section")


    // Get the total number of categories and items
    categoryCount = collectionView!.numberOfItemsInSection(0)
    itemCount     = collectionView!.numberOfItemsInSection(1)

    // Calculate category section height
    categorySectionHeight = CGFloat(categoryCount) * (categorySize.height + verticalSpacing)

    // Calculate item section height
    let rowCount = CGFloat(itemCount / (viewingMode == .Thumbnail ? 3 : 1))
    itemSectionHeight =  rowCount * (itemSize.height + verticalSpacing)

    // Precalculate category attributes
    categoryAttributes.removeAll()
    categoryAttributes.reserveCapacity(categoryCount)
    var frame = CGRect(origin: CGPoint(x: 0.0, y: verticalSpacing), size: categorySize)
    for category in 0 ..< categoryCount {
      let indexPath = NSIndexPath(forRow: category, inSection: 0)
      let attributes = BankCollectionAttributes(forCellWithIndexPath: indexPath)
      attributes.frame = frame
      attributes.viewingMode = viewingMode
      categoryAttributes.append(attributes)
      frame.origin.y += categorySize.height + verticalSpacing
    }

    // Precalculate item attributes
    itemAttributes.removeAll()
    itemAttributes.reserveCapacity(itemCount)
    let itemsPerRow = viewingMode == .Thumbnail ? 3 : 1
    frame.size = itemSize
    for item in 0 ..< itemCount {
      let indexPath = NSIndexPath(forRow: item, inSection: 1)
      let attributes = BankCollectionAttributes(forCellWithIndexPath: indexPath)
      attributes.frame = frame
      attributes.viewingMode = viewingMode
      itemAttributes.append(attributes)
      let row = item / itemsPerRow
      let col = item % 3 + 1
      if col == 3 || itemsPerRow == 1 { frame.origin.y += itemSize.height + verticalSpacing }

      if col == 3 || itemsPerRow == 1 { frame.origin.x = 0.0 }
      else { frame.origin.x += itemSize.width + horizontalSpacing }
    }

  }

  /**

  layoutAttributesForElementsInRect:

  :param: rect CGRect

  :returns: [AnyObject]?

  */
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
    return categoryAttributes.filter{CGRectIntersectsRect($0.frame, rect)} + itemAttributes.filter{CGRectIntersectsRect($0.frame, rect)}
  }

  /**
  layoutAttributesForItemAtIndexPath:

  :param: indexPath NSIndexPath

  :returns: UICollectionViewLayoutAttributes!
  */
  override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
    return indexPath.section == 0 ? categoryAttributes[indexPath.row] : itemAttributes[indexPath.row]
  }

  /**
  collectionViewContentSize

  :returns: CGSize
  */
  override func collectionViewContentSize() -> CGSize {
    var size = CGSize(width: 320.0, height: categorySectionHeight + itemSectionHeight)
    if categoryCount > 0 && itemCount > 0 { size.height += verticalSpacing }
    return size
  }

  /**
  layoutAttributeClass

  :returns: AnyClass
  */
  override class func layoutAttributesClass() -> AnyClass { return BankCollectionAttributes.self }

  /**

  shouldInvalidateLayoutForBoundsChange:

  :param: newBounds CGRect

  :returns: Bool

  */
   // override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool { return true }


}
