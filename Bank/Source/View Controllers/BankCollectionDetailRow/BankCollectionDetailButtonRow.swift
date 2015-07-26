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

  var nilItem: BankCollectionDetailButtonCell.Item?
  var createItem: BankCollectionDetailButtonCell.Item?
  var didSelectItem: ((AnyObject?) -> Void)?
  var titleForInfo: ((AnyObject?) -> String)?
  var data: [AnyObject]?

  /**
  configure:

  - parameter cell: BankCollectionDetailCell
  */
  override func configureCell(cell: BankCollectionDetailCell) {
    if let buttonCell = cell as? BankCollectionDetailButtonCell {
      // Set picker data first so it is there when `info` gets set by `super`
      buttonCell.titleForInfo = titleForInfo
      buttonCell.nilItem = nilItem
      buttonCell.createItem = createItem
      buttonCell.didSelectItem = didSelectItem
      if data != nil {buttonCell.data = data! }

      super.configureCell(cell)

    }
  }

}
