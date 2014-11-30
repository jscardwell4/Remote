//
//  DetailLabeledImageRow.swift
//  Remote
//
//  Created by Jason Cardwell on 11/28/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailLabeledImageRow: DetailRow {

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
  initWithPreviewableItem:

  :param: previewableItem BankDisplayItemModel
  */
  convenience init(label: String, previewableItem: PreviewableItem?) {
    self.init()
    name = label
    info = previewableItem?.preview
  }

  /** init */
  convenience init() { self.init(identifier: .LabeledImage) }


}
