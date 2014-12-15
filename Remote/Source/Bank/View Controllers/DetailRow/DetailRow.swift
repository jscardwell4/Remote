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

  var tag: Any?
  weak var cell: DetailCell?

  var identifier: DetailCell.Identifier { return .Cell }
  var indexPath: NSIndexPath?
  var select: ((Void) -> Void)?
  var delete: ((Void) -> Void)?
  var editActions: [UITableViewRowAction]?
  var editingStyle: UITableViewCellEditingStyle { return delete != nil || editActions != nil ? .Delete : .None }
  var deleteRemovesRow: Bool = true

  var backgroundColor: UIColor?
  var indentationLevel: Int?
  var indentationWidth: CGFloat?
  var name: String?
  var info: AnyObject?
  var infoDataType: DetailCell.DataType?
  var shouldAllowNonDataTypeValue: ((AnyObject?) -> Bool)?
  var valueDidChange: ((AnyObject?) -> Void)?
  var valueIsValid: ((AnyObject?) -> Bool)?

  /**
  super.configureCell:

  :param: cell DetailCell
  */
  func configureCell(cell: DetailCell) {
    self.cell = cell
    if infoDataType != nil                { cell.infoDataType = infoDataType!                               }
    if backgroundColor != nil             { cell.backgroundColor = backgroundColor!                         }
    if indentationLevel != nil            { cell.indentationLevel = indentationLevel!                       }
    if indentationWidth != nil            { cell.indentationWidth = indentationWidth!                       }
    if name != nil                        { cell.name = name!                                               }
    if info != nil                        { cell.info = info!                                               }
    if shouldAllowNonDataTypeValue != nil { cell.shouldAllowNonDataTypeValue = shouldAllowNonDataTypeValue! }
    if valueIsValid != nil                { cell.valueIsValid = valueIsValid!                               }
    if valueDidChange != nil              { cell.valueDidChange = valueDidChange!                           }
  }

  var load: (DetailRow) -> Void = {_ in }

  /** init */
  init(){}
}
