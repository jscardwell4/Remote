//
//  DetailStepperRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailStepperRow: DetailRow {

  var stepperWraps: Bool = true
  var stepperMinValue: Double = Double(CGFloat.min)
  var stepperMaxValue: Double = Double(CGFloat.max)
  var stepperStepValue: Double = 1.0

  override var identifier: DetailCell.Identifier { return .Stepper }

  /**
  configure:

  :param: cell DetailCell
  */
  override func configureCell(cell: DetailCell) {
    super.configureCell(cell)
    (cell as? DetailStepperCell)?.stepperWraps = stepperWraps
    (cell as? DetailStepperCell)?.stepperMinValue = stepperMinValue
    (cell as? DetailStepperCell)?.stepperMaxValue = stepperMaxValue
    (cell as? DetailStepperCell)?.stepperStepValue = stepperStepValue
  }

  /** init */
  override init() { super.init() }

}
