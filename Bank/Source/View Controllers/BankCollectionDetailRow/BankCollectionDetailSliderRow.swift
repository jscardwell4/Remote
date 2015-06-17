//
//  BankCollectionDetailSliderRow.swift
//  Remote
//
//  Created by Jason Cardwell on 11/28/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

final class BankCollectionDetailSliderRow: BankCollectionDetailRow {

  var minValue: Float?
  var maxValue: Float?
  var sliderStyle: Slider.SliderStyle?
  override var identifier: BankCollectionDetailCell.Identifier { return .Slider }

  /**
  configure:

  - parameter cell: BankCollectionDetailCell
  */
  override func configureCell(cell: BankCollectionDetailCell) {
    super.configureCell(cell)
    if let sliderCell = cell as? BankCollectionDetailSliderCell {
      if minValue != nil    { sliderCell.minValue = minValue!       }
      if maxValue != nil    { sliderCell.maxValue = maxValue!       }
      if sliderStyle != nil { sliderCell.sliderStyle = sliderStyle! }
    }
  }

}
