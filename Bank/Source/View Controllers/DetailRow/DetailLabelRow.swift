//
//  DetailLabelRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

final class DetailLabelRow: DetailRow {

  override var identifier: DetailCell.Identifier { return .Label }

  /**
  configure:

  :param: cell DetailCell
  */
  // override func configureCell(cell: DetailCell) {
  //   super.configureCell(cell)
  // }

  /**
  initWithLabel:value:

  :param: label String
  :param: value String?
  */
  convenience init(label: String, value: String?) {
    self.init()
    name = label
    info = value
  }

  /**
  initWithPushableCategory:label:hasEditingState:

  :param: pushableCategory BankItemCategory
  :param: label String
  */
  convenience init(pushableCollection: BankModelCollection, label: String) {
    self.init()
    select = {
      if let controller = BankCollectionController(collection: pushableCollection) {
        if let nav = UIApplication.sharedApplication().keyWindow?.rootViewController as? UINavigationController {
          nav.pushViewController(controller, animated: true)
        }
      }
    }
    name = label
    info = pushableCollection
  }

  /** init */
  override init() { super.init() }

}
