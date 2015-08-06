//
//  BankCollectionDetailTextViewCell.swift
//  Remote
//
//  Created by Jason Cardwell on 10/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

final class BankCollectionDetailTextViewCell: BankCollectionDetailTextInputCell {

  enum DisplayStyle: String { case Default = "default", Condensed = "condensed" }

  private static let defaultIdentifier = MoonKit.Identifier(BankCollectionDetailTextViewCell.self, "Internal", "Default")
  private static let condensedIdentifier = MoonKit.Identifier(BankCollectionDetailTextViewCell.self, "Internal", "Condensed")

  override func initializeIVARs() {
    super.initializeIVARs()

    contentView.addSubview(nameLabel)

    let textView = UITextView(autolayout: true)
    textView.userInteractionEnabled = false
    textView.scrollEnabled = false
    textView.font = Bank.infoFont
    textView.textColor = Bank.infoColor
    textView.setContentHuggingPriority(750, forAxis: .Horizontal)
    textView.setContentHuggingPriority(750, forAxis: .Vertical)
    textView.setContentCompressionResistancePriority(750, forAxis: .Horizontal)
    textView.setContentCompressionResistancePriority(750, forAxis: .Vertical)
    textView.textContainer.widthTracksTextView = true
    textView.textContainer.heightTracksTextView = true
    textView.delegate = self
    contentView.addSubview(textView)

    textInput = textView
  }

  override func updateConstraints() {
    super.updateConstraints()
    guard let textView = textInput as? UITextView else { return }

    let condensedID = MoonKit.Identifier(self, "Condensed")
    let defaultID = MoonKit.Identifier(self, "Default")

    let condensedConstraints = constraintsWithIdentifier(condensedID)
    let defaultConstraints = constraintsWithIdentifier(defaultID)

    switch displayStyle {
      case .Condensed:
        if defaultConstraints.count > 0 { removeConstraints(defaultConstraints) }
        if condensedConstraints.count == 0 {
          constrain(
            𝗛|-nameLabel--textView-|𝗛 --> condensedID,
            [𝗩|--8--nameLabel] --> condensedID,
            𝗩|--8--textView--8--|𝗩 --> condensedID
          )
      }
      case .Default:
        if condensedConstraints.count > 0 { removeConstraints(condensedConstraints) }
        if defaultConstraints.count == 0 {
          constrain(
            𝗛|-nameLabel-|𝗛 --> defaultID,
            𝗛|-textView-|𝗛 --> defaultID,
            𝗩|--8--nameLabel--8--textView--8--|𝗩 --> defaultID
          )
        }
    }
  }

  /// Configuring how the label and text view are displayed
  var displayStyle: DisplayStyle = .Default { didSet { setNeedsUpdateConstraints() } }

}
