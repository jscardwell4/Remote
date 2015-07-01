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

  private static let defaultIdentifier = createIdentifier(BankCollectionDetailTextViewCell.self, ["Internal", "Default"])
  private static let condensedIdentifier = createIdentifier(BankCollectionDetailTextViewCell.self, ["Internal", "Condensed"])

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
    removeAllConstraints()
    super.updateConstraints()

    if let textView = textInput as? UITextView {
      switch displayStyle {
        case .Condensed: constrain(𝗛|-nameLabel--textView-|𝗛, [𝗩|--8--nameLabel], 𝗩|--8--textView--8--|𝗩)
        case .Default:   constrain(𝗛|-nameLabel-|𝗛, 𝗛|-textView-|𝗛, 𝗩|--8--nameLabel--8--textView--8--|𝗩)
      }
    }
  }

  /// Configuring how the label and text view are displayed
  var displayStyle: DisplayStyle = .Default { didSet { setNeedsUpdateConstraints() } }

}
