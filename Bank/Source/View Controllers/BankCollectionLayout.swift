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

@objc protocol BankCollectionLayoutDelegate: UICollectionViewDelegate {
  optional func zoomedItemSize() -> CGSize
}

final class BankCollectionLayout: UICollectionViewLayout {

  /** init */
  override init() {
    super.init()
    registerClass(BlurDecoration.self, forDecorationViewOfKind: BlurDecoration.kind)
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    registerClass(BlurDecoration.self, forDecorationViewOfKind: BlurDecoration.kind)
  }

  static let defaultSize   = CGSize(width: 320, height: 38)
  static let thumbnailSize = CGSize(square: 100)

  var verticalSpacing:   CGFloat = 10
  var horizontalSpacing: CGFloat = 10

  typealias ViewingMode = Bank.ViewingMode

  var viewingMode: ViewingMode = .List {
    didSet {
      switch viewingMode {
        case .List:      itemSize = BankCollectionLayout.defaultSize
        case .Thumbnail: itemSize = BankCollectionLayout.thumbnailSize
        default: break
      }
      if oldValue != viewingMode { invalidateLayout() }
    }
  }

  private let blurPath = NSIndexPath(forRow: 0, inSection: 0)

  var zoomedItem: NSIndexPath? {
    didSet {
      MSLogDebug("zoomedItem = \(toString(zoomedItem))")
      if let collectionView = collectionView, indexPath = zoomedItem ?? oldValue {
//        storedAttributes[indexPath]?.zoomed = zoomedItem != nil
        collectionView.performBatchUpdates({
//          collectionView.deleteItemsAtIndexPaths([indexPath])
          self.invalidateLayout()
//          collectionView.insertItemsAtIndexPaths([indexPath])
          }, completion: nil)
      }
    }
  }

  private(set) var itemSize  = BankCollectionLayout.defaultSize

  private var itemsPerRow: Int { return viewingMode == .Thumbnail ? 3 : 1 }

  private var categorySectionHeight: CGFloat {
    return CGFloat(collectionView?.numberOfItemsInSection(0) ?? 0) * (BankCollectionLayout.defaultSize.height + verticalSpacing)
  }

  private var itemSectionHeight: CGFloat {
    return CGFloat(collectionView?.numberOfItemsInSection(1) ?? 0 / itemsPerRow) * (itemSize.height + verticalSpacing)
  }

  private var storedAttributes: [NSIndexPath:BankCollectionAttributes] = [:]

  /** prepareLayout */
  override func prepareLayout() {

    storedAttributes.removeAll(keepCapacity: true)

    let categoryCount = collectionView?.numberOfItemsInSection(0) ?? 0
    let itemCount     = collectionView?.numberOfItemsInSection(1) ?? 0
    let indexPaths = (zip(0..<categoryCount, 0) + zip(0..<itemCount, 1)).map { NSIndexPath(forRow: $0, inSection: $1) }

    apply(indexPaths) { self.storedAttributes[$0] = (self.layoutAttributesForItemAtIndexPath($0) as! BankCollectionAttributes) }

  }

  /**
  indexPathsToInsertForDecorationViewOfKind:

  :param: elementKind String

  :returns: [AnyObject]
  */
  override func indexPathsToInsertForDecorationViewOfKind(elementKind: String) -> [AnyObject] {
    return zoomedItem != nil ? [blurPath] : []
  }

  /**
  indexPathsToDeleteForDecorationViewOfKind:

  :param: elementKind String

  :returns: [AnyObject]
  */
  override func indexPathsToDeleteForDecorationViewOfKind(elementKind: String) -> [AnyObject] {
    return [blurPath]
  }

  /**

  layoutAttributesForElementsInRect:

  :param: rect CGRect

  :returns: [AnyObject]?

  */
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
    var attributes = filter(storedAttributes.values) { $0.frame.intersects(rect) }
    if zoomedItem != nil {
      let blurAttributes = layoutAttributesForDecorationViewOfKind(BlurDecoration.kind, atIndexPath: blurPath)
        as! BankCollectionAttributes
      attributes.append(blurAttributes)
    }
    return attributes
  }

  /**
  layoutAttributesForDecorationViewOfKind:atIndexPath:

  :param: elementKind String
  :param: indexPath NSIndexPath

  :returns: UICollectionViewLayoutAttributes!
  */
  override func layoutAttributesForDecorationViewOfKind(elementKind: String,
                                             atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes!
  {
    let attributes = BankCollectionAttributes(forDecorationViewOfKind: BlurDecoration.kind, withIndexPath: indexPath)
    attributes.frame = collectionView?.bounds ?? CGRect.zeroRect
    attributes.blurStyle = .Dark
    attributes.zIndex = 50
    return attributes
  }

  /**
  layoutAttributesForItemAtIndexPath:

  :param: indexPath NSIndexPath

  :returns: UICollectionViewLayoutAttributes!
  */
  override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
    let attributes = BankCollectionAttributes(forCellWithIndexPath: indexPath)
    switch indexPath.section {
    case 1:
      attributes.size = itemSize
      attributes.frame.origin.x =
        CGFloat(indexPath.row % itemsPerRow) * (itemSize.width + horizontalSpacing)
      attributes.frame.origin.y =
        CGFloat(indexPath.row / itemsPerRow) * (itemSize.height + verticalSpacing) + max(categorySectionHeight, verticalSpacing)
      break
    default:
      attributes.size = BankCollectionLayout.defaultSize
      attributes.frame.origin.x = 0
      attributes.frame.origin.y = CGFloat(indexPath.row) * (BankCollectionLayout.defaultSize.height + verticalSpacing)
      break
    }
    attributes.viewingMode = viewingMode
    attributes.zoomed = zoomedItem == indexPath
    if attributes.zoomed {
      attributes.size = (collectionView?.delegate as? BankCollectionLayoutDelegate)?.zoomedItemSize?() ?? attributes.size
      attributes.center = collectionView?.bounds.center ?? CGPoint.zeroPoint
      attributes.zIndex = 100
    }
    return attributes
  }

  /**
  collectionViewContentSize

  :returns: CGSize
  */
  override func collectionViewContentSize() -> CGSize {
    return CGSize(width: UIScreen.mainScreen().bounds.width, height: categorySectionHeight + itemSectionHeight + verticalSpacing)
  }

  /**
  layoutAttributeClass

  :returns: AnyClass
  */
  override class func layoutAttributesClass() -> AnyClass { return BankCollectionAttributes.self }

  /**
  initialLayoutAttributesForAppearingDecorationElementOfKind:atIndexPath:

  :param: elementKind String
  :param: indexPath NSIndexPath

  :returns: UICollectionViewLayoutAttributes?
  */
  override func initialLayoutAttributesForAppearingDecorationElementOfKind(elementKind: String,
    atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?
  {
    MSLogDebug("")
    return layoutAttributesForDecorationViewOfKind(elementKind, atIndexPath: indexPath)
  }

  /**
  finalLayoutAttributesForDisappearingDecorationElementOfKind:atIndexPath:

  :param: elementKind String
  :param: indexPath NSIndexPath

  :returns: UICollectionViewLayoutAttributes?
  */
  override func finalLayoutAttributesForDisappearingDecorationElementOfKind(elementKind: String,
    atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?
  {
    MSLogDebug("")
    let attributes = layoutAttributesForDecorationViewOfKind(elementKind, atIndexPath: indexPath)
    attributes.hidden = true
    return attributes
  }
  

}
