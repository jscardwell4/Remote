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

final class DetailSliderRow: DetailRow {

  var minValue: Float?
  var maxValue: Float?
  var sliderStyle: Slider.SliderStyle?
  override var identifier: DetailCell.Identifier { return .Slider }

  /**
  configure:

  :param: cell DetailCell
  */
  override func configureCell(cell: DetailCell) {
    super.configureCell(cell)
    if minValue != nil           { (cell as? DetailSliderCell)?.minValue = minValue!                    }
    if maxValue != nil           { (cell as? DetailSliderCell)?.maxValue = maxValue!                    }
    if sliderStyle != nil { (cell as? DetailSliderCell)?.sliderStyle = sliderStyle!}
  }

  /** init */
  override init() { super.init() }

}
