//
//  DetailStepperRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailStepperRow: DetailRow {

  var stepperWraps: Bool = true
  var stepperMinValue: Double = Double(CGFloat.min)
  var stepperMaxValue: Double = Double(CGFloat.max)
  var stepperStepValue: Double = 1.0

  let identifier: DetailCell.Identifier = .Stepper
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

  /**
  configure:

  :param: cell DetailCell
  */
  func configureCell(cell: DetailCell, forTableView tableView: UITableView) {
    if !(cell is DetailStepperCell) { return }
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
    (cell as DetailStepperCell).stepperWraps = stepperWraps
    (cell as DetailStepperCell).stepperMinValue = stepperMinValue
    (cell as DetailStepperCell).stepperMaxValue = stepperMaxValue
    (cell as DetailStepperCell).stepperStepValue = stepperStepValue
  }

  /** init */
  init() {}

}
