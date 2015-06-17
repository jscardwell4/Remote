//
//  DetailColorRow.swift
//  Remote
//
//  Created by Jason Cardwell on 11/28/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

final class DetailColorRow: DetailRow {

  var placeholderColor: UIColor?

  override var identifier: DetailCell.Identifier { return .Color }

  /**
  configure:

  - parameter cell: DetailCell
  */
  override func configureCell(cell: DetailCell) {
    super.configureCell(cell)
    (cell as? DetailColorCell)?.placeholderColor = placeholderColor
  }

}
