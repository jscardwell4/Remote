//
//  DetailTextInputCell.swift
//  Remote
//
//  Created by Jason Cardwell on 12/04/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailTextInputCell: DetailCell {


  var textInput: UITextInput? {
    didSet {
      (textInput as? AnyObject)?.setValue(returnKeyType.rawValue, forKey: "returnKeyType")
      (textInput as? AnyObject)?.setValue(keyboardType.rawValue, forKey: "keyboardType")
      (textInput as? AnyObject)?.setValue(autocapitalizationType.rawValue, forKey: "autocapitalizationType")
      (textInput as? AnyObject)?.setValue(autocorrectionType.rawValue, forKey: "autocorrectionType")
      (textInput as? AnyObject)?.setValue(spellCheckingType.rawValue, forKey: "spellCheckingType")
      (textInput as? AnyObject)?.setValue(enablesReturnKeyAutomatically, forKey: "enablesReturnKeyAutomatically")
      (textInput as? AnyObject)?.setValue(keyboardAppearance.rawValue, forKey: "keyboardAppearance")
      (textInput as? AnyObject)?.setValue(secureTextEntry, forKey: "secureTextEntry")
    }
  }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    nameLabel.text = nil
  }

  var currentText: String? {
    get {
      return textInput != nil && (textInput! as AnyObject).respondsToSelector("text")
               ? (textInput! as AnyObject).valueForKey("text") as? String
               : nil
    }
    set {
      if textInput != nil && (textInput! as AnyObject).respondsToSelector("text") {
        (textInput! as AnyObject).setValue(newValue, forKey: "text")
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

  override var isEditingState: Bool {
    didSet {
      if textInput != nil {
        if let textInputView = (textInput! as AnyObject) as? UIView {
          textInputView.userInteractionEnabled = isEditingState
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

  var keyboardAppearance: UIKeyboardAppearance = DetailController.keyboardAppearance {
    didSet {
      (textInput as? AnyObject)?.setValue(keyboardAppearance.rawValue, forKey: "keyboardAppearance")
     }
   }

  var secureTextEntry: Bool = false {
    didSet { (textInput as? AnyObject)?.setValue(secureTextEntry, forKey: "secureTextEntry") }
  }

  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewCellStyle
  :param: reuseIdentifier String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

}
