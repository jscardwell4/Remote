//
//  BankCollectionDetailTextFieldRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

final class BankCollectionDetailTextFieldRow: BankCollectionDetailTextInputRow {

  override var identifier: BankCollectionDetailCell.Identifier { return .TextField }

  var inputType: BankCollectionDetailTextFieldCell.InputType?
  var placeholderText: String?
  var placeholderAttributedText: NSAttributedString?
  var leftView: ((Void) -> UIView)?
  var rightView: ((Void) -> UIView)?
  var leftViewMode: UITextFieldViewMode?
  var rightViewMode: UITextFieldViewMode?

  /**
  configure:

  :param: cell BankCollectionDetailCell
  */
  override func configureCell(cell: BankCollectionDetailCell) {
    super.configureCell(cell)
    if let textFieldCell = cell as? BankCollectionDetailTextFieldCell {
      if inputType != nil { textFieldCell.inputType = inputType! }
      textFieldCell.placeholderText = placeholderText
      textFieldCell.placeholderAttributedText = placeholderAttributedText
      textFieldCell.leftView = leftView?()
      textFieldCell.rightView = rightView?()
      textFieldCell.leftViewMode = leftViewMode
      textFieldCell.rightViewMode = rightViewMode
    }
  }

}
