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

final class DetailStepperRow: DetailRow {

  var stepperWraps: Bool?
  var stepperMinValue: Double?
  var stepperMaxValue: Double?
  var stepperStepValue: Double?

  override var identifier: DetailCell.Identifier { return .Stepper }

  /**
  configure:

  :param: cell DetailCell
  */
  override func configureCell(cell: DetailCell) {
    super.configureCell(cell)
    if let stepperCell = cell as? DetailStepperCell {
      stepperCell.stepperWraps = stepperWraps
      stepperCell.stepperMinValue = stepperMinValue
      stepperCell.stepperMaxValue = stepperMaxValue
      stepperCell.stepperStepValue = stepperStepValue
    }
  }

}
