//
//  DetailTextViewCell.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

final class DetailTextViewCell: DetailTextInputCell, UITextViewDelegate {

  enum DisplayStyle: String { case Default = "default", Condensed = "condensed" }

  private static let defaultIdentifier = createIdentifier(DetailTextViewCell.self, ["Internal", "Default"])
  private static let condensedIdentifier = createIdentifier(DetailTextViewCell.self, ["Internal", "Condensed"])

  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewCellStyle
  :param: reuseIdentifier String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    contentView.addSubview(nameLabel)

    let textView = UITextView(autolayout: true)
    textView.userInteractionEnabled = false
    textView.scrollEnabled = false
    textView.font = DetailController.infoFont
    textView.textColor = DetailController.infoColor
    textView.setContentHuggingPriority(750, forAxis: .Horizontal)
    textView.setContentHuggingPriority(750, forAxis: .Vertical)
    textView.setContentCompressionResistancePriority(750, forAxis: .Horizontal)
    textView.setContentCompressionResistancePriority(750, forAxis: .Vertical)
    textView.textContainer.widthTracksTextView = true
    textView.textContainer.heightTracksTextView = true
    textView.delegate = self
    contentView.addSubview(textView)

    contentView.constrain(identifier: self.dynamicType.defaultIdentifier,
              nameLabel.left => contentView.left + 20,
              nameLabel.right => contentView.right - 20,
              nameLabel.top => contentView.top + 8,
              textView.left => contentView.left + 20,
              textView.right => contentView.right - 20,
              textView.bottom => contentView.bottom - 8,
              nameLabel.bottom => textView.top - 8)

    textInput = textView
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  override func updateConstraints() {
    let defaultIdentifier = self.dynamicType.defaultIdentifier
    let condensedIdentifier = self.dynamicType.condensedIdentifier

    contentView.removeConstraintsWithIdentifier(defaultIdentifier)
    contentView.removeConstraintsWithIdentifier(condensedIdentifier)

    super.updateConstraints()

    if let textView = textInput as? UITextView {
      switch displayStyle {
      case .Condensed:
        contentView.constrain(identifier: condensedIdentifier,
          nameLabel.left => contentView.left + 20,
          nameLabel.top => contentView.top + 8,
          nameLabel.bottom => contentView.bottom - 8,
          nameLabel.right => textView.left - 20,
          textView.top => contentView.top + 8,
          textView.bottom => contentView.bottom - 8,
          textView.right => contentView.right - 20
        )
      case .Default:
        contentView.constrain(identifier: defaultIdentifier,
          nameLabel.left => contentView.left + 20,
          nameLabel.right => contentView.right - 20,
          nameLabel.top => contentView.top + 8,
          textView.left => contentView.left + 20,
          textView.right => contentView.right - 20,
          textView.bottom => contentView.bottom - 8,
          nameLabel.bottom => textView.top - 8)
      }
    }
  }

  /// Configuring how the label and text view are displayed
  var displayStyle: DisplayStyle = .Default { didSet { setNeedsUpdateConstraints() } }

  /**
  _textDidChange:

  :param: textInput UITextInput
  */
  internal override func _textDidChange(textInput: UITextInput) {
    super._textDidChange(textInput)
    if textInput !== self.textInput { return }

  }

}
