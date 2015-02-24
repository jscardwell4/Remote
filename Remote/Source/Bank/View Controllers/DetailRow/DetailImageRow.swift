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

final class DetailImageRow: DetailRow {

  override var identifier: DetailCell.Identifier { return .Image }

  var imageTint: UIColor?

  /**
  configure:

  :param: cell DetailCell
  */
  override func configureCell(cell: DetailCell) {
    super.configureCell(cell)
    if imageTint != nil { (cell as? DetailImageCell)?.imageTint = imageTint }
  }

  /**
  initWithPreviewableItem:

  :param: previewableItem BankDisplayItemModel
  */
  convenience init(previewableItem: PreviewableItem?) { self.init(); info = previewableItem?.preview }

  /** init */
  override init() { super.init() }

}
