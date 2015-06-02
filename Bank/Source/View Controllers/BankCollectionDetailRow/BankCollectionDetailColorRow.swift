//
//  BankCollectionDetailColorRow.swift
//  Remote
//
//  Created by Jason Cardwell on 11/28/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

final class BankCollectionDetailColorRow: BankCollectionDetailRow {

  var placeholderColor: UIColor?

  override var identifier: BankCollectionDetailCell.Identifier { return .Color }

  /**
  configure:

  :param: cell BankCollectionDetailCell
  */
  override func configureCell(cell: BankCollectionDetailCell) {
    super.configureCell(cell)
    (cell as? BankCollectionDetailColorCell)?.placeholderColor = placeholderColor
  }

}
