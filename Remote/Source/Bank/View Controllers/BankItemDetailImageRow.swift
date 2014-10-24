//
//  BankItemDetailImageRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankItemDetailImageRow: BankItemDetailRow {

	/**
	configureCell:forTableView:

	:param: cell BankItemCell
	:param: tableView UITableView
	*/
	override func configureCell(cell: BankItemCell, forTableView tableView: UITableView) {
		super.configureCell(cell, forTableView: tableView)
	}

  /**
  initWithPreviewableItem:

  :param: previewableItem BankDisplayItemModel
  */
  init(previewableItem: BankDisplayItemModel) {
    super.init(identifier: .Image)
    info = previewableItem.preview
  }

}
