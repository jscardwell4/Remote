//
//  BankCollectionFilteringDetailSectionHeader.swift
//  Remote
//
//  Created by Jason Cardwell on 6/02/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankCollectionFilteringDetailSectionHeader: BankCollectionDetailSectionHeader {

  private let checkBoxContainer = UIView(autolayout: true)

  override func initializeIVARs() { super.initializeIVARs(); addSubview(checkBoxContainer) }

  var activePredicatesDidChange: ((Void) -> Void)?

  var predicates: [BankCollectionFilteringDetailSection.Predicate]? {
    didSet {
      if predicates == nil { apply(checkBoxContainer.subviews){$0.removeFromSuperview()} }
      else {
        apply(predicates!) {
          predicate in

            let view = LabeledCheckbox(title: predicate.name, font: Bank.sectionHeaderSubFont, autolayout: true)
            view.titleColor = Bank.sectionHeaderSubColor
            view.checkboxColor = Bank.sectionHeaderSubColor
            view.checked = predicate.active
            view.addActionBlock({predicate.active = view.checked; _ = self.activePredicatesDidChange?()},
               forControlEvents: .TouchUpInside)
            self.checkBoxContainer.addSubview(view)
        }
        setNeedsUpdateConstraints()
      }
    }
  }

  override func updateConstraints() {
    removeAllConstraints()

    super.updateConstraints()

    let h = Bank.sectionHeaderFont.pointSize
    constrain([checkBoxContainer-|𝗛], 𝗩|--(≥h)--checkBoxContainer--(≥8)--|𝗩 -!> 999)

    if let checkboxes = checkBoxContainer.subviews as? [UIView] {

      apply(checkboxes) { self.checkBoxContainer.constrain(𝗩|-$0|𝗩) }
      if let firstCheckBox = checkboxes.first { checkBoxContainer.constrain(𝗛|-firstCheckBox) }
      if let lastCheckBox = checkboxes.last { checkBoxContainer.constrain(lastCheckBox-|𝗛) }
      if checkboxes.count > 1 { pairwiseApply(checkboxes) { self.checkBoxContainer.constrain($0--$1) } }

    }
  }

  /** prepareForReuse */
  override func prepareForReuse() { predicates = nil; super.prepareForReuse() }

}
