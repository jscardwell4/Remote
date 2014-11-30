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

  let identifier: DetailCell.Identifier
  var indexPath: NSIndexPath!
  var selectionHandler: ((Void) -> Void)?
  var deletionHandler: ((Void) -> Void)?

  var editActions: [UITableViewRowAction]?
  var editingStyle: UITableViewCellEditingStyle { return deletionHandler != nil || editActions != nil ? .Delete : .None }

  var isDeletable: Bool { return deletionHandler != nil }
  var deleteRemovesRow = true
  var isSelectable: Bool { return selectionHandler != nil }

  private(set) weak var bankItemCell: DetailCell?

  /// Properties that mirror `DetailCell` properties
  ////////////////////////////////////////////////////////////////////////////////

  var name: String?
  var info: AnyObject?
  var infoDataType: DetailCell.DataType = .StringData
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
    bankItemCell = cell
    if let color = backgroundColor { cell.backgroundColor = color }
    cell.indentationLevel = indentationLevel
    cell.indentationWidth = indentationWidth
    cell.info = info
    cell.infoDataType = infoDataType
    cell.valueIsValid = valueIsValid
    cell.valueDidChange = valueDidChange
    cell.sizeDidChange = {(cell: DetailCell) -> Void in tableView.beginUpdates(); tableView.endUpdates()}
  }

  /**
  initWithIdentifier:hasEditingState:selectionHandler:configureCell:

  :param: identifier DetailCell.Identifier
  :param: hasEditingState Bool = false
  :param: selectionHandler ((Void) -> Void
  :param: configureCell (DetailCell) -> Void
  */
  init(identifier: DetailCell.Identifier,
       selectionHandler: ((Void) -> Void)? = nil,
       deletionHandler: ((Void) -> Void)? = nil)
  {
    self.identifier = identifier
    self.selectionHandler = selectionHandler
    self.deletionHandler = deletionHandler
  }

}

