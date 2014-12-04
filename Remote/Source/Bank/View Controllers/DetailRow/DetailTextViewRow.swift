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

class DetailTextViewRow: DetailRow {

  override var identifier: DetailCell.Identifier { return .TextView }
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
  override func configureCell(cell: DetailCell) {
    super.configureCell(cell)
    (cell as? DetailTextViewCell)?.returnKeyType = returnKeyType
    (cell as? DetailTextViewCell)?.keyboardType = keyboardType
    (cell as? DetailTextViewCell)?.autocapitalizationType = autocapitalizationType
    (cell as? DetailTextViewCell)?.autocorrectionType = autocorrectionType
    (cell as? DetailTextViewCell)?.spellCheckingType = spellCheckingType
    (cell as? DetailTextViewCell)?.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
    (cell as? DetailTextViewCell)?.keyboardAppearance = keyboardAppearance
    (cell as? DetailTextViewCell)?.secureTextEntry = secureTextEntry
    (cell as? DetailTextViewCell)?.shouldAllowReturnsInTextView = shouldAllowReturnsInTextView
  }

  /** init */
  override init() { super.init() }

}
