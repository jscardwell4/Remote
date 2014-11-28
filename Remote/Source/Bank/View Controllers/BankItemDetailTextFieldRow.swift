//
//  BankItemDetailTextFieldRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankItemDetailTextFieldRow: BankItemDetailTextInputRow {

  var shouldUseIntegerKeyboard: Bool = false

  /**
  configureCell:forTableView:

  :param: cell BankItemCell
  :param: tableView UITableView
  */
  override func configureCell(cell: BankItemCell, forTableView tableView: UITableView) {
  	super.configureCell(cell, forTableView: tableView)
    cell.name = name
  	if let textFieldCell = cell as? BankItemTextFieldCell {
      textFieldCell.shouldUseIntegerKeyboard = shouldUseIntegerKeyboard
    }
  }

  /** init */
  convenience init() { self.init(identifier: .TextField) }

  /**
  initWithNumber:label:dataType:valueDidChange:

  :param: number NSNumber
  :param: label String
  :param: dataType BankItemCell.DataType
  :param: valueDidChange (NSObject?) -> Void
  */
  convenience init(number: NSNumber, label: String, dataType: BankItemCell.DataType, valueDidChange: (NSObject?) -> Void) {
    self.init(identifier: .TextField)
    name = label
    info = number
    infoDataType = dataType
    shouldUseIntegerKeyboard = true
    self.valueDidChange = valueDidChange
  }

}
