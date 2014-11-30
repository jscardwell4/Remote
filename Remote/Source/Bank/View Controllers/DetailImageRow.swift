//
//  DetailImageRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailImageRow: DetailRow {

	/**
	configureCell:forTableView:

	:param: cell DetailCell
	:param: tableView UITableView
	*/
	override func configureCell(cell: DetailCell, forTableView tableView: UITableView) {
		super.configureCell(cell, forTableView: tableView)
	}

  /**
  initWithPreviewableItem:

  :param: previewableItem BankDisplayItemModel
  */
  convenience init(previewableItem: PreviewableItem?) {
    self.init()
    info = previewableItem?.preview
  }

  /** init */
  convenience init() { self.init(identifier: .Image) }

}
