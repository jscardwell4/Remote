//
//  BankCollectionDetailStepperRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

final class BankCollectionDetailStepperRow: BankCollectionDetailRow {

  var stepperWraps: Bool?
  var stepperMinValue: Double?
  var stepperMaxValue: Double?
  var stepperStepValue: Double?

  override var identifier: BankCollectionDetailCell.Identifier { return .Stepper }

  /**
  configure:

  :param: cell BankCollectionDetailCell
  */
  override func configureCell(cell: BankCollectionDetailCell) {
    super.configureCell(cell)
    if let stepperCell = cell as? BankCollectionDetailStepperCell {
      stepperCell.stepperWraps = stepperWraps
      stepperCell.stepperMinValue = stepperMinValue
      stepperCell.stepperMaxValue = stepperMaxValue
      stepperCell.stepperStepValue = stepperStepValue
    }
  }

}
