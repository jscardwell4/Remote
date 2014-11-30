//
//  DetailColorCell.swift
//  Remote
//
//  Created by Jason Cardwell on 11/28/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailColorCell: DetailCell, UITextFieldDelegate {

  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewCellStyle
  :param: reuseIdentifier String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    textFieldView.delegate = self
    contentView.addSubview(nameLabel)
    contentView.addSubview(textFieldView)
    contentView.addSubview(colorBox)
    let format = "|-[name]-[text]-[color]-| :: V:|-[color]-| :: V:|-[name]-| :: V:|-[text]-|"
    contentView.constrain(format, views: ["name": nameLabel, "text": textFieldView, "color": colorBox])
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    nameLabel.text = nil
    textFieldView.text = nil
    colorBox.backgroundColor = UIColor.clearColor()
  }

  override var info: AnyObject? {
    get { return colorBox.backgroundColor }
    set {
      if let color = newValue as? UIColor {
        textFieldView.text = color.rgbaHexString
        colorBox.backgroundColor = color
      } else {
        textFieldView.text = nil
        colorBox.backgroundColor = UIColor.clearColor()
      }
    }
  }

  private let colorBox: UIView =  {
    let view = UIView()
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.userInteractionEnabled = false
    view.constrainAspect(1.0)
    view.backgroundColor = UIColor.clearColor()
    return view
  }()

  override var isEditingState: Bool {
    didSet {
      textFieldView.userInteractionEnabled = isEditingState
       if textFieldView.isFirstResponder() { textFieldView.resignFirstResponder() }
    }
  }

  private let textFieldView: UITextField = {
    let view = UITextField(frame: CGRect(x: 0, y: 0, width: 150, height: 38))
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.userInteractionEnabled = false
    view.returnKeyType = .Done
    view.autocapitalizationType = .None
    view.keyboardType = .ASCIICapable
    view.autocorrectionType = .No
    view.spellCheckingType = .No
    view.enablesReturnKeyAutomatically = false
    view.keyboardAppearance = Bank.keyboardAppearance
    view.secureTextEntry = false
    view.font = Bank.infoFont
    view.textColor = Bank.infoColor
    view.textAlignment = .Right
    return view
  }()

  private var beginStateText: String?  // Stores pre-edited text field/view content

  /// UITextFieldDelegate
  ////////////////////////////////////////////////////////////////////////////////

  /**
  textFieldDidBeginEditing:

  :param: textField UITextField
  */
  func textFieldDidBeginEditing(textField: UITextField) { beginStateText = textField.text }

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
    switch (range.location, range.length) {
      case let (loc, len) where loc == 0 && len <= 9: return ~/"^#[0-9a-fA-F]{\(len - 1)}$" ~= string
      case let (loc, len) where (1...8).contains(loc) && len <= 9 - loc: return ~/"^[0-9a-fA-F]{\(len)}$" ~= string
      default: return false
    }
  }

  /**
  textFieldDidEndEditing:

  :param: textField UITextField
  */
  func textFieldDidEndEditing(textField: UITextField) {
    if textField.text != beginStateText {
      let color = textField.text == nil ? UIColor.clearColor() : UIColor(string: textField.text!)
      colorBox.backgroundColor = color
      valueDidChange?(color)
    }
  }

  /**
  textFieldShouldEndEditing:

  :param: textField UITextField

  :returns: Bool
  */
  func textFieldShouldEndEditing(textField: UITextField) -> Bool {
    var shouldEnd = true
    if textField.text != nil && !(~/"(?:^$)|(?:^#[0-9a-fA-F]{8}$)" ~= textField.text!) { shouldEnd = false }
    if shouldEnd { shouldEnd = valueIsValid?(textField.text) ?? true }
    if !shouldEnd && !isEditingState { textField.text = beginStateText; shouldEnd = true }
    return shouldEnd
  }

  /**
  textFieldShouldReturn:

  :param: textField UITextField

  :returns: Bool
  */
  func textFieldShouldReturn(textField: UITextField) -> Bool { textField.resignFirstResponder(); return false }

}
