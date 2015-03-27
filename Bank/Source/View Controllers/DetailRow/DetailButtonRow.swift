//
//  DetailButtonRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit
import DataModel

final class DetailButtonRow: DetailRow {

  override var identifier: DetailCell.Identifier { return .Button }

  var showPickerRow: ((DetailButtonCell) -> Bool)?
  var hidePickerRow: ((DetailButtonCell) -> Bool)?
  var detailPickerRow: DetailPickerRow?

  /**
  configure:

  :param: cell DetailCell
  */
  override func configureCell(cell: DetailCell) {
    if detailPickerRow != nil { (cell as? DetailButtonCell)?.detailPickerRow = detailPickerRow }
    super.configureCell(cell)
    if showPickerRow != nil { (cell as? DetailButtonCell)?.showPickerRow = showPickerRow }
    if hidePickerRow != nil { (cell as? DetailButtonCell)?.hidePickerRow = hidePickerRow }
  }

  /** init */
  override init() { super.init() }

  /**
  initWithPushableCategory:

  :param: pushableCategory BankItemCategory
  */
//  convenience init(pushableCategory: ModelCategory?) {
//    self.init()
//    info = pushableCategory
//    select = {
//      if let category = pushableCategory {
//        if let controller = BankCollectionController(category: category) {
//          if let nav = UIApplication.sharedApplication().keyWindow?.rootViewController as? UINavigationController {
//            nav.pushViewController(controller, animated: true)
//          }
//        }
//      }
//    }
//  }

  /**
  initWithPushableItem:

  :param: pushableItem EditableModel?
  */
  convenience init(pushableItem: protocol<EditableModel,Detailable>?) {
    self.init()
    info = pushableItem
    select = {
      if let item = pushableItem {
        if let nav =  UIApplication.sharedApplication().keyWindow?.rootViewController as? UINavigationController {
          nav.pushViewController(item.detailController(), animated: true)
        }
      }
    }
  }

}
