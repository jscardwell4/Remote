//
//  PhotoCollectionLayout.swift
//  Remote
//
//  Created by Jason Cardwell on 5/24/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import UIKit
import MoonKit

@objc protocol PhotoCollectionLayoutDelegate: UICollectionViewDelegate {
  optional func sizeForZoomedItemAtIndexPath(indexPath: NSIndexPath) -> CGSize
}

class PhotoCollectionLayout: UICollectionViewLayout {

  /** init */
  override init() {
    super.init()
    registerClass(BlurDecoration.self, forDecorationViewOfKind: BlurDecoration.kind)
  }

  /**
  init:

  - parameter aDecoder: NSCoder
  */
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    registerClass(BlurDecoration.self, forDecorationViewOfKind: BlurDecoration.kind)
  }

  /** An enumeration for specifying the scale of the layout's items */
  enum ItemScale: Float, CustomStringConvertible {
    case OneAcross = 1, TwoAcross, ThreeAcross, FourAcross, FiveAcross, SixAcross, SevenAcross, EightAcross

    static var minScale: ItemScale { return .EightAcross }
    static var maxScale: ItemScale { return .OneAcross }
    static var step: Float { return 1/(minScale.rawValue - 1) }

    var itemSize: CGSize { return CGSize(square: UIScreen.mainScreen().bounds.width/CGFloat(rawValue)) }
    var normalized: Float { return ItemScale.step * (ItemScale.minScale.rawValue - rawValue) }

    var interval: ClosedInterval<Float> {
      let halfStep = half(ItemScale.step)
      let value = normalized
      return ClosedInterval(max(value - halfStep, 0), min(value + halfStep, 1))
    }

    static var all: [ItemScale] {
      return [.OneAcross, .TwoAcross, .ThreeAcross, .FourAcross, .FiveAcross, .SixAcross, .SevenAcross, .EightAcross]
    }

    init(rawValue: Float) {
      if let layout = findFirst(ItemScale.all, {$0.interval.contains(rawValue)}) { self = layout }
      else if ItemScale.minScale.rawValue > rawValue { self = ItemScale.minScale }
      else { self = ItemScale.maxScale }
    }

    var description: String {
      switch self {
        case .OneAcross:   return "OneAcross"
        case .TwoAcross:   return "TwoAcross"
        case .ThreeAcross: return "ThreeAcross"
        case .FourAcross:  return "FourAcross"
        case .FiveAcross:  return "FiveAcross"
        case .SixAcross:   return "SixAcross"
        case .SevenAcross: return "SevenAcross"
        case .EightAcross: return "EightAcross"
      }
    }
  }

  var itemScale = ItemScale.minScale { didSet { if oldValue != itemScale { invalidateLayout() } } }

  private var itemCount = 0
  private var itemsPerRow: Int { return Int(itemScale.rawValue) }

  /**
  prepareForCollectionViewUpdates:

  - parameter updateItems: [AnyObject]!
  */
  override func prepareForCollectionViewUpdates(updateItems: [UICollectionViewUpdateItem]) {
    switch zoomState {
      case .ZoomingStage2:   zoomState = .ZoomingStage1
      case .UnzoomingStage2: zoomState = .UnzoomingStage1
      default:               break
    }
    super.prepareForCollectionViewUpdates(updateItems)
  }


  /** prepareLayout */
  override func prepareLayout() {
    if let count = collectionView?.numberOfItemsInSection(0) {
      itemCount = count
      storedAttributes.removeAll(keepCapacity: true)
      apply((0..<count).map{NSIndexPath(forRow: $0, inSection: 0)}) {
        self.storedAttributes[$0] = self.layoutAttributesForItemAtIndexPath($0)
      }

    }
  }

  /**
  collectionViewContentSize

  - returns: CGSize
  */
  override func collectionViewContentSize() -> CGSize {
    let w = itemScale.itemSize.width * CGFloat(itemsPerRow)
    let h = ceil(CGFloat(itemCount) / CGFloat(itemsPerRow)) * itemScale.itemSize.height
    return CGSize(width: w, height: h)
  }

  typealias AttributesIndex = OrderedDictionary<NSIndexPath, UICollectionViewLayoutAttributes>

  private var storedAttributes: AttributesIndex = [:]

  private enum ZoomState { case Default, ZoomingStage1, ZoomingStage2, UnzoomingStage1, UnzoomingStage2 }

  private var zoomState = ZoomState.Default
  private var unzoomingItem: NSIndexPath? { didSet {  zoomState = unzoomingItem != nil ? .UnzoomingStage2 : .Default } }
  private var zoomingItem: NSIndexPath? { didSet { if zoomingItem != nil { zoomState = .ZoomingStage2 } } }

  var zoomedItem: NSIndexPath? {
    get { return zoomingItem }
    set {
      unzoomingItem = zoomingItem
      zoomingItem = newValue
      if let collectionView = collectionView, indexPath = zoomingItem ?? unzoomingItem {
        collectionView.performBatchUpdates({
          collectionView.deleteItemsAtIndexPaths([indexPath])
          collectionView.insertItemsAtIndexPaths([indexPath])
        }, completion: {_ in self.unzoomingItem = nil})
      }
    }
  }

  /**
  indexPathsToInsertForDecorationViewOfKind:

  - parameter elementKind: String

  - returns: [AnyObject]
  */
  override func indexPathsToInsertForDecorationViewOfKind(elementKind: String) -> [NSIndexPath] {
    return zoomingItem != nil ? [NSIndexPath(forRow: itemCount, inSection: 0)] : []
  }

  /**
  indexPathsToDeleteForDecorationViewOfKind:

  - parameter elementKind: String

  - returns: [AnyObject]
  */
  override func indexPathsToDeleteForDecorationViewOfKind(elementKind: String) -> [NSIndexPath] {
    return unzoomingItem != nil ? [NSIndexPath(forRow: itemCount, inSection: 0)] : []
  }

  /**
  layoutAttributesForElementsInRect:

  - parameter rect: CGRect

  - returns: [AnyObject]?
  */
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    let yToRow = {$0/self.itemScale.itemSize.height * CGFloat(self.itemsPerRow)}
    let minRow = Int(floor(yToRow(max(rect.minY, 0))))
    let maxRow = Int(ceil(yToRow(rect.maxY)))
    var result: [AnyObject]? = itemCount > minRow ? Array(storedAttributes.values.array[minRow..<min(maxRow, itemCount)]) : nil
    if zoomingItem != nil {
      result?.append(layoutAttributesForDecorationViewOfKind(BlurDecoration.kind,
                                                 atIndexPath: NSIndexPath(forRow: itemCount, inSection: 0)))
    }
    return result
  }

  /**
  layoutAttributesForDecorationViewOfKind:atIndexPath:

  - parameter elementKind: String
  - parameter indexPath: NSIndexPath

  - returns: UICollectionViewLayoutAttributes!
  */
  override func layoutAttributesForDecorationViewOfKind(elementKind: String,
                                            atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes!
  {
    let attributes = UICollectionViewLayoutAttributes(forDecorationViewOfKind: BlurDecoration.kind, withIndexPath: indexPath)
    attributes.frame = collectionView?.bounds ?? CGRect.zeroRect
    attributes.zIndex = 50
    return attributes
  }

  /**
  defaultAttributesForItemAtIndexPath:

  - parameter indexPath: NSIndexPath

  - returns: UICollectionViewLayoutAttributes
  */
  private func defaultAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes {
    let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
    let col = CGFloat(indexPath.row % itemsPerRow)
    let row = CGFloat(indexPath.row / itemsPerRow)
    let (w, h) = itemScale.itemSize.unpack()
    attributes.frame = CGRect(x: col * w, y: row * h, width: w, height: h)
    return attributes
  }

  /**
  zoomify:

  - parameter attr: UICollectionViewLayoutAttributes

  - returns: UICollectionViewLayoutAttributes
  */
  private func zoomify(attr: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    if let collectionView = collectionView {
      attr.size = zoomifiedSizeForIndexPath(attr.indexPath)
      attr.center = collectionView.bounds.center
      attr.zIndex = 100
    }
    return attr
  }

  private func zoomifiedSizeForIndexPath(indexPath: NSIndexPath) -> CGSize {
    return (collectionView?.delegate as? PhotoCollectionLayoutDelegate)?.sizeForZoomedItemAtIndexPath?(indexPath)
      ?? ItemScale.maxScale.itemSize
  }

  /**
  layoutAttributesForItemAtIndexPath:

  - parameter indexPath: NSIndexPath

  - returns: UICollectionViewLayoutAttributes!
  */
  override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
    let attributes: UICollectionViewLayoutAttributes
    switch indexPath {
      case zoomingItem where zoomState == .ZoomingStage2, unzoomingItem where zoomState == .ZoomingStage1:
        attributes = zoomify(defaultAttributesForItemAtIndexPath(indexPath))
      default:
        attributes = defaultAttributesForItemAtIndexPath(indexPath)
    }
    return attributes
  }

  /**
  initialLayoutAttributesForAppearingItemAtIndexPath:

  - parameter indexPath: NSIndexPath

  - returns: UICollectionViewLayoutAttributes?
  */
  override func initialLayoutAttributesForAppearingItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?
  {
    let attributes: UICollectionViewLayoutAttributes?
    switch indexPath {
      case unzoomingItem: attributes = defaultAttributesForItemAtIndexPath(indexPath)
      case zoomingItem:   attributes = zoomify(defaultAttributesForItemAtIndexPath(indexPath))
      default:            attributes = nil
    }
    return attributes
  }

  /**
  initialLayoutAttributesForAppearingDecorationElementOfKind:atIndexPath:

  - parameter elementKind: String
  - parameter indexPath: NSIndexPath

  - returns: UICollectionViewLayoutAttributes?
  */
  override func initialLayoutAttributesForAppearingDecorationElementOfKind(elementKind: String,
    atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?
  {
    return layoutAttributesForDecorationViewOfKind(elementKind, atIndexPath: indexPath)
  }

  /**
  finalLayoutAttributesForDisappearingDecorationElementOfKind:atIndexPath:

  - parameter elementKind: String
  - parameter indexPath: NSIndexPath

  - returns: UICollectionViewLayoutAttributes?
  */
  override func finalLayoutAttributesForDisappearingDecorationElementOfKind(elementKind: String,
    atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?
  {
    return layoutAttributesForDecorationViewOfKind(elementKind, atIndexPath: indexPath)
  }

  /**
  finalLayoutAttributesForDisappearingItemAtIndexPath:

  - parameter itemIndexPath: NSIndexPath

  - returns: UICollectionViewLayoutAttributes?
  */
  override func finalLayoutAttributesForDisappearingItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
    let attributes: UICollectionViewLayoutAttributes?
    switch indexPath {
      case unzoomingItem: attributes = zoomify(defaultAttributesForItemAtIndexPath(indexPath))
      case zoomingItem:   attributes = defaultAttributesForItemAtIndexPath(indexPath)
      default:            attributes = nil
    }
    return attributes
  }

}
