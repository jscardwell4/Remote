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

  private typealias AttributesIndex = OrderedDictionary<NSIndexPath, UICollectionViewLayoutAttributes>

  weak var delegate: InlinePickerView?

  private var storedAttributes: AttributesIndex = [:]
  private var width: CGFloat = 0.0
  private var midX: CGFloat = 0.0
  private var maxAngle: CGFloat = 0.0
  private var cellWidths: [CGFloat] = []
  private var cellHeight: CGFloat = 44.0
  private var cellPadding: CGFloat = 8.0

  override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool { return true }

  /** prepareLayout */
  override func prepareLayout() {
    if let collectionView = collectionView, delegate = delegate {

      let sizes = delegate.cellSizes
      cellWidths = sizes.map {$0.width}
      cellHeight = (sizes.map{$0.height} + [delegate.cellHeight]).maxElement()!
      cellPadding = delegate.cellPadding

      let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
      midX = visibleRect.midX
      width = visibleRect.width / 2
      maxAngle = CGFloat(M_PI_2)
      storedAttributes = AttributesIndex(
        (0 ..< collectionView.numberOfItemsInSection(0)).map { NSIndexPath(forRow: $0, inSection: 0) } .map {
          ($0, self.layoutAttributesForItemAtIndexPath($0)!)
        }
      )

      MSLogDebug("storedAttributes = \(storedAttributes)")
    }
  }

  /**
  collectionViewContentSize

  - returns: CGSize
  */
  override func collectionViewContentSize() -> CGSize {
    return CGSize(width: storedAttributes.values.reduce(0, combine: {max($0, $1.frame.maxX)}), height: cellHeight)
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
    let padding = cellPadding * CGFloat(indexPath.item)
    let xOffset = widths.sum + padding
    attributes.frame = CGRect(x: xOffset, y: 0, width: cellWidths[indexPath.item], height: cellHeight)

    let distance = CGRectGetMidX(attributes.frame) - midX
    let currentAngle = maxAngle * distance / width / CGFloat(M_PI_2)
    var transform = CATransform3DIdentity
    transform = CATransform3DTranslate(transform, -distance, 0, -width)
    transform = CATransform3DRotate(transform, currentAngle, 0, 1, 0)
    transform = CATransform3DTranslate(transform, 0, 0, width)
    attributes.transform3D = transform
    attributes.alpha = fabs(currentAngle) < maxAngle ? 1.0 : 0.0

    return attributes
  }

}
