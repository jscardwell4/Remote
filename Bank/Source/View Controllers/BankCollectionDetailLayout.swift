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

protocol BankCollectionDetailLayoutDataSource: UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, itemTypesInSection section: Int)
    -> [BankCollectionDetailLayout.ItemType]
  func headerTypesInCollectionView(collectionView: UICollectionView) -> [BankCollectionDetailLayout.HeaderType?]
}

class BankCollectionDetailLayout: UICollectionViewLayout {

  typealias HeaderType = BankCollectionDetailSectionHeader.Identifier
  typealias ItemType = BankCollectionDetailCell.Identifier

  /** prepareLayout */
  override func prepareLayout() {
    if let dataSource = collectionView?.dataSource as? BankCollectionDetailLayoutDataSource {

      headerTypes = dataSource.headerTypesInCollectionView(collectionView!)

      let sectionCount = headerTypes.count

      itemTypes = map(0 ..< sectionCount) {dataSource.collectionView(self.collectionView!, itemTypesInSection: $0)}
      let itemCounts = map(0 ..< sectionCount) {self.itemTypes[$0].count}
      itemHeights = itemTypes.map { $0.map { self.heightForItemType($0) } }

      let indexPaths = flatMap(0 ..< sectionCount, {s in map(0 ..< itemCounts[s]) {r in NSIndexPath(r, s) } })
      let tuples = indexPaths.map {($0, self.layoutAttributesForItemAtIndexPath($0))}
      storedAttributes = AttributesIndex(tuples)
    }
  }

  /**
  heightForItemType:

  :param: type ItemType

  :returns: CGFloat
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
  heightForSection:

  :param: section Int

  :returns: CGFloat
  */
  func heightForSection(section: Int) -> CGFloat {
    let sectionItemHeights = itemHeights[section]
    return reduce(sectionItemHeights, CGFloat(sectionItemHeights.count) + 1 * verticalSpacing) {$0 + $1}
  }

  /**
  collectionViewContentSize

  :returns: CGSize
  */
  override func collectionViewContentSize() -> CGSize {
    let w = UIScreen.mainScreen().bounds.width
    let h = reduce(0 ..< headerTypes.count, verticalSpacing, {$0 + self.heightForSection($1)})
    return CGSize(width: w, height: h)
  }

  private typealias AttributesIndex = OrderedDictionary<NSIndexPath, UICollectionViewLayoutAttributes!>

  private var itemTypes: [[ItemType]] = []
  private var itemHeights: [[CGFloat]] = []
  private var headerTypes: [HeaderType?] = []
  private var storedAttributes: AttributesIndex = [:]

  var verticalSpacing: CGFloat = 10

  /**
  layoutAttributesForElementsInRect:

  :param: rect CGRect

  :returns: [AnyObject]?
  */
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
    return filter(storedAttributes.values) { $0.frame.intersects(rect) }
  }

   // MARK: Items

  /**
  layoutAttributesForItemAtIndexPath:

  :param: indexPath NSIndexPath

  :returns: UICollectionViewLayoutAttributes!
  */
  override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
    let attributesClass = self.dynamicType.layoutAttributesClass() as! UICollectionViewLayoutAttributes.Type
    let attributes = attributesClass(forCellWithIndexPath: indexPath)

    let section = indexPath.section
    let sectionOffset = reduce(0 ..< section, CGFloat(section) * verticalSpacing) {$0 + self.heightForSection($1)}
    let sectionItemHeights = itemHeights[section]
    let row = indexPath.row
    let rowOffset = reduce(0 ..< row, 0) {$0 + sectionItemHeights[$1]}

    let width = UIScreen.mainScreen().bounds.width
    let height = sectionItemHeights[row]

    attributes.frame = CGRect(x: 0, y: sectionOffset + rowOffset, width: width, height: height)

    return attributes
  }

}
