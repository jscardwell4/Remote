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

    colorBoxWrapper.addSubview(colorBox)
    colorBoxWrapper.constrain("|-2-[color]-2-| :: V:|-2-[color]-2-|", views: ["color": colorBox])
    contentView.addSubview(colorBoxWrapper)

    let format = "|-[name]-[text(>=90)]-[color]-| :: V:|-[color]-| :: V:|-[name]-| :: V:|-[text]-|"
    contentView.constrain(format, views: ["name": nameLabel, "text": textFieldView, "color": colorBoxWrapper])
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

  private let colorBoxWrapper: UIView = {
    let view = UIView()
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.userInteractionEnabled = false
    view.constrainAspect(1.0)
    view.layer.cornerRadius = 5.0
    view.layer.shadowOpacity = 0.5
    view.layer.shadowRadius = 2.5
    view.layer.shadowOffset = CGSize(width: 0.0, height: -1.25)
    view.backgroundColor = UIColor.whiteColor()
    return view
  }()

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
    view.placeholder = "None"
    view.textColor = Bank.infoColor
    view.textAlignment = .Right
    view.inputView = HexIntegerInputView(frame: CGRect(x: 0, y: 0, width: 320, height: 324), target: view)
    return view
  }()

  private var beginStateText: String?  // Stores pre-edited text field/view content
  var placeholderText: String = "None" { didSet { textFieldView.placeholder = placeholderText } }
  var placeholderColor: UIColor = UIColor.clearColor()

  /// UITextFieldDelegate
  ////////////////////////////////////////////////////////////////////////////////

  /**
  textFieldDidBeginEditing:

  :param: textField UITextField
  */
  func textFieldDidBeginEditing(textField: UITextField) {
    var currentText = textField.text
    beginStateText = currentText
    if currentText?.hasPrefix("#") == true { currentText?.removeAtIndex(currentText.startIndex) }
    textField.text = currentText
  }

  /**
  textField:shouldChangeCharactersInRange:replacementString:

  :param: textField UITextField
  :param: range NSRange
  :param: string String

  :returns: Bool
  */
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
  {
    return (textField.text.characterCount - range.length + string.characterCount) <= 8
  }

  /**
  textFieldDidEndEditing:

  :param: textField UITextField
  */
  func textFieldDidEndEditing(textField: UITextField) {
    var currentText = textField.text
    if currentText?.isEmpty == true { currentText = nil }
    else { currentText?.insert("#", atIndex: currentText!.startIndex) }

    if currentText != beginStateText {
      colorBox.backgroundColor = currentText == nil ? placeholderColor : UIColor(string: currentText!)
      valueDidChange?(colorBox.backgroundColor)
    }
    textField.text = currentText
  }

  /**
  textFieldShouldEndEditing:

  :param: textField UITextField

  :returns: Bool
  */
  func textFieldShouldEndEditing(textField: UITextField) -> Bool {
    var shouldEnd = true
    if textField.text != nil && !(~/"(?:^$)|(?:^[0-9A-F]{1,8}$)" ~= textField.text!) { shouldEnd = false }
    if shouldEnd { shouldEnd = valueIsValid?("#" + textField.text) ?? true }
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
