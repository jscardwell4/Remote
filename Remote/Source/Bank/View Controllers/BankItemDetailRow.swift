//
//  BankItemDetailRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/16/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankItemDetailRow {

  let identifier: BankItemCell.Identifier
  var indexPath: NSIndexPath!
  var selectionHandler: ((Void) -> Void)?
  var deletionHandler: ((Void) -> Void)?

  var editActions: [UITableViewRowAction]?
  var editingStyle: UITableViewCellEditingStyle { return deletionHandler != nil || editActions != nil ? .Delete : .None }

  var isDeletable: Bool { return deletionHandler != nil }
  var deleteRemovesRow = true
  var isSelectable: Bool { return selectionHandler != nil }

  private(set) weak var bankItemCell: BankItemCell?

  /// Properties that mirror `BankItemCell` properties
  ////////////////////////////////////////////////////////////////////////////////

  var name: String?
  var info: AnyObject?
  var infoDataType: BankItemCell.DataType = .StringData
  var valueDidChange: ((NSObject?) -> Void)?
  var valueIsValid: ((NSObject?) -> Bool)?

  /**
  configure:

  :param: cell BankItemCell
  */
  func configureCell(cell: BankItemCell, forTableView tableView: UITableView) {
    bankItemCell = cell
    cell.info = info
    cell.infoDataType = infoDataType
    cell.valueIsValid = valueIsValid
    cell.valueDidChange = valueDidChange
    cell.sizeDidChange = {(cell: BankItemCell) -> Void in tableView.beginUpdates(); tableView.endUpdates()}
  }

  /**
  initWithIdentifier:hasEditingState:selectionHandler:configureCell:

  :param: identifier BankItemCell.Identifier
  :param: hasEditingState Bool = false
  :param: selectionHandler ((Void) -> Void
  :param: configureCell (BankItemCell) -> Void
  */
  init(identifier: BankItemCell.Identifier,
       selectionHandler: ((Void) -> Void)? = nil,
       deletionHandler: ((Void) -> Void)? = nil)
  {
    self.identifier = identifier
    self.selectionHandler = selectionHandler
    self.deletionHandler = deletionHandler
  }

}

