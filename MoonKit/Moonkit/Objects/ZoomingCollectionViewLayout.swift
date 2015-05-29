//
//  ZoomingCollectionViewLayout.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/28/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import UIKit

class BlurDecoration: UICollectionReusableView {

  static let kind = "Blur"

  private weak var blur: UIVisualEffectView!

  private func createBlurWithStyle(style: UIBlurEffectStyle) {
    self.blur?.removeFromSuperview()
    let blur = UIVisualEffectView(effect: UIBlurEffect(style: style))
    blur.setTranslatesAutoresizingMaskIntoConstraints(false)
    addSubview(blur)
    constrain(𝗩|blur|𝗩, 𝗛|blur|𝗛)
    self.blur = blur
  }

  private func setup() {
    backgroundColor = UIColor.clearColor()
    createBlurWithStyle(.Dark)
  }
  override init(frame: CGRect) { super.init(frame: frame); setup() }
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder); setup() }
}

@objc protocol ZoomingCollectionViewLayoutDelegate: UICollectionViewDelegate {
  optional func sizeForZoomedItemAtIndexPath(indexPath: NSIndexPath) -> CGSize
}

public class ZoomingCollectionViewLayout: UICollectionViewLayout {

  /** init */
  override init() {
    super.init()
    registerClass(BlurDecoration.self, forDecorationViewOfKind: BlurDecoration.kind)
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required public init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    registerClass(BlurDecoration.self, forDecorationViewOfKind: BlurDecoration.kind)
  }

  /** An enumeration for specifying the scale of the layout's items */
  enum ItemScale: Float, Printable {
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

  :param: updateItems [AnyObject]!
  */
  override public func prepareForCollectionViewUpdates(updateItems: [AnyObject]!) {
    switch zoomState {
    case .ZoomingStage2:   zoomState = .ZoomingStage1
    case .UnzoomingStage2: zoomState = .UnzoomingStage1
    default:               break
    }
    super.prepareForCollectionViewUpdates(updateItems)
  }


  /** prepareLayout */
  override public func prepareLayout() {
    if let count = collectionView?.numberOfItemsInSection(0) {
      itemCount = count
      storedAttributes.removeAll(keepCapacity: true)
      apply(map(0..<count){NSIndexPath(forRow: $0, inSection: 0)}) {
        self.storedAttributes[$0] = self.layoutAttributesForItemAtIndexPath($0)
      }

    }
  }

  /**
  collectionViewContentSize

  :returns: CGSize
  */
  override public func collectionViewContentSize() -> CGSize {
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

  :param: elementKind String

  :returns: [AnyObject]
  */
  override public func indexPathsToInsertForDecorationViewOfKind(elementKind: String) -> [AnyObject] {
    return zoomingItem != nil ? [NSIndexPath(forRow: itemCount, inSection: 0)] : []
  }

  /**
  indexPathsToDeleteForDecorationViewOfKind:

  :param: elementKind String

  :returns: [AnyObject]
  */
  override public func indexPathsToDeleteForDecorationViewOfKind(elementKind: String) -> [AnyObject] {
    return unzoomingItem != nil ? [NSIndexPath(forRow: itemCount, inSection: 0)] : []
  }

  /**
  layoutAttributesForElementsInRect:

  :param: rect CGRect

  :returns: [AnyObject]?
  */
  override public func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
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

  :param: elementKind String
  :param: indexPath NSIndexPath

  :returns: UICollectionViewLayoutAttributes!
  */
  override public func layoutAttributesForDecorationViewOfKind(elementKind: String,
    atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes!
  {
    let attributes = UICollectionViewLayoutAttributes(forDecorationViewOfKind: BlurDecoration.kind, withIndexPath: indexPath)
    attributes.frame = collectionView?.bounds ?? CGRect.zeroRect
    attributes.zIndex = 50
    return attributes
  }

  /**
  defaultAttributesForItemAtIndexPath:

  :param: indexPath NSIndexPath

  :returns: UICollectionViewLayoutAttributes
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

  :param: attr UICollectionViewLayoutAttributes

  :returns: UICollectionViewLayoutAttributes
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
    return (collectionView?.delegate as? ZoomingCollectionViewLayoutDelegate)?.sizeForZoomedItemAtIndexPath?(indexPath)
      ?? ItemScale.maxScale.itemSize
  }

  /**
  layoutAttributesForItemAtIndexPath:

  :param: indexPath NSIndexPath

  :returns: UICollectionViewLayoutAttributes!
  */
  override public func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
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

  :param: indexPath NSIndexPath

  :returns: UICollectionViewLayoutAttributes?
  */
  override public func initialLayoutAttributesForAppearingItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?
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

  :param: elementKind String
  :param: indexPath NSIndexPath

  :returns: UICollectionViewLayoutAttributes?
  */
  override public func initialLayoutAttributesForAppearingDecorationElementOfKind(elementKind: String,
    atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?
  {
    return layoutAttributesForDecorationViewOfKind(elementKind, atIndexPath: indexPath)
  }

  /**
  finalLayoutAttributesForDisappearingDecorationElementOfKind:atIndexPath:

  :param: elementKind String
  :param: indexPath NSIndexPath

  :returns: UICollectionViewLayoutAttributes?
  */
  override public func finalLayoutAttributesForDisappearingDecorationElementOfKind(elementKind: String,
    atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?
  {
    return layoutAttributesForDecorationViewOfKind(elementKind, atIndexPath: indexPath)
  }

  /**
  finalLayoutAttributesForDisappearingItemAtIndexPath:

  :param: itemIndexPath NSIndexPath

  :returns: UICollectionViewLayoutAttributes?
  */
  override public func finalLayoutAttributesForDisappearingItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
    let attributes: UICollectionViewLayoutAttributes?
    switch indexPath {
    case unzoomingItem: attributes = zoomify(defaultAttributesForItemAtIndexPath(indexPath))
    case zoomingItem:   attributes = defaultAttributesForItemAtIndexPath(indexPath)
    default:            attributes = nil
    }
    return attributes
  }
  
}
