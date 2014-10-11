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

@objc(BankItemCell)
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
    case Table     = "BankItemDetailTableCell"
  }

  /**
  registerIdentifiersWithTableView:

  :param: tableView UITableView
  */
  class func registerIdentifiersWithTableView(tableView: UITableView) {
    let identifiers: [Identifier] =
      [.Label, .List, .Button, .Image, .Switch, .Stepper, .Detail, .TextView, .TextField, .Table]
    for identifier in identifiers { tableView.registerClass(self, forCellReuseIdentifier: identifier.rawValue) }
  }


  /// MARK: Handlers
  ////////////////////////////////////////////////////////////////////////////////


  var changeHandler          : ((BankItemCell) -> Void)?
  var validationHandler      : ((BankItemCell) -> Bool)?
  var pickerSelectionHandler : ((NSObject?) -> Void)?
  var buttonActionHandler    : ((BankItemCell) -> Void)?
  var rowSelectionHandler    : ((BankItemCell) -> Void)?
  var shouldShowPicker       : ((BankItemCell) -> Bool)?
  var shouldHidePicker       : ((BankItemCell) -> Bool)?
  var didShowPicker          : ((BankItemCell) -> Void)?
  var didHidePicker          : ((BankItemCell) -> Void)?


  /// MARK: Keyboard settings
  ////////////////////////////////////////////////////////////////////////////////


  var returnKeyType: UIReturnKeyType = .Done {
    didSet {
      textFieldℹ︎?.returnKeyType = returnKeyType
      textViewℹ︎?.returnKeyType = returnKeyType
    }
  }

  var keyboardType: UIKeyboardType = .ASCIICapable {
    didSet {
      textFieldℹ︎?.keyboardType = keyboardType
      textViewℹ︎?.keyboardType = keyboardType
    }
  }

  var autocapitalizationType: UITextAutocapitalizationType = .None {
    didSet {
      textFieldℹ︎?.autocapitalizationType = autocapitalizationType
      textViewℹ︎?.autocapitalizationType = autocapitalizationType
    }
  }

  var autocorrectionType: UITextAutocorrectionType = .No {
    didSet {
      textFieldℹ︎?.autocorrectionType = autocorrectionType
      textViewℹ︎?.autocorrectionType = autocorrectionType
    }
  }

  var spellCheckingType: UITextSpellCheckingType = .No {
    didSet {
      textFieldℹ︎?.spellCheckingType = spellCheckingType
      textViewℹ︎?.spellCheckingType = spellCheckingType
    }
  }

  var enablesReturnKeyAutomatically: Bool = false {
    didSet {
      textFieldℹ︎?.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
      textViewℹ︎?.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
    }
  }

  var keyboardAppearance: UIKeyboardAppearance = Bank.keyboardAppearance {
    didSet {
      textFieldℹ︎?.keyboardAppearance = keyboardAppearance
      textViewℹ︎?.keyboardAppearance = keyboardAppearance
    }
  }

  var secureTextEntry: Bool = false {
    didSet {
      textFieldℹ︎?.secureTextEntry = secureTextEntry
      textViewℹ︎?.secureTextEntry = secureTextEntry
    }
  }

  var shouldAllowReturnsInTextView = false

  var shouldUseIntegerKeyboard: Bool = false {
    didSet {
      if let input = textFieldℹ︎ {
        input.inputView = shouldUseIntegerKeyboard
                            ? MSIntegerInputView(frame: CGRect(x: 0, y: 0, width: 320, height: 216), target: input)
                            : nil
      }
    }
  }


  /// MARK: Table settings
  ////////////////////////////////////////////////////////////////////////////////


  var tableIdentifier: Identifier = .List
  var tableData:       [NSObject]?
  var tableSelection:  NSObject?

  var shouldAllowRowSelection: Bool? {
    get { return tableℹ?.allowsSelection }
    set { tableℹ?.allowsSelection = newValue ?? false }
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
  }

  var infoDataType: DataType = .StringData

  /**
  textFromObject:dataType:

  :param: obj AnyObject
  :param: dataType DataType = .StringData

  :returns: String
  */
  private func textFromObject(obj: AnyObject?, dataType: DataType = .StringData) -> String {
    var text = ""
    if let string = obj as? String { text = string }
    else if let number = obj as? NSNumber { text = "\(number)" }
    else if obj != nil {
      if obj!.respondsToSelector("name") { if let name = obj!.valueForKey("name") as? String { text = name } }
      else { text = "\(obj)" }
    }
    return text
  }

  /**
  numberFromText:dataType:

  :param: text String?
  :param: dataType DataType = .IntegerData(Int.min...Int.max)

  :returns: NSNumber?
  */
  private func numberFromText(text: String?, dataType: DataType = .IntegerData(Int.min...Int.max)) -> NSNumber? {
    var number: NSNumber?
    if text != nil {
      switch dataType {
      case .IntData(let r):
        let scanner = NSScanner.localizedScannerWithString(text!) as NSScanner
        var n: Int32 = 0
        if scanner.scanInt(&n) && r ∋ n { number = NSNumber(int: n) }
      case .IntegerData(let r):
        let scanner = NSScanner.localizedScannerWithString(text!) as NSScanner
        var n: Int = 0
        if scanner.scanInteger(&n) && r ∋ n { number = NSNumber(long: n) }
        if r ∌ n { return false }
      case .LongLongData(let r):
        let scanner = NSScanner.localizedScannerWithString(text!) as NSScanner
        var n: Int64 = 0
        if scanner.scanLongLong(&n) && r ∋ n { number = NSNumber(longLong: n) }
        if r ∌ n { return false }
      case .FloatData(let r):
        let scanner = NSScanner.localizedScannerWithString(text!) as NSScanner
        var n: Float = 0
        if scanner.scanFloat(&n) && r ∋ n { number = NSNumber(float: n) }
        if r ∌ n { return false }
      case .DoubleData(let r):
        let scanner = NSScanner.localizedScannerWithString(text!) as NSScanner
        var n: Double = 0
        if scanner.scanDouble(&n) && r ∋ n { number = NSNumber(double: n) }
        if r ∌ n { return false }
      default:
        break
      }
    }
    return number
  }

  var info: AnyObject? {
    get {
      switch identifier {
        case .Label, .List:      return labelℹ︎?.text
        case .Button, .Detail:   return buttonℹ︎?.titleForState(.Normal)
        case .Image:             return imageℹ︎?.image
        case .Switch:            return switchℹ︎?.on
        case .Stepper:           return stepper?.value
        case .TextView:          return numberFromText(textViewℹ︎?.text, dataType: infoDataType) ?? textViewℹ︎?.text
        case .TextField:         return numberFromText(textFieldℹ︎?.text, dataType: infoDataType) ?? textFieldℹ︎?.text
        case .Table:             return tableData
      }
    }
    set {
      switch identifier {
        case .Label, .List:
          labelℹ︎?.text = textFromObject(newValue)
        case .Button, .Detail:
          buttonℹ︎?.setTitle(textFromObject(newValue), forState:.Normal)
        case .Image:
          imageℹ︎?.image = newValue as? UIImage
          if let imageSize = (newValue as? UIImage)?.size {
            imageℹ︎?.contentMode = CGSizeContainsSize(bounds.size, imageSize) ? .Center : .ScaleAspectFit
          }
        case .Switch:
          switchℹ︎?.on = newValue as? Bool ?? false
        case .Stepper:
          stepper?.value = newValue as? Double ?? 0.0
          labelℹ︎?.text = textFromObject(newValue, dataType: infoDataType)
        case .TextView:
          textViewℹ︎?.text = textFromObject(newValue, dataType: infoDataType)
        case .TextField:
          textFieldℹ︎?.text = textFromObject(newValue, dataType: infoDataType)
        case .Table:
          tableData = newValue as? [NSObject]
          tableℹ?.reloadData()
      }
    }
  }


  /// MARK: Content subviews
  ////////////////////////////////////////////////////////////////////////////////


  private weak var tableℹ: UITableView?
  private weak var nameLabel: UILabel?
  private weak var buttonℹ︎: UIButton?
  private weak var imageℹ︎: UIImageView?
  private weak var switchℹ︎: UISwitch?
  private weak var labelℹ︎: UILabel?
  private weak var stepper: UIStepper?
  private weak var textFieldℹ︎: UITextField?
  private weak var textViewℹ︎: UITextView?
  private weak var picker: UIPickerView!


  /// MARK: Miscellaneous properties
  ////////////////////////////////////////////////////////////////////////////////


  private var beginStateText: String?  // Stores pre-edited text field/view content


  /// MARK: Picker settings
  ////////////////////////////////////////////////////////////////////////////////

  class var pickerHeight: CGFloat { return 162.0 }
  var pickerEnabled = false
  var pickerData: [NSObject]? { didSet { pickerEnabled = pickerData != nil } }
  var pickerSelection: NSObject?
  var pickerNilSelectionTitle: String? { didSet { if info == nil { info = pickerNilSelectionTitle } } }

  /** togglePicker */
  func togglePicker() { if picker.hidden { showPickerView() } else { hidePickerView() } }

  /** showPickerView */
  func showPickerView() {
    precondition(pickerEnabled, "method should only be called when picker is enabled")
    if !picker.hidden { return }                                  		// Make sure picker is actually hidden
    if shouldShowPicker ∅|| shouldShowPicker!(self) {             	// Check if we should show the picker
      if pickerSelection != nil {                                 		// Check if we have a picker selection set
        if let idx = find(pickerData!, pickerSelection!) {
          picker.selectRow(pickerNilSelectionTitle != nil ? idx + 1 : idx, inComponent: 0, animated: false)
        }
      } else if pickerNilSelectionTitle != nil {                  		// Check if we have a title set for empty selections
        picker.selectRow(0, inComponent: 0, animated: false)
      }
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
      if textFieldℹ︎ != nil && textFieldℹ︎!.isFirstResponder() { textFieldℹ︎?.resignFirstResponder() }
      didHidePicker?(self)
    }
  }

  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewStyle
  :param: reuseIdentifier String
  */
  override init?(style: UITableViewCellStyle, reuseIdentifier: String?) {
    identifier = Identifier(rawValue: reuseIdentifier ?? "") ?? .Label
    super.init(style:style, reuseIdentifier: reuseIdentifier)
    contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
    picker = {
      let view = UIPickerView.newForAutolayout()
      view.delegate = self
      view.dataSource = self
      view.hidden = true
      self.addSubview(view)
      return view
      }()
      constrainWithFormat("|[content]| :: V:|[content]| :: |[picker]| :: V:[picker(==\(BankItemCell.pickerHeight))]|",
                    views: ["content": contentView, "picker": picker])



    /// Create some more or less generic constraint strings for use in decorator blocks
    ////////////////////////////////////////////////////////////////////////////////

    let nameAndInfoCenterYConstraints  = "\n".join(["|-20-[name]-8-[info]-20-|",
                                                    "name.centerY = info.centerY",
                                                    "name.height = info.height",
                                                    "V:|-8-[name]-8-|"])

    let infoConstraints = "|-20-[info]-20-| :: V:|-8-[info]-8-|"

    let infoDisclosureConstraints = "|-20-[info]-75-| :: V:|-8-[info]-8-|"

    let nameAndTextViewInfoConstraints = "V:|-8-[name]-8-[info]-8-| :: |-20-[name]-(>=20)-| :: |-20-[info]-20-|"

    let tableViewInfoConstraints = "|-20-[info]-20-| :: V:|-8-[info]-8-|"

    let nameInfoAndStepperConstraints  = "\n".join(["|-20-[name]-8-[info]",
                                                    "'info trailing' info.trailing = stepper.leading - 20",
                                                    "name.centerY = info.centerY",
                                                    "name.height = info.height",
                                                    "'stepper leading' stepper.leading = self.trailing",
                                                    "stepper.centerY = name.centerY",
                                                    "V:|-8-[name]-8-|"])

    let imageViewInfoConstraints = "|-20-[info]-20-| :: V:|-8-[info]-8-|"


    /// Create some generic blocks to add name and info views
    ////////////////////////////////////////////////////////////////////////////////

    let addName = {(name: UILabel, cell: BankItemCell) -> UILabel in

      name.setTranslatesAutoresizingMaskIntoConstraints(false)
      name.setContentHuggingPriority(750.0, forAxis:.Horizontal)
      name.font      = Bank.labelFont
      name.textColor = Bank.labelColor
      cell.contentView.addSubview(name)
      cell.nameLabel = name

      return name

    }

    let addInfo = {(info: NSObject, cell: BankItemCell) -> NSObject in

      if let view = info as? UIView {
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        cell.contentView.addSubview(view)
        view.setContentCompressionResistancePriority(750.0, forAxis:.Vertical)
        view.userInteractionEnabled = false
      }

      if let labelℹ︎ = info as? UILabel {
        labelℹ︎.font = Bank.infoFont
        labelℹ︎.textColor = Bank.infoColor
        labelℹ︎.textAlignment = .Right
        cell.labelℹ︎ = labelℹ︎
      }

      else if let buttonℹ︎ = info as? UIButton {
        buttonℹ︎.titleLabel?.font = Bank.infoFont;
        buttonℹ︎.titleLabel?.textAlignment = .Right;
        buttonℹ︎.constrainWithFormat("|[title]| :: V:|[title]|", views: ["title": buttonℹ︎.titleLabel!])
        buttonℹ︎.setTitleColor(Bank.infoColor, forState:.Normal)
        buttonℹ︎.addTarget(cell, action:"buttonUpAction:", forControlEvents:.TouchUpInside)
        cell.buttonℹ︎ = buttonℹ︎
      }

      else if let textFieldℹ︎ = info as? UITextField {
        textFieldℹ︎.font = Bank.infoFont
        textFieldℹ︎.textColor = Bank.infoColor
        textFieldℹ︎.textAlignment = .Right
        textFieldℹ︎.delegate = cell
        textFieldℹ︎.returnKeyType = cell.returnKeyType
        textFieldℹ︎.keyboardType = cell.keyboardType
        textFieldℹ︎.autocapitalizationType = cell.autocapitalizationType
        textFieldℹ︎.autocorrectionType = cell.autocorrectionType
        textFieldℹ︎.spellCheckingType = cell.spellCheckingType
        textFieldℹ︎.enablesReturnKeyAutomatically = cell.enablesReturnKeyAutomatically
        textFieldℹ︎.keyboardAppearance = cell.keyboardAppearance
        textFieldℹ︎.secureTextEntry = cell.secureTextEntry
        cell.textFieldℹ︎ = textFieldℹ︎
      }

      else if let textViewℹ︎ = info as? UITextView {
        textViewℹ︎.font = Bank.infoFont
        textViewℹ︎.textColor = Bank.infoColor
        textViewℹ︎.delegate = cell
        textViewℹ︎.returnKeyType = cell.returnKeyType
        textViewℹ︎.keyboardType = cell.keyboardType
        textViewℹ︎.autocapitalizationType = cell.autocapitalizationType
        textViewℹ︎.autocorrectionType = cell.autocorrectionType
        textViewℹ︎.spellCheckingType = cell.spellCheckingType
        textViewℹ︎.enablesReturnKeyAutomatically = cell.enablesReturnKeyAutomatically
        textViewℹ︎.keyboardAppearance = cell.keyboardAppearance
        textViewℹ︎.secureTextEntry = cell.secureTextEntry
        cell.textViewℹ︎ = textViewℹ︎
      }

      else if let imageℹ︎ = info as? UIImageView {
        imageℹ︎.contentMode = .ScaleAspectFit
        imageℹ︎.tintColor = UIColor.blackColor()
        imageℹ︎.backgroundColor = UIColor.clearColor()
        cell.imageℹ︎ = imageℹ︎
      }

      else if let infoTableView = info as? UITableView {
        infoTableView.separatorStyle = .None
        infoTableView.rowHeight = Bank.defaultRowHeight
        infoTableView.delegate = cell
        infoTableView.dataSource = cell
        BankItemCell.registerIdentifiersWithTableView(infoTableView)
        cell.tableℹ = infoTableView
      }

      else if let switchℹ︎ = info as? UISwitch {
        switchℹ︎.addTarget(cell, action:"switchValueDidChange:", forControlEvents:.ValueChanged)
        cell.switchℹ︎ = switchℹ︎
      }

      else if let stepper = info as? UIStepper {
        stepper.addTarget(cell, action:"stepperValueDidChange:", forControlEvents:.ValueChanged)
        cell.stepper = stepper
      }

      return info

    }

    /// Use blocks to create subviews switching on identifer
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    switch identifier {
      case .Label:
        let name = addName(UILabel(), self)
        let info = addInfo(UILabel(), self)
        contentView.constrainWithFormat(nameAndInfoCenterYConstraints, views: ["name": name, "info": info])

      case .List:
        let info = addInfo(UILabel(), self)
        contentView.constrainWithFormat(infoConstraints, views: ["info": info])

      case .Button:
        let name = addName(UILabel(), self)
        let info = addInfo(UIButton(), self)
        contentView.constrainWithFormat(nameAndInfoCenterYConstraints, views: ["name": name, "info": info])

      case .Image:
        let info = addInfo(UIImageView(), self)
        contentView.constrainWithFormat(imageViewInfoConstraints, views: ["info": info])

      case .Switch:
        let name = addName(UILabel(), self)
        let info = addInfo(UISwitch(), self)
        contentView.constrainWithFormat(nameAndInfoCenterYConstraints, views: ["name": name, "info": info])

      case .Stepper:
        let name    = addName(UILabel(), self)
        let info    = addInfo(UILabel(), self)
        let stepper = addInfo(UIStepper(), self)
        contentView.constrainWithFormat(nameInfoAndStepperConstraints, views: ["name": name, "info": info, "stepper": stepper])

      case .Detail:
        accessoryType = .DetailDisclosureButton
        let info = addInfo(UIButton(), self)
        contentView.constrainWithFormat(infoDisclosureConstraints, views: ["info": info])

      case .TextView:
        let name = addName(UILabel(), self)
        let info = addInfo(UITextView(), self)
        contentView.constrainWithFormat(nameAndTextViewInfoConstraints, views: ["name": name, "info": info])

      case .TextField:
        let name = addName(UILabel(), self)
        let info = addInfo(UITextField(), self)
        contentView.constrainWithFormat(nameAndInfoCenterYConstraints, views: ["name": name, "info": info])

      case .Table:
        let info = addInfo(UITableView(), self)
        contentView.constrainWithFormat(tableViewInfoConstraints, views: ["info": info])

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
    buttonℹ︎?.setTitle(nil, forState: .Normal)
    imageℹ︎?.image = nil
    imageℹ︎?.contentMode = .ScaleAspectFit
    switchℹ︎?.on = false
    labelℹ︎?.text = nil
    stepper?.value = 0.0
    stepper?.minimumValue = Double(CGFloat.min)
    stepper?.maximumValue = Double(CGFloat.max)
    stepper?.wraps = true
    textFieldℹ︎?.text = nil
    textViewℹ︎?.text = nil
    tableData = nil
    tableℹ?.reloadData()
    pickerData = nil
    pickerSelection = nil
  }

  /**
  stepperValueDidChange:

  :param: sender UIStepper
  */
  func stepperValueDidChange(sender: UIStepper) {
    changeHandler?(self)
    labelℹ︎?.text = textFromObject(sender.value, dataType: infoDataType)
  }

  /**
  buttonUpAction:

  :param: sender UIButton
  */
  func buttonUpAction(sender: UIButton) {
    buttonActionHandler?(self)
    if pickerEnabled { togglePicker() }
  }

  /**
  switchValueDidChange:

  :param: sender UISwitch
  */
  func switchValueDidChange(sender: UISwitch) { if let action = changeHandler { action(self) } }

  /**
  willTransitionToState:

  :param: state UITableViewCellStateMask
  */
  override func willTransitionToState(state: UITableViewCellStateMask) {
    let isEditingState: Bool = ((state & .ShowingEditControlMask) == .ShowingEditControlMask)
    switch identifier {
      case .Button:  buttonℹ︎?.userInteractionEnabled = isEditingState
      case .Switch:  switchℹ︎?.userInteractionEnabled = isEditingState
      case .Stepper:
        stepper?.userInteractionEnabled = isEditingState
        if let infoTrailing = contentView.constraintWithIdentifier("info trailing") {
          if let stepperLeading = contentView.constraintWithIdentifier("stepper leading") {
            infoTrailing.constant = isEditingState ? -8.0 : -20.0
            stepperLeading.constant = isEditingState ? -20.0 - (stepper?.bounds.size.width ?? 0.0) : 0.0
          }
        }
      case .TextView:  textViewℹ︎?.userInteractionEnabled  = isEditingState
      case .TextField: textFieldℹ︎?.userInteractionEnabled = isEditingState
      default: break
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
    if textField.text != beginStateText { if let action = changeHandler { action(self) } }
    if picker != nil && !picker!.hidden { hidePickerView() }
  }

  /**
  textFieldShouldEndEditing:

  :param: textField UITextField

  :returns: Bool
  */
  func textFieldShouldEndEditing(textField: UITextField) -> Bool {
    switch infoDataType {
      case .IntData(let r):
        let scanner = NSScanner.localizedScannerWithString(textField.text) as NSScanner
        var n: Int32 = 0
        if !scanner.scanInt(&n) { return false }
        if r ∌ n { return false }
      case .IntegerData(let r):
        let scanner = NSScanner.localizedScannerWithString(textField.text) as NSScanner
        var n: Int = 0
        if !scanner.scanInteger(&n) { return false }
        if r ∌ n { return false }
      case .LongLongData(let r):
        let scanner = NSScanner.localizedScannerWithString(textField.text) as NSScanner
        var n: Int64 = 0
        if !scanner.scanLongLong(&n) { return false }
        if r ∌ n { return false }
      case .FloatData(let r):
        let scanner = NSScanner.localizedScannerWithString(textField.text) as NSScanner
        var n: Float = 0
        if !scanner.scanFloat(&n) { return false }
        if r ∌ n { return false }
      case .DoubleData(let r):
        let scanner = NSScanner.localizedScannerWithString(textField.text) as NSScanner
        var n: Double = 0
        if !scanner.scanDouble(&n) { return false }
        if r ∌ n { return false }
       default:
         break
    }
    return validationHandler?(self) ?? true
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
  func textViewDidEndEditing(textView: UITextView) { if textView.text != beginStateText { changeHandler?(self) } }

  /**
  textViewShouldEndEditing:

  :param: textView UITextView

  :returns: Bool
  */
  func textViewShouldEndEditing(textField: UITextView) -> Bool { return validationHandler?(self) ?? true }

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
    var count = pickerData?.count ?? 0
    if pickerNilSelectionTitle != nil { count++ }
    return count
  }

  /**
  pickerView:titleForRow:forComponent:

  :param: pickerView UIPickerView
  :param: row Int
  :param: component Int

  :returns: String?
  */
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    if let nilTitle = pickerNilSelectionTitle {
      return row == 0 ? nilTitle : textFromObject(pickerData?[row - 1] ?? "")
    } else {
      return textFromObject(pickerData?[row] ?? "")
    }
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
    if pickerNilSelectionTitle != nil {
      if row == 0 {
        pickerSelection = nil
      } else {
        pickerSelection = pickerData?[row - 1]
      }
    } else {
      pickerSelection = pickerData?[row]
    }
    pickerSelectionHandler?(pickerSelection)
    info = pickerSelection
    hidePickerView()
  }

}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - UITableViewDataSource
////////////////////////////////////////////////////////////////////////////////
extension BankItemCell: UITableViewDataSource {


  /**
  numberOfSectionsInTableView:

  :param: tableView UITableView

  :returns: Int
  */
  func numberOfSectionsInTableView(tableView: UITableView) -> Int { return 1 }


  /**
  tableView:numberOfRowsInSection:

  :param: tableView UITableView
  :param: section Int

  :returns: Int
  */
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return tableData?.count ?? 0 }

  /**
  tableView:heightForRowAtIndexPath:

  :param: tableView UITableView
  :param: indexPath NSIndexPath

  :returns: CGFloat
  */
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return BankItemDetailController.defaultRowHeight
  }

  /**
  tableView:cellForRowAtIndexPath:

  :param: tableView UITableView
  :param: indexPath NSIndexPath

  :returns: UITableViewCell
  */
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(tableIdentifier.rawValue, forIndexPath: indexPath) as BankItemCell
    cell.info = tableData?[indexPath.row]
    return cell
  }

}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - UITableViewDelegate
////////////////////////////////////////////////////////////////////////////////
extension BankItemCell: UITableViewDelegate {}
