//
//  BankCollectionDetailCustomRow.swift
//  Remote
//
//  Created by Jason Cardwell on 12/16/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankCollectionDetailCustomRow: BankCollectionDetailRow {

  override var identifier: BankCollectionDetailCell.Identifier { return .Custom }

  var generateCustomView: ((Void) -> UIView)?

  /**
  configure:

  :param: cell BankCollectionDetailCell
  */
  override func configureCell(cell: BankCollectionDetailCell) {
    super.configureCell(cell)
    (cell as? BankCollectionDetailCustomCell)?.generateCustomView = generateCustomView
  }

}
