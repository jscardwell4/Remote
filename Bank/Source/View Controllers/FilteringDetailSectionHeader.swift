//
//  FilteringDetailSectionHeader.swift
//  Remote
//
//  Created by Jason Cardwell on 12/12/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class FilteringDetailSectionHeader: DetailSectionHeader {

  private var checkBoxContainer = UIView(autolayout: true)

  /**
  init:

  :param: reuseIdentifier String?
  */
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    contentView.removeAllConstraints()
    contentView.addSubview(checkBoxContainer)
    contentView.constrain("[container]-| :: V:|-(>=\(DetailSectionHeader.headerFont.pointSize)@999)-[container]-(>=8@999)-|",
                    views: ["container": checkBoxContainer])
  }

  var activePredicatesDidChange: ((Void) -> Void)?

  var predicates: [FilteringDetailSection.Predicate]? {
    didSet {
      if predicates == nil { apply(checkBoxContainer.subviews){$0.removeFromSuperview()} }
      else {
        let font = UIFont(name: "Elysio-Medium", size: 12)!
        let color = UIColor(red: 0.937, green: 0.937, blue: 0.957, alpha: 1.000)
        let labeledCheckboxes: [LabeledCheckbox] = predicates!.map{
          predicate in
          let view = LabeledCheckbox(title: predicate.name, font: font, autolayout: true)
          view.titleColor = color
          view.checkboxColor = color
          view.checked = predicate.active
          view.addActionBlock({
            predicate.active = view.checked
            _ = self.activePredicatesDidChange?()
          }, forControlEvents: .TouchUpInside)
          return view
        }
        apply(labeledCheckboxes){self.checkBoxContainer.addSubview($0)}
        let views: OrderedDictionary<String, UIView> = OrderedDictionary(keys: (0..<labeledCheckboxes.count).map{"view\($0)"},
                                                                         values: labeledCheckboxes)
        let horizontalFormat = "|-" + "-8-".join(views.keys.map{"[\($0)]"}) + "-|"
        let verticalForamt = "::".join(views.keys.map{"V:|-[\($0)]|"})
        let format = "::".join(horizontalFormat, verticalForamt)
        checkBoxContainer.constrain(format, views: views.dictionary)
      }
    }
  }

  /**
  initWithFrame:

  :param: frame CGRect
  */
  override init(frame: CGRect) { super.init(frame: frame) }

  /**
  initWithCoder:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /** prepareForReuse */
  override func prepareForReuse() { predicates = nil; super.prepareForReuse() }

}
