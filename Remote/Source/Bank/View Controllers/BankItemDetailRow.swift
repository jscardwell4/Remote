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
	let isEditable: Bool
	var height: CGFloat {
		switch identifier {
			case .TextView: return BankItemDetailController.textViewRowHeight
			case .Image:    return BankItemDetailController.previewRowHeight
			case .Switch:   return BankItemDetailController.switchRowHeight
			default:        return BankItemDetailController.defaultRowHeight

		}
	}
	var configureCell: (BankItemCell) -> Void
	var selectionHandler: ((Void) -> Void)?
  var deletionHandler: ((Void) -> Void)?

	/**
	initWithIdentifier:isEditable:selectionHandler:configureCell:

	:param: identifier BankItemCell.Identifier
	:param: isEditable Bool = false
	:param: selectionHandler ((Void) -> Void
	:param: configureCell (BankItemCell) -> Void
	*/
	init(identifier: BankItemCell.Identifier,
			 isEditable: Bool = false,
			 selectionHandler: ((Void) -> Void)? = nil,
			 deletionHandler: ((Void) -> Void)? = nil,
			 configureCell: (BankItemCell) -> Void)
	{
		self.identifier = identifier
		self.isEditable = isEditable
		self.selectionHandler = selectionHandler
    self.deletionHandler = deletionHandler
		self.configureCell = configureCell
	}


	/**
	initWithPushableItem:isEditable:

	:param: pushableItem BankDisplayItemModel
	:param: isEditable Bool = true
	*/
  convenience init(pushableItem: BankDisplayItemModel, isEditable: Bool = true) {
		self.init(identifier: .List, isEditable: isEditable,
			selectionHandler: {
				let controller = pushableItem.detailController()
				if let nav = MSRemoteAppController.sharedAppController().window.rootViewController as? UINavigationController {
					nav.pushViewController(controller, animated: true)
				}
			},
      deletionHandler: {pushableItem.delete()},
			configureCell: {
				(cell: BankItemCell) -> Void in
					cell.info = pushableItem
			})
	}

	/**
	initWithPushableCategory:isEditable:

	:param: pushableCategory BankDisplayItemCategory
	:param: isEditable Bool = true
	*/
	convenience init(pushableCategory: BankDisplayItemCategory, isEditable: Bool = true) {
		self.init(identifier: .List, isEditable: isEditable,
			selectionHandler: {
				if let controller = BankCollectionController(category: pushableCategory) {
					if let nav = MSRemoteAppController.sharedAppController().window.rootViewController as? UINavigationController {
						nav.pushViewController(controller, animated: true)
					}
				}
			},
      deletionHandler: {pushableCategory.delete()},
			configureCell: {
				(cell: BankItemCell) -> Void in
					cell.info = pushableCategory
			})
	}

	/**
	initWithPushableCategory:label:isEditable:

	:param: pushableCategory BankDisplayItemCategory
	:param: label String
	:param: isEditable Bool = true
	*/
	convenience init(pushableCategory: BankDisplayItemCategory, label: String, isEditable: Bool = true) {
		self.init(identifier: .Label, isEditable: isEditable,
			selectionHandler: {
				if let controller = BankCollectionController(category: pushableCategory) {
					if let nav = MSRemoteAppController.sharedAppController().window.rootViewController as? UINavigationController {
						nav.pushViewController(controller, animated: true)
					}
				}
			},
      deletionHandler: {pushableCategory.delete()},
			configureCell: {
				(cell: BankItemCell) -> Void in
					cell.name = label
					cell.info = pushableCategory
			})
	}

	/**
	initWithNamedItem:isEditable:

	:param: namedItem NamedModelObject
	:param: isEditable Bool = true
	*/
	convenience init(namedItem: NamedModelObject, isEditable: Bool = true) {
		self.init(identifier: .List, isEditable: isEditable, configureCell: {
			(cell: BankItemCell) -> Void in
				cell.info = namedItem
		})
	}

	/**
	initWithPreviewableItem:

	:param: previewableItem BankDisplayItemModel
	*/
	convenience init(previewableItem: BankDisplayItemModel) {
		self.init(identifier: .Image, configureCell: {
			(cell: BankItemCell) -> Void in
				cell.info = previewableItem.preview
			})
	}

	/**
	initWithLabel:value:

	:param: label String
	:param: value String
	*/
	convenience init(label: String, value: String) {
		self.init(identifier: .Label, configureCell: {
			(cell: BankItemCell) -> Void in
				cell.name = label
				cell.info = value
			})
	}


  /**
  initWithNumber:label:dataType:changeHandler:

  :param: number NSNumber
  :param: label String
  :param: dataType BankItemCell.DataType
  :param: changeHandler (NSObject?) -> Void
  */
  convenience init(number: NSNumber, label: String, dataType: BankItemCell.DataType, changeHandler: (NSObject?) -> Void) {
    self.init(identifier: .TextField, isEditable: true, configureCell: {
      (cell: BankItemCell) -> Void in
        cell.name = label
        cell.info = number
        cell.infoDataType = dataType
        cell.shouldUseIntegerKeyboard = true
        cell.changeHandler = changeHandler
    })
  }

}

