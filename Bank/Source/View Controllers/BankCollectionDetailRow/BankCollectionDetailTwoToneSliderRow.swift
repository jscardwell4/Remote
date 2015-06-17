//
//  BankCollectionDetailTwoToneSliderRow.swift
//  Remote
//
//  Created by Jason Cardwell on 12/08/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

final class BankCollectionDetailTwoToneSliderRow: BankCollectionDetailRow {

  var generatedColorType: TwoToneSlider.GeneratedColorType?
  var lowerColor: ((TwoToneSlider) -> UIColor)?
  var upperColor: ((TwoToneSlider) -> UIColor)?

  override var identifier: BankCollectionDetailCell.Identifier { return .TwoToneSlider }

  /**
  configure:

  - parameter cell: BankCollectionDetailCell
  */
  override func configureCell(cell: BankCollectionDetailCell) {
    super.configureCell(cell)
    if let sliderCell = cell as? BankCollectionDetailTwoToneSliderCell {
      if lowerColor != nil         { sliderCell.lowerColor = lowerColor!                }
      if upperColor != nil         { sliderCell.upperColor = upperColor!                }
      if generatedColorType != nil { sliderCell.generatedColorType = generatedColorType!}
    }
  }

}
