//
//  BankCollectionDetailImageRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

final class BankCollectionDetailImageRow: BankCollectionDetailRow {

  override var identifier: BankCollectionDetailCell.Identifier { return .Image }

  var imageTint: UIColor?

  /**
  configure:

  :param: cell BankCollectionDetailCell
  */
  override func configureCell(cell: BankCollectionDetailCell) {
    super.configureCell(cell)
    (cell as? BankCollectionDetailImageCell)?.imageTint = imageTint
  }

}
