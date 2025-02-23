//
//  BankCollectionCategoryCell.swift
//  Remote
//
//  Created by Jason Cardwell on 9/27/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//
import Foundation
import UIKit
import MoonKit
import DataModel

final class BankCollectionCategoryCell: BankCollectionCell {

  override class var cellIdentifier: String { return "CategoryCell" }

  var collection: ModelCollection? { didSet { label.text = collection?.name } }

  override var exportItem: JSONValueConvertible? { return collection as? JSONValueConvertible }

  private let label: UILabel = {
    let view = UILabel(autolayout: true)
    view.nametag = "label"
    view.font = Bank.infoFont
    view.backgroundColor = UIColor.clearColor()
    view.opaque = false
    return view
    }()

  /** updateConstraints */
  override func updateConstraints() {

    let identifierBase = createIdentifier(self, "Internal")
    let identifier = createIdentifierGenerator(identifierBase)

    removeConstraintsWithIdentifierPrefix(identifierBase)
    
    super.updateConstraints()

    constrain(
      indicator--20--label--8--chevron
        --> identifier(suffixes: "Spacing", "Horizontal"),
      [label.centerY => contentView.centerY
        --> identifier(suffixes: "Label", "Vertical"),
      indicator.centerY => contentView.centerY
        --> identifier(suffixes: "Indicator", "Vertical"),
      indicator.right => contentView.left + (indicatorImage == nil ? 0 : 40)
        --> identifier(suffixes: "Indicator", "Horizontal")]
    )

    indicatorConstraint = constraintWithIdentifier(identifier(suffixes: "Indicator", "Horizontal"))

  }

  /** initializeIVARs */
  private func initializeIVARs() { contentView.addSubview(label) }

  /**
  initWithFrame:

  :param: frame CGRect
  */
  override init(frame: CGRect) { super.init(frame: frame); initializeIVARs() }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder); initializeIVARs() }

}
