//
//  DetailTextViewCell.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailTextViewCell: DetailCell, UITextViewDelegate {

  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewCellStyle
  :param: reuseIdentifier String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    textViewℹ.delegate = self
    textViewℹ.returnKeyType = returnKeyType
    textViewℹ.keyboardType = keyboardType
    textViewℹ.autocapitalizationType = autocapitalizationType
    textViewℹ.autocorrectionType = autocorrectionType
    textViewℹ.spellCheckingType = spellCheckingType
    textViewℹ.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
    textViewℹ.keyboardAppearance = keyboardAppearance
    textViewℹ.secureTextEntry = secureTextEntry
    contentView.addSubview(nameLabel)
    contentView.addSubview(textViewℹ)
    let format = "|-[name]-| :: |-[text]-| :: V:|-[name]-[text]-|"
    contentView.constrain(format, views: ["name": nameLabel, "text": textViewℹ])
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    textViewℹ.text = nil
    nameLabel.text = nil
  }

  override var info: AnyObject? {
    get { return infoDataType.objectFromText(textViewℹ.text) }
    set { textViewℹ.text = textFromObject(newValue); textViewDidChange(textViewℹ) }
  }

  override var isEditingState: Bool {
    didSet {
      textViewℹ.userInteractionEnabled = isEditingState
       if textViewℹ.isFirstResponder() { textViewℹ.resignFirstResponder() }
    }
  }
  private let textViewℹ: UITextView = {
    let view = UITextView()
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.userInteractionEnabled = false
    view.scrollEnabled = false
    view.font = Bank.infoFont
    view.textColor = Bank.infoColor
    view.textContainer.widthTracksTextView = true
    return view
    }()

  private var beginStateText: String?  // Stores pre-edited text field/view content

  var shouldAllowReturnsInTextView: Bool = false

  /// MARK: Keyboard settings
  ////////////////////////////////////////////////////////////////////////////////

  var returnKeyType: UIReturnKeyType = .Done { didSet { textViewℹ.returnKeyType = returnKeyType } }

  var keyboardType: UIKeyboardType = .ASCIICapable { didSet { textViewℹ.keyboardType = keyboardType } }

  var autocapitalizationType: UITextAutocapitalizationType = .None {
    didSet {
      textViewℹ.autocapitalizationType = autocapitalizationType
    }
  }

  var autocorrectionType: UITextAutocorrectionType = .No { didSet { textViewℹ.autocorrectionType = autocorrectionType } }

  var spellCheckingType: UITextSpellCheckingType = .No { didSet { textViewℹ.spellCheckingType = spellCheckingType } }

  var enablesReturnKeyAutomatically: Bool = false {
    didSet {
      textViewℹ.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
    }
  }

  var keyboardAppearance: UIKeyboardAppearance = Bank.keyboardAppearance {
    didSet {
      textViewℹ.keyboardAppearance = keyboardAppearance
     }
   }

  var secureTextEntry: Bool = false { didSet { textViewℹ.secureTextEntry = secureTextEntry } }


  /// UITextViewDelegate
  ////////////////////////////////////////////////////////////////////////////////

  /**
  textViewDidBeginEditing:

  :param: textView UITextView
  */
  func textViewDidBeginEditing(textView: UITextView) {
    beginStateText = textView.text
  }

  /**
  textViewDidEndEditing:

  :param: textView UITextView
  */
  func textViewDidEndEditing(textView: UITextView) {
    if textView.text != beginStateText {
      valueDidChange?(textView.text)
    }
  }

  /**
  textViewShouldEndEditing:

  :param: textView UITextView

  :returns: Bool
  */
  func textViewShouldEndEditing(textView: UITextView) -> Bool {
    if !(valueIsValid ∅|| valueIsValid!(textView.text)) {
      textView.text = beginStateText
    }
    return true
  }

  /**
  textView:shouldChangeTextInRange:replacementText:

  :param: textView UITextView
  :param: range NSRange
  :param: text String?

  :returns: Bool
  */
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String?) -> Bool {
    if let currentText = textView.text {
      if (currentText as NSString).containsString("\n") && !shouldAllowReturnsInTextView {
        textView.resignFirstResponder()
        return false
      }
    }
    return true
  }

  /**
  textViewDidChange:

  :param: textView UITextView
  */
  func textViewDidChange(textView: UITextView) {
    let height = textView.bounds.size.height
    textView.sizeToFit()
    let isFirstResponder = textView.isFirstResponder()
    if textView.bounds.size.height != height {
      sizeDidChange?(self)
      if isFirstResponder {
        textView.becomeFirstResponder()
      }
    }
  }
}
