//
//  DetailButtonRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

struct DetailButtonRow: DetailRow {

  let identifier: DetailCell.Identifier = .Button
  var indexPath: NSIndexPath?
  var select: ((Void) -> Void)?
  var delete: ((Void) -> Void)?

  var editActions: [UITableViewRowAction]?
  var editingStyle: UITableViewCellEditingStyle { return delete != nil || editActions != nil ? .Delete : .None }

  var deleteRemovesRow = true

  /// Properties that mirror `DetailCell` properties
  ////////////////////////////////////////////////////////////////////////////////

  var name: String?
  var info: AnyObject?
  var infoDataType: DetailCell.DataType = .StringData
  var shouldAllowNonDataTypeValue: ((AnyObject?) -> Bool)?
  var valueDidChange: ((AnyObject?) -> Void)?
  var valueIsValid: ((AnyObject?) -> Bool)?
  var indentationLevel: Int = 0
  var indentationWidth: CGFloat = 8.0
  var backgroundColor: UIColor?

  var showPickerRow: ((DetailButtonCell) -> Bool)?
  var hidePickerRow: ((DetailButtonCell) -> Bool)?
  var detailPickerRow: DetailPickerRow?

  /**
  configure:

  :param: cell DetailCell
  */
  func configureCell(cell: DetailCell, forTableView tableView: UITableView) {
    if !(cell is DetailButtonCell) { return }
    if let color = backgroundColor { cell.backgroundColor = color }
    cell.indentationLevel = indentationLevel
    cell.indentationWidth = indentationWidth
    cell.name = name
    cell.info = info
    cell.infoDataType = infoDataType
    cell.valueIsValid = valueIsValid
    cell.valueDidChange = valueDidChange
    cell.sizeDidChange = {(cell: DetailCell) -> Void in tableView.beginUpdates(); tableView.endUpdates()}
    cell.shouldAllowNonDataTypeValue = shouldAllowNonDataTypeValue
    if showPickerRow != nil { (cell as DetailButtonCell).showPickerRow = showPickerRow }
    if hidePickerRow != nil { (cell as DetailButtonCell).hidePickerRow = hidePickerRow }
    (cell as DetailButtonCell).detailPickerRow = detailPickerRow
  }


  /** init */
  init() {}

  /**
  initWithPushableCategory:

  :param: pushableCategory BankDisplayItemCategory
  */
  init(pushableCategory: BankDisplayItemCategory?) {
    info = pushableCategory
    select = {
      if let category = pushableCategory {
        if let controller = BankCollectionController(category: category) {
          if let nav = MSRemoteAppController.sharedAppController().window?.rootViewController as? UINavigationController {
            nav.pushViewController(controller, animated: true)
          }
        }
      }
    }
  }

  /**
  initWithPushableItem:

  :param: pushableItem BankDisplayItemModel?
  */
  init(pushableItem: BankDisplayItemModel?) {
    info = pushableItem
    select = {
      if let item = pushableItem {
        if let nav =  MSRemoteAppController.sharedAppController().window?.rootViewController as? UINavigationController {
          nav.pushViewController(item.detailController(), animated: true)
        }
      }
    }
  }

}
