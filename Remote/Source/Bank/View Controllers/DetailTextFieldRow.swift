//
//  DetailTextFieldRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailTextFieldRow: DetailTextInputRow {

  var shouldUseIntegerKeyboard: Bool = false

  /**
  configureCell:forTableView:

  :param: cell DetailCell
  :param: tableView UITableView
  */
  override func configureCell(cell: DetailCell, forTableView tableView: UITableView) {
  	super.configureCell(cell, forTableView: tableView)
    cell.name = name
  	if let textFieldCell = cell as? DetailTextFieldCell {
      textFieldCell.shouldUseIntegerKeyboard = shouldUseIntegerKeyboard
    }
  }

  /** init */
  convenience init() { self.init(identifier: .TextField) }

  /**
  initWithNumber:label:dataType:valueDidChange:

  :param: number NSNumber
  :param: label String
  :param: dataType DetailCell.DataType
  :param: valueDidChange (NSObject?) -> Void
  */
  convenience init(number: NSNumber, label: String, dataType: DetailCell.DataType, valueDidChange: (AnyObject?) -> Void) {
    self.init(identifier: .TextField)
    name = label
    info = number
    infoDataType = dataType
    shouldUseIntegerKeyboard = true
    self.valueDidChange = valueDidChange
  }

}
