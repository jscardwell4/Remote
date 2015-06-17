//
//  BankCollectionDetailTextViewRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

final class BankCollectionDetailTextViewRow: BankCollectionDetailTextInputRow {

  override var identifier: BankCollectionDetailCell.Identifier { return .TextView }

  var displayStyle: BankCollectionDetailTextViewCell.DisplayStyle = .Default

  /**
  configure:

  - parameter cell: BankCollectionDetailCell
  */
  override func configureCell(cell: BankCollectionDetailCell) {
    super.configureCell(cell)
    (cell as? BankCollectionDetailTextViewCell)?.displayStyle = displayStyle
  }

}
