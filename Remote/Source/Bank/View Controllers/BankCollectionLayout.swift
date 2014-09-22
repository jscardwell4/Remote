//
//  BankCollectionLayout.swift
//  Remote
//
//  Created by Jason Cardwell on 9/15/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit

class BankCollectionLayout: UICollectionViewFlowLayout {

  /**

  layoutAttributesForElementsInRect:

  :param: rect CGRect

  :returns: [AnyObject]?

  */
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {

    var allAttributes = super.layoutAttributesForElementsInRect(rect) as [UICollectionViewLayoutAttributes]
    let missingSections = NSMutableIndexSet()
    let allCellAttributes = allAttributes.filter {$0.representedElementCategory == UICollectionElementCategory.Cell }
    for attributes in allAttributes {
      if attributes.representedElementCategory == .Cell { missingSections.addIndex(attributes.indexPath.section) }
    }

//    let allHeaderAttributes = allAttributes.filter { $0.representedElementKind == UICollectionElementKindSectionHeader }


    return allAttributes
  }

  /**

  shouldInvalidateLayoutForBoundsChange:

  :param: newBounds CGRect

  :returns: Bool

  */
  override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool { return true }


}