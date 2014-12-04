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

  var placeholderImage: UIImage?

  override var identifier: DetailCell.Identifier { return .LabeledImage }

  /**
  configure:

  :param: cell DetailCell
  */
  override func configureCell(cell: DetailCell) {
    (cell as? DetailLabeledImageCell)?.placeholderImage = placeholderImage
    super.configureCell(cell)
  }

  /**
  initWithLabel:previewableItem:

  :param: label String
  :param: previewableItem PreviewableItem?
  */
  convenience init(label: String, previewableItem: PreviewableItem?) {
    self.init()
    name = label
    info = previewableItem?.preview
  }

  /** init */
  override init() { super.init() }

}
