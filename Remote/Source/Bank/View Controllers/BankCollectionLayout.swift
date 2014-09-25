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

private let ListItemCellSize      = CGSize(width: 320.0, height: 38.0)
private let ThumbnailItemCellSize = CGSize(width: 100.0, height: 100.0)
private let HeaderSize            = CGSize(width: 320.0, height: 38.0)

@objc(BankCollectionLayout)
class BankCollectionLayout: UICollectionViewFlowLayout {

  class var ListItemCellSize: CGSize { return CGSize(width: 320.0, height: 38.0) }
  class var ThumbnailItemCellSize: CGSize { return CGSize(width: 100.0, height: 100.0) }
  class var HeaderSize : CGSize { return CGSize(width: 320.0, height: 38.0) }

  var viewingMode: BankCollectionAttributes.ViewingMode = .None {
    didSet {
      switch viewingMode {
        case .List:      itemSize = BankCollectionLayout.ListItemCellSize
        case .Thumbnail: itemSize = BankCollectionLayout.ThumbnailItemCellSize
        default: break
      }
    }
  }

  private var hiddenSections = [Int]()

  /**
  init
  */
  override init() {
    super.init()
    headerReferenceSize = BankCollectionLayout.HeaderSize
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    headerReferenceSize = BankCollectionLayout.HeaderSize
  }

  var includeSectionHeaders: Bool = true {
    didSet {
      headerReferenceSize = includeSectionHeaders ? BankCollectionLayout.HeaderSize : CGSizeZero
    }
  }

  /**
  Add or remove section to/from `hiddenSections` and invalidate the layout

  :param: section Int
  */
  func toggleItemsForSection(section: Int) {
    if hiddenSections ∋ section { hiddenSections = hiddenSections.filter{$0 != section} }
    else                        { hiddenSections.append(section); hiddenSections.sort(<) }
    invalidateLayout()
  }

  /**

  layoutAttributesForElementsInRect:

  :param: rect CGRect

  :returns: [AnyObject]?

  */
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {

    // Get the total number of sections
    let sectionCount = collectionView!.numberOfSections()

    // Get the attributes as the super class would lay them out
    var attributes = super.layoutAttributesForElementsInRect(rect) as [BankCollectionAttributes]

    // Create an array to hold arrays of attributes by section
    var attributesBySection = [[BankCollectionAttributes]](count: sectionCount,
                                                                 repeatedValue: [BankCollectionAttributes]())

    // Iterate through the attributes to assign our viewing mode and partition by section
    for attrs in attributes {
      attrs.viewingMode = viewingMode
      attributesBySection[attrs.indexPath.section].append(attrs)
    }

    // Iterate through the hidden sections
    for section in hiddenSections {

      // Get all the cell attributes for the section
      var sectionCellAttributes = attributesBySection[section].filter{
        $0.representedElementCategory == UICollectionElementCategory.Cell
      }

      // Hide all the cells in this section
      sectionCellAttributes.reduce(Void()){$0.1.hidden = true}

      // Shouldn't need to perform computations unless there are more sections to follow this section
      if sectionCellAttributes.count > 0 && section + 1 < sectionCount {

        // Get the min and max y values for the frames of the attributes in this section
        let (minY, maxY) = sectionCellAttributes.reduce((CGFloat.max, CGFloat.min)) {
          (min($0.0.0, CGRectGetMinY($0.1.frame)), max($0.0.1, CGRectGetMaxY($0.1.frame)))
        }

        // Get the difference, which we will subtract from the frames of following sections
        let adjustY = maxY - minY

        // Iterate through the remaining sections
        for sectionToAdjust in section + 1..<sectionCount {

          // Get all attributes for the section to adjust
          var sectionToAdjustAttributes = attributesBySection[sectionToAdjust]

          // Iterate through the attributes to update the frame values
          for attr in sectionToAdjustAttributes { attr.frame.origin.y -= adjustY }

        }

      }

    }

    return attributes

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
  override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool { return true }


}