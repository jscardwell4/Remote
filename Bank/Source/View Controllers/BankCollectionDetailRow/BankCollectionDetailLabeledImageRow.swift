//
//  BankCollectionDetailLabeledImageRow.swift
//  Remote
//
//  Created by Jason Cardwell on 11/28/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

final class BankCollectionDetailLabeledImageRow: BankCollectionDetailRow {

  var placeholderImage: UIImage?

  override var identifier: BankCollectionDetailCell.Identifier { return .LabeledImage }

  /**
  configure:

  - parameter cell: BankCollectionDetailCell
  */
  override func configureCell(cell: BankCollectionDetailCell) {
    super.configureCell(cell)
    (cell as? BankCollectionDetailLabeledImageCell)?.placeholderImage = placeholderImage
  }

}
