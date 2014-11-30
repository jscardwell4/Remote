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

class DetailSliderRow: DetailRow {

  var sliderMinValue: Float = 0.0
  var sliderMaxValue: Float = 1.0


  /**
  configureCell:forTableView:

  :param: cell DetailCell
  :param: tableView UITableView
  */
  override func configureCell(cell: DetailCell, forTableView tableView: UITableView) {
    super.configureCell(cell, forTableView: tableView)
    cell.name = name
    if let sliderCell = cell as? DetailSliderCell {
      sliderCell.sliderMinValue = sliderMinValue
      sliderCell.sliderMaxValue = sliderMaxValue
    }
  }

  /** init */
  convenience init() { self.init(identifier: .Slider) }

}
