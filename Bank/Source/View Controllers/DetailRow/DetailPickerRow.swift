//
//  DetailPickerRow.swift
//  Remote
//
//  Created by Jason Cardwell on 12/01/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

final class DetailPickerRow: DetailRow {


  override var identifier: DetailCell.Identifier { return .Picker }

  var nilItemTitle: String?
  var createItemTitle: String?
  var createItem: ((Void) -> Void)?
  var didSelectItem: ((AnyObject?) -> Void)?
  var titleForInfo: ((AnyObject?) -> String)?
  var data: [AnyObject]?


  /**
  configure:

  :param: cell DetailCell
  */
  override func configureCell(cell: DetailCell) {
    // Set picker cell properties first so data is there when `info` gets set by `super`
    if let pickerCell = cell as? DetailPickerCell {
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
