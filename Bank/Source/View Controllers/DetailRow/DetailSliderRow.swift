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

  - parameter cell: DetailCell
  */
  override func configureCell(cell: DetailCell) {
    super.configureCell(cell)
    if let sliderCell = cell as? DetailSliderCell {
      if minValue != nil    { sliderCell.minValue = minValue!       }
      if maxValue != nil    { sliderCell.maxValue = maxValue!       }
      if sliderStyle != nil { sliderCell.sliderStyle = sliderStyle! }
    }
  }

}
