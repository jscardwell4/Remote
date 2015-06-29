//
//  BankCollectionDetailTextInputCell.swift
//  Remote
//
//  Created by Jason Cardwell on 12/04/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankCollectionDetailTextInputCell: BankCollectionDetailCell {

  var textInput: UITextInput? {
    didSet {
      if let textField = self.textField {
        textField.returnKeyType = returnKeyType
        textField.keyboardType = keyboardType
        textField.autocapitalizationType = autocapitalizationType
        textField.autocorrectionType = autocorrectionType
        textField.spellCheckingType = spellCheckingType
        textField.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
        textField.keyboardAppearance = keyboardAppearance
        textField.secureTextEntry = secureTextEntry
      } else if let textView = self.textView {
        textView.returnKeyType = returnKeyType
        textView.keyboardType = keyboardType
        textView.autocapitalizationType = autocapitalizationType
        textView.autocorrectionType = autocorrectionType
        textView.spellCheckingType = spellCheckingType
        textView.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
        textView.keyboardAppearance = keyboardAppearance
        textView.secureTextEntry = secureTextEntry
      }
    }
  }

  var textView: UITextView? { return textInput as? UITextView }
  var textField: UITextField? { return textInput as? UITextField }

  /// Storing pre-edited text field/view content
  private var beginStateAttributedText: NSAttributedString?
  private var beginStateText: String?

  var allowableCharacters = ~NSCharacterSet.emptyCharacterSet
  var allowEmptyString = true

  var shouldBeginEditing: ((BankCollectionDetailTextInputCell) -> Bool)?
  var shouldEndEditing: ((BankCollectionDetailTextInputCell) -> Bool)?
  var didBeginEditing: ((BankCollectionDetailTextInputCell) -> Void)?
  var didEndEditing: ((BankCollectionDetailTextInputCell) -> Void)?
  var shouldChangeText: ((BankCollectionDetailTextInputCell, NSRange, String?) -> Bool)?
  var shouldClear: ((BankCollectionDetailTextInputCell) -> Bool)?
  var shouldReturn: ((BankCollectionDetailTextInputCell) -> Bool)?


  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    nameLabel.text = nil
    beginStateAttributedText = nil
    beginStateText = nil
    allowableCharacters = ~NSCharacterSet.emptyCharacterSet
    allowEmptyString = true
    shouldBeginEditing = nil
    shouldEndEditing = nil
    didBeginEditing = nil
    didEndEditing = nil
    shouldChangeText = nil
    shouldClear = nil
    shouldReturn = nil
  }

  var currentText: String? {
    get {
      return textInput != nil && (textInput as! AnyObject).respondsToSelector("text")
               ? (textInput as! AnyObject).valueForKey("text") as? String
               : nil
    }
    set {
      if textInput != nil && (textInput as! AnyObject).respondsToSelector("text") {
        (textInput as! AnyObject).setValue(newValue, forKey: "text")
      }
    }
  }

  var currentAttributedText: NSAttributedString? {
    get {
      return textInput != nil && (textInput! as AnyObject).respondsToSelector("attributedText")
               ? (textInput! as AnyObject).valueForKey("attributedText") as? NSAttributedString
               : nil
    }
    set {
      if textInput != nil && (textInput! as AnyObject).respondsToSelector("attributedText") {
        (textInput! as AnyObject).setValue(newValue, forKey: "attributedText")
      }
    }
  }

  private var textRange: UITextRange? {
    return textInput?.textRangeFromPosition(textInput!.beginningOfDocument, toPosition: textInput!.endOfDocument)
  }

  override var info: AnyObject? {
    get { return infoDataType.objectFromText(currentText, attributedText: currentAttributedText) }
    set {
      switch infoDataType.textualRepresentationForObject(newValue) {
        case let text as NSAttributedString: currentAttributedText = text
        case let text as String: currentText = text
        default: currentText = nil; currentAttributedText = nil
      }
    }
  }

  override var editing: Bool {
    didSet {
      if textInput != nil {
        if let textInputView = (textInput! as AnyObject) as? UIView {
          textInputView.userInteractionEnabled = editing
          if textInputView.isFirstResponder() { textInputView.resignFirstResponder() }
        }
      }
    }
  }

  /// MARK: Keyboard settings
  ////////////////////////////////////////////////////////////////////////////////

  var returnKeyType: UIReturnKeyType = .Done {
    didSet { (textInput as? AnyObject)?.setValue(returnKeyType.rawValue, forKey: "returnKeyType") }
  }

  var keyboardType: UIKeyboardType = .ASCIICapable {
    didSet { (textInput as? AnyObject)?.setValue(keyboardType.rawValue, forKey: "keyboardType") }
  }

  var autocapitalizationType: UITextAutocapitalizationType = .None {
    didSet {
      (textInput as? AnyObject)?.setValue(autocapitalizationType.rawValue, forKey: "autocapitalizationType")
    }
  }

  var autocorrectionType: UITextAutocorrectionType = .No {
    didSet { (textInput as? AnyObject)?.setValue(autocorrectionType.rawValue, forKey: "autocorrectionType") }
  }

  var spellCheckingType: UITextSpellCheckingType = .No {
    didSet { (textInput as? AnyObject)?.setValue(spellCheckingType.rawValue, forKey: "spellCheckingType") }
  }

  var enablesReturnKeyAutomatically: Bool = false {
    didSet {
      (textInput as? AnyObject)?.setValue(enablesReturnKeyAutomatically, forKey: "enablesReturnKeyAutomatically")
    }
  }

  var keyboardAppearance: UIKeyboardAppearance = Bank.keyboardAppearance {
    didSet {
      (textInput as? AnyObject)?.setValue(keyboardAppearance.rawValue, forKey: "keyboardAppearance")
     }
   }

  var secureTextEntry: Bool = false {
    didSet { (textInput as? AnyObject)?.setValue(secureTextEntry, forKey: "secureTextEntry") }
  }

}

// MARK: - Common delegate method implementations
extension BankCollectionDetailTextInputCell {

  /**
  shouldBeginEditing:

  - parameter textInput: UITextInput

  - returns: Bool
  */
  internal func _shouldBeginEditing(textInput: UITextInput) -> Bool {
    return textInput !== self.textInput ? false : shouldBeginEditing?(self) ?? true
  }

  /**
  didBeginEditing:

  - parameter textInput: UITextInput
  */
  internal func _didBeginEditing(textInput: UITextInput) {
    if textInput !== self.textInput { return }
    if let textField = self.textField {
      beginStateText = textField.text
      beginStateAttributedText = textField.attributedText
    } else if let textView = self.textView {
      beginStateText = textView.text
      beginStateAttributedText = textView.attributedText
    }
    didBeginEditing?(self)
  }

  /**
  shouldChangeText:range:replacement:

  - parameter textInput: UITextInput
  - parameter range: NSRange
  - parameter string: String

  - returns: Bool
  */
  internal func _shouldChangeText(textInput: UITextInput, range: NSRange, replacement: String) -> Bool {
    return textInput === self.textInput
      && allowableCharacters ⊃ NSCharacterSet(charactersInString: replacement)
      && shouldChangeText?(self, range, replacement) ?? true
  }

  /**
  shouldEndEditing:

  - parameter textInput: UITextInput

  - returns: Bool
  */
  internal func _shouldEndEditing(textInput: UITextInput) -> Bool {
    if textInput !== self.textInput { return false }
    let text = textInput.textInRange(textInput.textRangeFromPosition(textInput.beginningOfDocument,
                                                          toPosition: textInput.endOfDocument)!)!
    if text.isEmpty { return allowEmptyString }

    let scanner = NSScanner(string: text)

    var shouldEnd = valueIsValid?(text) ?? true

    if shouldEnd {
      switch infoDataType {
        case .IntData(let r):
          var n: Int32 = 0
          if !scanner.scanInt(&n) || r ∌ n { shouldEnd = shouldAllowNonDataTypeValue?(text) ?? false }
        case .IntegerData(let r):
          var n: Int = 0
          if !scanner.scanInteger(&n) || r ∌ n { shouldEnd = shouldAllowNonDataTypeValue?(text) ?? false }
        case .LongLongData(let r):
          var n: Int64 = 0
          if !scanner.scanLongLong(&n) || r ∌ n { shouldEnd = shouldAllowNonDataTypeValue?(text) ?? false }
        case .FloatData(let r):
          var n: Float = 0
          if !scanner.scanFloat(&n) || r ∌ n { shouldEnd = shouldAllowNonDataTypeValue?(text) ?? false }
        case .DoubleData(let r):
          var n: Double = 0
          if !scanner.scanDouble(&n) || r ∌ n { shouldEnd = shouldAllowNonDataTypeValue?(text) ?? false }
        default:
          break
      }
    }

    if !(shouldEnd || editing)  {
      currentText = beginStateText
      currentAttributedText = beginStateAttributedText
      shouldEnd = true
    }

    return true
  }

  /**
  _didEndEditing:

  - parameter textInput: UITextInput
  */
  internal func _didEndEditing(textInput: UITextInput) { if textInput === self.textInput { didEndEditing?(self) } }

  /**
  _textDidChange:

  - parameter textInput: UITextInput
  */
  internal func _textDidChange(textInput: UITextInput) {
    if textInput === self.textInput {
      valueDidChange?(infoDataType.objectFromText(currentText, attributedText: currentAttributedText))
    }
  }
}

// MARK: - UITextFieldDelegate

extension BankCollectionDetailTextInputCell: UITextFieldDelegate {
  /**
  textFieldShouldBeginEditing:

  - parameter textField: UITextField

  - returns: Bool
  */
  func textFieldShouldBeginEditing(textField: UITextField) -> Bool { return _shouldBeginEditing(textField) }

  /**
  textFieldDidBeginEditing:

  - parameter textField: UITextField
  */
  func textFieldDidBeginEditing(textField: UITextField) { _didBeginEditing(textField) }

  /**
  textField:shouldChangeCharactersInRange:replacementString:

  - parameter textField: UITextField
  - parameter range: NSRange
  - parameter string: String

  - returns: Bool
  */
  func                  textField(textField: UITextField,
    shouldChangeCharactersInRange range: NSRange,
                replacementString string: String) -> Bool
  {
    let shouldChange = _shouldChangeText(textField, range: range, replacement: string)
    if shouldChange { _textDidChange(textField) }
    return shouldChange
  }

  /**
  textFieldShouldEndEditing:

  - parameter textField: UITextField

  - returns: Bool
  */
  func textFieldShouldEndEditing(textField: UITextField) -> Bool { return _shouldEndEditing(textField) }

  /**
  textFieldDidEndEditing:

  - parameter textField: UITextField
  */
  func textFieldDidEndEditing(textField: UITextField) { _didEndEditing(textField) }

  /**
  textFieldShouldClear:

  - parameter textField: UITextField

  - returns: Bool
  */
  func textFieldShouldClear(textField: UITextField) -> Bool { return shouldClear?(self) ?? true }

  /**
  textFieldShouldReturn:

  - parameter textField: UITextField

  - returns: Bool
  */
  func textFieldShouldReturn(textField: UITextField) -> Bool { textField.resignFirstResponder(); return false }

}

// MARK: - UITextViewDelegate

extension BankCollectionDetailTextInputCell: UITextViewDelegate {
  /**
  textViewShouldBeginEditing:

  - parameter textView: UITextView

  - returns: Bool
  */
  func textViewShouldBeginEditing(textView: UITextView) -> Bool { return _shouldBeginEditing(textView) }

  /**
  textViewDidBeginEditing:

  - parameter textView: UITextView
  */
  func textViewDidBeginEditing(textView: UITextView) { _didBeginEditing(textView) }

  /**
  textViewDidEndEditing:

  - parameter textView: UITextView
  */
  func textViewDidEndEditing(textView: UITextView) { _didEndEditing(textView) }

  /**
  textViewShouldEndEditing:

  - parameter textView: UITextView

  - returns: Bool
  */
  func textViewShouldEndEditing(textView: UITextView) -> Bool { return _shouldEndEditing(textView) }

  /**
  textView:shouldChangeTextInRange:replacementText:

  - parameter textView: UITextView
  - parameter range: NSRange
  - parameter text: String?

  - returns: Bool
  */
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    return _shouldChangeText(textView, range: range, replacement: text)
  }

  /**
  textViewDidChange:

  - parameter textView: UITextView
  */
  func textViewDidChange(textView: UITextView) { _textDidChange(textView) }

}

