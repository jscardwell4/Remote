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

  /**
  configureCell:forTableView:

  :param: cell DetailCell
  :param: tableView UITableView
  */
  override func configureCell(cell: DetailCell, forTableView tableView: UITableView) {
  	super.configureCell(cell, forTableView: tableView)
    cell.name = name
  	if let stepperCell = cell as? DetailStepperCell {
      stepperCell.stepperWraps = stepperWraps
      stepperCell.stepperMinValue = stepperMinValue
      stepperCell.stepperMaxValue = stepperMaxValue
      stepperCell.stepperStepValue = stepperStepValue
  	}
  }
  /** init */
  convenience init() { self.init(identifier: .Stepper) }

}
