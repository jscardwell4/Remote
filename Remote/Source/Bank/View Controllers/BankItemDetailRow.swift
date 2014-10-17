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
			 configureCell: (BankItemCell) -> Void)
	{
		self.identifier = identifier
		self.isEditable = isEditable
		self.selectionHandler = selectionHandler
		self.configureCell = configureCell
	}

}
