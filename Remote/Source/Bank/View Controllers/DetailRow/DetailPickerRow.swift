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
    if titleForInfo != nil    { (cell as? DetailPickerCell)?.titleForInfo = titleForInfo!       }
    if nilItemTitle != nil    { (cell as? DetailPickerCell)?.nilItemTitle = nilItemTitle!       }
    if createItemTitle != nil { (cell as? DetailPickerCell)?.createItemTitle = createItemTitle! }
    if didSelectItem != nil   { (cell as? DetailPickerCell)?.didSelectItem = didSelectItem!     }
    if createItem != nil      { (cell as? DetailPickerCell)?.createItem = createItem!           }
    if data != nil            { (cell as? DetailPickerCell)?.data = data!                       }
    super.configureCell(cell)
  }

  /** init */
  override init() { super.init() }

}
