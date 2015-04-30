//
//  NamedItemDetailController.swift
//  Remote
//
//  Created by Jason Cardwell on 11/29/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit
import DataModel

class NamedItemDetailController: DetailController {

  var namedItem: protocol<Named, Detailable> { return item as! protocol<Named, Detailable> }

  /**
  init:bundle:

  :param: nibNameOrNil String?
  :param: nibBundleOrNil NSBundle?
  */
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  /**
  initWithStyle:

  :param: style UITableViewStyle
  */
//  override init(style: UITableViewStyle) { super.init(style: style) }

  /**
  initWithCoder:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /**
  initWithModel:

  :param: model BankableModelObject
  */
  init(namedItem: protocol<Named, Detailable>) {
    super.init(item: namedItem)
  }

  lazy var nameTextField: UITextField =  {
    let textField = UITextField(frame: CGRect(x: 70, y: 70, width: 180, height: 30))
    textField.placeholder = "Name"
    textField.font = Bank.boldLabelFont
    textField.textColor = Bank.labelColor
    textField.keyboardAppearance = Bank.keyboardAppearance
    textField.adjustsFontSizeToFitWidth = true
    textField.returnKeyType = .Done
    textField.textAlignment = .Center
    textField.delegate = self
    return textField
    }()

   /** loadView */
   override func loadView() {
     super.loadView()
     navigationItem.titleView = nameTextField
   }

  /** updateDisplay */
  override func updateDisplay() {
    nameTextField.text = namedItem.name
    super.updateDisplay()
  }

  /**
  setEditing:animated:

  :param: editing Bool
  :param: animated Bool
  */
  override func setEditing(editing: Bool, animated: Bool) {
    if self.editing != editing {
      nameTextField.userInteractionEnabled = editing
      if nameTextField.isFirstResponder() { nameTextField.resignFirstResponder() }
      super.setEditing(editing, animated: animated)
    }
  }

}

/// MARK: - UITextFieldDelegate
////////////////////////////////////////////////////////////////////////////////

extension NamedItemDetailController: UITextFieldDelegate {

  /**
  textFieldShouldReturn:

  :param: textField UITextField

  :returns: Bool
  */
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    precondition(textField === nameTextField, "what other text fields are we delegating besides name label?")
    textField.resignFirstResponder()
    return false
  }

  /**
  textFieldDidEndEditing:

  :param: textField UITextField
  */
  func textFieldDidEndEditing(textField: UITextField) {
    precondition(textField === nameTextField, "what other text fields are we delegating besides name label?")
    if textField.text?.length > 0 { (item as? protocol<DynamicallyNamed,Editable>)?.name = textField.text }
    else { textField.text = namedItem.name }
  }

}

