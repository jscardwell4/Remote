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

final class DetailTextViewCell: DetailTextInputCell, UITextViewDelegate {

  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewCellStyle
  :param: reuseIdentifier String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    contentView.addSubview(nameLabel)

    let textView = UITextView(autolayout: true)
    textView.userInteractionEnabled = false
    textView.scrollEnabled = false
    textView.font = Bank.infoFont
    textView.textColor = Bank.infoColor
    textView.textContainer.widthTracksTextView = true
    textView.delegate = self
    contentView.addSubview(textView)

    let format = "|-[name]-| :: |-[text]-| :: V:|-[name]-[text]-|"
    contentView.constrain(format, views: ["name": nameLabel, "text": textView])

    textInput = textView
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /// Storing pre-edited text field/view content
  private var beginStateAttributedText: NSAttributedString?
  private var beginStateText: String?

  var shouldAllowReturnsInTextView: Bool = false
  var shouldBeginEditing: ((UITextView) -> Bool)?
  var shouldEndEditing: ((UITextView) -> Bool)?
  var didBeginEditing: ((UITextView) -> Void)?
  var didEndEditing: ((UITextView) -> Void)?
  var shouldChangeText: ((UITextView, NSRange, String?) -> Bool)?

  /// UITextViewDelegate
  ////////////////////////////////////////////////////////////////////////////////

  /**
  textViewShouldBeginEditing:

  :param: textView UITextView

  :returns: Bool
  */
  func textViewShouldBeginEditing(textView: UITextView) -> Bool { return shouldBeginEditing?(textView) ?? true }

  /**
  textViewDidBeginEditing:

  :param: textView UITextView
  */
  func textViewDidBeginEditing(textView: UITextView) {
    beginStateText = textView.text
    beginStateAttributedText = textView.attributedText
    didBeginEditing?(textView)
  }

  /**
  textViewDidEndEditing:

  :param: textView UITextView
  */
  func textViewDidEndEditing(textView: UITextView) {
    if textView.text != beginStateText {
      valueDidChange?(infoDataType.objectFromText(textView.text, attributedText: textView.attributedText))
    }
    didEndEditing?(textView)
  }

  /**
  textViewShouldEndEditing:

  :param: textView UITextView

  :returns: Bool
  */
  func textViewShouldEndEditing(textView: UITextView) -> Bool {
    if valueIsValid?(textView.text) == false { textView.text = beginStateText }
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
    if Array(text ?? "") ∋ Character("\n") && !shouldAllowReturnsInTextView {
      textView.resignFirstResponder()
      return false
    } else {
      return shouldChangeText?(textView, range, text) ??  true
    }
  }

  /**
  textViewDidChange:

  :param: textView UITextView
  */
  func textViewDidChange(textView: UITextView) {
    MSLogDebug("")
    // let height = textView.bounds.size.height
    // textView.sizeToFit()
    // let isFirstResponder = textView.isFirstResponder()
    // if textView.bounds.size.height != height {
    //   sizeDidChange?(self)
    //   if isFirstResponder {
    //     textView.becomeFirstResponder()
    //   }
    // }
  }
}
