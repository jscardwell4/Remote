//
//  DetailSliderRow.swift
//  Remote
//
//  Created by Jason Cardwell on 11/28/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailSliderRow: DetailRow {

  var sliderMinValue: Float = 0.0
  var sliderMaxValue: Float = 1.0

  override var identifier: DetailCell.Identifier { return .Slider }

  /**
  configure:

  :param: cell DetailCell
  */
  override func configureCell(cell: DetailCell) {
    super.configureCell(cell)
    (cell as? DetailSliderCell)?.sliderMinValue = sliderMinValue
    (cell as? DetailSliderCell)?.sliderMaxValue = sliderMaxValue
  }

  /** init */
  override init() { super.init() }

}
