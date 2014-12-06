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
  var shouldAllowReturnsInTextView: Bool?
  var shouldBeginEditing: ((UITextView) -> Bool)?
  var shouldEndEditing: ((UITextView) -> Bool)?
  var didBeginEditing: ((UITextView) -> Void)?
  var didEndEditing: ((UITextView) -> Void)?
  var shouldChangeText: ((UITextView, NSRange, String?) -> Bool)?

  /**
  configure:

  :param: cell DetailCell
  */
  override func configureCell(cell: DetailCell) {
    super.configureCell(cell)
    if shouldAllowReturnsInTextView != nil {
      (cell as? DetailTextViewCell)?.shouldAllowReturnsInTextView = shouldAllowReturnsInTextView!
    }
    if shouldBeginEditing != nil { (cell as? DetailTextViewCell)?.shouldBeginEditing = shouldBeginEditing! }
    if shouldEndEditing != nil   { (cell as? DetailTextViewCell)?.shouldEndEditing = shouldEndEditing!     }
    if didBeginEditing != nil    { (cell as? DetailTextViewCell)?.didBeginEditing = didBeginEditing!       }
    if didEndEditing != nil      { (cell as? DetailTextViewCell)?.didEndEditing = didEndEditing!           }
    if shouldChangeText != nil   { (cell as? DetailTextViewCell)?.shouldChangeText = shouldChangeText!     }
  }

  /** init */
  override init() { super.init() }

}
