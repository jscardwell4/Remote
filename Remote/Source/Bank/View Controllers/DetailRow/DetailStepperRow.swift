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
    if stepperWraps != nil     { (cell as? DetailStepperCell)?.stepperWraps = stepperWraps!         }
    if stepperMinValue != nil  { (cell as? DetailStepperCell)?.stepperMinValue = stepperMinValue!   }
    if stepperMaxValue != nil  { (cell as? DetailStepperCell)?.stepperMaxValue = stepperMaxValue!   }
    if stepperStepValue != nil { (cell as? DetailStepperCell)?.stepperStepValue = stepperStepValue! }
  }

  /** init */
  override init() { super.init() }

}
