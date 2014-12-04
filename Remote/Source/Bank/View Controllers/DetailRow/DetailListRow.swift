//
//  DetailListRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailListRow: DetailRow {

  override var identifier: DetailCell.Identifier { return .List }

  /**
  configure:

  :param: cell DetailCell
  */
  override func configureCell(cell: DetailCell) {
    super.configureCell(cell)
  }

  /**
  initWithPushableItem:hasEditingState:

  :param: pushableItem BankDisplayItemModel
  */
  convenience init(pushableItem: BankDisplayItemModel) {
    self.init()
    select = {
      let controller = pushableItem.detailController()
      if let nav = MSRemoteAppController.sharedAppController().window.rootViewController as? UINavigationController {
        nav.pushViewController(controller, animated: true)
      }
    }
    delete = { pushableItem.delete() }
    info = pushableItem
  }

  /**
  initWithPushableCategory:hasEditingState:

  :param: pushableCategory BankDisplayItemCategory
  */
  convenience init(pushableCategory: BankDisplayItemCategory) {
    self.init()
    select = {
      if let controller = BankCollectionController(category: pushableCategory) {
        if let nav = MSRemoteAppController.sharedAppController().window.rootViewController as? UINavigationController {
          nav.pushViewController(controller, animated: true)
        }
      }
    }
    delete = { pushableCategory.delete() }
    info = pushableCategory
  }

  /**
  initWithNamedItem:hasEditingState:

  :param: namedItem NamedModelObject
  */
  convenience init(namedItem: NamedModelObject) { self.init(); info = namedItem }

  /** init */
  override init() { super.init() }

}
