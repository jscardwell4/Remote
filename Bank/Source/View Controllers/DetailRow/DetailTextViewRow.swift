//
//  DetailTextViewRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

final class DetailTextViewRow: DetailTextInputRow {

  override var identifier: DetailCell.Identifier { return .TextView }

  var displayStyle: DetailTextViewCell.DisplayStyle = .Default

  /**
  configure:

  :param: cell DetailCell
  */
  override func configureCell(cell: DetailCell) {
    super.configureCell(cell)
    (cell as? DetailTextViewCell)?.displayStyle = displayStyle
  }

}
