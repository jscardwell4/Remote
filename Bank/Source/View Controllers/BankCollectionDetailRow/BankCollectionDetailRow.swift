//
//  BankCollectionDetailRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/16/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit
import DataModel

class BankCollectionDetailRow {

  var tag: Any?
  weak var cell: BankCollectionDetailCell?

  var identifier: BankCollectionDetailCell.Identifier { return .Cell }
  var indexPath: NSIndexPath?
  var select: ((Void) -> Void)?
  var delete: ((Void) -> Void)?
  var deleteRemovesRow: Bool = true

  var backgroundColor: UIColor?
  var name: String?
  var info: AnyObject?
  var infoDataType: BankCollectionDetailCell.DataType?
  var shouldAllowNonDataTypeValue: ((AnyObject?) -> Bool)?
  var valueDidChange: ((AnyObject?) -> Void)?
  var valueIsValid: ((AnyObject?) -> Bool)?

  static func selectPushableCollection<C:BankModelCollection>(pushableCollection: C?) -> Void -> Void {
    return {
      if let collection = pushableCollection,
        collectionDelegate = BankModelCollectionDelegate(collection: collection),
        nav = UIApplication.sharedApplication().keyWindow?.rootViewController as? UINavigationController
      {
        let controller = BankCollectionController(collectionDelegate: collectionDelegate)
        nav.pushViewController(controller, animated: true)
      }
    }
  }

  static func selectPushableItem(pushableItem: protocol<EditableModel, Detailable>?) -> Void -> Void {
    return {
      if let item = pushableItem,
        nav = UIApplication.sharedApplication().keyWindow?.rootViewController as? UINavigationController
      {
        nav.pushViewController(item.detailController(), animated: true)
      }
    }
  }

  /**
  super.configureCell:

  - parameter cell: BankCollectionDetailCell
  */
  func configureCell(cell: BankCollectionDetailCell) {
    self.cell = cell
    if infoDataType != nil                { cell.infoDataType = infoDataType!                               }
    if backgroundColor != nil             { cell.backgroundColor = backgroundColor!                         }
    if name != nil                        { cell.name = name!                                               }
    if shouldAllowNonDataTypeValue != nil { cell.shouldAllowNonDataTypeValue = shouldAllowNonDataTypeValue! }
    if valueIsValid != nil                { cell.valueIsValid = valueIsValid!                               }
    if valueDidChange != nil              { cell.valueDidChange = valueDidChange!                           }
    cell.info = info
    cell.select = select
    cell.delete = delete
  }

}
