//
//  DetailPickerRow.swift
//  Remote
//
//  Created by Jason Cardwell on 12/01/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

struct DetailPickerRow: DetailRow {


  let identifier: DetailCell.Identifier = .Picker
  var indexPath: NSIndexPath?
  var select: ((Void) -> Void)? { get { return nil } set {} }
  var delete: ((Void) -> Void)? { get { return nil } set {} }

  var editActions: [UITableViewRowAction]?
  var editingStyle: UITableViewCellEditingStyle { return .None }

  var deleteRemovesRow = false

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

  var nilItemTitle: String?
  var createItemTitle: String?
  var createItem: ((Void) -> Void)?
  var didSelectItem: ((AnyObject?) -> Void)?
  var titleForInfo: ((AnyObject?) -> String)?
  var data: [AnyObject] = []


  /**
  configure:

  :param: cell DetailCell
  */
  func configureCell(cell: DetailCell, forTableView tableView: UITableView) {
    if !(cell is DetailPickerCell) { return }
    if let color = backgroundColor { cell.backgroundColor = color }
    cell.indentationLevel = indentationLevel
    cell.indentationWidth = indentationWidth
    cell.infoDataType = infoDataType
    cell.valueIsValid = valueIsValid
    cell.valueDidChange = valueDidChange
    cell.sizeDidChange = {(cell: DetailCell) -> Void in tableView.beginUpdates(); tableView.endUpdates()}
    cell.shouldAllowNonDataTypeValue = shouldAllowNonDataTypeValue
    (cell as DetailPickerCell).data = data
    (cell as DetailPickerCell).nilItemTitle = nilItemTitle
    (cell as DetailPickerCell).createItemTitle = createItemTitle
    (cell as DetailPickerCell).didSelectItem = didSelectItem
    (cell as DetailPickerCell).createItem = createItem
    (cell as DetailPickerCell).info = info
  }

  /** init */
  init() {}

}
