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
  var zoomed = false
  var blurStyle: UIBlurEffectStyle = .Dark

  override var description: String {
    return super.description + " viewingMode = \(viewingMode); zoomed = \(zoomed); blurStyle = \(blurStyle);"
  }

  /**
  copyWithZone:

  :param: zone NSZone

  :returns: AnyObject
  */
  override func copyWithZone(zone: NSZone) -> AnyObject {
    let attributes: AnyObject = super.copyWithZone(zone)
    if let bankAttributes = attributes as? BankCollectionAttributes {
      bankAttributes.viewingMode = viewingMode
      bankAttributes.zoomed = zoomed
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
      return viewingMode == other.viewingMode  && zoomed == other.zoomed ? super.isEqual(object) : false
    } else { return false }
  }

}
