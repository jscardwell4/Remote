//
//  BankItemDetailLabelRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankItemDetailLabelRow: BankItemDetailRow {

	/**
	configureCell:forTableView:

	:param: cell BankItemCell
	:param: tableView UITableView
	*/
	override func configureCell(cell: BankItemCell, forTableView tableView: UITableView) {
		super.configureCell(cell, forTableView: tableView)
    cell.name = name
	}

  /**
  initWithPushableCategory:label:hasEditingState:

  :param: pushableCategory BankDisplayItemCategory
  :param: label String
  */
  convenience init(pushableCategory: BankDisplayItemCategory, label: String) {
    self.init()
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
  initWithLabel:value:

  :param: label String
  :param: value String
  */
  convenience init(label: String, value: String) {
    self.init()
    name = label
    info = value
  }

  /** init */
  convenience init() { self.init(identifier: .Label) }

}
