//
//  BankItemCell.swift
//  Remote
//
//  Created by Jason Cardwell on 9/26/14.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

// TODO: Add creation row option for table style cells as well as ability to delete member rows
// TODO: Create a specific cell type for the cells of a table style cell

class BankItemCell: UITableViewCell {


  /// MARK: Identifiers
  ////////////////////////////////////////////////////////////////////////////////


  private let identifier: Identifier

  /** A simple string-based enum to establish valid reuse identifiers for use with styling the cell */
  enum Identifier: String {
    case Label     = "BankItemDetailLabelCell"
    case List      = "BankItemDetailListCell"
    case Button    = "BankItemDetailButtonCell"
    case Image     = "BankItemDetailImageCell"
    case Switch    = "BankItemDetailSwitchCell"
    case Stepper   = "BankItemDetailStepperCell"
    case Detail    = "BankItemDetailDetailCell"
    case TextView  = "BankItemDetailTextViewCell"
    case TextField = "BankItemDetailTextFieldCell"

    /**
    registerWithTableView:

    :param: tableView UITableView
    */
    func registerWithTableView(tableView: UITableView) {
      switch self {
        case .Label:     tableView.registerClass(BankItemCell.self, forCellReuseIdentifier: self.rawValue)
        case .List:      tableView.registerClass(BankItemCell.self, forCellReuseIdentifier: self.rawValue)
        case .Button:    tableView.registerClass(BankItemCell.self, forCellReuseIdentifier: self.rawValue)
        case .Image:     tableView.registerClass(BankItemCell.self, forCellReuseIdentifier: self.rawValue)
        case .Switch:    tableView.registerClass(BankItemCell.self, forCellReuseIdentifier: self.rawValue)
        case .Stepper:   tableView.registerClass(BankItemCell.self, forCellReuseIdentifier: self.rawValue)
        case .Detail:    tableView.registerClass(BankItemCell.self, forCellReuseIdentifier: self.rawValue)
        case .TextView:  tableView.registerClass(BankItemCell.self, forCellReuseIdentifier: self.rawValue)
        case .TextField: tableView.registerClass(BankItemCell.self, forCellReuseIdentifier: self.rawValue)
      }
    }
  }

  /**
  registerIdentifiersWithTableView:

  :param: tableView UITableView
  */
  class func registerIdentifiersWithTableView(tableView: UITableView) {
    let identifiers: [Identifier] = [.Label, .List, .Button, .Image, .Switch, .Stepper, .Detail, .TextView, .TextField]
    for identifier in identifiers { identifier.registerWithTableView(tableView) }
  }


  /// MARK: Handlers
  ////////////////////////////////////////////////////////////////////////////////


  var changeHandler               : ((NSObject?)    -> Void)?
  var validationHandler           : ((NSObject?)    -> Bool)?
  var pickerSelectionHandler      : ((NSObject?)    -> Void)?
  var pickerCreateSelectionHandler: ((Void)         -> Void)?
  var buttonActionHandler         : ((Void)         -> Void)?
  var buttonEditingActionHandler  : ((Void)         -> Void)?
  var rowSelectionHandler         : ((NSObject?)    -> Void)?
  var shouldShowPicker            : ((BankItemCell) -> Bool)?
  var shouldHidePicker            : ((BankItemCell) -> Bool)?
  var didShowPicker               : ((BankItemCell) -> Void)?
  var didHidePicker               : ((BankItemCell) -> Void)?


  /// MARK: Keyboard settings
  ////////////////////////////////////////////////////////////////////////////////


  var returnKeyType: UIReturnKeyType = .Done {
    didSet {
      textFieldℹ?.returnKeyType = returnKeyType
      textViewℹ?.returnKeyType = returnKeyType
    }
  }

  var keyboardType: UIKeyboardType = .ASCIICapable {
    didSet {
      textFieldℹ?.keyboardType = keyboardType
      textViewℹ?.keyboardType = keyboardType
    }
  }

  var autocapitalizationType: UITextAutocapitalizationType = .None {
    didSet {
      textFieldℹ?.autocapitalizationType = autocapitalizationType
      textViewℹ?.autocapitalizationType = autocapitalizationType
    }
  }

  var autocorrectionType: UITextAutocorrectionType = .No {
    didSet {
      textFieldℹ?.autocorrectionType = autocorrectionType
      textViewℹ?.autocorrectionType = autocorrectionType
    }
  }

  var spellCheckingType: UITextSpellCheckingType = .No {
    didSet {
      textFieldℹ?.spellCheckingType = spellCheckingType
      textViewℹ?.spellCheckingType = spellCheckingType
    }
  }

  var enablesReturnKeyAutomatically: Bool = false {
    didSet {
      textFieldℹ?.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
      textViewℹ?.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
    }
  }

  var keyboardAppearance: UIKeyboardAppearance = Bank.keyboardAppearance {
    didSet {
      textFieldℹ?.keyboardAppearance = keyboardAppearance
      textViewℹ?.keyboardAppearance = keyboardAppearance
    }
  }

  var secureTextEntry: Bool = false {
    didSet {
      textFieldℹ?.secureTextEntry = secureTextEntry
      textViewℹ?.secureTextEntry = secureTextEntry
    }
  }

  var shouldAllowReturnsInTextView = false

  var shouldUseIntegerKeyboard: Bool = false {
    didSet {
      if let input = textFieldℹ {
        input.inputView = shouldUseIntegerKeyboard
                            ? MSIntegerInputView(frame: CGRect(x: 0, y: 0, width: 320, height: 216), target: input)
                            : nil
      }
    }
  }

  /// MARK: Stepper settings
  ////////////////////////////////////////////////////////////////////////////////


  var stepperWraps:     Bool?   { get { return stepper?.wraps        } set { stepper?.wraps = newValue ?? true              } }
  var stepperMinValue:  Double? { get { return stepper?.minimumValue } set { stepper?.minimumValue = newValue ?? 0.0        } }
  var stepperMaxValue:  Double? { get { return stepper?.maximumValue } set { stepper?.maximumValue = newValue ?? 0.0        } }
  var stepperStepValue: Double? { get { return stepper?.stepValue    } set { stepper?.stepValue = max(newValue ?? 1.0, 1.0) } }


  /// MARK: Name and info properties
  ////////////////////////////////////////////////////////////////////////////////


  var name: String? { get { return nameLabel?.text } set { nameLabel?.text = newValue } }



  /** A simple enum to specify kinds of data */
  enum DataType {
    case IntData(ClosedInterval<Int32>)
    case IntegerData(ClosedInterval<Int>)
    case LongLongData(ClosedInterval<Int64>)
    case FloatData(ClosedInterval<Float>)
    case DoubleData(ClosedInterval<Double>)
    case StringData

    /**
    objectFromText:

    :param: text String?

    :returns: NSObject?
    */
    func objectFromText(text: String?) -> NSObject? {
      if let t = text {
        let scanner = NSScanner.localizedScannerWithString(t) as NSScanner
        switch self {
          case .IntData(let r):
            var n: Int32 = 0
            if scanner.scanInt(&n) && r ∋ n { return NSNumber(int: n) }
          case .IntegerData(let r):
            var n: Int = 0
            if scanner.scanInteger(&n) && r ∋ n { return NSNumber(long: n) }
          case .LongLongData(let r):
            var n: Int64 = 0
            if scanner.scanLongLong(&n) && r ∋ n { return NSNumber(longLong: n) }
          case .FloatData(let r):
            var n: Float = 0
            if scanner.scanFloat(&n) && r ∋ n { return NSNumber(float: n) }
          case .DoubleData(let r):
            var n: Double = 0
            if scanner.scanDouble(&n) && r ∋ n { return NSNumber(double: n) }
          case .StringData:
            return t
        }
      }
      return nil
    }
  }

  var infoDataType: DataType = .StringData

  /**
  textFromObject:dataType:

  :param: obj AnyObject
  :param: dataType DataType = .StringData

  :returns: String
  */
  func textFromObject(object: AnyObject?) -> String? {

    var text: String?

    if let string = object as? String {
      text = string
    } else if let obj: AnyObject = object {
      if obj.respondsToSelector("name") {
        text = obj.valueForKey("name") as? String
      } else {
        text = "\(obj)"
      }
    }

    return text

  }

  var info: AnyObject? {
    get {
      switch identifier {
        case .Label, .List:      return labelℹ?.text
        case .Button, .Detail:   return buttonℹ?.titleForState(.Normal)
        case .Image:             return imageℹ?.image
        case .Switch:            return switchℹ?.on
        case .Stepper:           return stepper?.value
        case .TextView:          return infoDataType.objectFromText(textViewℹ?.text)
        case .TextField:         return infoDataType.objectFromText(textFieldℹ?.text)
      }
    }
    set {
      switch identifier {
        case .Label, .List:
          labelℹ?.text = textFromObject(newValue)
        case .Button, .Detail:
          buttonℹ?.setTitle(textFromObject(newValue), forState:.Normal)
        case .Image:
          imageℹ?.image = newValue as? UIImage
          if let imageSize = (newValue as? UIImage)?.size {
            imageℹ?.contentMode = CGSizeContainsSize(bounds.size, imageSize) ? .Center : .ScaleAspectFit
          }
        case .Switch:
          switchℹ?.on = newValue as? Bool ?? false
        case .Stepper:
          stepper?.value = newValue as? Double ?? 0.0
          labelℹ?.text = textFromObject(newValue)
        case .TextView:
          textViewℹ?.text = textFromObject(newValue)
        case .TextField:
          textFieldℹ?.text = textFromObject(newValue)
      }
    }
  }


  /// MARK: Content subviews
  ////////////////////////////////////////////////////////////////////////////////


  private weak var nameLabel: UILabel?
  private weak var buttonℹ: UIButton?
  private weak var imageℹ: UIImageView?
  private weak var switchℹ: UISwitch?
  private weak var labelℹ: UILabel?
  private weak var stepper: UIStepper?
  private weak var textFieldℹ: UITextField?
  private weak var textViewℹ: UITextView?
  private weak var picker: UIPickerView!


  /// MARK: Miscellaneous properties
  ////////////////////////////////////////////////////////////////////////////////


  private var beginStateText: String?  // Stores pre-edited text field/view content


  /// MARK: Picker settings
  ////////////////////////////////////////////////////////////////////////////////

  class var pickerHeight: CGFloat { return 162.0 }

  var pickerData: [NSObject]? {
    didSet {
      pickerEnabled = pickerData != nil
      picker.reloadAllComponents()
    }
  }

  var pickerSelection: NSObject? {
    didSet {
      info = pickerSelection ?? pickerNilSelectionTitle
      if picker.hidden == false {
        picker.selectRow(pickerSelectionIndex, inComponent: 0, animated: true)
      }
    }
  }

  var pickerSelectionIndex: Int {
    if let idx = find(pickerData!, pickerSelection) {
      return idx + prependedPickerItemCount
    } else {
      return 0
    }
  }

  var pickerNilSelectionTitle: String? {
    didSet { prependedPickerItemCount = pickerNilSelectionTitle != nil ? 1 : 0 }
  }

  var pickerCreateSelectionTitle: String? {
    didSet { appendedPickerItemCount = pickerCreateSelectionTitle != nil ? 1 : 0 }
  }

  var pickerEnabled = false
  var prependedPickerItemCount = 0
  var appendedPickerItemCount = 0

  var pickerItemCount: Int {
    var count = prependedPickerItemCount + appendedPickerItemCount
    if pickerData != nil { count += pickerData!.count }
    return count
  }

  /**
  pickerDataItemForRow:

  :param: row Int

  :returns: NSObject?
  */
  func pickerDataItemForRow(row: Int) -> NSObject? {
    if prependedPickerItemCount > 0 && row == 0 { return pickerNilSelectionTitle }
    else if appendedPickerItemCount > 0 && row == pickerItemCount - 1 { return pickerCreateSelectionTitle }
    else { return pickerData?[row - prependedPickerItemCount] }
  }

  /** togglePicker */
  func togglePicker() { if picker.hidden { showPickerView() } else { hidePickerView() } }

  /** showPickerView */
  func showPickerView() {
    precondition(pickerEnabled, "method should only be called when picker is enabled")
    if !picker.hidden { return }                                  		// Make sure picker is actually hidden
    if shouldShowPicker ∅|| shouldShowPicker!(self) {             	// Check if we should show the picker
      picker.selectRow(pickerSelectionIndex, inComponent: 0, animated: false)
//      if let idx = find(pickerData!, pickerSelection) {         	  	// Check if we have a picker selection set
//          picker.selectRow(idx + prependedPickerItemCount, inComponent: 0, animated: false)
//      } else if pickerNilSelectionTitle != nil {                  		// Check if we have a title set for empty selections
//        picker.selectRow(0, inComponent: 0, animated: false)
//      }
      picker.hidden = false
      didShowPicker?(self)
    }
  }

  /** hidePickerView */
  func hidePickerView() {
    precondition(pickerEnabled, "method should only be called when picker is enabled")
    if picker.hidden { return }                                  		// Make sure picker is actually visible
    if shouldHidePicker ∅|| shouldHidePicker!(self) {             	// Check if we should hide the picker
      picker.hidden = true
      textFieldℹ?.resignFirstResponder()
      didHidePicker?(self)
    }
  }


  /// MARK: Initializers
  ////////////////////////////////////////////////////////////////////////////////


  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewStyle
  :param: reuseIdentifier String
  */
  override init?(style: UITableViewCellStyle, reuseIdentifier: String?) {
    identifier = Identifier(rawValue: reuseIdentifier ?? "") ?? .Label
    super.init(style:style, reuseIdentifier: reuseIdentifier)
//    shouldIndentWhileEditing = false
    selectionStyle = .None
    picker = {
      let view = UIPickerView()
      view.setTranslatesAutoresizingMaskIntoConstraints(false)
//      view.backgroundColor = UIColor.yellowColor()
      view.delegate = self
      view.dataSource = self
      view.hidden = true
      self.addSubview(view)
      return view
      }()
      constrainWithFormat("|[picker]| :: V:[picker(==\(BankItemCell.pickerHeight))]|",
                    views: ["picker": picker])

    switch identifier {
      case .Label:
        contentView.constrainWithFormat(nameAndInfoCenterYConstraints,
                                 views: ["name": addNameLabel(self),
                                         "info": addLabel(self)])

      case .List:
        contentView.constrainWithFormat(infoConstraints,
                                 views: ["info": addLabel(self)])

      case .Button:
        contentView.constrainWithFormat(nameAndInfoCenterYConstraints,
                                 views: ["name": addNameLabel(self),
                                         "info": addButton(self)])

      case .Image:
        contentView.constrainWithFormat(thumbnailViewInfoConstraints,
                                 views: ["info": addImageView(self)])

      case .Switch:
        contentView.constrainWithFormat(nameAndInfoCenterYConstraints,
                                 views: ["name": addNameLabel(self),
                                         "info": addSwitch(self)])

      case .Stepper:
        contentView.constrainWithFormat(nameInfoAndStepperConstraints,
                                 views: ["name": addNameLabel(self),
                                         "info": addLabel(self),
                                         "stepper": addStepper(self)])

      case .Detail:
        accessoryType = .DisclosureIndicator
        contentView.constrainWithFormat(nameAndInfoCenterYConstraints,
                                 views: ["name": addNameLabel(self),
                                         "info": addButton(self)])

      case .TextView:
        contentView.constrainWithFormat(nameAndTextViewInfoConstraints,
                                 views: ["name": addNameLabel(self),
                                         "info": addTextView(self)])

      case .TextField:
        contentView.constrainWithFormat(nameAndInfoCenterYConstraints,
                                 views: ["name": addNameLabel(self),
                                         "info": addTextField(self)])
    }

  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { identifier = .Label; super.init(coder: aDecoder) }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    nameLabel?.text = nil
    buttonℹ?.setTitle(nil, forState: .Normal)
    imageℹ?.image = nil
    imageℹ?.contentMode = .ScaleAspectFit
    switchℹ?.on = false
    labelℹ?.text = nil
    stepper?.value = 0.0
    stepper?.minimumValue = Double(CGFloat.min)
    stepper?.maximumValue = Double(CGFloat.max)
    stepper?.wraps = true
    textFieldℹ?.text = nil
    textViewℹ?.text = nil
    pickerData = nil
    pickerSelection = nil
  }


  /// MARK: Action callbacks
  ////////////////////////////////////////////////////////////////////////////////


  /**
  stepperValueDidChange:

  :param: sender UIStepper
  */
  func stepperValueDidChange(sender: UIStepper) {
    changeHandler?(sender.value)
    labelℹ?.text = textFromObject(sender.value)
  }

  /**
  buttonUpAction:

  :param: sender UIButton
  */
  func buttonUpAction(sender: UIButton) {
    if isEditingState {
      buttonEditingActionHandler?()
      if pickerEnabled { togglePicker() }
    } else {
      buttonActionHandler?()
    }
  }

  /**
  switchValueDidChange:

  :param: sender UISwitch
  */
  func switchValueDidChange(sender: UISwitch) { changeHandler?(NSNumber(bool: sender.on)) }


  /// MARK: UITableViewCell
  ////////////////////////////////////////////////////////////////////////////////

  var isEditingState: Bool = false {
    didSet {
      switch identifier {
          case .Button:  buttonℹ?.userInteractionEnabled = isEditingState
          case .Switch:  switchℹ?.userInteractionEnabled = isEditingState
          case .Stepper:
            stepper?.userInteractionEnabled = isEditingState
            if let infoTrailing = contentView.constraintWithIdentifier("info trailing") {
              if let stepperLeading = contentView.constraintWithIdentifier("stepper leading") {
                infoTrailing.constant = isEditingState ? -8.0 : -20.0
                stepperLeading.constant = isEditingState ? -20.0 - (stepper?.bounds.size.width ?? 0.0) : 0.0
              }
            }
          case .TextView:
            textViewℹ!.userInteractionEnabled  = isEditingState
            if textViewℹ!.isFirstResponder() { textViewℹ!.resignFirstResponder() }
          case .TextField:
            textFieldℹ!.userInteractionEnabled = isEditingState
            if textFieldℹ!.isFirstResponder() { textFieldℹ!.resignFirstResponder() }
          default: break
      }
      if !picker.hidden { hidePickerView() }
    }
  }

}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - UITextFieldDelegate
////////////////////////////////////////////////////////////////////////////////
extension BankItemCell: UITextFieldDelegate {

  /**
  textFieldDidBeginEditing:

  :param: textField UITextField
  */
  func textFieldDidBeginEditing(textField: UITextField) {
    beginStateText = textField.text
    if pickerData != nil { showPickerView() }
  }

  /**
  textFieldDidEndEditing:

  :param: textField UITextField
  */
  func textFieldDidEndEditing(textField: UITextField) {
    if textField.text != beginStateText { changeHandler?(infoDataType.objectFromText(textField.text)) }
    if picker != nil && !picker!.hidden { hidePickerView() }
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

    if shouldEnd { shouldEnd = validationHandler?(textField.text) ?? true }

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

////////////////////////////////////////////////////////////////////////////////
/// MARK: - UITextViewDelegate
////////////////////////////////////////////////////////////////////////////////
extension BankItemCell: UITextViewDelegate {

  /**
  textViewDidBeginEditing:

  :param: textView UITextView
  */
  func textViewDidBeginEditing(textView: UITextView) { beginStateText = textView.text }

  /**
  textViewDidEndEditing:

  :param: textView UITextView
  */
  func textViewDidEndEditing(textView: UITextView) { if textView.text != beginStateText { changeHandler?(textView.text) } }

  /**
  textViewShouldEndEditing:

  :param: textView UITextView

  :returns: Bool
  */
  func textViewShouldEndEditing(textView: UITextView) -> Bool { return validationHandler?(textView.text) ?? true }

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

}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - UIPickerViewDataSource
////////////////////////////////////////////////////////////////////////////////
extension BankItemCell: UIPickerViewDataSource {


  /**
  numberOfComponentsInPickerView:

  :param: pickerView UIPickerView

  :returns: Int
  */
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int { return 1 }

  /**
  pickerView:numberOfRowsInComponent:

  :param: pickerView UIPickerView
  :param: component Int

  :returns: Int
  */
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerItemCount
  }

  /**
  pickerView:titleForRow:forComponent:

  :param: pickerView UIPickerView
  :param: row Int
  :param: component Int

  :returns: String?
  */
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return textFromObject(pickerDataItemForRow(row))
  }

}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - UIPickerViewDelegate
////////////////////////////////////////////////////////////////////////////////
extension BankItemCell: UIPickerViewDelegate {

  /**
  pickerView:didSelectRow:inComponent:

  :param: pickerView UIPickerView
  :param: row Int
  :param: component Int
  */
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

    if appendedPickerItemCount > 0 && row == pickerItemCount - 1 { pickerCreateSelectionHandler?() }
    else {
      if prependedPickerItemCount > 0 && row == 0 { pickerSelection = nil }
      else { pickerSelection = pickerData?[row - prependedPickerItemCount] }
      pickerSelectionHandler?(pickerSelection)
      // hidePickerView()
    }
  }

}

/// Create some more or less generic constraint strings for use in decorator blocks
///////////////////////////////////////////////////////////////////////////////////

private let nameAndInfoCenterYConstraints  = "\n".join([
  "|-20-[name]-8-[info]-20-|",
  "name.centerY = info.centerY",
  "name.height = info.height",
  "V:|-8-[name]"
  ])

private let infoConstraints = "|-20-[info]-20-| :: V:|-8-[info]-8-|"

private let nameAndTextViewInfoConstraints = "V:|-8-[name]-8-[info]-8-| :: |-20-[name]-(>=20)-| :: |-20-[info]-20-|"

private let nameInfoAndStepperConstraints  = "\n".join([
  "|-20-[name]-8-[info]",
  "'info trailing' info.trailing = stepper.leading - 20",
  "name.centerY = info.centerY",
  "name.height = info.height",
  "'stepper leading' stepper.leading = self.trailing",
  "stepper.centerY = name.centerY",
  "V:|-8-[name]-8-|"
  ])

private let thumbnailViewInfoConstraints = "|-20-[info]-20-| :: V:|-8-[info]-8-|"


/// MARK: - Helper functions for adding subviews per identfier style
////////////////////////////////////////////////////////////////////////////////

/**
addNameLabel:

:param: cell BankItemCell

:returns: UILabel
*/
private func addNameLabel(cell: BankItemCell) -> UILabel {

  let name = UILabel()
  name.setTranslatesAutoresizingMaskIntoConstraints(false)
  name.setContentHuggingPriority(750.0, forAxis:.Horizontal)
  name.font      = Bank.labelFont
  name.textColor = Bank.labelColor
  cell.contentView.addSubview(name)
  cell.nameLabel = name

  return name

}

/**
addInfoView:cell:

:param: info UIView
:param: cell BankItemCell

:returns: UIView
*/
private func addInfoView(info: UIView, cell: BankItemCell) {
  info.setTranslatesAutoresizingMaskIntoConstraints(false)
  cell.contentView.addSubview(info)
  info.setContentCompressionResistancePriority(750.0, forAxis:.Vertical)
  info.userInteractionEnabled = false
}

/**
addLabel:

:param: cell BankItemCell

:returns: UILabel
*/
private func addLabel(cell: BankItemCell) -> UILabel {
  let view = UILabel()
  addInfoView(view, cell)
//  view.backgroundColor = UIColor.cyanColor()
  view.font = Bank.infoFont
  view.textColor = Bank.infoColor
  view.textAlignment = .Right
  cell.labelℹ = view
  return view
}

/**
addButton:

:param: cell BankItemCell

:returns: UIButton
*/
private func addButton(cell: BankItemCell) -> UIButton {
  let view = UIButton()
  addInfoView(view, cell)
//  view.backgroundColor = UIColor.brownColor()
  view.titleLabel?.font = Bank.infoFont;
  view.titleLabel?.textAlignment = .Right;
  view.constrainWithFormat("|[title]| :: V:|[title]|", views: ["title": view.titleLabel!])
  view.setTitleColor(Bank.infoColor, forState:.Normal)
  view.addTarget(cell, action:"buttonUpAction:", forControlEvents:.TouchUpInside)
  cell.buttonℹ = view
  return view
}

/**
addSwitch:

:param: cell BankItemCell

:returns: UISwitch
*/
private func addSwitch(cell: BankItemCell) -> UISwitch {
  let view = UISwitch()
  addInfoView(view, cell)
//  view.backgroundColor = UIColor.magentaColor()
  view.addTarget(cell, action:"switchValueDidChange:", forControlEvents:.ValueChanged)
  cell.switchℹ = view
  return view
}

/**
addStepper:

:param: cell BankItemCell

:returns: UIStepper
*/
private func addStepper(cell: BankItemCell) -> UIStepper {
  let view = UIStepper()
  addInfoView(view, cell)
//  view.backgroundColor = UIColor.redColor()
  view.addTarget(cell, action:"stepperValueDidChange:", forControlEvents:.ValueChanged)
  cell.stepper = view
  return view
}

/**
addImageView:

:param: cell BankItemCell

:returns: UIImageView
*/
private func addImageView(cell: BankItemCell) -> UIImageView {
  let view = UIImageView()
  addInfoView(view, cell)
//  view.backgroundColor = UIColor.orangeColor()
  view.contentMode = .ScaleAspectFit
  view.tintColor = UIColor.blackColor()
  view.backgroundColor = UIColor.clearColor()
  cell.imageℹ = view
  return view
}

/**
addTextField:

:param: cell BankItemCell

:returns: UITextField
*/
private func addTextField(cell: BankItemCell) -> UITextField {
  let view = UITextField()
  addInfoView(view, cell)
//  view.backgroundColor = UIColor.blueColor()
  view.font = Bank.infoFont
  view.textColor = Bank.infoColor
  view.textAlignment = .Right
  view.delegate = cell
  view.returnKeyType = cell.returnKeyType
  view.keyboardType = cell.keyboardType
  view.autocapitalizationType = cell.autocapitalizationType
  view.autocorrectionType = cell.autocorrectionType
  view.spellCheckingType = cell.spellCheckingType
  view.enablesReturnKeyAutomatically = cell.enablesReturnKeyAutomatically
  view.keyboardAppearance = cell.keyboardAppearance
  view.secureTextEntry = cell.secureTextEntry
  cell.textFieldℹ = view
  return view
}

/**
addTextView:

:param: cell BankItemCell

:returns: UITextView
*/
private func addTextView(cell: BankItemCell) -> UITextView {
  let view = UITextView()
  addInfoView(view, cell)
//  view.backgroundColor = UIColor.purpleColor()
  view.font = Bank.infoFont
  view.textColor = Bank.infoColor
  view.delegate = cell
  view.returnKeyType = cell.returnKeyType
  view.keyboardType = cell.keyboardType
  view.autocapitalizationType = cell.autocapitalizationType
  view.autocorrectionType = cell.autocorrectionType
  view.spellCheckingType = cell.spellCheckingType
  view.enablesReturnKeyAutomatically = cell.enablesReturnKeyAutomatically
  view.keyboardAppearance = cell.keyboardAppearance
  view.secureTextEntry = cell.secureTextEntry
  cell.textViewℹ = view
  return view
}
