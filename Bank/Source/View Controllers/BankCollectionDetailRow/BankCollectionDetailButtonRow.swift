//
//  BankCollectionDetailButtonRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

final class BankCollectionDetailButtonRow: BankCollectionDetailRow {

  override var identifier: BankCollectionDetailCell.Identifier { return .Button }

  var showPickerRow: ((BankCollectionDetailButtonCell) -> Bool)?
  var hidePickerRow: ((BankCollectionDetailButtonCell) -> Bool)?
  var detailPickerRow: BankCollectionDetailPickerRow?

  /**
  configure:

  :param: cell BankCollectionDetailCell
  */
  override func configureCell(cell: BankCollectionDetailCell) {
    if let buttonCell = cell as? BankCollectionDetailButtonCell {
      // Set picker row first so data is there when `info` gets set by `super`
      buttonCell.detailPickerRow = detailPickerRow

      super.configureCell(cell)

      buttonCell.showPickerRow = showPickerRow
      buttonCell.hidePickerRow = hidePickerRow
    }
  }

}
