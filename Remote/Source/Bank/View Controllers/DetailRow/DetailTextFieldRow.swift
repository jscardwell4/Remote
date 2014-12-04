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

  override var identifier: DetailCell.Identifier { return .TextField }

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
  override func configureCell(cell: DetailCell) {
    super.configureCell(cell)
    (cell as? DetailTextFieldCell)?.returnKeyType = returnKeyType
    (cell as? DetailTextFieldCell)?.keyboardType = keyboardType
    (cell as? DetailTextFieldCell)?.autocapitalizationType = autocapitalizationType
    (cell as? DetailTextFieldCell)?.autocorrectionType = autocorrectionType
    (cell as? DetailTextFieldCell)?.spellCheckingType = spellCheckingType
    (cell as? DetailTextFieldCell)?.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
    (cell as? DetailTextFieldCell)?.keyboardAppearance = keyboardAppearance
    (cell as? DetailTextFieldCell)?.secureTextEntry = secureTextEntry
    (cell as? DetailTextFieldCell)?.shouldUseIntegerKeyboard = shouldUseIntegerKeyboard
    (cell as? DetailTextFieldCell)?.shouldBeginEditing = shouldBeginEditing
    (cell as? DetailTextFieldCell)?.shouldEndEditing = shouldEndEditing
    (cell as? DetailTextFieldCell)?.didBeginEditing = didBeginEditing
    (cell as? DetailTextFieldCell)?.didEndEditing = didEndEditing
    (cell as? DetailTextFieldCell)?.shouldChangeCharacters = shouldChangeCharacters
    (cell as? DetailTextFieldCell)?.shouldClear = shouldClear
    (cell as? DetailTextFieldCell)?.shouldReturn = shouldReturn
    (cell as? DetailTextFieldCell)?.allowableCharacters = allowableCharacters
    (cell as? DetailTextFieldCell)?.allowEmptyString = allowEmptyString
    (cell as? DetailTextFieldCell)?.placeholderText = placeholderText
  }

  /** init */
  override init() { super.init() }

}
