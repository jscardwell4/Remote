//
//  InlinePickerViewLayout.swift
//  MoonKit
//
//  Created by Jason Cardwell on 7/2/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

class InlinePickerViewLayout: UICollectionViewLayout {

  // MARK: - Typealiases
  private typealias AttributesIndex = OrderedDictionary<NSIndexPath, UICollectionViewLayoutAttributes>

  // MARK: - Exposed properties and methods

  weak var delegate: InlinePickerView?

  /**
  indexOfItemAtOffset:

  - parameter offset: CGPoint

  - returns: Int?
  */
  func indexOfItemAtOffset(offset: CGPoint) -> Int? {

    // Check for an exact match
    if let idx = stopLocations.indexOf(offset.x) { return idx }

    // Otherwise use a switch to rule out base cases
    switch stopLocations.count {
      case 0:                                           // No items means no index
        return nil
      case 1, _ where stopLocations[0] > offset.x:      // Single-item array or the first item is greater than the offset
        return 0
      case let c where stopLocations[c - 1] < offset.x: // Offset is greater than the last item
        return c - 1
      default:                                          // Could be one of two choices, return the nearest of the two to the offset
        guard let i = stopLocations.indexOf({$0 > offset.x}) else { return nil }
        let d1 = abs(stopLocations[i] - offset.x)
        let d2 = abs(stopLocations[i - 1] - offset.x)
        return d1 < d2 ? i : i - 1
    }
  }

  func offsetForItemAtIndex(index: Int) -> CGPoint {
    return CGPoint(x: rawLocations[index], y: 0)
  }

  // MARK: - Internally used properties
  private var storedAttributes: AttributesIndex = [:]
  private var visibleRect = CGRect.zeroRect
  private let maxAngle = CGFloat(M_PI_2)
  private var cellWidths: [CGFloat] = []
  private var contentHeight: CGFloat = 0.0
  private var contentWidth: CGFloat = 0.0
  private var cellPadding: CGFloat = 8.0
  private var contentPadding: CGFloat = 0.0
  private var stopLocations: [CGFloat] = []
  private var rawLocations: [CGFloat] = []

  // MARK: - UICollectionViewLayout method overrides

  /**
  shouldInvalidateLayoutForBoundsChange:

  - parameter newBounds: CGRect

  - returns: Bool
  */
  override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
    return true //collectionView?.bounds.width != newBounds.width
  }

  /** prepareLayout */
  override func prepareLayout() {
    guard let collectionView = collectionView, delegate = delegate else { return }

    cellWidths = delegate.itemWidths
    cellPadding = ceil(delegate.itemPadding)
    let cellBoundaryWidth = ceil(cellWidths.sum + cellPadding * CGFloat(cellWidths.count - 1))
    contentPadding = ceil(cellBoundaryWidth / 2)
    contentWidth = cellBoundaryWidth + contentPadding * 2
    contentHeight = ceil(delegate.itemHeight)

    visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)

    storedAttributes = AttributesIndex(
      (0 ..< collectionView.numberOfItemsInSection(0)).map { NSIndexPath(forRow: $0, inSection: 0) } .map {
        ($0, self.layoutAttributesForItemAtIndexPath($0)!)
      }
    )

    stopLocations = storedAttributes.values.map {[offset = collectionView.bounds.width / 2] in $0.frame.midX - offset }
    rawLocations = {
      var locations: [CGFloat] = []
      var x = self.contentPadding
      for width in self.cellWidths {
        let halfWidth = width / 2
        x += halfWidth
        locations.append(x)
        x += self.cellPadding + halfWidth
      }
      return locations
      }()

  }

  /**
  collectionViewContentSize

  - returns: CGSize
  */
  override func collectionViewContentSize() -> CGSize {
    return CGSize(width: contentWidth, height: contentHeight)
  }

  /**
  layoutAttributesForElementsInRect:

  - parameter rect: CGRect

  - returns: [AnyObject]?
  */
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    return storedAttributes.values.filter { $0.frame.intersects(rect) }.array
  }

  /**
  layoutAttributesForItemAtIndexPath:

  - parameter indexPath: NSIndexPath

  - returns: UICollectionViewLayoutAttributes!
  */
  override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
    let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)

    let widths = cellWidths[0..<indexPath.item]
    let padding = contentPadding + cellPadding * CGFloat(indexPath.item)
    let xOffset = widths.sum + padding
    attributes.frame = CGRect(x: xOffset, y: 0, width: cellWidths[indexPath.item], height: contentHeight)

    let distance = attributes.frame.midX - visibleRect.midX
      let w = visibleRect.width / 2
      let currentAngle = maxAngle * distance / w / CGFloat(M_PI_2)

      var transform = CATransform3DIdentity
      transform = CATransform3DTranslate(transform, -distance, 0, -w)
      transform = CATransform3DRotate(transform, currentAngle, 0, 1, 0)
      transform = CATransform3DTranslate(transform, 0, 0, w)

      attributes.transform3D = transform
      attributes.alpha = fabs(currentAngle) < maxAngle ? 1.0 : 0.0

    return attributes
  }

  /**
  offsetForProposedOffset:

  - parameter offset: CGPoint

  - returns: CGPoint
  */
  private func offsetForProposedOffset(offset: CGPoint) -> CGPoint {
    MSLogDebug("\n".join(
      "proposedContentOffset = \(offset)",
      "contentWidth = \(contentWidth)",
      "collectionView!.bounds = \(collectionView!.bounds)",
      "attribute frames = \(storedAttributes.values.map({$0.frame}).array)",
      "stop locations = \(stopLocations)"
      )
    )
    if let idx = indexOfItemAtOffset(offset) { return CGPoint(x: stopLocations[idx], y: 0) }
    else { return offset }
  }

  /**
  targetContentOffsetForProposedContentOffset:

  - parameter proposedContentOffset: CGPoint

  - returns: CGPoint
  */
  override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint) -> CGPoint {
    let offset = offsetForProposedOffset(proposedContentOffset)
    MSLogDebug("offset: \(offset)")
    return offset
  }

  /**
  targetContentOffsetForProposedContentOffset:withScrollingVelocity:

  - parameter proposedContentOffset: CGPoint
  - parameter velocity: CGPoint

  - returns: CGPoint
  */
  override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint
  {
    let offset = offsetForProposedOffset(proposedContentOffset)
    MSLogDebug("offset: \(offset)")
    return offset
  }

}
