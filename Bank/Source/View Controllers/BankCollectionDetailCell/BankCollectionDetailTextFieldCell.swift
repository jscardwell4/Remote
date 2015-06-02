//
//  BankCollectionDetailTextFieldCell.swift
//  Remote
//
//  Created by Jason Cardwell on 10/21/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

final class BankCollectionDetailTextFieldCell: BankCollectionDetailTextInputCell, UITextFieldDelegate {

  enum InputType { case Default, Integer, HexInteger, FloatingPoint }

  override func initializeIVARs() {
    contentView.addSubview(nameLabel)

    let field = UITextField(autolayout: true)
    field.userInteractionEnabled = false
    field.font = Bank.infoFont
    field.textColor = Bank.infoColor
    field.textAlignment = .Right
    field.delegate = self
    field.clipsToBounds = false
    contentView.addSubview(field)
    contentView.constrain(𝗛|-nameLabel--field-|𝗛, 𝗩|-nameLabel-|𝗩, 𝗩|-field-|𝗩)

    textInput = field
  }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    name = nil
    placeholderText = nil
    placeholderAttributedText = nil
    inputType = .Default
  }

  var inputType: InputType = .Default {
    didSet {
      if let textField = textInput as? UITextField {
        let w = UIScreen.mainScreen().bounds.width
        switch inputType {
          case .Integer:
            textField.inputView = IntegerInputView(frame: CGRect(x: 0, y: 0, width: w, height: 216), target: textField)
          case .HexInteger:
            textField.inputView = HexIntegerInputView(frame: CGRect(x: 0, y: 0, width: w, height: 324), target: textField)
          case .FloatingPoint:
            textField.inputView = FloatInputView(frame: CGRect(x: 0, y: 0, width: w, height: 216), target: textField)
          case .Default:
            textField.inputView = nil
        }
      }
    }
  }

  var leftView: UIView? {
    get { return (textInput as? UITextField)?.leftView }
    set { (textInput as? UITextField)?.leftView = newValue }
  }

  var leftViewMode: UITextFieldViewMode? {
    get { return (textInput as? UITextField)?.leftViewMode }
    set { (textInput as? UITextField)?.leftViewMode = newValue ?? .Never }
  }

  var rightViewMode: UITextFieldViewMode? {
    get { return (textInput as? UITextField)?.rightViewMode }
    set { (textInput as? UITextField)?.rightViewMode = newValue ?? .Never }
  }

  var rightView: UIView? {
    get { return (textInput as? UITextField)?.rightView }
    set { (textInput as? UITextField)?.rightView = newValue }
  }

  /// Placeholders for nil info value
  var placeholderText: String? {
    didSet {
      if let textField = textInput as? UITextField {
        textField.placeholder = placeholderText
      }
    }
  }

  var placeholderAttributedText: NSAttributedString? {
    didSet {
      if let textField = textInput as? UITextField {
        textField.attributedPlaceholder = placeholderAttributedText
      }
    }
  }

}
