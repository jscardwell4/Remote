//
//  DetailSwitchRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailSwitchRow: DetailRow {

	/**
	configureCell:forTableView:

	:param: cell DetailCell
	:param: tableView UITableView
	*/
	override func configureCell(cell: DetailCell, forTableView tableView: UITableView) {
		super.configureCell(cell, forTableView: tableView)
    cell.name = name
	}

  /** init */
  convenience init() { self.init(identifier: .Switch) }

}
