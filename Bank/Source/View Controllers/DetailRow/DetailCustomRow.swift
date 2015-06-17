//
//  DetailCustomRow.swift
//  Remote
//
//  Created by Jason Cardwell on 12/16/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailCustomRow: DetailRow {

  override var identifier: DetailCell.Identifier { return .Custom }

  var generateCustomView: ((Void) -> UIView)?

  /**
  configure:

  - parameter cell: DetailCell
  */
  override func configureCell(cell: DetailCell) {
    super.configureCell(cell)
    (cell as? DetailCustomCell)?.generateCustomView = generateCustomView
  }

}
