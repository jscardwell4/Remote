//
//  BankItemDetailListRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankItemDetailListRow: BankItemDetailRow {

	/**
	configureCell:forTableView:

	:param: cell BankItemCell
	:param: tableView UITableView
	*/
	override func configureCell(cell: BankItemCell, forTableView tableView: UITableView) {
		super.configureCell(cell, forTableView: tableView)
	}

  /**
  initWithPushableItem:hasEditingState:

  :param: pushableItem BankDisplayItemModel
  */
  init(pushableItem: BankDisplayItemModel) {
    super.init(identifier: .List)
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
  init(pushableCategory: BankDisplayItemCategory) {
    super.init(identifier: .List)
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
  initWithNamedItem:hasEditingState:

  :param: namedItem NamedModelObject
  */
  init(namedItem: NamedModelObject) {
    super.init(identifier: .List)
    info = namedItem
  }

}
