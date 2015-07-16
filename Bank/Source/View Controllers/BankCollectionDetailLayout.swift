//
//  BankCollectionDetailLayout.swift
//  Remote
//
//  Created by Jason Cardwell on 6/02/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankCollectionDetailLayout: UICollectionViewLayout {

  typealias HeaderType = BankCollectionDetailSectionHeader.Identifier
  typealias ItemType = BankCollectionDetailCell.Identifier

  weak var delegate: BankCollectionDetailController?

  /** prepareLayout */
  override func prepareLayout() {
    guard let collectionView = collectionView, delegate = delegate else { clearCache(); return }


    headerTypes = delegate.headerTypes

    let sectionCount = collectionView.numberOfSections()

    itemTypes = (0 ..< sectionCount).map {delegate.itemTypesInSection($0)}
    let itemCounts = (0 ..< sectionCount).map {self.itemTypes[$0].count}
    itemHeights = itemTypes.map { $0.map { self.heightForItemType($0) } }

    let w = UIScreen.mainScreen().bounds.width
    let h = (0 ..< headerTypes.count).reduce(verticalSpacing) {$0 + self.heightForSection($1)}
    contentSize = CGSize(width: w, height: h)

    storedAttributes = AttributesIndex(
      (0 ..< sectionCount).flatMap {
        s in
        (0 ..< itemCounts[s]).map {
          i in
          NSIndexPath(forItem: i, inSection: s)
        }
      } .map { ($0, self.layoutAttributesForItemAtIndexPath($0)) }
    )

    headerTypes.enumerate().apply {
      if $1 != nil {
        var indexes = [$0, 0, 0]
        let indexPath = NSIndexPath(indexes: &indexes, length: 3)
        let attributes = self.layoutAttributesForSupplementaryViewOfKind("Header", atIndexPath: indexPath)
        self.storedAttributes[indexPath] = attributes
      }
    }
  }

  /**
  heightForItemType:

  - parameter type: ItemType

  - returns: CGFloat
  */
  func heightForItemType(type: ItemType) -> CGFloat {
    switch type {
      case .Cell:           return 44
      case .AttributedText: return 44
      case .Label:          return 44
      case .List:           return 44
      case .Button:         return 44
      case .Image:          return 44
      case .LabeledImage:   return 44
      case .Switch:         return 44
      case .Color:          return 44
      case .Slider:         return 44
      case .TwoToneSlider:  return 44
      case .Picker:         return 44
      case .Stepper:        return 44
      case .TextView:       return 44
      case .TextField:      return 44
      case .Custom:         return 44
    }
  }

  /**
  heightForHeaderInSection:

  - parameter section: Int

  - returns: CGFloat
  */
  func heightForHeaderInSection(section: Int) -> CGFloat { if headerTypes[section] != nil { return 44 } else { return 0 } }

  /**
  heightForSection:

  - parameter section: Int

  - returns: CGFloat
  */
  func heightForSection(section: Int) -> CGFloat {
    let sectionItemHeights = itemHeights[section]
    let sectionHeaderHeight = heightForHeaderInSection(section)
    let spacing = CGFloat(sectionItemHeights.count - 1) * verticalSpacing
    return sectionItemHeights.reduce(spacing + sectionHeaderHeight) {$0 + $1}
  }

  /**
  verticalOffsetForSection:

  - parameter section: Int

  - returns: CGFloat
  */
  func verticalOffsetForSection(section: Int) -> CGFloat {
    return (0 ..< section).reduce(CGFloat(section) * verticalSpacing) {$0 + self.heightForSection($1)}
  }

  /**
  collectionViewContentSize

  - returns: CGSize
  */
  override func collectionViewContentSize() -> CGSize { return contentSize }

  private typealias AttributesIndex = OrderedDictionary<NSIndexPath, UICollectionViewLayoutAttributes?>

  private var itemTypes: [[ItemType]] = []
  private var itemHeights: [[CGFloat]] = []
  private var headerTypes: [HeaderType?] = []
  private var storedAttributes: AttributesIndex = [:]
  private var contentSize = CGSize.zeroSize

  /** clearCache */
  private func clearCache() {
    itemTypes.removeAll()
    itemHeights.removeAll()
    headerTypes.removeAll()
    storedAttributes.removeAll()
    contentSize = CGSize.zeroSize
  }

  var verticalSpacing: CGFloat = 0

  /**
  layoutAttributesForElementsInRect:

  - parameter rect: CGRect

  - returns: [AnyObject]?
  */
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    return storedAttributes.values.filter { $0?.frame.intersects(rect) == true }.map{$0!}
  }

  // MARK: Headers

  /**
  layoutAttributesForSupplementaryViewOfKind:atIndexPath:

  - parameter elementKind: String
  - parameter indexPath: NSIndexPath

  - returns: UICollectionViewLayoutAttributes!
  */
  override func layoutAttributesForSupplementaryViewOfKind(elementKind: String,
                                               atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?
  {
    let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: "Header", withIndexPath: indexPath)
    attributes.frame = CGRect(
      x: 0,
      y: verticalOffsetForSection(indexPath.section),
      width: contentSize.width,
      height: heightForHeaderInSection(indexPath.section)
    )
    return attributes
  }

   // MARK: Items

  /**
  layoutAttributesForItemAtIndexPath:

  - parameter indexPath: NSIndexPath

  - returns: UICollectionViewLayoutAttributes!
  */
  override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
    let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)

    let sectionOffset = verticalOffsetForSection(indexPath.section)
    let sectionItemHeights = itemHeights[indexPath.section]
    let rowOffset = (0 ..< indexPath.row).reduce(heightForHeaderInSection(indexPath.section)) {$0 + sectionItemHeights[$1]}

    let width = UIScreen.mainScreen().bounds.width
    let height = sectionItemHeights[indexPath.row]

    attributes.frame = CGRect(x: 0, y: sectionOffset + rowOffset, width: width, height: height)

    return attributes
  }

}