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

  private func setup() {
    backgroundColor = UIColor.clearColor()
    opaque = false
    let blur = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
    blur.setTranslatesAutoresizingMaskIntoConstraints(false)
    blur.backgroundColor = UIColor.clearColor()
    blur.opaque = false
    blur.contentView.backgroundColor = UIColor.clearColor()
    blur.contentView.opaque = false
    addSubview(blur)
    constrain(𝗩|blur|𝗩, 𝗛|blur|𝗛)
  }
  override init(frame: CGRect) { super.init(frame: frame); setup() }
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder); setup() }
}

@objc public protocol ZoomingCollectionViewLayoutDelegate: UICollectionViewDelegate {
  optional func sizeForZoomedItemAtIndexPath(indexPath: NSIndexPath) -> CGSize
}

public class ZoomingCollectionViewLayout: UICollectionViewLayout {

  /** init */
  override public init() {
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

  // MARK: - Item scale

  /** An enumeration for specifying the scale of the layout's items */
  public struct ItemScale: Printable, Equatable {

    /** An enumeration for specifying the width of the scale value */
    public enum Width: Float, Printable {
      case OneAcross = 1, TwoAcross, ThreeAcross, FourAcross, FiveAcross, SixAcross, SevenAcross, EightAcross

      public var description: String {
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

      public static var minScale: Width { return .EightAcross }
      public static var maxScale: Width { return .OneAcross }
      public static var step: Float { return 1/(minScale.rawValue - 1) }

      public var normalized: Float { return Width.step * (Width.minScale.rawValue - rawValue) }
      public var width: CGFloat { return  UIScreen.mainScreen().bounds.width/CGFloat(rawValue) }

      public var interval: ClosedInterval<Float> {
        let halfStep = half(Width.step)
        let value = normalized
        return ClosedInterval(max(value - halfStep, 0), min(value + halfStep, 1))
      }

      public static var all: [Width] {
        return [.OneAcross, .TwoAcross, .ThreeAcross, .FourAcross, .FiveAcross, .SixAcross, .SevenAcross, .EightAcross]
      }

      public init(rawValue: Float) {
        if let layout = findFirst(Width.all, {$0.interval.contains(rawValue)}) { self = layout }
        else if Width.minScale.rawValue > rawValue { self = Width.minScale }
        else { self = Width.maxScale }
      }
    }

    public var square = true
    private var _height: CGFloat = 0
    public var height: CGFloat { get { return square ? width.width : _height } set { _height = newValue } }
    public var width: Width = .OneAcross
    public var size: CGSize { return CGSize(width: width.width, height: height) }

    public var description: String { return "(\(width.width)(\(width)), \(height))" }

    public init(width w: Width, height h: CGFloat? = nil) {
      width = w
      if h != nil { height = h!; square = false } else { square = true }
    }
  }

  public var itemScale = ItemScale(width: .OneAcross) { didSet { if oldValue != itemScale { invalidateLayout() } } }

  private var itemScalesPerSection: [Int:ItemScale] = [:]

  /**
  setItemScale:forSection:

  :param: scale ItemScale
  :param: section Int
  */
  public func setItemScale(scale: ItemScale, forSection section: Int) {
    let oldValue = itemScalesPerSection.updateValue(scale, forKey: section)
    if oldValue != scale { invalidateLayout() }
  }

  /**
  itemScaleForSection:

  :param: section Int

  :returns: ItemScale
  */
  public func itemScaleForSection(section: Int) -> ItemScale { return itemScalesPerSection[section] ?? itemScale }

  /**
  itemsPerRowInSection:

  :param: section Int

  :returns: Int
  */
  public func itemsPerRowInSection(section: Int) -> Int { return Int(itemScaleForSection(section).width.rawValue) }

  // MARK: - Preperation

  /**
  heightForSection:

  :param: section Int

  :returns: CGFloat
  */
  public func heightForSection(section: Int) -> CGFloat {
    if let collectionView = collectionView {
      let itemScale = itemScaleForSection(section)
      let rowCount = collectionView.numberOfItemsInSection(section) / Int(itemScale.width.rawValue)
      return CGFloat(rowCount) * itemScale.height
    } else { return 0 }
  }

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
    if let collectionView = collectionView {
      storedAttributes = AttributesIndex(
        flatMap(0 ..< collectionView.numberOfSections()) {
          s in map(0 ..< collectionView.numberOfItemsInSection(s)) {
            r in NSIndexPath(forRow: r, inSection: s)
          }
        } .map {
          ($0, self.layoutAttributesForItemAtIndexPath($0))
        }
      )
    }
  }

  /**
  numberOfItemsBeforeSection:

  :param: section Int

  :returns: Int
  */
  private func numberOfItemsBeforeSection(section: Int) -> Int {
    if let collectionView = collectionView where section < collectionView.numberOfSections() {
      return reduce(0 ..< section, 0) {$0 + collectionView.numberOfItemsInSection($1)}
    } else {
      return 0
    }
  }

  /**
  collectionViewContentSize

  :returns: CGSize
  */
  override public func collectionViewContentSize() -> CGSize {
    let w = reduce(storedAttributes.values, 0, {max($0, $1.frame.maxX)})
    let h = reduce(storedAttributes.values, 0, {max($0, $1.frame.maxY)})
    return CGSize(width: w, height: h)
  }

  private typealias AttributesIndex = OrderedDictionary<NSIndexPath, UICollectionViewLayoutAttributes!>

  private var storedAttributes: AttributesIndex = [:]

  // MARK: - Zooming

  public enum ZoomState: Printable {
    case Default, ZoomingStage1, ZoomingStage2, UnzoomingStage1, UnzoomingStage2
    public var description: String {
      switch self {
        case .Default:         return "Default"
        case .ZoomingStage1:   return "ZoomingStage1"
        case .ZoomingStage2:   return "ZoomingStage2"
        case .UnzoomingStage1: return "UnzoomingStage1"
        case .UnzoomingStage2: return "UnzoomingStage2"
      }
    }
  }

  public private(set) var zoomState = ZoomState.Default

  public var zoomedItem: NSIndexPath? {
    didSet { collectionView?.performBatchUpdates({ self.invalidateLayout() }, completion: nil) }
  }

  public static let SupplementaryZoomKind = "SupplementaryZoomKind"

  // MARK: - Layout attributes

  /**
  layoutAttributesForElementsInRect:

  :param: rect CGRect

  :returns: [AnyObject]?
  */
  override public func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
    var result = filter(storedAttributes.values) { $0.frame.intersects(rect) }
    if zoomedItem != nil {
      result.append(layoutAttributesForDecorationViewOfKind(BlurDecoration.kind,
                                                atIndexPath: zoomedItem!))
      result.append(layoutAttributesForSupplementaryViewOfKind(self.dynamicType.SupplementaryZoomKind, atIndexPath: zoomedItem!))
    }
    return result
  }

  // MARK: Blur decoration

  /**
  layoutAttributesForDecorationViewOfKind:atIndexPath:

  :param: elementKind String
  :param: indexPath NSIndexPath

  :returns: UICollectionViewLayoutAttributes!
  */
  override public func layoutAttributesForDecorationViewOfKind(elementKind: String,
    atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes!
  {
    let attributesClass = self.dynamicType.layoutAttributesClass() as! UICollectionViewLayoutAttributes.Type
    let attributes = attributesClass(forDecorationViewOfKind: BlurDecoration.kind, withIndexPath: indexPath)
    attributes.frame = collectionView?.bounds ?? CGRect.zeroRect
    attributes.zIndex = 50
    return attributes
  }

  /**
  layoutAttributesForSupplementaryViewOfKind:atIndexPath:

  :param: elementKind String
  :param: indexPath NSIndexPath

  :returns: UICollectionViewLayoutAttributes!
  */
  public override func layoutAttributesForSupplementaryViewOfKind(elementKind: String,
    atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes!
  {
    let attributesClass = self.dynamicType.layoutAttributesClass() as! UICollectionViewLayoutAttributes.Type
    let attributes = attributesClass(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
    attributes.frame = collectionView?.bounds ?? CGRect.zeroRect
    attributes.zIndex = 100
    return attributes
  }

  // MARK: Items

  /**
  layoutAttributesForItemAtIndexPath:

  :param: indexPath NSIndexPath

  :returns: UICollectionViewLayoutAttributes!
  */
  override public func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
    let attributesClass = self.dynamicType.layoutAttributesClass() as! UICollectionViewLayoutAttributes.Type
    let attributes = attributesClass(forCellWithIndexPath: indexPath)

    let yOffset = reduce(0 ..< indexPath.section, CGFloat(0)) {$0 + self.heightForSection($1)}

    let itemsPerRow = itemsPerRowInSection(indexPath.section)
    let col = CGFloat(indexPath.row % itemsPerRow)
    let row = CGFloat(indexPath.row / itemsPerRow)
    let (w, h) = itemScaleForSection(indexPath.section).size.unpack()

    attributes.frame = CGRect(x: col * w, y: row * h + yOffset, width: w, height: h)

    return attributes
  }

}

// MARK: - Support functions

/**
Equatable support for `ZoomingCollectionViewLayout.ItemScale`

:param: lhs ZoomingCollectionViewLayout.ItemScale
:param: rhs ZoomingCollectionViewLayout.ItemScale

:returns: Bool
*/
public func ==(lhs: ZoomingCollectionViewLayout.ItemScale, rhs: ZoomingCollectionViewLayout.ItemScale) -> Bool {
  return lhs.width == rhs.width && lhs.height == rhs.height
}