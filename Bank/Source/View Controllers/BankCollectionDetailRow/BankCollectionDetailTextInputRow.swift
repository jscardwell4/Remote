//
//  BankCollectionDetailTextInputRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankCollectionDetailTextInputRow: BankCollectionDetailRow {

  var returnKeyType: UIReturnKeyType?
  var keyboardType: UIKeyboardType?
  var autocapitalizationType: UITextAutocapitalizationType?
  var autocorrectionType: UITextAutocorrectionType?
  var spellCheckingType: UITextSpellCheckingType?
  var enablesReturnKeyAutomatically: Bool?
  var keyboardAppearance: UIKeyboardAppearance?
  var secureTextEntry: Bool?
  var shouldBeginEditing: ((BankCollectionDetailTextInputCell) -> Bool)?
  var shouldEndEditing: ((BankCollectionDetailTextInputCell) -> Bool)?
  var didBeginEditing: ((BankCollectionDetailTextInputCell) -> Void)?
  var didEndEditing: ((BankCollectionDetailTextInputCell) -> Void)?
  var shouldChangeText: ((BankCollectionDetailTextInputCell, NSRange, String?) -> Bool)?
  var shouldClear: ((BankCollectionDetailTextInputCell) -> Bool)?
  var shouldReturn: ((BankCollectionDetailTextInputCell) -> Bool)?
  var allowEmptyString: Bool?
  var allowableCharacters: NSCharacterSet?

  /**
  configureCell:forTableView:

  - parameter cell: BankCollectionDetailCell
  - parameter tableView: UITableView
  */
  override func configureCell(cell: BankCollectionDetailCell) {
  	super.configureCell(cell)
    if let textInputCell = cell as? BankCollectionDetailTextInputCell {
      if returnKeyType != nil                 { textInputCell.returnKeyType = returnKeyType!                                 }
      if keyboardType != nil                  { textInputCell.keyboardType = keyboardType!                                   }
      if autocapitalizationType != nil        { textInputCell.autocapitalizationType = autocapitalizationType!               }
      if autocorrectionType != nil            { textInputCell.autocorrectionType = autocorrectionType!                       }
      if spellCheckingType != nil             { textInputCell.spellCheckingType = spellCheckingType!                         }
      if enablesReturnKeyAutomatically != nil { textInputCell.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically! }
      if keyboardAppearance != nil            { textInputCell.keyboardAppearance = keyboardAppearance!                       }
      if secureTextEntry != nil               { textInputCell.secureTextEntry = secureTextEntry!                             }
      textInputCell.shouldBeginEditing = shouldBeginEditing
      textInputCell.shouldEndEditing = shouldEndEditing
      textInputCell.didBeginEditing = didBeginEditing
      textInputCell.didEndEditing = didEndEditing
      textInputCell.shouldChangeText = shouldChangeText
      textInputCell.shouldClear = shouldClear
      textInputCell.shouldReturn = shouldReturn
      if allowableCharacters != nil { textInputCell.allowableCharacters = allowableCharacters! }
      if allowEmptyString != nil { textInputCell.allowEmptyString = allowEmptyString! }
    }
  }

}
