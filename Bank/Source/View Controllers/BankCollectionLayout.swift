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

final class BankCollectionLayout: ZoomingCollectionViewLayout {

  /**
  stringForAttributes:

  :param: attributes BankCollectionAttributes?

  :returns: String
  */
  private func stringForAttributes(attributes: BankCollectionAttributes?) -> String {
    if let attr = attributes {
      return "attributes: " + "; ".join(
        "zoomState = \(toString(attr.zoomState))",
        "indexPath = (row: \(attr.indexPath.row), section: \(attr.indexPath.section)",
        "frame = \(attr.frame)",
        "zIndex = \(attr.zIndex)"
      )
    } else { return "attributes: nil; zoomState = \(zoomState)" }
  }

  /**
  layoutAttributeClass

  :returns: AnyClass
  */
  override class func layoutAttributesClass() -> AnyClass { return BankCollectionAttributes.self }

  typealias ViewingMode = Bank.ViewingMode

  var viewingMode: ViewingMode = .List {
    willSet {
      if newValue != viewingMode {
        switch newValue {
          case .List:      setItemScale(ItemScale(width: .OneAcross, height :38), forSection: 1)
          case .Thumbnail: setItemScale(ItemScale(width: .ThreeAcross), forSection: 1)
        }
      }
    }
    didSet { if oldValue != viewingMode { invalidateLayout() } }
  }

  /**
  layoutAttributesForItemAtIndexPath:

  :param: indexPath NSIndexPath

  :returns: UICollectionViewLayoutAttributes!
  */
  override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
    let attributes = super.layoutAttributesForItemAtIndexPath(indexPath) as! BankCollectionAttributes
    attributes.viewingMode = viewingMode
    attributes.zoomed = zoomedItem == indexPath
    MSLogDebug(stringForAttributes(attributes))
    return attributes
  }

  /**
  initialLayoutAttributesForAppearingItemAtIndexPath:

  :param: indexPath NSIndexPath

  :returns: UICollectionViewLayoutAttributes?
  */
  override func initialLayoutAttributesForAppearingItemAtIndexPath(indexPath: NSIndexPath)
    -> UICollectionViewLayoutAttributes?
  {
    let attributes = super.finalLayoutAttributesForDisappearingItemAtIndexPath(indexPath) as? BankCollectionAttributes
    attributes?.viewingMode = viewingMode
    attributes?.zoomed = zoomedItem == indexPath
    MSLogDebug(stringForAttributes(attributes))
    return attributes
  }

  /**
  finalLayoutAttributesForDisappearingItemAtIndexPath:

  :param: indexPath NSIndexPath

  :returns: UICollectionViewLayoutAttributes?
  */
  override func finalLayoutAttributesForDisappearingItemAtIndexPath(indexPath: NSIndexPath)
    -> UICollectionViewLayoutAttributes?
  {
    let attributes = super.finalLayoutAttributesForDisappearingItemAtIndexPath(indexPath) as? BankCollectionAttributes
    attributes?.viewingMode = viewingMode
    attributes?.zoomed = zoomedItem == indexPath
    MSLogDebug(stringForAttributes(attributes))
    return attributes
  }
}
