//
//  DetailImageRow.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailImageRow: DetailRow {

  override var identifier: DetailCell.Identifier { return .Image }

  /**
  configure:

  :param: cell DetailCell
  */
  override func configureCell(cell: DetailCell) { super.configureCell(cell) }

  /**
  initWithPreviewableItem:

  :param: previewableItem BankDisplayItemModel
  */
  convenience init(previewableItem: PreviewableItem?) { self.init(); info = previewableItem?.preview }

  /** init */
  override init() { super.init() }

}
