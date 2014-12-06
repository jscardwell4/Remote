//
//  DetailTextInputRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailTextInputRow: DetailRow {

  var returnKeyType: UIReturnKeyType?
  var keyboardType: UIKeyboardType?
  var autocapitalizationType: UITextAutocapitalizationType?
  var autocorrectionType: UITextAutocorrectionType?
  var spellCheckingType: UITextSpellCheckingType?
  var enablesReturnKeyAutomatically: Bool?
  var keyboardAppearance: UIKeyboardAppearance?
  var secureTextEntry: Bool?

  /**
  configureCell:forTableView:

  :param: cell DetailCell
  :param: tableView UITableView
  */
  override func configureCell(cell: DetailCell) {
  	super.configureCell(cell)
    if returnKeyType != nil                 { (cell as? DetailTextInputCell)?.returnKeyType = returnKeyType!                                 }
    if keyboardType != nil                  { (cell as? DetailTextInputCell)?.keyboardType = keyboardType!                                   }
    if autocapitalizationType != nil        { (cell as? DetailTextInputCell)?.autocapitalizationType = autocapitalizationType!               }
    if autocorrectionType != nil            { (cell as? DetailTextInputCell)?.autocorrectionType = autocorrectionType!                       }
    if spellCheckingType != nil             { (cell as? DetailTextInputCell)?.spellCheckingType = spellCheckingType!                         }
    if enablesReturnKeyAutomatically != nil { (cell as? DetailTextInputCell)?.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically! }
    if keyboardAppearance != nil            { (cell as? DetailTextInputCell)?.keyboardAppearance = keyboardAppearance!                       }
    if secureTextEntry != nil               { (cell as? DetailTextInputCell)?.secureTextEntry = secureTextEntry!                             }
  }

}
