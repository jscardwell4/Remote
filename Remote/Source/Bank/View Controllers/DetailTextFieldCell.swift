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

class DetailTextFieldCell: DetailCell, UITextFieldDelegate {

  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewCellStyle
  :param: reuseIdentifier String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    textFieldView.delegate = self
    textFieldView.returnKeyType = returnKeyType
    textFieldView.keyboardType = keyboardType
    textFieldView.autocapitalizationType = autocapitalizationType
    textFieldView.autocorrectionType = autocorrectionType
    textFieldView.spellCheckingType = spellCheckingType
    textFieldView.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
    textFieldView.keyboardAppearance = keyboardAppearance
    textFieldView.secureTextEntry = secureTextEntry
    contentView.addSubview(nameLabel)
    contentView.addSubview(textFieldView)
    let format = "|-[name]-[text]-| :: V:|-[name]-| :: V:|-[text]-|"
    contentView.constrain(format, views: ["name": nameLabel, "text": textFieldView])
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    textFieldView.text = nil
    nameLabel.text = nil
  }

  override var info: AnyObject? {
    get { if infoDataType == .AttributedStringData { return infoDataType.objectFromAttributedText(textFieldView.attributedText) }
          else { return infoDataType.objectFromText(textFieldView.text) } }
    set { if infoDataType == .AttributedStringData { textFieldView.attributedText = newValue as? NSAttributedString }
          else { textFieldView.text = textFromObject(newValue) } }
  }

  override var isEditingState: Bool {
    didSet {
      textFieldView.userInteractionEnabled = isEditingState
       if textFieldView.isFirstResponder() { textFieldView.resignFirstResponder() }
    }
  }

  private let textFieldView: UITextField = {
    let view = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 38))
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.userInteractionEnabled = false
    view.font = Bank.infoFont
    view.textColor = Bank.infoColor
    view.textAlignment = .Right
    return view
  }()

  private var beginStateAttributedText: NSAttributedString?
  private var beginStateText: String?  // Stores pre-edited text field/view content

  /// MARK: Keyboard settings
  ////////////////////////////////////////////////////////////////////////////////


  var returnKeyType: UIReturnKeyType = .Done { didSet { textFieldView.returnKeyType = returnKeyType } }

  var keyboardType: UIKeyboardType = .ASCIICapable { didSet { textFieldView.keyboardType = keyboardType } }

  var autocapitalizationType: UITextAutocapitalizationType = .None {
    didSet {
      textFieldView.autocapitalizationType = autocapitalizationType
    }
  }

  var autocorrectionType: UITextAutocorrectionType = .No { didSet { textFieldView.autocorrectionType = autocorrectionType } }

  var spellCheckingType: UITextSpellCheckingType = .No { didSet { textFieldView.spellCheckingType = spellCheckingType } }

  var enablesReturnKeyAutomatically: Bool = false {
    didSet {
      textFieldView.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
    }
  }

  var keyboardAppearance: UIKeyboardAppearance = Bank.keyboardAppearance {
    didSet {
      textFieldView.keyboardAppearance = keyboardAppearance
     }
   }

  var secureTextEntry: Bool = false { didSet { textFieldView.secureTextEntry = secureTextEntry } }

  var shouldUseIntegerKeyboard: Bool = false {
    didSet {
      textFieldView.inputView = shouldUseIntegerKeyboard
                               ? IntegerInputView(frame: CGRect(x: 0, y: 0, width: 320, height: 216), target: textFieldView)
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
    beginStateAttributedText = textField.attributedText
    beginStateText = textField.text
  }

  /**
  textFieldDidEndEditing:

  :param: textField UITextField
  */
  func textFieldDidEndEditing(textField: UITextField) {
    if textField.text != beginStateText {
      var value: AnyObject?
      if infoDataType == .AttributedStringData { value = textField.attributedText }
      else { value = infoDataType.objectFromText(textField.text) }
      valueDidChange?(value)
    }
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
      if infoDataType == .AttributedStringData { textField.attributedText = beginStateAttributedText }
      else { textField.text = beginStateText }
      shouldEnd = true
    }

    return shouldEnd
  }

  /**
  textFieldShouldReturn:

  :param: textField UITextField

  :returns: Bool
  */
  func textFieldShouldReturn(textField: UITextField) -> Bool { textField.resignFirstResponder(); return false }

}
