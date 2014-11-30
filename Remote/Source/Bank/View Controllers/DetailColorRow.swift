//
//  DetailColorRow.swift
//  Remote
//
//  Created by Jason Cardwell on 11/28/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailColorRow: DetailRow {

  /**
  configureCell:forTableView:

  :param: cell DetailCell
  :param: tableView UITableView
  */
  override func configureCell(cell: DetailCell, forTableView tableView: UITableView) {
    super.configureCell(cell, forTableView: tableView)
    cell.name = name
  }

  /**
  initWithLabel:color:

  :param: label String
  :param: color UIColor
  */
  convenience init(label: String, color: UIColor?) {
    self.init()
    name = label
    info = color
  }

  /** init */
  convenience init() { self.init(identifier: .Color) }

}
