//
//  BankCollectionAttributes.swift
//  Remote
//
//  Created by Jason Cardwell on 9/23/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//
import Foundation
import UIKit

final class BankCollectionAttributes: UICollectionViewLayoutAttributes {


  var viewingMode: Bank.ViewingMode = .List

  override var description: String {
    var result = super.description
    result.sub("\\(<NSIndexPath[^\\)]+\\)", "(item: \(indexPath.item), section: \(indexPath.section))")
    result += "; viewingMode = \(viewingMode)"
    return result
  }

  /**
  copyWithZone:

  - parameter zone: NSZone

  - returns: AnyObject
  */
  override func copyWithZone(zone: NSZone) -> AnyObject {
    let attributes: AnyObject = super.copyWithZone(zone)
    if let bankAttributes = attributes as? BankCollectionAttributes {
      bankAttributes.viewingMode = viewingMode
    }
    return attributes
  }

  /**
  isEqual:

  - parameter object: AnyObject?

  - returns: Bool
  */
  override func isEqual(object: AnyObject?) -> Bool {
    if let other = object as? BankCollectionAttributes {
      return viewingMode == other.viewingMode ? super.isEqual(object) : false
    } else { return false }
  }

}
