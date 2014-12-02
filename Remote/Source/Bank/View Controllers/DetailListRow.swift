//
//  DetailListRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

struct DetailListRow: DetailRow {

  let identifier: DetailCell.Identifier = .List
  var indexPath: NSIndexPath?
  var select: ((Void) -> Void)?
  var delete: ((Void) -> Void)?

  var editActions: [UITableViewRowAction]?
  var editingStyle: UITableViewCellEditingStyle { return delete != nil || editActions != nil ? .Delete : .None }

  var deleteRemovesRow = true

  /// Properties that mirror `DetailCell` properties
  ////////////////////////////////////////////////////////////////////////////////

  var name: String? { get { return nil } set {} }
  var info: AnyObject?
  var infoDataType: DetailCell.DataType = .StringData
  var shouldAllowNonDataTypeValue: ((AnyObject?) -> Bool)?
  var valueDidChange: ((AnyObject?) -> Void)?
  var valueIsValid: ((AnyObject?) -> Bool)?
  var indentationLevel: Int = 0
  var indentationWidth: CGFloat = 8.0
  var backgroundColor: UIColor?

  /**
  configure:

  :param: cell DetailCell
  */
  func configureCell(cell: DetailCell, forTableView tableView: UITableView) {
    if !(cell is DetailListCell) { return }
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
  }

  /** init */
  init() {}

  /**
  initWithPushableItem:hasEditingState:

  :param: pushableItem BankDisplayItemModel
  */
  init(pushableItem: BankDisplayItemModel) {
    select = {
      let controller = pushableItem.detailController()
      if let nav = MSRemoteAppController.sharedAppController().window.rootViewController as? UINavigationController {
        nav.pushViewController(controller, animated: true)
      }
    }
    delete = { pushableItem.delete() }
    info = pushableItem
  }

  /**
  initWithPushableCategory:hasEditingState:

  :param: pushableCategory BankDisplayItemCategory
  */
  init(pushableCategory: BankDisplayItemCategory) {
    select = {
      if let controller = BankCollectionController(category: pushableCategory) {
        if let nav = MSRemoteAppController.sharedAppController().window.rootViewController as? UINavigationController {
          nav.pushViewController(controller, animated: true)
        }
      }
    }
    delete = { pushableCategory.delete() }
    info = pushableCategory
  }

  /**
  initWithNamedItem:hasEditingState:

  :param: namedItem NamedModelObject
  */
  init(namedItem: NamedModelObject) {
    info = namedItem
  }

}
