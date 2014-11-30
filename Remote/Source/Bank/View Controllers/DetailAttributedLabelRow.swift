//
//  DetailAttributedLabelRow.swift
//  Remote
//
//  Created by Jason Cardwell on 11/28/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailAttributedLabelRow: DetailRow {

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
  initWithLabel:value:

  :param: label String
  :param: value String
  */
  convenience init(label: String, value: NSAttributedString?) {
    self.init()
    name = label
    info = value
  }

  /** init */
  convenience init() { self.init(identifier: .AttributedLabel) }

}
