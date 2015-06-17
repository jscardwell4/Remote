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
  layoutAttributeClass

  - returns: AnyClass
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

  - parameter indexPath: NSIndexPath

  - returns: UICollectionViewLayoutAttributes!
  */
  override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
    let attributes = super.layoutAttributesForItemAtIndexPath(indexPath) as! BankCollectionAttributes
    attributes.viewingMode = viewingMode
    return attributes
  }

}
