//
//  BankItemDetailSection.swift
//  Remote
//
//  Created by Jason Cardwell on 10/16/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankItemDetailSection {

	var title: String?
	private var _rows: [BankItemDetailRow] = []
	var rows: [BankItemDetailRow] {
		if _rows.count == 0 { _rows = createRows() }
		return _rows
	}
	let sectionNumber: Int
	let createRows: (Void) -> [BankItemDetailRow]

	/** reloadRows */
	func reloadRows() {
		_rows = createRows()
	}

	/**
	initWithSectionNumber:title:createRows:

	:param: sectionNumber Int
	:param: title String? = nil
	:param: createRows (Void) -> [BankItemDetailRow]
	*/
	init(sectionNumber: Int, title: String? = nil, createRows: (Void) -> [BankItemDetailRow]) {
		self.sectionNumber = sectionNumber
		self.title = title
		self.createRows = createRows
	}
}
