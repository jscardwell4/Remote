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

  // MARK: - Internally used properties
  private var storedAttributes: AttributesIndex = [:] /// Holds all the calculated layout attributes
  private var visibleRect = CGRect.zeroRect           /// Frame used during calculations
  private var cellWidths: [CGFloat] = []              /// Cache of widths provided by `delegate`
  private var cellHeight: CGFloat = 0                 /// Caches `itemHeight` provided by `delegate`
  private var contentSize = CGSize.zeroSize           /// Size calculated for the content
  private var cellPadding: CGFloat = 8                /// Padding value provided by `delegate`
  private var rawFrames: [CGRect] = []                /// Cache of cell frames without any transforms applied
  private var contentPadding: CGFloat = 0             /// Space before and after the first and last cells
  private var contentOffsetAdjustment: CGFloat = 0    /// Difference between where the offset is and where we need it to be

  // MARK: - UICollectionViewLayout method overrides

  override var description: String {
    var result = super.description + "\n"
    result += "visibleRect = \(visibleRect)\n"
    result += "cellWidths = \(cellWidths)\n"
    result += "cellHeight = \(cellHeight)\n"
    result += "contentSize = \(contentSize)\n"
    result += "cellPadding = \(cellPadding)\n"
    result += "rawFrames = \(rawFrames)\n"
    result += "contentPadding = \(contentPadding)\n"
    let attributesDescriptions = storedAttributes.values.map {
      attributes -> String in
      return "\t{\n\t\t" + "\n\t\t".join(
        "item: \(attributes.indexPath.item)",
        "frame: \(attributes.frame)",
        "transform: \(attributes.transform)",
        "transform3D: {\n\(NSStringFromCATransform3D(attributes.transform3D).indentedBy(8))\n\t\t}",
        "alpha: \(attributes.alpha)",
        "hidden: \(attributes.hidden)"
        ) + "\n\t}"
    }
    result += "storedAttributes = {\n\t" + ",\n".join(attributesDescriptions) + "\n}"
    return result
  }

  /** clearCache */
  private func clearCache() {
    visibleRect = CGRect.zeroRect
    cellWidths.removeAll(keepCapacity: true)
    cellHeight = 0
    contentSize = CGSize.zeroSize
    cellPadding = 0
    rawFrames.removeAll(keepCapacity: true)
    contentPadding = 0
    contentOffsetAdjustment = 0
  }

  /**
  shouldInvalidateLayoutForBoundsChange:

  - parameter newBounds: CGRect

  - returns: Bool
  */
  override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool { return true }

  /** prepareLayout */
  override func prepareLayout() {

    guard let delegate = delegate, collectionView = collectionView else {
      MSLogDebug("Missing delegate, collectionView or both … clearing cache and skipping prep")
      clearCache()
      return
    }

    let itemCount = collectionView.numberOfItemsInSection(0)

    guard delegate.itemWidths.count == itemCount else {
      MSLogDebug("delegate.itemWidths.count != itemCount … clearing cache and skipping prep")
      clearCache()
      return
    }

    guard delegate.itemWidths.count > 0 else {
      MSLogDebug("collection is empty … clearing cache and skipping prep")
      clearCache()
      return
    }

    guard (0 ..< itemCount).contains(delegate.selection) else {
      MSLogDebug("no valid selection, really no point in performing calculations now … skipping prep")
      return
    }

    cellPadding = delegate.itemPadding
    visibleRect = collectionView.bounds
    cellHeight = delegate.itemHeight
    cellWidths = delegate.itemWidths

    let sumOfWidths = cellWidths.sum
    let sumOfCellPadding = CGFloat(itemCount - 1) * cellPadding

    contentPadding = (sumOfWidths + sumOfCellPadding) / 2
    contentSize = CGSize(width: (sumOfWidths + sumOfCellPadding) * 2, height: cellHeight)

    rawFrames.removeAll(keepCapacity: true)
    var x = contentPadding
    for width in cellWidths {
      rawFrames.append(CGRect(x: x, y: (visibleRect.height - cellHeight) / 2, width: width, height: cellHeight))
      x += width + cellPadding
    }

    if !(collectionView.decelerating || collectionView.tracking || collectionView.dragging) {
      contentOffsetAdjustment = rawFrames[delegate.selection].midX - visibleRect.midX
      if contentOffsetAdjustment != 0 {
        var offset = visibleRect.origin
        offset.x += contentOffsetAdjustment
        collectionView.setContentOffset(offset, animated: false)
      }
    } else { contentOffsetAdjustment = 0 }

    storedAttributes = AttributesIndex(
      (0 ..< itemCount).map { NSIndexPath(forRow: $0, inSection: 0) } .map {
        ($0, self.layoutAttributesForItemAtIndexPath($0)!)
      }
    )

//    MSLogDebug(description)
  }

  /**
  collectionViewContentSize

  - returns: CGSize
  */
  override func collectionViewContentSize() -> CGSize { return contentSize }

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
    guard indexPath.item < rawFrames.count else { return nil }

    let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
    attributes.frame = rawFrames[indexPath.item]

    applyTransformToAttributes(attributes)

    return attributes
  }

  /**
  applyTransformToAttributes:

  - parameter attributes: UICollectionViewLayoutAttributes
  */
  private func applyTransformToAttributes(attributes: UICollectionViewLayoutAttributes) {
    guard !visibleRect.isEmpty, let selection = delegate?.selection, editing = delegate?.editing else { return }

    let distance = attributes.frame.midX - visibleRect.midX - contentOffsetAdjustment
    let w = visibleRect.width / 2

    let currentAngle = distance / w
    MSLogDebug("currentAngle = \(currentAngle), distance / w = \(distance / w)")

    var transform = CATransform3DIdentity
    transform = CATransform3DTranslate(transform, -distance, 0, -w)
    transform = CATransform3DRotate(transform, currentAngle, 0, 1, 0)
    transform = CATransform3DTranslate(transform, 0, 0, w)

    attributes.transform3D = transform
    attributes.alpha = fabs(currentAngle) < CGFloat(M_PI_2) ? 1.0 : 0.0
    attributes.hidden = !editing && selection != attributes.indexPath.item
  }

  /**
  offsetForProposedOffset:

  - parameter offset: CGPoint

  - returns: CGPoint
  */
  private func offsetForProposedOffset(offset: CGPoint) -> CGPoint {
    guard let idx = indexOfItemAtOffset(offset) else { return offset }
    return offsetForItemAtIndex(idx) ?? offset
  }

  /**
  Returns the content offset for the center of a given cell

  - parameter index: Int

  - returns: CGPoint
  */
  func offsetForItemAtIndex(index: Int) -> CGPoint? {
    guard let attributes = storedAttributes[NSIndexPath(forItem: index, inSection: 0)] where !visibleRect.isEmpty else { return nil }
    return CGPoint(x: attributes.frame.midX - visibleRect.width / 2, y: 0)
  }

  /**
  indexOfItemAtOffset:

  - parameter offset: CGPoint

  - returns: Int?
  */
  func indexOfItemAtOffset(offset: CGPoint) -> Int? {

    let offsets = (0 ..< storedAttributes.count).flatMap {self.offsetForItemAtIndex($0)}
    guard offsets.count == storedAttributes.count else { return nil }

    // Check for an exact match
    if let idx = offsets.indexOf(offset) { return idx }

    // Otherwise use a switch to rule out base cases
    switch offsets.count {
      case 0:                                       // No items means no index
        return nil
      case 1, _ where offsets[0].x > offset.x:      // Single-item array or the first item is greater than the offset
        return 0
      case let c where offsets[c - 1].x < offset.x: // Offset is greater than the last item
        return c - 1
      default:                                      // Could be one of two choices, return the nearest of the two to the offset
        guard let i = offsets.indexOf({$0.x > offset.x}) else { return nil }
        let d1 = abs(offsets[i].x - offset.x)
        let d2 = abs(offsets[i - 1].x - offset.x)
        return d1 < d2 ? i : i - 1
    }
  }

  /**
  targetContentOffsetForProposedContentOffset:

  - parameter proposedContentOffset: CGPoint

  - returns: CGPoint
  */
  override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint) -> CGPoint {
    return offsetForProposedOffset(proposedContentOffset)
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
    return offsetForProposedOffset(proposedContentOffset)
  }

}
