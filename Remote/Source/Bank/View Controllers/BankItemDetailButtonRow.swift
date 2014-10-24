//
//  BankItemDetailButtonRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankItemDetailButtonRow: BankItemDetailRow {

  var pickerNilSelectionTitle: String?
  var pickerCreateSelectionTitle: String?
  var pickerData: [NSObject]?
  var pickerSelection: NSObject?
  var didSelectItem: ((NSObject?) -> Void)?
  var pickerCreateSelectionHandler: ((Void) -> Void)?

  /**
  configureCell:forTableView:

  :param: cell BankItemCell
  :param: tableView UITableView
  */
  override func configureCell(cell: BankItemCell, forTableView tableView: UITableView) {
  	super.configureCell(cell, forTableView: tableView)
    cell.name = name
  	if let buttonCell = cell as? BankItemButtonCell {
      buttonCell.pickerData = pickerData
      buttonCell.pickerNilSelectionTitle = pickerNilSelectionTitle
      buttonCell.pickerCreateSelectionTitle = pickerCreateSelectionTitle
      buttonCell.didSelectItem = didSelectItem
      buttonCell.pickerCreateSelectionHandler = pickerCreateSelectionHandler
      buttonCell.pickerSelection = pickerSelection
      if info == nil { buttonCell.info = pickerSelection ?? pickerNilSelectionTitle }
  	}
  }

  /** init */
  init() { super.init(identifier: .Button) }

  /**
  initWithPushableCategory:

  :param: pushableCategory BankDisplayItemCategory
  */
  convenience init(pushableCategory: BankDisplayItemCategory?) {
    self.init()
    info = pushableCategory
    selectionHandler = {
      if let category = pushableCategory {
        if let controller = BankCollectionController(category: category) {
          if let nav = self.bankItemCell?.window?.rootViewController as? UINavigationController {
            nav.pushViewController(controller, animated: true)
          }
        }
      }
    }
  }

  convenience init(pushableItem: BankDisplayItemModel?) {
    self.init()
    info = pushableItem
    selectionHandler = {
      if let item = pushableItem {
        if let nav = self.bankItemCell?.window?.rootViewController as? UINavigationController {
          nav.pushViewController(item.detailController(), animated: true)
        }
      }
    }
  }
}
