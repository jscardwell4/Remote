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

final class DetailTextFieldRow: DetailTextInputRow {

  override var identifier: DetailCell.Identifier { return .TextField }

  var inputType: DetailTextFieldCell.InputType?
  var shouldBeginEditing: ((UITextField) -> Bool)?
  var shouldEndEditing: ((UITextField) -> Bool)?
  var didBeginEditing: ((UITextField) -> Void)?
  var didEndEditing: ((UITextField) -> Void)?
  var shouldChangeCharacters: ((UITextField, NSRange, String) -> Bool)?
  var shouldClear: ((UITextField) -> Bool)?
  var shouldReturn: ((UITextField) -> Bool)?
  var allowEmptyString: Bool?
  var allowableCharacters: NSCharacterSet?
  var placeholderText: String?
  var placeholderAttributedText: NSAttributedString?
  var leftView: ((Void) -> UIView)?
  var rightView: ((Void) -> UIView)?
  var leftViewMode: UITextFieldViewMode?
  var rightViewMode: UITextFieldViewMode?
  /**
  configure:

  :param: cell DetailCell
  */
  override func configureCell(cell: DetailCell) {
    super.configureCell(cell)
    if inputType != nil                 { (cell as? DetailTextFieldCell)?.inputType = inputType!                                }
    if shouldBeginEditing != nil        { (cell as? DetailTextFieldCell)?.shouldBeginEditing = shouldBeginEditing               }
    if shouldEndEditing != nil          { (cell as? DetailTextFieldCell)?.shouldEndEditing = shouldEndEditing                   }
    if didBeginEditing != nil           { (cell as? DetailTextFieldCell)?.didBeginEditing = didBeginEditing                     }
    if didEndEditing != nil             { (cell as? DetailTextFieldCell)?.didEndEditing = didEndEditing                         }
    if shouldChangeCharacters != nil    { (cell as? DetailTextFieldCell)?.shouldChangeCharacters = shouldChangeCharacters       }
    if shouldClear != nil               { (cell as? DetailTextFieldCell)?.shouldClear = shouldClear                             }
    if shouldReturn != nil              { (cell as? DetailTextFieldCell)?.shouldReturn = shouldReturn                           }
    if allowableCharacters != nil       { (cell as? DetailTextFieldCell)?.allowableCharacters = allowableCharacters!            }
    if allowEmptyString != nil          { (cell as? DetailTextFieldCell)?.allowEmptyString = allowEmptyString!                  }
    if placeholderText != nil           { (cell as? DetailTextFieldCell)?.placeholderText = placeholderText                     }
    if placeholderAttributedText != nil { (cell as? DetailTextFieldCell)?.placeholderAttributedText = placeholderAttributedText }
    if leftView != nil                  { (cell as? DetailTextFieldCell)?.leftView = leftView!()                                }
    if rightView != nil                 { (cell as? DetailTextFieldCell)?.rightView = rightView!()                              }
    if leftViewMode != nil              { (cell as? DetailTextFieldCell)?.leftViewMode = leftViewMode!                          }
    if rightViewMode != nil             { (cell as? DetailTextFieldCell)?.rightViewMode = rightViewMode!                        }
  }

  /** init */
  override init() { super.init() }

}
