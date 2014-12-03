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

class DetailTextFieldRow: DetailRow {

  let identifier: DetailCell.Identifier = .TextField
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

  var shouldUseIntegerKeyboard: Bool = false
  var shouldBeginEditing: ((UITextField) -> Bool)?
  var shouldEndEditing: ((UITextField) -> Bool)?
  var didBeginEditing: ((UITextField) -> Void)?
  var didEndEditing: ((UITextField) -> Void)?
  var shouldChangeCharacters: ((UITextField, NSRange, String) -> Bool)?
  var shouldClear: ((UITextField) -> Bool)?
  var shouldReturn: ((UITextField) -> Bool)?
  var allowEmptyString: Bool = true
  var allowableCharacters: NSCharacterSet = ~NSCharacterSet.emptyCharacterSet
  var placeholderText: String?

  /**
  configure:

  :param: cell DetailCell
  */
  func configureCell(cell: DetailCell, forTableView tableView: UITableView) {
    if !(cell is DetailTextFieldCell) { return }
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
    (cell as DetailTextFieldCell).returnKeyType = returnKeyType
    (cell as DetailTextFieldCell).keyboardType = keyboardType
    (cell as DetailTextFieldCell).autocapitalizationType = autocapitalizationType
    (cell as DetailTextFieldCell).autocorrectionType = autocorrectionType
    (cell as DetailTextFieldCell).spellCheckingType = spellCheckingType
    (cell as DetailTextFieldCell).enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
    (cell as DetailTextFieldCell).keyboardAppearance = keyboardAppearance
    (cell as DetailTextFieldCell).secureTextEntry = secureTextEntry
    (cell as DetailTextFieldCell).shouldUseIntegerKeyboard = shouldUseIntegerKeyboard
    (cell as DetailTextFieldCell).shouldBeginEditing = shouldBeginEditing
    (cell as DetailTextFieldCell).shouldEndEditing = shouldEndEditing
    (cell as DetailTextFieldCell).didBeginEditing = didBeginEditing
    (cell as DetailTextFieldCell).didEndEditing = didEndEditing
    (cell as DetailTextFieldCell).shouldChangeCharacters = shouldChangeCharacters
    (cell as DetailTextFieldCell).shouldClear = shouldClear
    (cell as DetailTextFieldCell).shouldReturn = shouldReturn
    (cell as DetailTextFieldCell).allowableCharacters = allowableCharacters
    (cell as DetailTextFieldCell).allowEmptyString = allowEmptyString
    (cell as DetailTextFieldCell).placeholderText = placeholderText
  }

  /** init */
  init() {}

}
