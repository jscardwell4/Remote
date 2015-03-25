//
//  DetailTwoToneSliderRow.swift
//  Remote
//
//  Created by Jason Cardwell on 12/08/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

final class DetailTwoToneSliderRow: DetailRow {

  var generatedColorType: TwoToneSlider.GeneratedColorType?
  var lowerColor: ((TwoToneSlider) -> UIColor)?
  var upperColor: ((TwoToneSlider) -> UIColor)?

  override var identifier: DetailCell.Identifier { return .TwoToneSlider }

  /**
  configure:

  :param: cell DetailCell
  */
  override func configureCell(cell: DetailCell) {
    super.configureCell(cell)
    if lowerColor != nil         { (cell as? DetailTwoToneSliderCell)?.lowerColor = lowerColor!                }
    if upperColor != nil         { (cell as? DetailTwoToneSliderCell)?.upperColor = upperColor!                }
    if generatedColorType != nil { (cell as? DetailTwoToneSliderCell)?.generatedColorType = generatedColorType!}
  }

  /** init */
  override init() { super.init() }

}
