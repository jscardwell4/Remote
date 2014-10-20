//
//  BankItemDetailRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/16/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankItemDetailRow {

	let identifier: BankItemCell.Identifier
	var height: CGFloat {
		switch identifier {
			case .TextView: return BankItemDetailController.textViewRowHeight
			case .Image:    return BankItemDetailController.previewRowHeight
			case .Switch:   return BankItemDetailController.switchRowHeight
			default:        return BankItemDetailController.defaultRowHeight

		}
	}
	var selectionHandler: ((Void) -> Void)?
  var deletionHandler: ((Void) -> Void)?

  var editActions: [UITableViewRowAction]?
  var editingStyle: UITableViewCellEditingStyle { return deletionHandler != nil || editActions != nil ? .Delete : .None }

  var isDeletable: Bool { return deletionHandler != nil }
  var deleteRemovesRow = true
  var isSelectable: Bool { return selectionHandler != nil }

  weak var bankItemCell: BankItemCell?

  /// Properties that mirror `BankItemCell` properties
  ////////////////////////////////////////////////////////////////////////////////

  var name: String?
  var info: AnyObject?
  var infoDataType: BankItemCell.DataType = .StringData
  var changeHandler: ((NSObject?) -> Void)?
  var validationHandler: ((NSObject?) -> Bool)?

  // picker related properties
  var enablePicker: Bool { return pickerData != nil }
  var pickerNilSelectionTitle: String?
  var pickerCreateSelectionTitle: String?
  var pickerData: [NSObject]?
  var pickerSelection: NSObject?
  var pickerSelectionHandler: ((NSObject?) -> Void)?
  var pickerCreateSelectionHandler: ((Void) -> Void)?

  // stepper related properties
  var stepperWraps: Bool = true
  var stepperMinValue: Double = Double(CGFloat.min)
  var stepperMaxValue: Double = Double(CGFloat.max)
  var stepperStepValue: Double = 1.0

  // keyboard related properties
	var returnKeyType: UIReturnKeyType = .Done
	var keyboardType: UIKeyboardType = .ASCIICapable
	var autocapitalizationType: UITextAutocapitalizationType = .None
	var autocorrectionType: UITextAutocorrectionType = .No
	var spellCheckingType: UITextSpellCheckingType = .No
	var enablesReturnKeyAutomatically: Bool = false
	var keyboardAppearance: UIKeyboardAppearance = Bank.keyboardAppearance
	var secureTextEntry: Bool = false
	var shouldAllowReturnsInTextView: Bool = false
	var shouldUseIntegerKeyboard: Bool = false

  // button related properties
  var buttonActionHandler: ((Void) -> Void)?
  var buttonEditingActionHandler: ((Void) -> Void)?

  /**
  configure:

  :param: cell BankItemCell
  */
  func configureCell(cell: BankItemCell) {
    bankItemCell = cell
    cell.name = name
    cell.info = info
    cell.infoDataType = infoDataType
    cell.validationHandler = validationHandler
    cell.changeHandler = changeHandler

    if enablePicker {
      cell.pickerData = pickerData
      cell.pickerNilSelectionTitle = pickerNilSelectionTitle
      cell.pickerCreateSelectionTitle = pickerCreateSelectionTitle
      cell.pickerSelectionHandler = pickerSelectionHandler
      cell.pickerCreateSelectionHandler = pickerCreateSelectionHandler
      cell.pickerSelection = pickerSelection
    }

    switch identifier {

      case .Button:
	      cell.buttonActionHandler = buttonActionHandler
	      cell.buttonEditingActionHandler = buttonEditingActionHandler

      case .Stepper:
				cell.stepperWraps = stepperWraps
				cell.stepperMinValue = stepperMinValue
				cell.stepperMaxValue = stepperMaxValue
				cell.stepperStepValue = stepperStepValue

      case .TextView:
        cell.shouldAllowReturnsInTextView = shouldAllowReturnsInTextView
        fallthrough

      case .TextField:
	      cell.returnKeyType = returnKeyType
				cell.keyboardType = keyboardType
				cell.autocapitalizationType = autocapitalizationType
				cell.autocorrectionType = autocorrectionType
				cell.spellCheckingType = spellCheckingType
				cell.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
				cell.keyboardAppearance = keyboardAppearance
				cell.secureTextEntry = secureTextEntry
				cell.shouldUseIntegerKeyboard = shouldUseIntegerKeyboard

			default: break

    }
  }

	/**
	initWithIdentifier:hasEditingState:selectionHandler:configureCell:

	:param: identifier BankItemCell.Identifier
	:param: hasEditingState Bool = false
	:param: selectionHandler ((Void) -> Void
	:param: configureCell (BankItemCell) -> Void
	*/
	init(identifier: BankItemCell.Identifier,
			 selectionHandler: ((Void) -> Void)? = nil,
			 deletionHandler: ((Void) -> Void)? = nil)
	{
		self.identifier = identifier
		self.selectionHandler = selectionHandler
    self.deletionHandler = deletionHandler
	}


	/**
	initWithPushableItem:hasEditingState:

	:param: pushableItem BankDisplayItemModel
	*/
  convenience init(pushableItem: BankDisplayItemModel) {
		self.init(identifier: .List)
    selectionHandler = {
      let controller = pushableItem.detailController()
      if let nav = MSRemoteAppController.sharedAppController().window.rootViewController as? UINavigationController {
        nav.pushViewController(controller, animated: true)
      }
    }
    deletionHandler = { pushableItem.delete() }
    info = pushableItem
	}

	/**
	initWithPushableCategory:hasEditingState:

	:param: pushableCategory BankDisplayItemCategory
	*/
	convenience init(pushableCategory: BankDisplayItemCategory) {
		self.init(identifier: .List)
		selectionHandler = {
			if let controller = BankCollectionController(category: pushableCategory) {
				if let nav = MSRemoteAppController.sharedAppController().window.rootViewController as? UINavigationController {
					nav.pushViewController(controller, animated: true)
				}
			}
		}
    deletionHandler = { pushableCategory.delete() }
    info = pushableCategory
	}

	/**
	initWithPushableCategory:label:hasEditingState:

	:param: pushableCategory BankDisplayItemCategory
	:param: label String
	*/
	convenience init(pushableCategory: BankDisplayItemCategory, label: String) {
		self.init(identifier: .Label)
		selectionHandler = {
			if let controller = BankCollectionController(category: pushableCategory) {
				if let nav = MSRemoteAppController.sharedAppController().window.rootViewController as? UINavigationController {
					nav.pushViewController(controller, animated: true)
				}
			}
		}
    name = label
    info = pushableCategory
	}

	/**
	initWithNamedItem:hasEditingState:

	:param: namedItem NamedModelObject
	*/
	convenience init(namedItem: NamedModelObject) {
		self.init(identifier: .List)
		info = namedItem
	}

	/**
	initWithPreviewableItem:

	:param: previewableItem BankDisplayItemModel
	*/
	convenience init(previewableItem: BankDisplayItemModel) {
		self.init(identifier: .Image)
		info = previewableItem.preview
	}

	/**
	initWithLabel:value:

	:param: label String
	:param: value String
	*/
	convenience init(label: String, value: String) {
		self.init(identifier: .Label)
		name = label
		info = value
	}


  /**
  initWithNumber:label:dataType:changeHandler:

  :param: number NSNumber
  :param: label String
  :param: dataType BankItemCell.DataType
  :param: changeHandler (NSObject?) -> Void
  */
  convenience init(number: NSNumber, label: String, dataType: BankItemCell.DataType, changeHandler: (NSObject?) -> Void) {
    self.init(identifier: .TextField)
    name = label
    info = number
    infoDataType = dataType
    shouldUseIntegerKeyboard = true
    self.changeHandler = changeHandler
  }

}

