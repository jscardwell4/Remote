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

class DetailColorRow: DetailRow {

  var placeholderText: String?
  var placeholderColor: UIColor?

  override var identifier: DetailCell.Identifier { return .Color }

  /**
  configure:

  :param: cell DetailCell
  */
  override func configureCell(cell: DetailCell) {
    super.configureCell(cell)
    if placeholderText != nil { (cell as? DetailColorCell)?.placeholderText = placeholderText! }
    if placeholderColor != nil { (cell as? DetailColorCell)?.placeholderColor = placeholderColor! }
  }

  /** init */
  override init() { super.init() }

}
