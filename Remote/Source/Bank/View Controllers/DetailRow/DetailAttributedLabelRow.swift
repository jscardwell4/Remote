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

final class DetailAttributedLabelRow: DetailRow {

  override var identifier: DetailCell.Identifier { return .AttributedLabel }

  override var infoDataType: DetailCell.DataType { get { return .AttributedStringData } set {} }

  /**
  configure:

  :param: cell DetailCell
  */
  override func configureCell(cell: DetailCell) { super.configureCell(cell) }

  /** init */
  override init() { super.init() }

}
