//
//  BankItemTextFieldCell.swift
//  Remote
//
//  Created by Jason Cardwell on 10/21/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankItemTextFieldCell: BankItemCell, UITextFieldDelegate {

  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewCellStyle
  :param: reuseIdentifier String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    textFieldℹ.delegate = self
    textFieldℹ.returnKeyType = returnKeyType
    textFieldℹ.keyboardType = keyboardType
    textFieldℹ.autocapitalizationType = autocapitalizationType
    textFieldℹ.autocorrectionType = autocorrectionType
    textFieldℹ.spellCheckingType = spellCheckingType
    textFieldℹ.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
    textFieldℹ.keyboardAppearance = keyboardAppearance
    textFieldℹ.secureTextEntry = secureTextEntry
    contentView.addSubview(nameLabel)
    contentView.addSubview(textFieldℹ)
    let format = "|-[name]-[text]-| :: V:|-[name]-| :: V:|-[text]-|"
    contentView.constrain(format, views: ["name": nameLabel, "text": textFieldℹ])
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    textFieldℹ.text = nil
    nameLabel.text = nil
  }

  override var info: AnyObject? {
    get { return infoDataType.objectFromText(textFieldℹ.text) }
    set { textFieldℹ.text = textFromObject(newValue) }
  }

  override var isEditingState: Bool {
    didSet {
      textFieldℹ.userInteractionEnabled = isEditingState
       if textFieldℹ.isFirstResponder() { textFieldℹ.resignFirstResponder() }
    }
  }

  private let textFieldℹ: UITextField = {
    let view = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 38))
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.userInteractionEnabled = false
    view.font = Bank.infoFont
    view.textColor = Bank.infoColor
    view.textAlignment = .Right
    return view
  }()

  private var beginStateText: String?  // Stores pre-edited text field/view content

  /// MARK: Keyboard settings
  ////////////////////////////////////////////////////////////////////////////////


  var returnKeyType: UIReturnKeyType = .Done { didSet { textFieldℹ.returnKeyType = returnKeyType } }

  var keyboardType: UIKeyboardType = .ASCIICapable { didSet { textFieldℹ.keyboardType = keyboardType } }

  var autocapitalizationType: UITextAutocapitalizationType = .None {
    didSet {
      textFieldℹ.autocapitalizationType = autocapitalizationType
    }
  }

  var autocorrectionType: UITextAutocorrectionType = .No { didSet { textFieldℹ.autocorrectionType = autocorrectionType } }

  var spellCheckingType: UITextSpellCheckingType = .No { didSet { textFieldℹ.spellCheckingType = spellCheckingType } }

  var enablesReturnKeyAutomatically: Bool = false {
    didSet {
      textFieldℹ.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
    }
  }

  var keyboardAppearance: UIKeyboardAppearance = Bank.keyboardAppearance {
    didSet {
      textFieldℹ.keyboardAppearance = keyboardAppearance
     }
   }

  var secureTextEntry: Bool = false { didSet { textFieldℹ.secureTextEntry = secureTextEntry } }

  var shouldUseIntegerKeyboard: Bool = false {
    didSet {
      textFieldℹ.inputView = shouldUseIntegerKeyboard
                               ? IntegerInputView(frame: CGRect(x: 0, y: 0, width: 320, height: 216), target: textFieldℹ)
                               : nil
    }
  }

  /// UITextFieldDelegate
  ////////////////////////////////////////////////////////////////////////////////

  /**
  textFieldDidBeginEditing:

  :param: textField UITextField
  */
  func textFieldDidBeginEditing(textField: UITextField) {
    beginStateText = textField.text
  }

  /**
  textFieldDidEndEditing:

  :param: textField UITextField
  */
  func textFieldDidEndEditing(textField: UITextField) {
    if textField.text != beginStateText { valueDidChange?(infoDataType.objectFromText(textField.text)) }
  }

  /**
  textFieldShouldEndEditing:

  :param: textField UITextField

  :returns: Bool
  */
  func textFieldShouldEndEditing(textField: UITextField) -> Bool {

    var shouldEnd = true

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

    if shouldEnd { shouldEnd = valueIsValid?(textField.text) ?? true }

    if !shouldEnd && !isEditingState {
      textField.text = beginStateText
      shouldEnd = true
    }

    return shouldEnd
  }

  /**
  textFieldShouldReturn:

  :param: textField UITextField

  :returns: Bool
  */
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }

}
