//
//  DetailTextViewRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

struct DetailTextViewRow: DetailRow {

  let identifier: DetailCell.Identifier = .TextView
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

  var returnKeyType: UIReturnKeyType = .Done
  var keyboardType: UIKeyboardType = .ASCIICapable
  var autocapitalizationType: UITextAutocapitalizationType = .None
  var autocorrectionType: UITextAutocorrectionType = .No
  var spellCheckingType: UITextSpellCheckingType = .No
  var enablesReturnKeyAutomatically: Bool = false
  var keyboardAppearance: UIKeyboardAppearance = Bank.keyboardAppearance
  var secureTextEntry: Bool = false
  var shouldAllowReturnsInTextView: Bool = false

  /**
  configure:

  :param: cell DetailCell
  */
  func configureCell(cell: DetailCell, forTableView tableView: UITableView) {
    if !(cell is DetailTextViewCell) { return }
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
    (cell as DetailTextViewCell).returnKeyType = returnKeyType
    (cell as DetailTextViewCell).keyboardType = keyboardType
    (cell as DetailTextViewCell).autocapitalizationType = autocapitalizationType
    (cell as DetailTextViewCell).autocorrectionType = autocorrectionType
    (cell as DetailTextViewCell).spellCheckingType = spellCheckingType
    (cell as DetailTextViewCell).enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
    (cell as DetailTextViewCell).keyboardAppearance = keyboardAppearance
    (cell as DetailTextViewCell).secureTextEntry = secureTextEntry
    (cell as DetailTextViewCell).shouldAllowReturnsInTextView = shouldAllowReturnsInTextView
  }

  /** init */
  init() {}

}
