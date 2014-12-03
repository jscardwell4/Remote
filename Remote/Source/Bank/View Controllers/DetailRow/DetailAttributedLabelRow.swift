//
//  DetailAttributedLabelRow.swift
//  Remote
//
//  Created by Jason Cardwell on 11/28/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailAttributedLabelRow: DetailRow {

  let identifier: DetailCell.Identifier = .AttributedLabel
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
  var infoDataType: DetailCell.DataType = .AttributedStringData
  var shouldAllowNonDataTypeValue: ((AnyObject?) -> Bool)?
  var valueDidChange: ((AnyObject?) -> Void)?
  var valueIsValid: ((AnyObject?) -> Bool)?
  var indentationLevel: Int = 0
  var indentationWidth: CGFloat = 8.0
  var backgroundColor: UIColor?

  /** init */
  init() {}

  /**
  configure:

  :param: cell DetailCell
  */
  func configureCell(cell: DetailCell, forTableView tableView: UITableView) {
    if !(cell is DetailAttributedLabelCell) { return }
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

}
