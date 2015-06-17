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

final class DetailButtonRow: DetailRow {

  override var identifier: DetailCell.Identifier { return .Button }

  var showPickerRow: ((DetailButtonCell) -> Bool)?
  var hidePickerRow: ((DetailButtonCell) -> Bool)?
  var detailPickerRow: DetailPickerRow?

  /**
  configure:

  - parameter cell: DetailCell
  */
  override func configureCell(cell: DetailCell) {
    if let buttonCell = cell as? DetailButtonCell {
      // Set picker row first so data is there when `info` gets set by `super`
      buttonCell.detailPickerRow = detailPickerRow

      super.configureCell(cell)
      
      buttonCell.showPickerRow = showPickerRow
      buttonCell.hidePickerRow = hidePickerRow
    }
  }

}
