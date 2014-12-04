//
//  DetailRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/16/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailRow {

  var name: String?
  var info: AnyObject?
  var indexPath: NSIndexPath?
  var select: ((Void) -> Void)?
  var delete: ((Void) -> Void)?
  var editActions: [UITableViewRowAction]?
  var editingStyle: UITableViewCellEditingStyle { return delete != nil || editActions != nil ? .Delete : .None }
  var deleteRemovesRow: Bool = true
  var infoDataType: DetailCell.DataType = .StringData
  var shouldAllowNonDataTypeValue: ((AnyObject?) -> Bool)?
  var valueDidChange: ((AnyObject?) -> Void)?
  var valueIsValid: ((AnyObject?) -> Bool)?
  var indentationLevel: Int = 0
  var indentationWidth: CGFloat = 8.0
  var backgroundColor: UIColor?
  var identifier: DetailCell.Identifier { return .Cell }

  /**
  super.configureCell:

  :param: cell DetailCell
  */
  func configureCell(cell: DetailCell) {
    if let color = backgroundColor { cell.backgroundColor = color }
    cell.indentationLevel = indentationLevel
    cell.indentationWidth = indentationWidth
    cell.name = name
    cell.info = info
    cell.infoDataType = infoDataType
    cell.valueIsValid = valueIsValid
    cell.valueDidChange = valueDidChange
    cell.shouldAllowNonDataTypeValue = shouldAllowNonDataTypeValue
  }

  /** init */
  init(){}
}
