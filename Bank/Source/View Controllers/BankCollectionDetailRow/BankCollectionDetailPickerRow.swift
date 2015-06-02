//
//  BankCollectionDetailPickerRow.swift
//  Remote
//
//  Created by Jason Cardwell on 12/01/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

final class BankCollectionDetailPickerRow: BankCollectionDetailRow {


  override var identifier: BankCollectionDetailCell.Identifier { return .Picker }

  var nilItemTitle: String?
  var createItemTitle: String?
  var createItem: ((Void) -> Void)?
  var didSelectItem: ((AnyObject?) -> Void)?
  var titleForInfo: ((AnyObject?) -> String)?
  var data: [AnyObject]?


  /**
  configure:

  :param: cell BankCollectionDetailCell
  */
  override func configureCell(cell: BankCollectionDetailCell) {
    // Set picker cell properties first so data is there when `info` gets set by `super`
    if let pickerCell = cell as? BankCollectionDetailPickerCell {
      pickerCell.titleForInfo = titleForInfo
      pickerCell.nilItemTitle = nilItemTitle
      pickerCell.createItemTitle = createItemTitle
      pickerCell.didSelectItem = didSelectItem
      pickerCell.createItem = createItem
      if data != nil {pickerCell.data = data! }
    }
    super.configureCell(cell)
  }

}
