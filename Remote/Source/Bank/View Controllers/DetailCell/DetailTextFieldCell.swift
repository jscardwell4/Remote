//
//  DetailTextFieldCell.swift
//  Remote
//
//  Created by Jason Cardwell on 10/21/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

final class DetailTextFieldCell: DetailTextInputCell, UITextFieldDelegate {

  enum InputType { case Default, Integer, HexInteger, FloatingPoint }

  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewCellStyle
  :param: reuseIdentifier String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    contentView.addSubview(nameLabel)

    let field = UITextField(autolayout: true)
    field.userInteractionEnabled = false
    field.font = Bank.infoFont
    field.textColor = Bank.infoColor
    field.textAlignment = .Right
    field.delegate = self
    contentView.addSubview(field)

    let format = "|-[name]-[text]-| :: V:|-[name]-| :: V:|-[text]-|"
    contentView.constrain(format, views: ["name": nameLabel, "text": field])

    textInput = field
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    name = nil
    placeholderText = nil
    placeholderAttributedText = nil
    beginStateAttributedText = nil
    beginStateText = nil
    inputType = .Default
    allowableCharacters = ~NSCharacterSet.emptyCharacterSet
    allowEmptyString = true
    shouldBeginEditing = nil
    shouldEndEditing = nil
    didBeginEditing = nil
    didEndEditing = nil
    shouldChangeCharacters = nil
    shouldClear = nil
    shouldReturn = nil
  }

  /// Storing pre-edited text field/view content
  private var beginStateAttributedText: NSAttributedString?
  private var beginStateText: String?

  var inputType: InputType = .Default {
    didSet {
      if let textField = textInput as? UITextField {
        switch inputType {
          case .Integer:
            textField.inputView = IntegerInputView(frame: CGRect(x: 0, y: 0, width: 320, height: 216), target: textField)
          case .HexInteger:
            textField.inputView = HexIntegerInputView(frame: CGRect(x: 0, y: 0, width: 320, height: 324), target: textField)
          case .FloatingPoint:
            textField.inputView = FloatInputView(frame: CGRect(x: 0, y: 0, width: 320, height: 216), target: textField)
          case .Default:
            textField.inputView = nil
        }
      }
    }
  }

  var allowableCharacters = ~NSCharacterSet.emptyCharacterSet
  var allowEmptyString = true

  /// Placeholders for nil info value
  var placeholderText: String? {
    didSet {
      if let textField = textInput? as? UITextField {
        textField.placeholder = placeholderText
      }
    }
  }
  var placeholderAttributedText: NSAttributedString? {
    didSet {
      if let textField = textInput? as? UITextField {
        textField.attributedPlaceholder = placeholderAttributedText
      }
    }
  }

  /// UITextFieldDelegate
  ////////////////////////////////////////////////////////////////////////////////

  var shouldBeginEditing: ((UITextField) -> Bool)?
  var shouldEndEditing: ((UITextField) -> Bool)?
  var didBeginEditing: ((UITextField) -> Void)?
  var didEndEditing: ((UITextField) -> Void)?
  var shouldChangeCharacters: ((UITextField, NSRange, String) -> Bool)?
  var shouldClear: ((UITextField) -> Bool)?
  var shouldReturn: ((UITextField) -> Bool)?

  /**
  textFieldShouldBeginEditing:

  :param: textField UITextField

  :returns: Bool
  */
  func textFieldShouldBeginEditing(textField: UITextField) -> Bool { return shouldBeginEditing?(textField) ?? true }

  /**
  textFieldDidBeginEditing:

  :param: textField UITextField
  */
  func textFieldDidBeginEditing(textField: UITextField) {
    beginStateAttributedText = textField.attributedText
    beginStateText = textField.text
    didBeginEditing?(textField)
  }

  /**
  textField:shouldChangeCharactersInRange:replacementString:

  :param: textField UITextField
  :param: range NSRange
  :param: string String

  :returns: Bool
  */
  func                  textField(textField: UITextField,
    shouldChangeCharactersInRange range: NSRange,
                replacementString string: String) -> Bool
  {
    var shouldChange = allowableCharacters ⊃ NSCharacterSet(charactersInString: string)
    if shouldChange && shouldChangeCharacters != nil { shouldChange = shouldChangeCharacters!(textField, range, string) }
    return shouldChange
  }

  /**
  textFieldShouldEndEditing:

  :param: textField UITextField

  :returns: Bool
  */
  func textFieldShouldEndEditing(textField: UITextField) -> Bool {

    var shouldEnd = true

    if textField.text.isEmpty { shouldEnd = allowEmptyString }
    else {
      let scanner = NSScanner.localizedScannerWithString(textField.text) as NSScanner
      switch infoDataType {
        case .IntData(let r):
          var n: Int32 = 0
          if !scanner.scanInt(&n) { shouldEnd = false }
          else if r ∌ n { shouldEnd = false }
        case .IntegerData(let r):
          var n: Int = 0
          if !scanner.scanInteger(&n) { shouldEnd = false }
          else if r ∌ n { shouldEnd = false }
        case .LongLongData(let r):
          var n: Int64 = 0
          if !scanner.scanLongLong(&n) { shouldEnd = false }
          else if r ∌ n { shouldEnd = false }
        case .FloatData(let r):
          var n: Float = 0
          if !scanner.scanFloat(&n) { shouldEnd = false }
          else if r ∌ n { shouldEnd = false }
        case .DoubleData(let r):
          var n: Double = 0
          if !scanner.scanDouble(&n) { shouldEnd = false }
          else if r ∌ n { shouldEnd = false }
         default:
           break
      }
    }

    if !shouldEnd && shouldAllowNonDataTypeValue != nil { shouldEnd = shouldAllowNonDataTypeValue!(textField.text) }
    if shouldEnd { shouldEnd = valueIsValid?(textField.text) ?? true }

    if !shouldEnd && !isEditingState {
      textField.text = beginStateText
      textField.attributedText = beginStateAttributedText
      shouldEnd = true
    }

    if shouldEnd && shouldEndEditing != nil { shouldEnd = shouldEndEditing!(textField) }

    return shouldEnd
  }

  /**
  textFieldDidEndEditing:

  :param: textField UITextField
  */
  func textFieldDidEndEditing(textField: UITextField) {
    if textField.text != beginStateText {
      valueDidChange?(infoDataType.objectFromText(textField.text, attributedText: textField.attributedText))
    }
    didEndEditing?(textField)
  }

  /**
  textFieldShouldClear:

  :param: textField UITextField

  :returns: Bool
  */
  func textFieldShouldClear(textField: UITextField) -> Bool { return shouldClear?(textField) ?? true }

  /**
  textFieldShouldReturn:

  :param: textField UITextField

  :returns: Bool
  */
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if shouldReturn != nil && shouldReturn!(textField) { return true }
    else { textField.resignFirstResponder(); return false }
  }

}
