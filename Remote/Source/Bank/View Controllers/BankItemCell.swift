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

  /** A simple enum to specify kinds of data */
  enum DataType {
    case IntData(ClosedInterval<Int32>)
    case IntegerData(ClosedInterval<Int>)
    case LongLongData(ClosedInterval<Int64>)
    case FloatData(ClosedInterval<Float>)
    case DoubleData(ClosedInterval<Double>)
    case StringData
  }

  class var PickerHeight: CGFloat { return 162.0 }

	/**
	registerIdentifiersWithTableView:

	:param: tableView UITableView
	*/
	class func registerIdentifiersWithTableView(tableView: UITableView) {
    let identifiers: [Identifier] =
      [.Label, .List, .Button, .Image, .Switch, .Stepper, .Detail, .TextView, .TextField, .Table]
		for identifier in identifiers { tableView.registerClass(self, forCellReuseIdentifier: identifier.rawValue) }
	}

	var changeHandler          : ((BankItemCell) -> Void)?
	var validationHandler      : ((BankItemCell) -> Bool)?
	var pickerSelectionHandler : ((BankItemCell) -> Void)?
	var buttonActionHandler    : ((BankItemCell) -> Void)?
	var rowSelectionHandler    : ((BankItemCell) -> Void)?
	var shouldShowPicker       : ((BankItemCell) -> Bool)?
	var shouldHidePicker       : ((BankItemCell) -> Bool)?
	var didShowPicker          : ((BankItemCell) -> Void)?
	var didHidePicker          : ((BankItemCell) -> Void)?

  var returnKeyType: UIReturnKeyType = .Done {
    didSet {
      infoTextField?.returnKeyType = returnKeyType
      infoTextView?.returnKeyType = returnKeyType
    }
  }

  var keyboardType: UIKeyboardType = .Default {
    didSet {
      infoTextField?.keyboardType = keyboardType
      infoTextView?.keyboardType = keyboardType
    }
  }

  var autocapitalizationType: UITextAutocapitalizationType = .None {
    didSet {
      infoTextField?.autocapitalizationType = autocapitalizationType
      infoTextView?.autocapitalizationType = autocapitalizationType
    }
  }

  var autocorrectionType: UITextAutocorrectionType = .No {
    didSet {
      infoTextField?.autocorrectionType = autocorrectionType
      infoTextView?.autocorrectionType = autocorrectionType
    }
  }

  var spellCheckingType: UITextSpellCheckingType = .No {
    didSet {
      infoTextField?.spellCheckingType = spellCheckingType
      infoTextView?.spellCheckingType = spellCheckingType
    }
  }

  var enablesReturnKeyAutomatically: Bool = false {
  	didSet {
  		infoTextField?.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
  		infoTextView?.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
  	}
  }

  var keyboardAppearance: UIKeyboardAppearance = .Default {
  	didSet {
  		infoTextField?.keyboardAppearance = keyboardAppearance
  		infoTextView?.keyboardAppearance = keyboardAppearance
  	}
  }

  var secureTextEntry: Bool = false {
  	didSet {
  		infoTextField?.secureTextEntry = secureTextEntry
  		infoTextView?.secureTextEntry = secureTextEntry
  	}
  }

  var shouldUseIntegerKeyboard: Bool = false {
		didSet {
			if let input = infoTextField { input.inputView = shouldUseIntegerKeyboard ? integerKeyboardForInput(input) : nil }
		}
	}
	var shouldAllowReturnsInTextView = false

	var shouldAllowRowSelection: Bool? {
    get { return table?.allowsSelection }
    set { table?.allowsSelection = newValue ?? false }
  }

	var stepperWraps: Bool?      { get { return stepper?.wraps        } set { stepper?.wraps = newValue ?? true       } }
	var stepperMinValue: Double? { get { return stepper?.minimumValue } set { stepper?.minimumValue = newValue ?? 0.0 } }
	var stepperMaxValue: Double? { get { return stepper?.maximumValue } set { stepper?.maximumValue = newValue ?? 0.0 } }
  var stepperStepValue: Double? { get { return stepper?.stepValue } set { stepper?.stepValue = max(newValue ?? 1.0, 1.0) } }

	var name: String? { get { return nameLabel?.text } set { nameLabel?.text = newValue } }

  var infoDataType: DataType = .StringData

	var info: AnyObject? {
		get {
			switch identifier {
				case .Label, .List:      return infoLabel?.text
				case .Button, .Detail:   return infoButton?.titleForState(.Normal)
				case .Image:     				 return infoImageView?.image
				case .Switch:    				 return infoSwitch?.on
				case .Stepper:   				 return stepper?.value
				case .TextView:  				 return numberFromText(infoTextView?.text, dataType: infoDataType) ?? infoTextView?.text
				case .TextField: 				 return numberFromText(infoTextField?.text, dataType: infoDataType) ?? infoTextField?.text
				case .Table:     				 return tableData
			}
		}
		set {
			switch identifier {
        case .Label, .List:
          infoLabel?.text = textFromObject(newValue)
        case .Button, .Detail:
          infoButton?.setTitle(textFromObject(newValue), forState:.Normal)
				case .Image:
          infoImageView?.image = newValue as? UIImage
					if let imageSize = (newValue as? UIImage)?.size {
						infoImageView?.contentMode = CGSizeContainsSize(bounds.size, imageSize) ? .Center : .ScaleAspectFit
					}
				case .Switch:
          infoSwitch?.on = newValue as? Bool ?? false
				case .Stepper:
          stepper?.value = newValue as? Double ?? 0.0
          infoLabel?.text = textFromObject(newValue, dataType: infoDataType)
        case .TextView:
          infoTextView?.text = textFromObject(newValue, dataType: infoDataType)
        case .TextField:
          infoTextField?.text = textFromObject(newValue, dataType: infoDataType)
				case .Table:
          tableData = newValue as? [NSObject]
          table?.reloadData()
			}
		}
	}

	private(set) weak var table         : UITableView?
	private      weak var nameLabel     : UILabel?
	private      weak var infoButton    : UIButton?
	private      weak var infoImageView : UIImageView?
	private      weak var infoSwitch    : UISwitch?
	private      weak var infoLabel     : UILabel?
	private      weak var stepper       : UIStepper?
	private      weak var infoTextField : UITextField?
	private      weak var infoTextView  : UITextView?
	private      weak var pickerView    : UIPickerView!

	private var beginStateText: String?
	private let identifier: Identifier

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

	var tableIdentifier: Identifier = .List

	var tableData:       [NSObject]?
	var pickerData:      [NSObject]?
	var pickerSelection: NSObject?
	var tableSelection:  NSObject?

	/** showPickerView */
	func showPickerView() {
		if pickerData != nil && (shouldShowPicker == nil || shouldShowPicker!(self)) {
			if pickerSelection != nil {
				let idx = find(pickerData!, pickerSelection!)
				if idx != nil { pickerView.selectRow(idx!, inComponent: 0, animated: false) }
			}
			pickerView.hidden = false
			didShowPicker?(self)
		}
	}

	/** hidePickerView */
	func hidePickerView() {
		if !pickerView.hidden && (shouldHidePicker == nil || shouldHidePicker!(self)) {
			pickerView.hidden = true
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
		pickerView = {
			let view = UIPickerView.newForAutolayout()
			view.delegate = self
			view.dataSource = self
			view.hidden = true
			self.addSubview(view)
			return view
			}()
			constrainWithFormat("|[content]| :: V:|[content]| :: |[picker]| :: V:[picker(==\(BankItemCell.PickerHeight))]|",
			              views: ["content": contentView, "picker": pickerView])



    /// Create some more or less generic constraint strings for use in decorator blocks
    ////////////////////////////////////////////////////////////////////////////////

    let nameAndInfoCenterYConstraints  = "\n".join(["|-20-[name]-8-[info]-20-|",
                                                    "name.centerY = info.centerY",
                                                    "name.height = info.height",
                                                    "V:|-8-[name]-8-|"])

    let infoConstraints                = "|-20-[info]-20-| :: V:|-8-[info]-8-|"

    let infoDisclosureConstraints      = "|-20-[info]-75-| :: V:|-8-[info]-8-|"

    let nameAndTextViewInfoConstraints = "V:|-8-[name]-8-[info]-8-| :: |-20-[name]-(>=20)-| :: |-20-[info]-20-|"

    let tableViewInfoConstraints       = "|-20-[info]-20-| :: V:|-8-[info]-8-|"

    let nameInfoAndStepperConstraints  = "\n".join(["|-20-[name]-8-[info]",
	                                                  "'info trailing' info.trailing = stepper.leading - 20",
	                                                  "name.centerY = info.centerY",
	                                                  "name.height = info.height",
	                                                  "'stepper leading' stepper.leading = self.trailing",
	                                                  "stepper.centerY = name.centerY",
	                                                  "V:|-8-[name]-8-|"])

    let imageViewInfoConstraints       = "|-20-[info]-20-| :: V:|-8-[info]-8-|"


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

      if let infoLabel = info as? UILabel {
        infoLabel.font          = Bank.infoFont
        infoLabel.textColor     = Bank.infoColor
        infoLabel.textAlignment = .Right
        cell.infoLabel = infoLabel
      }

      else if let infoButton = info as? UIButton {
        infoButton.titleLabel?.font          = Bank.infoFont;
        infoButton.titleLabel?.textAlignment = .Right;
        infoButton.constrainWithFormat("|[title]| :: V:|[title]|", views: ["title": infoButton.titleLabel!])
        infoButton.setTitleColor(Bank.infoColor, forState:.Normal)
        infoButton.addTarget(cell, action:"buttonUpAction:", forControlEvents:.TouchUpInside)
        cell.infoButton = infoButton
      }

      else if let infoTextField = info as? UITextField {
        infoTextField.font          = Bank.infoFont
        infoTextField.textColor     = Bank.infoColor
        infoTextField.textAlignment = .Right
        infoTextField.delegate      = cell
        infoTextField.returnKeyType = cell.returnKeyType
        infoTextField.keyboardType = cell.keyboardType
        infoTextField.autocapitalizationType = cell.autocapitalizationType
        infoTextField.autocorrectionType = cell.autocorrectionType
        infoTextField.spellCheckingType = cell.spellCheckingType
        infoTextField.enablesReturnKeyAutomatically = cell.enablesReturnKeyAutomatically
        infoTextField.keyboardAppearance = cell.keyboardAppearance
        infoTextField.secureTextEntry = cell.secureTextEntry
        cell.infoTextField = infoTextField
      }

      else if let infoTextView = info as? UITextView {
        infoTextView.font      = Bank.infoFont
        infoTextView.textColor = Bank.infoColor
        infoTextView.delegate  = cell
        infoTextView.returnKeyType = cell.returnKeyType
        infoTextView.keyboardType = cell.keyboardType
        infoTextView.autocapitalizationType = cell.autocapitalizationType
        infoTextView.autocorrectionType = cell.autocorrectionType
        infoTextView.spellCheckingType = cell.spellCheckingType
        infoTextView.enablesReturnKeyAutomatically = cell.enablesReturnKeyAutomatically
        infoTextView.keyboardAppearance = cell.keyboardAppearance
        infoTextView.secureTextEntry = cell.secureTextEntry
        cell.infoTextView = infoTextView
      }

      else if let infoImageView = info as? UIImageView {
        infoImageView.contentMode = .ScaleAspectFit
        infoImageView.tintColor = UIColor.blackColor()
        infoImageView.backgroundColor = UIColor.clearColor()
        cell.infoImageView = infoImageView
      }

      else if let infoTableView = info as? UITableView {
        infoTableView.separatorStyle = .None
        infoTableView.rowHeight      = 38.0
        infoTableView.delegate       = cell
        infoTableView.dataSource     = cell
        BankItemCell.registerIdentifiersWithTableView(infoTableView)
        cell.table = infoTableView
      }

      else if let infoSwitch = info as? UISwitch {
        infoSwitch.addTarget(cell, action:"switchValueDidChange:", forControlEvents:.ValueChanged)
        cell.infoSwitch = infoSwitch
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
		infoButton?.setTitle(nil, forState: .Normal)
		infoImageView?.image = nil
		infoImageView?.contentMode = .ScaleAspectFit
		infoSwitch?.on = false
		infoLabel?.text = nil
		stepper?.value = 0.0
		stepper?.minimumValue = Double(CGFloat.min)
		stepper?.maximumValue = Double(CGFloat.max)
		stepper?.wraps = true
		infoTextField?.text = nil
		infoTextView?.text = nil
		tableData = nil
		table?.reloadData()
		pickerData = nil
		pickerSelection = nil
	}

	/**
	integerKeyboardForInput:

	:param: input UITextInput

	:returns: UIView
	*/
	private func integerKeyboardForInput(input: UITextField) -> UIView {

		let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 219))

		let index = [0: "1",      1: "2",  2: "3",
		             3: "4",      4: "5",  5: "6",
		             6: "7",      7: "8",  8: "9",
		             9: "Erase", 10: "0", 11: "Done"]

		for i in 0...11 {
			let b = UIButton.newForAutolayout()
			if i == 11 {
				b.backgroundColor = UIColor(r:0, g:122, b:255, a:255)
				b.setTitle("Done", forState: .Normal)
				b.setTitleColor(UIColor.whiteColor(), forState: .Normal)
			} else {
				b.setImage(UIImage(named:"IntegerKeyboard_\(index[i]!)"), forState: .Normal)
				b.setImage(UIImage(named:"IntegerKeyboard_\(index[i]!)-Highlighted"), forState: .Highlighted)
			}

      var actionBlock: (Void) -> Void
      switch i {
        case  9: actionBlock = {input.deleteBackward()}
        case 11: actionBlock = {_ = input.resignFirstResponder()}
        default: actionBlock = {input.insertText(index[i]!)}
      }
      b.addActionBlock(actionBlock, forControlEvents: .TouchUpInside)
      b.constrainWithFormat("self.height = 54 :: self.width = 106")
      view.addSubview(b)

      let views = ["b": b]

      if i < 3                 { view.constrainWithFormat("b.top = self.top",                 views: views)  }
      else if i > 8            { view.constrainWithFormat("b.bottom = self.bottom",           views: views)  }

      if i % 3 == 0            { view.constrainWithFormat("b.left = self.left",               views: views) }
      else if (i + 1) % 3 == 0 { view.constrainWithFormat("b.right = self.right",             views: views) }
      else                     { view.constrainWithFormat("b.centerX = self.centerX",         views: views) }

      if 3...5 ∋ i      { view.constrainWithFormat("b.centerY = self.centerY - 27.5", views: views) }
      else if 6...8 ∋ i { view.constrainWithFormat("b.centerY = self.centerY + 27.5", views: views) }

    }

		return view

	}

	/**
	stepperValueDidChange:

	:param: sender UIStepper
	*/
	func stepperValueDidChange(sender: UIStepper) {
		changeHandler?(self)
		infoLabel?.text = textFromObject(sender.value, dataType: infoDataType)
	}

	/**
	buttonUpAction:

	:param: sender UIButton
	*/
	func buttonUpAction(sender: UIButton) {
		buttonActionHandler?(self)
		if pickerData != nil { if pickerView.hidden { showPickerView() } else { hidePickerView() } }
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
			case .Button:  infoButton?.userInteractionEnabled = isEditingState
			case .Switch:  infoSwitch?.userInteractionEnabled = isEditingState
			case .Stepper:
				stepper?.userInteractionEnabled = isEditingState
				if let infoTrailing = contentView.constraintWithIdentifier("info trailing") {
					if let stepperLeading = contentView.constraintWithIdentifier("stepper leading") {
						infoTrailing.constant = isEditingState ? -8.0 : -20.0
						stepperLeading.constant = isEditingState ? -20.0 - (stepper?.bounds.size.width ?? 0.0) : 0.0
					}
				}
			case .TextView:  infoTextView?.userInteractionEnabled  = isEditingState
			case .TextField: infoTextField?.userInteractionEnabled = isEditingState
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
		if pickerView != nil && !pickerView!.hidden { hidePickerView() }
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

	:param: picker UIPickerView

	:returns: Int
	*/
	func numberOfComponentsInPickerView(picker: UIPickerView) -> Int { return 1 }

	/**
	pickerView:numberOfRowsInComponent:

	:param: picker UIPickerView
	:param: component Int

	:returns: Int
	*/
	func pickerView(picker: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return pickerData?.count ?? 0 }

	/**
	pickerView:titleForRow:forComponent:

	:param: picker UIPickerView
	:param: row Int
	:param: component Int

	:returns: String?
	*/
	func pickerView(picker: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return textFromObject(pickerData?[row] ?? "")
	}

}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - UIPickerViewDelegate
////////////////////////////////////////////////////////////////////////////////

extension BankItemCell: UIPickerViewDelegate {

	/**
	pickerView:didSelectRow:inComponent:

	:param: picker UIPickerView
	:param: row Int
	:param: component Int
	*/
	func pickerView(picker: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		pickerSelection = pickerData?[row]
		pickerSelectionHandler?(self)
		info = pickerSelection
		if infoTextField != nil && infoTextField!.isFirstResponder() { infoTextField?.resignFirstResponder() }
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
    return BankItemDetailController.DefaultRowHeight
  }

  /**
  tableView:cellForRowAtIndexPath:

  :param: tableView UITableView
  :param: indexPath NSIndexPath

  :returns: UITableViewCell
  */
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
  	let cell = tableView.dequeueReusableCellWithIdentifier(tableIdentifier.rawValue, forIndexPath: indexPath) as? UITableViewCell
  	if let bankItemCell = cell as? BankItemCell { bankItemCell.info = tableData?[indexPath.row] }
  	return cell ?? UITableViewCell()
  }

}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - UITableViewDelegate
////////////////////////////////////////////////////////////////////////////////

extension BankItemCell: UITableViewDelegate {}
