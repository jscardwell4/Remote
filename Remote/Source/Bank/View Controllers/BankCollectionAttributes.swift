//
//  BankCollectionAttributes.swift
//  Remote
//
//  Created by Jason Cardwell on 9/23/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//
import Foundation
import UIKit

@objc(BankCollectionAttributes)
class BankCollectionAttributes: UICollectionViewLayoutAttributes {

  enum ViewingMode { case List, Thumbnail }

  var viewingMode: ViewingMode = .List

  /**
  copyWithZone:

  :param: zone NSZone

  :returns: AnyObject
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

  :param: object AnyObject?

  :returns: Bool
  */
  override func isEqual(object: AnyObject?) -> Bool {
    if let other = object as? BankCollectionAttributes {
      return viewingMode == other.viewingMode ? super.isEqual(object) : false
    } else { return false }
  }

}
